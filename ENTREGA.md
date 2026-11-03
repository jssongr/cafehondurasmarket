# NexCarg — Entrega técnica

Para quien reciba este código y tenga que seguirlo o mantenerlo. Supone que
sabés programar, pero no que conocés este proyecto.

- **Qué hace la plataforma y qué funciones tiene** → `README.md`
- **Cómo se administra el día a día** (aprobar usuarios, confirmar pagos,
  configurar correos, límites de los planes gratuitos) → `OPERACION.md`
- **Qué se le dice al usuario final** → `docs/manual-cliente.md` y
  `docs/manual-transportista.md`

Este archivo es el mapa: dónde está cada cosa y qué hay que saber antes de
tocarla.

---

## Lo primero: no es un prototipo, está en producción

`nexcarg.com` está en línea y la base de datos es real. Cada push a `main`
redespliega la web y reconstruye el APK. No hay entorno de pruebas separado:
si vas a probar algo contra la base, hacelo dentro de una transacción
(`begin; … rollback;`) o creá un proyecto de Supabase aparte.

Al momento de esta entrega la plataforma todavía no tiene usuarios reales
—2 cuentas de prueba, 0 cargas publicadas—, así que hay margen para
equivocarse. Eso cambia el día que entre el primer transportista.

## Arrancar en local

Necesitás el SDK de Flutter (canal estable, 3.x).

```bash
flutter pub get
flutter run -d chrome     # vista previa en el navegador
flutter run               # dispositivo o emulador conectado
flutter analyze           # debe salir sin errores; quedan 7 avisos informativos
flutter build web --release
```

No hace falta configurar nada más: la URL y la clave publicable de Supabase
están en `lib/main.dart`. Esa clave es pública a propósito —viaja dentro de
cualquier APK— y lo que protege los datos son las políticas de la base, no el
secreto de la clave.

## Cómo está organizado el código

Todo el código de la app vive en `lib/`, en Dart. El proyecto arrancó como un
prototipo en Expo/React Native y se reescribió completo en Flutter; no queda
nada de aquello.

| Carpeta | Qué hay |
| --- | --- |
| `lib/main.dart` | Arranque, inicialización de Supabase y tema |
| `lib/state/app_state.dart` | **El centro de todo.** Un único `ChangeNotifier` con la sesión, los datos y todas las llamadas a Supabase |
| `lib/models/` | Los tipos del dominio: `Usuario`, `Carga`, `Factura`, estados |
| `lib/screens/` | Una carpeta por área: `auth`, `dashboard`, `marketplace`, `messages`, `tracking`, `facturacion`, `admin`, `landing`, `settings`, `modals` |
| `lib/navigation/` | Pestañas por rol (cliente, transportista, admin) y el navegador raíz |
| `lib/widgets/` | Piezas reutilizables. `panel.dart` y `app_button.dart` son la base del aspecto visual |
| `lib/theme/theme.dart` | Colores, sombras y espaciados. Tema claro y oscuro |
| `lib/services/` | Ubicación GPS y subida de archivos |
| `lib/utils/accion.dart` | Envoltorio para ejecutar una acción y mostrar el error en palabras entendibles |
| `lib/data/constants.dart` | Países, ciudades, tipos de carga, comisión, datos de depósito |
| `web/` | `index.html`, el arranque de Flutter y las páginas estáticas públicas |
| `docs/sql/` | Los scripts SQL que se aplicaron a producción, como registro |
| `herramientas/` | Scripts de Python que generan la imagen de portada y la marca |

Dependencias: `provider`, `supabase_flutter`, `geolocator`, `flutter_map`,
`image_picker`, `url_launcher`, `shared_preferences`, `intl`.

### Dos convenciones que conviene respetar

**El código está en español**, comentarios incluidos, y los comentarios
explican *por qué* algo está hecho así, no qué hace la línea. Varios de ellos
documentan decisiones que costaron caro; antes de "limpiar" uno, leelo.

**Nada de fallos silenciosos.** Toda acción que toca la base pasa por
`ejecutar()` de `lib/utils/accion.dart`, que muestra el resultado al usuario y
traduce el error. Si agregás una acción nueva, usala.

## La base de datos

Supabase (Postgres + Auth + Storage + Realtime). Tablas: `usuarios`, `cargas`,
`conversaciones`, `mensajes`, `facturas`, `historial`, `notificaciones`, y la
vista `usuarios_publicos`.

Tres cosas que no son evidentes y que rompen todo si se tocan sin entenderlas:

**1. Las operaciones de negocio no son `update` desde el cliente.** Asignar una
carga, firmar el contrato, iniciar viaje, confirmar la entrega, calificar y
confirmar el pago pasan por funciones `SECURITY DEFINER` en la base
(`asignar_carga`, `firmar_contrato`, `iniciar_viaje`,
`confirmar_entrega_con_prueba`, `calificar`, `confirmar_pago_recibido`, …).
Están así porque antes se podía, desde fuera de la app, asignarse una carga al
precio que uno quisiera, falsificar las dos firmas del contrato e inventar
calificaciones. Cada función verifica `auth.uid()` por su cuenta: una función
`SECURITY DEFINER` corre con los permisos de quien la creó, así que si no
comprueba quién llama, no comprueba nada. Ver
`docs/sql/cerrar-funciones-de-negocio.sql`.

El analizador de seguridad de Supabase marca estas funciones como aviso. Es
esperado: son llamables por usuarios con sesión a propósito, y cada una se
defiende sola.

**2. Los documentos de identidad están en un bucket privado.** Las fotos de
DNI, licencias y selfies no son legibles públicamente; se abren con enlaces
temporales que genera el administrador al verificar. Ver
`docs/sql/documentos-privados.sql`.

**3. Hay un trigger `proteger_campos_usuario`** que impide que alguien se
ponga `tipo = 'admin'` o `verificado = true` por su cuenta. Para cambiar esos
campos a mano hay que desactivarlo (`alter table … disable trigger user`),
hacer el cambio y volver a activarlo. El procedimiento está en `OPERACION.md`.

## Los correos

Salen de Postgres, no de un servidor aparte: un trabajo de `pg_cron` corre cada
minuto, llama a `enviar_correos_pendientes()`, y esa función manda las
notificaciones pendientes a la API de Brevo usando `pg_net`. La clave de API
vive en Supabase Vault, en el secreto `BREVO_API_KEY`.

Si el secreto está vacío la función devuelve 0 y no intenta nada, así que el
sistema puede quedar programado antes de tener la clave. Solo se mandan
notificaciones de tipo `oferta` y `sistema` —los mensajes de chat quedan fuera
a propósito, serían demasiados— y nada de más de dos días de antigüedad.

Para diagnosticar: `select * from cron.job_run_details order by end_time desc`
y la columna `email_error` de la tabla `notificaciones`.

## Infraestructura y accesos

| Servicio | Para qué | Quién tiene la cuenta |
| --- | --- | --- |
| **Supabase** | Base de datos, autenticación, archivos | Grupo Groantz |
| **Vercel** | Hosting de `nexcarg.com`, se despliega solo desde `main` | Grupo Groantz |
| **GitHub** | Código y construcción del APK (`.github/workflows/build-apk.yml`) | Grupo Groantz |
| **Brevo** | Envío de correos transaccionales | Grupo Groantz |

El técnico que reciba esto necesita acceso a los cuatro. Las claves **no están
en el repositorio** y no deben estarlo: la de Brevo vive en Supabase Vault, y
las de despliegue en los secretos de GitHub y Vercel.

## Lo que falta para lanzar

Ninguna de estas cuatro cosas es trabajo de programación; son datos y
configuraciones que solo puede poner el dueño de las cuentas.

1. **Clave de API de Brevo** en el secreto `BREVO_API_KEY` de Supabase Vault,
   con el remitente `soporte@nexcarg.com` verificado y el dominio
   `nexcarg.com` autenticado (DKIM/DMARC). Sin esto no sale ningún correo.
2. **Datos de la cuenta bancaria** en `datosDeposito`, en
   `lib/data/constants.dart`. Mientras esté vacío, la app le dice al cliente
   que escriba a soporte en lugar de inventar un número de cuenta.
3. **Número de WhatsApp de soporte** en `soporteWhatsapp`, mismo archivo. Con
   el valor vacío el botón no aparece.
4. **Leaked password protection** activado en Supabase → Authentication →
   Passwords.

Y un viaje de prueba completo con un transportista de confianza, de punta a
punta, antes de abrirlo al público.

## Lo que se decidió dejar para después

- **Pasarela de pago.** Está previsto PixelPay, pero todavía no hay cuenta. Por
  eso el depósito y la transferencia son manuales hoy. Cuando se integre, los
  puntos a tocar son `confirmar_pago_recibido` en la base y
  `lib/widgets/estado_pago_card.dart` en la app.
- **México.** Se quitó de la lista de países a propósito: su cabotaje está
  cerrado a transportistas extranjeros y el tramo mexicano exige permiso de la
  SICT, licencia federal, seguro mexicano y Carta Porte del SAT. Dejarlo
  permitía cotizar viajes que después nadie podía cumplir. El razonamiento
  está comentado arriba de `paises` en `lib/data/constants.dart`.
- **GPS en segundo plano.** Hoy la ubicación se reporta solo con la app
  abierta.
- **Porcentaje real de avance del viaje.** Requiere coordenadas de origen y
  destino; hoy solo se guardan nombres de ciudades. Antes había un porcentaje
  inventado por un trabajo periódico y se quitó: era un número que no
  significaba nada.
- **Publicación en Google Play y App Store.** El APK se construye y se publica
  como release de GitHub; las tiendas requieren cuentas de desarrollador
  propias y firmar cada build.
