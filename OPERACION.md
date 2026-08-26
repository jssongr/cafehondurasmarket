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
alter table public.usuarios disable trigger user;

update public.usuarios
set tipo = 'admin', verificado = true, estado_cuenta = 'aprobado'
where lower(email) = lower('correo@ejemplo.com');

alter table public.usuarios enable trigger user;

select email, tipo::text as tipo, verificado, estado_cuenta from public.usuarios;
```

3. Cerrar sesión en la app y volver a entrar. Aparece el panel de administrador.

**Por qué se desactiva el disparador:** la tabla tiene una protección
(`proteger_campos_usuario`) que impide cambiar `tipo` y `verificado`, para que
nadie pueda ascenderse a administrador ni auto-verificarse editando su propia
fila. Bloquea el cambio venga de donde venga, incluso desde el editor de SQL. Sin
desactivarla, el UPDATE dice "Success" pero **no cambia esas dos columnas** — hay
que correr el bloque completo, porque la penúltima línea vuelve a activarla y la
consulta final confirma cómo quedó.

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

## Quién ve los datos de quién

La tabla `usuarios` es privada: cada persona solo lee su propia fila, y el
administrador las lee todas. Ahí viven el correo, el teléfono y los enlaces a los
documentos de identidad.

Lo que el marketplace y el chat necesitan mostrar de la contraparte —nombre,
foto, tipo, país, calificación— sale de la vista `usuarios_publicos`, que **no
incluye documentos ni datos de contacto**. Si algún día hay que mostrar un dato
nuevo de otro usuario, se agrega a esa vista; nunca se abre la tabla.

### Los archivos

El depósito de archivos (`uploads`) es **privado**. La dirección que se guarda
en la base de datos no abre nada por sí sola: cada vez que la app va a mostrar
una imagen le pide a Supabase un enlace firmado que vale una hora y va atado a
la sesión de quien lo pidió. Al cerrar sesión, esos enlaces se descartan.

Quién ve cada carpeta:

| Carpeta | Qué guarda | Quién puede verla |
| --- | --- | --- |
| `documentos/` | DNI, licencia, papeles de empresa, seguro | Solo su dueño y el administrador |
| `selfies/` | Foto de perfil | Cualquier usuario con sesión |
| `cargas/` | Fotos de la mercancía | Cualquier usuario con sesión |
| `entregas/` | Foto y firma de la entrega | Cualquier usuario con sesión |

Las selfies y las fotos de carga se muestran entre usuarios a propósito: son el
avatar en el chat y las fotos que acompañan una publicación en el marketplace.
Los documentos de identidad no: ni siquiera otro usuario registrado los puede
abrir teniendo la dirección exacta.

El SQL que deja esto así está en `docs/sql/documentos-privados.sql`. No hay que
volver a correrlo salvo que se rehaga el proyecto de Supabase desde cero.

**Si algún día se agrega una carpeta nueva** (por ejemplo `facturas/`), hay que
decidir a mano quién la puede leer y agregarla a la política correspondiente.
Por omisión, una carpeta nueva cae en "cualquier usuario con sesión".

## Por qué México no está en la lista de países

La plataforma cubre seis países: Panamá, Costa Rica, Nicaragua, Honduras, El
Salvador y Guatemala. México **se sacó a propósito**, no es un olvido.

México tiene el cabotaje cerrado a transportistas extranjeros: un camión
centroamericano no puede entregar dentro de territorio mexicano. El tramo
mexicano exige permiso de autotransporte federal de la SICT (que se otorga a
empresas constituidas en México), Licencia Federal de Conductor, seguro
mexicano y el complemento Carta Porte del SAT en cada viaje.

Mientras México estuvo en la lista, la app dejaba cotizar viajes de Panamá a
Ciudad de México que en la práctica nadie podía cumplir.

**Para atenderlo algún día** hacen falta tres cosas, y en este orden:

1. Transportistas mexicanos verificados en la plataforma, con su permiso de la
   SICT al día.
2. Modelar el **relevo en frontera**: el viaje se parte en dos tramos —uno
   centroamericano hasta Tecún Umán o El Carmen, y uno mexicano hacia
   adentro—, cada uno con su transportista, su contrato y la prueba de quién
   tenía la carga en cada momento.
3. Resolver el régimen de plataformas digitales del SAT: cobrar comisión a
   usuarios mexicanos probablemente obliga a registrarse ante el SAT y cobrar
   IVA. Eso es tema de contador, y va antes de tener el primer usuario
   mexicano, no después.

Nada de esto es consejo legal. Antes de invertir en la entrada a México hay que
confirmarlo con un abogado aduanero mexicano.

## Tema claro y oscuro

La app viene en los dos, y cada quien elige el suyo en **Más → Configuración**:
claro, oscuro o automático (sigue al teléfono o al navegador). La elección se
guarda en el aparato, no en la cuenta, así que la misma persona puede tener la
app oscura en el teléfono y clara en la computadora.

Para quien toque el código: los colores viven en `lib/theme/theme.dart` y hay
tres familias que no se pueden mezclar.

| Familia | Ejemplos | Regla |
| --- | --- | --- |
| Tinta y superficies | `navy`, `texto`, `white`, `gris100` | Se dan vuelta con el tema. `navy` es el color del **texto**, no un fondo |
| Relleno fuerte | `solido` | Fondo de lo seleccionado, siempre con contenido blanco encima |
| Marca | `marcaFondo`, `marcaFondo2` | Los fondos oscuros del encabezado y de la presentación. No cambian nunca |

El error fácil es usar `navy` como fondo de algo que lleva texto blanco: en tema
oscuro `navy` es casi blanco y el texto desaparece. Para eso está `solido`.

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
