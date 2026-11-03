# NexCarg

> ¿Recibís este código para mantenerlo? Empezá por **[`ENTREGA.md`](ENTREGA.md)**:
> el mapa del proyecto, lo que no es evidente y lo que falta.

Plataforma tecnológica que conecta empresas que necesitan transportar mercancías con transportistas y empresas de transporte, en el corredor Panamá–Costa Rica–Nicaragua–Honduras–El Salvador–Guatemala. App nativa para **iPhone, Android y Web** construida con **Flutter** (un solo código para las tres plataformas).

Digitaliza la contratación de transporte terrestre: las empresas publican cargas, los transportistas las aceptan o cotizan, ambas partes firman un contrato digital, el pago queda retenido en garantía y se libera al transportista cuando la entrega queda probada con foto y firma.

## Funcionalidad

- **Registro y verificación** de identidad (documento + selfie), para clientes (empresas) y transportistas (independientes, conductores de flota o empresas con flota). La revisión la hace un administrador a mano desde el panel; no hay verificación automática.
- **Publicación de cargas** y mercado de cargas disponibles con filtros para transportistas.
- **Negociación**: aceptar al precio publicado o enviar/recibir cotizaciones por chat interno.
- **Contrato digital**: se genera al asignar un viaje; ambas partes deben firmarlo antes de que el transportista pueda iniciar el trayecto.
- **Pago en garantía**: el cliente deposita antes de que salga el camión y el monto queda retenido hasta que la entrega esté probada, momento en que se libera al transportista descontando la comisión. Hoy el depósito y la transferencia se hacen por fuera y un administrador los confirma en la app — el estado que ve cada parte es real, el movimiento del dinero es manual. Ver `OPERACION.md`.
- **Seguimiento GPS real** del transportista mientras la app está abierta, mostrado en un mapa en vivo, con la hora del último reporte.
- **Calificaciones** mutuas entre cliente y transportista al finalizar cada viaje.
- **Facturación** automática con desglose de comisión en cada viaje completado.
- **Panel administrativo**: resumen de usuarios, viajes e ingresos por comisión, listado de usuarios y de todos los viajes.
- **Notificaciones** en tiempo real dentro de la app.

## Stack técnico

- [Flutter](https://flutter.dev) (SDK estable 3.x) — una sola base de código para iOS, Android y Web.
- `provider` para estado centralizado (`lib/state/app_state.dart`), respaldado por **Supabase** (Postgres + Auth + Storage + Realtime) como base de datos real y compartida.
- Navegación con `Navigator` nativo de Flutter: barra inferior por rol (`lib/navigation/`) + pantallas modales para detalle de carga, contrato, calificación y chat.
- Tipografía local (Liberation Sans, empaquetada en `assets/fonts/`) para no depender de Google Fonts en tiempo de ejecución.

## Desarrollo local

```bash
flutter pub get
flutter run -d chrome     # vista previa en el navegador
flutter run                # dispositivo/emulador conectado (iOS/Android)
```

Para compilar la versión web de producción:

```bash
flutter build web --release
```

### Publicar en las tiendas

Este repositorio construye la app completa, pero publicarla en App Store / Google Play requiere cuentas de desarrollador propias (Apple Developer Program y Google Play Console) y firmar el build de cada plataforma (`flutter build ipa` / `flutter build appbundle`).
