-- NexCarg — Cerrar el depósito de archivos
--
-- Problema que resuelve: hoy el depósito `uploads` es público. Cualquiera con
-- la dirección exacta de un archivo puede abrir el DNI de un transportista sin
-- tener sesión, sin ser usuario y sin dejar rastro. Las direcciones llevan un
-- sufijo aleatorio y ya no se pueden sacar desde la app, pero basta con que una
-- se filtre —un mensaje reenviado, una captura, un registro de servidor— para
-- que quede abierta para siempre.
--
-- Después de correr esto:
--   · Las selfies, fotos de carga y pruebas de entrega las ve cualquier persona
--     con sesión iniciada en NexCarg. Nadie más.
--   · Los documentos de identidad los ve únicamente su dueño y el
--     administrador. Ni siquiera el resto de usuarios registrados.
--
-- Correr en Supabase → SQL Editor, de arriba a abajo, en una sola pasada.
-- IMPORTANTE: la app ya tiene que estar desplegada con los enlaces firmados.


-- ---------------------------------------------------------------------------
-- Paso 1 — Ver qué hay hoy
-- ---------------------------------------------------------------------------
-- Sirve para revisar el "antes". Si aparece alguna política de SELECT dirigida
-- a `anon` o a `public`, hay que borrarla: dejaría la puerta abierta aunque el
-- depósito pase a privado.

select policyname, cmd, roles
from pg_policies
where schemaname = 'storage' and tablename = 'objects'
order by policyname;


-- ---------------------------------------------------------------------------
-- Paso 2 — Quién puede leer qué
-- ---------------------------------------------------------------------------

-- Contenido normal de la plataforma: selfies, fotos de carga, pruebas de
-- entrega. Se muestran entre usuarios (el avatar en el chat, las fotos de una
-- carga en el marketplace), así que las ve cualquiera con sesión iniciada.
drop policy if exists "uploads: leer contenido de la plataforma" on storage.objects;
create policy "uploads: leer contenido de la plataforma"
on storage.objects for select to authenticated
using (
  bucket_id = 'uploads'
  and (storage.foldername(name))[1] <> 'documentos'
);

-- Documentos de identidad: licencia, DNI, papeles de empresa, seguro.
-- Solo su dueño y el administrador. La comparación es contra las direcciones
-- guardadas en la propia fila de `usuarios`, así que un usuario registrado no
-- puede abrir el documento de otro ni teniendo la dirección exacta.
drop policy if exists "uploads: leer documentos propios o siendo admin" on storage.objects;
create policy "uploads: leer documentos propios o siendo admin"
on storage.objects for select to authenticated
using (
  bucket_id = 'uploads'
  and (storage.foldername(name))[1] = 'documentos'
  and exists (
    select 1
    from public.usuarios u
    where u.id = auth.uid()
      and (
        u.tipo::text = 'admin'
        or u.doc_url            like '%' || objects.name
        or u.doc_identidad_url  like '%' || objects.name
        or u.seguro_url         like '%' || objects.name
      )
  )
);


-- ---------------------------------------------------------------------------
-- Paso 3 — Cerrar el depósito
-- ---------------------------------------------------------------------------
-- Esto es lo que apaga el acceso sin sesión. Hasta acá, todo lo anterior no
-- cambia nada de lo que ya funcionaba.

update storage.buckets set public = false where id = 'uploads';


-- ---------------------------------------------------------------------------
-- Comprobación
-- ---------------------------------------------------------------------------
-- `public` debe quedar en false, y abajo deben salir las dos políticas nuevas.

select id, public from storage.buckets where id = 'uploads';

select policyname, cmd, roles
from pg_policies
where schemaname = 'storage' and tablename = 'objects'
order by policyname;
