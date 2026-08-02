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

## Aprobar usuarios nuevos

Todo usuario que se registra queda en estado "Cuenta en verificación" y no puede
publicar ni aceptar cargas hasta que un administrador revise sus documentos.

Panel de administrador → Usuarios → revisar documento, DNI y selfie →
"Aprobar documentos".

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
