# NexCarg — Guía de operación

Notas prácticas para administrar la plataforma. No es el manual de usuario final:
esto es para quien opera NexCarg.

## Enlaces

| Qué | Dónde |
| --- | --- |
| App web | https://nexcarg.com |
| APK Android (siempre la última versión) | https://github.com/jssongr/cafehondurasmarket/releases/download/latest-apk/app-release.apk |
| Código | https://github.com/jssongr/cafehondurasmarket |
| Base de datos y usuarios | Supabase → jssongr's Project |
| Hosting web | Vercel → proyecto `nexcarg.` |

Cada vez que se sube código a la rama `main`, se reconstruye el APK y se
redespliega la web automáticamente. El enlace de descarga del APK nunca cambia.

## Cuentas de administrador

Un administrador puede ver todos los usuarios, aprobar sus documentos y ver el
resumen de ingresos por comisión. La pantalla de registro **no** permite crear
administradores a propósito: se asignan a mano en la base de datos.

Para convertir una cuenta existente en administrador:

1. Registrar la cuenta normalmente en la app (con cualquier tipo de usuario).
2. En Supabase → SQL Editor, correr:

```sql
update public.usuarios
set tipo = 'admin', verificado = true
where id = (select id from auth.users where email = 'correo@ejemplo.com');
```

3. Cerrar sesión en la app y volver a entrar. Aparece el panel de administrador.

Conviene tener la cuenta de administrador **separada** de la cuenta con la que se
prueba como cliente o transportista, para poder revisar ambas vistas.

## Revisar y moderar usuarios

Todo usuario que se registra queda **pendiente** y no puede publicar ni aceptar
cargas hasta que un administrador revise sus documentos.

Panel de administrador → **Usuarios**. Los pendientes aparecen primero. Hay
buscador (nombre, correo, teléfono, país) y filtros por estado y por tipo.

Al tocar un usuario se abre su ficha completa: todos los documentos que subió a
ancho completo, y tocando cualquiera se abre a pantalla completa con zoom para
poder leer un número de DNI. **Revisar los documentos antes de decidir** — el
botón de aprobar no comprueba nada por sí solo.

Estados posibles:

| Estado | Qué significa | Acciones disponibles |
| --- | --- | --- |
| Pendiente | Recién registrado, sin revisar | Aprobar · Rechazar |
| Aprobado | Puede operar normalmente | Suspender |
| Rechazado | Documentos no válidos | Aprobar de todas formas · Suspender |
| Suspendido | Bloqueado por el administrador | Reactivar |

Rechazar y suspender **exigen escribir un motivo**. Ese texto le llega al usuario
como notificación y le reemplaza el aviso del panel, así sabe qué corregir. Sin
eso, un usuario rechazado seguiría viendo "un administrador está revisando" y
esperaría indefinidamente.

Nadie puede suspenderse a sí mismo, y los administradores no aparecen en la
lista.

## Límites que hay que vigilar

### Almacenamiento de archivos — el primero que se va a llenar

Cada usuario sube entre 3 y 4 imágenes al registrarse (documento de empresa o
licencia, DNI, selfie, y opcionalmente el comprobante de seguro), unos 4-5 MB por
usuario.

El plan gratuito de Supabase da alrededor de **1 GB**, o sea unos **200 usuarios
registrados**. Al pasarse, las subidas empiezan a fallar y nadie más puede
completar su registro.

**Qué hacer:** revisar el consumo en Supabase → Project Settings → Usage. Antes de
llegar al límite, subir al plan Pro (unos $25 al mes), que amplía el espacio de
forma considerable. Conviene revisarlo cuando se pasen los 150 usuarios.

### Envío de correos

El servicio de correo que Supabase trae incluido es solo para pruebas: permite
apenas unos **2 correos por hora** y no se puede subir.

Hoy el registro no manda correos (la confirmación por correo está desactivada), así
que esto no frena a nadie al registrarse. Pero **recuperar contraseña sí manda
correo**, y con ese límite la función no sirve en la vida real.

**Qué hacer:** conectar un proveedor de correo propio en
Supabase → Project Settings → Authentication → SMTP Settings. Ver
"Configurar el envío de correos" más abajo.

## Configurar el envío de correos (Brevo)

Brevo permite verificar una sola dirección de correo sin necesidad de tener un
dominio propio, y su plan gratuito cubre 300 correos por día.

1. Crear cuenta en https://www.brevo.com
2. **Senders, Domains & Dedicated IPs → Senders → Add a sender**: agregar la
   dirección desde la que van a salir los correos. Brevo manda un correo de
   verificación a esa dirección; hay que confirmarlo.
3. **SMTP & API → SMTP**: ahí aparecen los datos de conexión. Anotar el *login*
   y la *master password* (la clave SMTP, no la contraseña de la cuenta Brevo).
4. En Supabase → **Project Settings → Authentication → SMTP Settings**, activar
   "Enable Custom SMTP" y llenar:

   | Campo | Valor |
   | --- | --- |
   | Host | `smtp-relay.brevo.com` |
   | Port | `587` |
   | Username | el login que da Brevo |
   | Password | la clave SMTP de Brevo |
   | Sender email | la dirección verificada en el paso 2 |
   | Sender name | `NexCarg` |

5. Guardar y probar con "¿Olvidaste tu contraseña?" en la app.

Valores de conexión (la clave NO se anota acá; vive solo en Supabase):

| Campo | Valor |
| --- | --- |
| Host | `smtp-relay.brevo.com` |
| Port | `587` |
| Username | `b428ce001@smtp-brevo.com` |
| Sender email | `soporte@nexcarg.com` |
| Sender name | `NexCarg` |

**Si un día los correos dejan de salir sin explicación**, lo primero a revisar es la
clave SMTP en Brevo: se revocan solas tras **90 días sin uso**, sin importar la
fecha de expiración elegida. Se genera una nueva y se actualiza en Supabase.

Las claves SMTP se muestran una sola vez al crearlas. Si se pierde, no se
recupera: hay que generar otra y borrar la anterior. Nunca se comparten por chat,
correo ni capturas de pantalla — quien tenga la clave puede enviar correos
haciéndose pasar por NexCarg.

Cuando se compre el dominio propio, conviene verificarlo en Brevo y cambiar el
*sender* a `soporte@nexcarg.com`, que se ve bastante más confiable que una
dirección personal.

### Plantillas de correo

Supabase trae las plantillas en inglés. La versión en español y con el diseño de
NexCarg está en `docs/correo/recuperar-contrasena.html`; se pega en
Supabase → Authentication → Emails → Reset Password → Message body.

### Comisión de la plataforma

Está fijada en **5%** y se descuenta automáticamente al confirmarse cada entrega.
Vive en dos lugares que deben coincidir siempre:

- `lib/data/constants.dart` → `comisionPct`
- La función `registrar_entrega()` en Supabase

## Configuración de autenticación

En Supabase → Authentication → Sign In / Providers:

- **Allow new users to sign up**: encendido. Apagarlo cierra el registro a todo el mundo.
- **Confirm email**: apagado. La identidad se verifica con documentos y aprobación
  de un administrador, no con un clic en un correo.
