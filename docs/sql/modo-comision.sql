-- Modo comisión: cobrar el 5% sin retener el dinero del viaje
-- ============================================================
--
-- Hasta ahora NexCarg solo sabía operar de una forma: el cliente deposita el
-- monto completo en la cuenta de NexCarg, NexCarg lo retiene, y lo libera al
-- transportista cuando la entrega queda probada. Esa es la promesa fuerte de
-- la plataforma, pero tiene dos costos para arrancar: obliga a tener listos
-- los datos bancarios antes del primer viaje, y pone a NexCarg a manejar
-- dinero ajeno desde el día uno, que es un problema distinto —y más serio—
-- que mover carga.
--
-- Este script agrega el otro modo: el cliente le paga directo al
-- transportista, y NexCarg factura su comisión aparte. Se gana lo mismo, no
-- se toca plata de terceros, y no hace falta resolver nada bancario para
-- empezar.
--
-- El modo se elige en la tabla `ajustes` y se puede cambiar en cualquier
-- momento sin recompilar la app. Cada viaje guarda, al asignarse, bajo qué
-- modo nació: así cambiar el ajuste no reescribe la historia ni confunde a un
-- viaje que ya está en camino.

begin;

-- 1. Dónde vive la configuración -------------------------------------------

create table if not exists public.ajustes (
  clave       text primary key,
  valor       text not null,
  descripcion text,
  actualizado timestamptz not null default now()
);

alter table public.ajustes enable row level security;

-- Cualquiera con sesión lo lee (la app necesita saber qué contarle al
-- usuario); solo un administrador lo cambia.
drop policy if exists ajustes_lectura on public.ajustes;
create policy ajustes_lectura on public.ajustes
  for select to authenticated using (true);

drop policy if exists ajustes_escritura on public.ajustes;
create policy ajustes_escritura on public.ajustes
  for all to authenticated using (public.es_admin()) with check (public.es_admin());

insert into public.ajustes (clave, valor, descripcion) values
  ('pago_modo', 'comision',
   'comision = el cliente le paga directo al transportista y NexCarg factura su 5% aparte. '
   'garantia = el cliente deposita en la cuenta de NexCarg y el dinero queda retenido hasta la entrega probada.')
on conflict (clave) do nothing;

-- 2. Cada viaje recuerda bajo qué modo nació -------------------------------

alter table public.cargas
  add column if not exists pago_modo text not null default 'garantia';

alter table public.cargas drop constraint if exists cargas_pago_modo_valido;
alter table public.cargas add constraint cargas_pago_modo_valido
  check (pago_modo in ('comision', 'garantia'));

-- 3. El modo vigente para los viajes nuevos --------------------------------

create or replace function public.modo_pago()
returns text
language sql
stable
security definer
set search_path to 'public'
as $$
  -- 'garantia' si no hay fila: ante la duda, el modo que retiene el dinero,
  -- que es el que protege al transportista.
  select coalesce((select valor from public.ajustes where clave = 'pago_modo'), 'garantia');
$$;

revoke all on function public.modo_pago() from public;
grant execute on function public.modo_pago() to authenticated;

-- 4. Asignar: sellar el modo y decir la verdad en el aviso -----------------

create or replace function public.asignar_carga(p_carga_id bigint, p_transportista_id uuid, p_monto numeric)
returns void
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  c record;
  v_nombre text;
  v_soy_transportista boolean;
  v_soy_cliente boolean;
  v_modo text;
begin
  if auth.uid() is null then
    raise exception 'Hay que iniciar sesion';
  end if;

  select * into c from public.cargas where id = p_carga_id for update;
  if c.id is null then
    raise exception 'La carga no existe';
  end if;
  if c.estado <> 'publicada' then
    raise exception 'Esa carga ya no esta disponible';
  end if;

  v_soy_transportista := (auth.uid() = p_transportista_id);
  v_soy_cliente := (auth.uid() = c.cliente_id);
  if not (v_soy_transportista or v_soy_cliente) then
    raise exception 'No autorizado';
  end if;

  if v_soy_transportista then
    if c.presupuesto is null then
      raise exception 'Esa carga esta abierta a cotizacion: hay que cotizarla, no aceptarla';
    end if;
    p_monto := c.presupuesto;
  else
    if not exists (
      select 1 from public.mensajes m
      join public.conversaciones cv on cv.id = m.conversacion_id
      where cv.carga_id = p_carga_id and m.de_id = p_transportista_id
        and m.es_oferta and m.precio = p_monto
    ) then
      raise exception 'No hay una cotizacion de ese transportista por ese monto';
    end if;
  end if;

  select nombre into v_nombre from public.usuarios
  where id = p_transportista_id and tipo = 'transportista'
    and verificado and estado_cuenta = 'aprobado';
  if v_nombre is null then
    raise exception 'El transportista no esta verificado';
  end if;

  -- El modo se sella acá y ya no cambia para este viaje.
  v_modo := public.modo_pago();

  update public.cargas set
    estado = 'asignada',
    transportista_id = p_transportista_id,
    transportista_nombre = v_nombre,
    precio_acordado = p_monto,
    pago_modo = v_modo,
    -- 'pendiente' en los dos modos: todavia nadie cobro nada.
    pago_estado = 'pendiente',
    pago_monto = p_monto,
    contrato_firma_cliente = false,
    contrato_firma_transportista = false,
    contrato_fecha_cliente = null,
    contrato_fecha_transportista = null,
    fecha_asignacion = now()
  where id = p_carga_id;

  if v_modo = 'comision' then
    insert into public.notificaciones (usuario_id, tipo, titulo, sub) values
      (c.cliente_id, 'sistema', 'Viaje aceptado',
       v_nombre || ' acepto transportar tu ' || c.tipo_carga ||
       '. Firma el contrato para que pueda salir. El pago lo arreglas directo con el transportista.'),
      (p_transportista_id, 'sistema', 'Viaje asignado',
       'Firma el contrato y coordina el pago con el cliente. NexCarg te factura su comision al entregar.');
  else
    insert into public.notificaciones (usuario_id, tipo, titulo, sub) values
      (c.cliente_id, 'sistema', 'Viaje aceptado',
       v_nombre || ' acepto transportar tu ' || c.tipo_carga || '. Deposita el monto para asegurar el viaje.'),
      (p_transportista_id, 'sistema', 'Viaje asignado',
       'Esperando que el cliente deposite el pago. Te avisamos cuando este asegurado.');
  end if;
end;
$function$;

-- 5. Iniciar viaje: el candado del depósito solo aplica en modo garantía ----

create or replace function public.iniciar_viaje(p_carga_id bigint)
returns void
language plpgsql
security definer
set search_path to 'public'
as $function$
declare c record;
begin
  select * into c from public.cargas where id = p_carga_id;
  if c.id is null then
    raise exception 'La carga no existe';
  end if;
  if c.transportista_id is distinct from auth.uid() then
    raise exception 'Solo el transportista asignado puede iniciar el viaje';
  end if;
  if c.estado <> 'asignada' then
    raise exception 'Este viaje no esta listo para salir';
  end if;
  if not (c.contrato_firma_cliente and c.contrato_firma_transportista) then
    raise exception 'Falta que las dos partes firmen el contrato';
  end if;
  -- En modo comision NexCarg no retiene nada, asi que no hay deposito que
  -- esperar: el contrato firmado por los dos es todo el requisito.
  if c.pago_modo = 'garantia' and c.pago_estado <> 'retenido' then
    raise exception 'El pago todavia no esta asegurado. No salgas hasta que NexCarg lo confirme.';
  end if;

  update public.cargas set estado = 'en_transito', progreso = 2 where id = p_carga_id;
end;
$function$;

-- 6. Confirmar depósito: no existe en modo comisión ------------------------

create or replace function public.confirmar_pago_recibido(p_carga_id bigint)
returns void
language plpgsql
security definer
set search_path to 'public'
as $function$
declare c record;
begin
  if not public.es_admin() then
    raise exception 'Solo un administrador puede confirmar un pago';
  end if;

  select * into c from public.cargas where id = p_carga_id for update;
  if c.id is null then
    raise exception 'La carga no existe';
  end if;
  if c.pago_modo = 'comision' then
    raise exception 'Este viaje es en modo comision: el cliente le paga directo al transportista, NexCarg no retiene nada';
  end if;
  if c.pago_estado <> 'pendiente' then
    raise exception 'Ese pago no esta pendiente de confirmacion';
  end if;

  update public.cargas set pago_estado = 'retenido' where id = p_carga_id;

  insert into public.notificaciones (usuario_id, tipo, titulo, sub) values
    (c.transportista_id, 'sistema', 'Pago asegurado',
     'NexCarg ya tiene retenido el pago de ' || c.tipo_carga || '. Podes salir con la carga.'),
    (c.cliente_id, 'sistema', 'Deposito confirmado',
     'Recibimos tu deposito. Queda retenido hasta que se pruebe la entrega.');
end;
$function$;

-- 7. Entrega: la factura es la misma, quien paga a quien no ----------------
--
-- Los numeros no cambian entre modos: el viaje vale lo mismo, la comision es
-- el 5% y al transportista le queda el resto. Lo unico distinto es por donde
-- pasa el dinero, y eso va en el aviso.

create or replace function public.registrar_entrega(p_carga_id bigint)
returns void
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  c record;
  v_ruta text;
  v_comision numeric;
  v_monto_transportista numeric;
  v_numero text;
begin
  select * into c from public.cargas where id = p_carga_id;
  if c.estado = 'entregada' then
    return; -- already processed
  end if;

  update public.cargas set
    progreso = 100,
    estado = 'entregada',
    pago_estado = 'liberado',
    fecha_entrega = now()
  where id = p_carga_id;

  v_ruta := c.ciudad_origen || ' (' || c.pais_origen || ') → ' || c.ciudad_destino || ' (' || c.pais_destino || ')';
  v_comision := round(c.precio_acordado * 5 / 100, 2);
  v_monto_transportista := round(c.precio_acordado - v_comision, 2);
  select 'NX-' || lpad((count(*) + 1)::text, 4, '0') into v_numero from public.facturas;

  insert into public.historial (carga_id, cliente_id, cliente, transportista_id, transportista, tipo_carga, ruta, monto, fecha, estado)
  values (c.id, c.cliente_id, c.cliente, c.transportista_id, c.transportista_nombre, c.tipo_carga, v_ruta, c.precio_acordado, to_char(now(), 'YYYY-MM-DD'), 'completado');

  insert into public.facturas (numero, carga_id, cliente_id, cliente, transportista_id, transportista, tipo_carga, ruta, monto, comision_pct, comision, monto_transportista, fecha)
  values (v_numero, c.id, c.cliente_id, c.cliente, c.transportista_id, c.transportista_nombre, c.tipo_carga, v_ruta, c.precio_acordado, 5, v_comision, v_monto_transportista, to_char(now(), 'YYYY-MM-DD'));

  if c.pago_modo = 'comision' then
    insert into public.notificaciones (usuario_id, tipo, titulo, sub) values
      (c.cliente_id, 'sistema', 'Carga entregada',
       c.tipo_carga || ' llego a ' || c.ciudad_destino || ' con prueba de entrega. Pagale al transportista lo acordado. Ya podes calificar el viaje.'),
      (c.transportista_id, 'sistema', 'Entrega confirmada',
       'Quedo probada la entrega de ' || c.tipo_carga || '. Cobrale al cliente los ' || c.precio_acordado ||
       '. La comision de NexCarg es ' || v_comision || ' y la ves en Facturacion.');
  else
    insert into public.notificaciones (usuario_id, tipo, titulo, sub) values
      (c.cliente_id, 'sistema', 'Carga entregada',
       c.tipo_carga || ' llegó a ' || c.ciudad_destino || '. Pago liberado al transportista. Ya puedes calificar el viaje.'),
      (c.transportista_id, 'sistema', 'Pago liberado',
       'Se liberó $' || v_monto_transportista || ' (neto de comisión) por la entrega de ' || c.tipo_carga || '.');
  end if;
end;
$function$;

commit;
