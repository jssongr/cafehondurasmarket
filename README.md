# NexCarg

Plataforma tecnológica que conecta empresas que necesitan transportar mercancías con transportistas y empresas de transporte, en el corredor Panamá–Costa Rica–Nicaragua–Honduras–El Salvador–Guatemala–México. App nativa para **iPhone, Android y Web** construida con **Flutter** (un solo código para las tres plataformas).

Digitaliza la contratación de transporte terrestre: las empresas publican cargas, los transportistas las aceptan o cotizan, ambas partes firman un contrato digital, el pago queda en garantía (escrow) dentro de la plataforma y se libera automáticamente al confirmarse la entrega vía seguimiento GPS.

## Funcionalidad

- **Registro y verificación** de identidad con IA simulada (documento + selfie), para clientes (empresas) y transportistas (independientes, conductores de flota o empresas con flota).
- **Publicación de cargas** y mercado de cargas disponibles con filtros para transportistas.
- **Negociación**: aceptar al precio publicado o enviar/recibir cotizaciones por chat interno.
- **Contrato digital**: se genera al asignar un viaje; ambas partes deben firmarlo antes de que el transportista pueda iniciar el trayecto.
- **Pago en garantía (escrow)**: el monto se retiene y se libera al transportista, descontando la comisión de la plataforma, al confirmarse la entrega.
- **Seguimiento GPS simulado** sobre el corredor Panamá–México, con progreso en vivo.
- **Calificaciones** mutuas entre cliente y transportista al finalizar cada viaje.
- **Facturación** automática con desglose de comisión en cada viaje completado.
- **Panel administrativo**: resumen de usuarios, viajes e ingresos por comisión, listado de usuarios y de todos los viajes.
- **Notificaciones** en tiempo real dentro de la app.

## Stack técnico

- [Flutter](https://flutter.dev) (SDK estable 3.x) — una sola base de código para iOS, Android y Web.
- `provider` para estado centralizado (`lib/state/app_state.dart`) — sin backend todavía, datos en memoria, listo para conectar a una API real.
- Navegación con `Navigator` nativo de Flutter: barra inferior por rol (`lib/navigation/`) + pantallas modales para detalle de carga, contrato, calificación y chat.
- Tipografía local (Liberation Sans, empaquetada en `assets/fonts/`) para no depender de Google Fonts en tiempo de ejecución.

## Cuentas de demostración

| Rol | Correo | Contraseña |
|---|---|---|
| Cliente (empresa) | cliente@demo.com | 1234 |
| Transportista | transportista@demo.com | 1234 |
| Administrador | admin@demo.com | 1234 |

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
