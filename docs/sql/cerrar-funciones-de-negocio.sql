-- NexCarg — Cerrar las funciones de negocio
--
-- Las funciones que mueven el negocio están declaradas SECURITY DEFINER, o sea
-- que corren con permisos totales y se saltan las reglas de la tabla. Varias no
-- comprobaban NADA sobre quién las llamaba, y encima estaban abiertas al rol
-- `anon`: cualquiera con la dirección del proyecto, sin cuenta y sin sesión,
-- podía llamarlas desde una terminal.
--
-- Lo que se podía hacer antes de esto:
--
--   · `asignar_carga` — asignarse cualquier carga publicada, a cualquier
--     transportista, por el monto que uno escribiera. Un lempira, por ejemplo.
--   · `firmar_contrato` — firmar por las dos partes de cualquier contrato.
--   · `calificar` — escribir cualquier calificación sobre cualquier viaje, que
--     es la reputación sobre la que se decide contratar.
--   · `iniciar_viaje` — poner en tránsito cualquier carga.
--   · `abrir_o_crear_convo` — abrir conversaciones entre terceros.
--   · `responder_oferta` — aceptar cotizaciones ajenas.
--
-- Además `responder_oferta` llamaba a `asignar_carga` con cuatro argumentos y
-- la función solo acepta tres, así que **aceptar una cotización nunca funcionó**:
-- reventaba con "function does not exist". Es el camino principal del
-- marketplace y estaba roto desde el principio.
--
-- La regla que sigue todo lo de abajo: quién sos se deduce de `auth.uid()`,
-- nunca de un parámetro que manda el cliente. Un parámetro se puede falsificar.


-- ---------------------------------------------------------------------------
-- Tomar una carga publicada / aceptar una cotización
-- ---------------------------------------------------------------------------
create or replace function public.asignar_carga(
  p_carga_id bigint,
  p_transportista_id uuid,
  p_monto numeric
) returns void
language plpgsql security definer set search_path to 'public'
as $$
declare
  c record;
  v_nombre text;
  v_soy_transportista boolean;
  v_soy_cliente boolean;
begin
  if auth.uid() is null then
    raise exception 'Hay que iniciar sesión';
  end if;

  -- `for update` bloquea la fila: si dos transportistas aceptan la misma carga
  -- en el mismo segundo, el segundo se encuentra el estado ya cambiado en vez
  -- de pisar la asignación del primero.
  select * into c from public.cargas where id = p_carga_id for update;
  if c.id is null then
    raise exception 'La carga no existe';
  end if;
  if c.estado <> 'publicada' then
    raise exception 'Esa carga ya no está disponible';
  end if;

  v_soy_transportista := (auth.uid() = p_transportista_id);
  v_soy_cliente := (auth.uid() = c.cliente_id);

  if not (v_soy_transportista or v_soy_cliente) then
    raise exception 'No autorizado';
  end if;

  if v_soy_transportista then
    -- El transportista toma la carga al precio publicado. El monto que manda
    -- se ignora a propósito: si se respetara, podría asignarse cargas por un
    -- lempira.
    if c.presupuesto is null then
      raise exception 'Esa carga está abierta a cotización: hay que cotizarla, no aceptarla';
    end if;
    p_monto := c.presupuesto;
  else
    -- El cliente solo puede asignar a un transportista que haya cotizado ese
    -- monto exacto en una conversación de esta carga. Si no, podría asignarle
    -- el viaje a alguien por un precio que esa persona nunca aceptó.
    if not exists (
      select 1
      from public.mensajes m
      join public.conversaciones cv on cv.id = m.conversacion_id
      where cv.carga_id = p_carga_id
        and m.de_id = p_transportista_id
        and m.es_oferta
        and m.precio = p_monto
    ) then
      raise exception 'No hay una cotización de ese transportista por ese monto';
    end if;
  end if;

  select nombre into v_nombre
  from public.usuarios
  where id = p_transportista_id
    and tipo = 'transportista'
    and verificado
    and estado_cuenta = 'aprobado';
  if v_nombre is null then
    raise exception 'El transportista no está verificado';
  end if;

  update public.cargas set
    estado = 'asignada',
    transportista_id = p_transportista_id,
    transportista_nombre = v_nombre,
    precio_acordado = p_monto,
    pago_estado = 'retenido',
    pago_monto = p_monto,
    contrato_firma_cliente = false,
    contrato_firma_transportista = false,
    contrato_fecha_cliente = null,
    contrato_fecha_transportista = null,
    fecha_asignacion = now()
  where id = p_carga_id;

  insert into public.notificaciones (usuario_id, tipo, titulo, sub)
  values (c.cliente_id, 'sistema', 'Viaje aceptado',
          v_nombre || ' aceptó transportar tu ' || c.tipo_carga || '.');
end;
$$;


-- ---------------------------------------------------------------------------
-- Responder una cotización
-- ---------------------------------------------------------------------------
create or replace function public.responder_oferta(
  p_mensaje_id bigint,
  p_accion estado_oferta
) returns void
language plpgsql security definer set search_path to 'public'
as $$
declare
  m record;
  cv record;
  c record;
begin
  select * into m from public.mensajes where id = p_mensaje_id and es_oferta;
  if m.id is null then
    raise exception 'Esa cotización no existe';
  end if;

  select * into cv from public.conversaciones where id = m.conversacion_id;
  if auth.uid() is null or auth.uid() not in (cv.participante_a, cv.participante_b) then
    raise exception 'No autorizado';
  end if;
  if m.de_id = auth.uid() then
    raise exception 'No podés responder tu propia cotización';
  end if;
  if m.estado_oferta <> 'pendiente' then
    raise exception 'Esa cotización ya fue respondida';
  end if;

  update public.mensajes set estado_oferta = p_accion where id = p_mensaje_id;

  if p_accion = 'aceptada' then
    select * into c from public.cargas where id = cv.carga_id;
    if c.cliente_id <> auth.uid() then
      raise exception 'Solo el cliente de la carga puede aceptar una cotización';
    end if;

    -- Acá estaba el fallo que rompía el camino principal: se llamaba con
    -- cuatro argumentos y la función solo acepta tres.
    perform public.asignar_carga(cv.carga_id, m.de_id, m.precio);

    insert into public.notificaciones (usuario_id, tipo, titulo, sub)
    values (m.de_id, 'oferta', 'Cotización aceptada',
            'Tu cotización de ' || m.precio || ' fue aceptada');
  end if;
end;
$$;


-- ---------------------------------------------------------------------------
-- Firmar el contrato
-- ---------------------------------------------------------------------------
create or replace function public.firmar_contrato(
  p_carga_id bigint,
  p_actor_tipo text  -- se conserva por compatibilidad; ya no se usa
) returns void
language plpgsql security definer set search_path to 'public'
as $$
declare
  c record;
begin
  select * into c from public.cargas where id = p_carga_id;
  if c.id is null then
    raise exception 'La carga no existe';
  end if;

  -- Quién firma se deduce de quién llama. Antes venía en un parámetro, así que
  -- cualquiera podía firmar por las dos partes de cualquier contrato.
  if auth.uid() = c.cliente_id then
    update public.cargas
    set contrato_firma_cliente = true, contrato_fecha_cliente = now()
    where id = p_carga_id;
  elsif auth.uid() = c.transportista_id then
    update public.cargas
    set contrato_firma_transportista = true, contrato_fecha_transportista = now()
    where id = p_carga_id;
  else
    raise exception 'No autorizado para firmar este contrato';
  end if;
end;
$$;


-- ---------------------------------------------------------------------------
-- Iniciar el viaje
-- ---------------------------------------------------------------------------
create or replace function public.iniciar_viaje(p_carga_id bigint)
returns void
language plpgsql security definer set search_path to 'public'
as $$
declare
  c record;
begin
  select * into c from public.cargas where id = p_carga_id;
  if c.id is null then
    raise exception 'La carga no existe';
  end if;
  if c.transportista_id is distinct from auth.uid() then
    raise exception 'Solo el transportista asignado puede iniciar el viaje';
  end if;
  if c.estado <> 'asignada' then
    raise exception 'Este viaje no está listo para salir';
  end if;
  -- La app ya lo exige en pantalla; acá se exige de verdad.
  if not (c.contrato_firma_cliente and c.contrato_firma_transportista) then
    raise exception 'Falta que las dos partes firmen el contrato';
  end if;

  update public.cargas set estado = 'en_transito', progreso = 2 where id = p_carga_id;
end;
$$;


-- ---------------------------------------------------------------------------
-- Calificar
-- ---------------------------------------------------------------------------
create or replace function public.calificar(
  p_historial_id bigint,
  p_actor_tipo text,  -- se conserva por compatibilidad; ya no se usa
  p_estrellas integer,
  p_comentario text
) returns void
language plpgsql security definer set search_path to 'public'
as $$
declare
  h record;
begin
  if p_estrellas is null or p_estrellas < 1 or p_estrellas > 5 then
    raise exception 'La calificación va de 1 a 5';
  end if;

  select * into h from public.historial where id = p_historial_id;
  if h.id is null then
    raise exception 'Ese viaje no existe';
  end if;

  -- Quién califica a quién sale de quién llama. La calificación es lo que la
  -- gente mira para decidir con quién trabajar: si se puede escribir a mano,
  -- no vale nada.
  if auth.uid() = h.cliente_id then
    update public.historial
    set cal_transportista_estrellas = p_estrellas, cal_transportista_comentario = p_comentario
    where id = p_historial_id;
  elsif auth.uid() = h.transportista_id then
    update public.historial
    set cal_cliente_estrellas = p_estrellas, cal_cliente_comentario = p_comentario
    where id = p_historial_id;
  else
    raise exception 'Solo quien hizo el viaje puede calificarlo';
  end if;
end;
$$;


-- ---------------------------------------------------------------------------
-- Conversaciones
-- ---------------------------------------------------------------------------
create or replace function public.abrir_o_crear_convo(
  p_carga_id bigint,
  p_yo_id uuid,  -- se conserva por compatibilidad; se ignora
  p_otro_id uuid
) returns bigint
language plpgsql security definer set search_path to 'public'
as $$
declare
  v_id bigint;
  v_yo uuid := auth.uid();
  c record;
begin
  if v_yo is null then
    raise exception 'Hay que iniciar sesión';
  end if;
  if v_yo = p_otro_id then
    raise exception 'No podés abrir una conversación con vos mismo';
  end if;

  select * into c from public.cargas where id = p_carga_id;
  if c.id is null then
    raise exception 'La carga no existe';
  end if;

  -- Una conversación es siempre entre el cliente de la carga y un
  -- transportista. Antes el "yo" venía por parámetro y se podían abrir
  -- conversaciones entre dos terceros cualesquiera.
  if v_yo <> c.cliente_id and p_otro_id <> c.cliente_id then
    raise exception 'No autorizado';
  end if;

  select id into v_id from public.conversaciones
  where carga_id = p_carga_id
    and ((participante_a = v_yo and participante_b = p_otro_id)
      or (participante_a = p_otro_id and participante_b = v_yo))
  limit 1;

  if v_id is null then
    insert into public.conversaciones (carga_id, participante_a, participante_b)
    values (p_carga_id, v_yo, p_otro_id)
    returning id into v_id;
  end if;
  return v_id;
end;
$$;


create or replace function public.enviar_mensaje(p_convo_id bigint, p_texto text)
returns void
language plpgsql security definer set search_path to 'public'
as $$
declare
  cv record;
  v_dest uuid;
  v_de_nombre text;
begin
  if coalesce(btrim(p_texto), '') = '' then
    raise exception 'El mensaje está vacío';
  end if;

  select * into cv from public.conversaciones where id = p_convo_id;
  if cv.id is null or auth.uid() is null
     or auth.uid() not in (cv.participante_a, cv.participante_b) then
    -- Sin esto, cualquiera con sesión podía escribir en la conversación de
    -- otros probando números de conversación.
    raise exception 'No autorizado';
  end if;

  insert into public.mensajes (conversacion_id, de_id, texto)
  values (p_convo_id, auth.uid(), p_texto);

  v_dest := case when cv.participante_a = auth.uid() then cv.participante_b else cv.participante_a end;
  select nombre into v_de_nombre from public.usuarios where id = auth.uid();

  insert into public.notificaciones (usuario_id, tipo, titulo, sub)
  values (v_dest, 'mensaje', 'Nuevo mensaje de ' || v_de_nombre, left(p_texto, 60));
end;
$$;


create or replace function public.enviar_oferta(p_convo_id bigint, p_precio numeric)
returns void
language plpgsql security definer set search_path to 'public'
as $$
declare
  cv record;
  v_dest uuid;
  v_de_nombre text;
begin
  if p_precio is null or p_precio <= 0 then
    raise exception 'El monto de la cotización tiene que ser mayor que cero';
  end if;

  select * into cv from public.conversaciones where id = p_convo_id;
  if cv.id is null or auth.uid() is null
     or auth.uid() not in (cv.participante_a, cv.participante_b) then
    raise exception 'No autorizado';
  end if;

  insert into public.mensajes (conversacion_id, de_id, es_oferta, precio, estado_oferta)
  values (p_convo_id, auth.uid(), true, p_precio, 'pendiente');

  v_dest := case when cv.participante_a = auth.uid() then cv.participante_b else cv.participante_a end;
  select nombre into v_de_nombre from public.usuarios where id = auth.uid();

  insert into public.notificaciones (usuario_id, tipo, titulo, sub)
  values (v_dest, 'oferta', 'Nueva cotización de ' || v_de_nombre,
          p_precio || ' por el viaje');
end;
$$;


-- ---------------------------------------------------------------------------
-- Permisos
-- ---------------------------------------------------------------------------
-- `revoke ... from anon` no alcanza: mientras PUBLIC conserve el permiso, anon
-- lo hereda igual. Hay que quitárselo a PUBLIC.

do $$
declare f text;
begin
  foreach f in array array[
    'public.abrir_o_crear_convo(bigint, uuid, uuid)',
    'public.actualizar_ubicacion(bigint, double precision, double precision)',
    'public.aprobar_usuario(uuid)',
    'public.asignar_carga(bigint, uuid, numeric)',
    'public.calificar(bigint, text, integer, text)',
    'public.confirmar_entrega_con_prueba(bigint, text, text, text)',
    'public.enviar_mensaje(bigint, text)',
    'public.enviar_oferta(bigint, numeric)',
    'public.es_admin()',
    'public.firmar_contrato(bigint, text)',
    'public.iniciar_viaje(bigint)',
    'public.reactivar_usuario(uuid)',
    'public.rechazar_usuario(uuid, text)',
    'public.responder_oferta(bigint, estado_oferta)',
    'public.suspender_usuario(uuid, text)'
  ] loop
    execute format('revoke all on function %s from public, anon', f);
    execute format('grant execute on function %s to authenticated', f);
  end loop;
end $$;


-- ---------------------------------------------------------------------------
-- Comprobación
-- ---------------------------------------------------------------------------
-- Ninguna fila debe salir con `anon` en la columna de permisos.

select p.proname,
       pg_get_function_identity_arguments(p.oid) as args,
       array_to_string(p.proacl::text[], ' | ') as permisos
from pg_proc p join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public'
order by p.proname;
