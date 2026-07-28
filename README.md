# NexCarg

Plataforma tecnológica que conecta empresas que necesitan transportar mercancías con transportistas y empresas de transporte, en el corredor Panamá–Costa Rica–Nicaragua–Honduras–El Salvador–Guatemala–México. App nativa para **iPhone, Android y Web** construida con **Expo + React Native** (un solo código para las tres plataformas).

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

- [Expo](https://expo.dev) (SDK 57) + React Native — una sola base de código para iOS, Android y Web.
- React Navigation (bottom tabs por rol + stacks anidados + pantallas modales para detalle de carga, contrato y calificación).
- Estado de la app centralizado en `src/state/AppContext.tsx` (sin backend todavía — datos en memoria, listos para conectar a una API real).

## Cuentas de demostración

| Rol | Correo | Contraseña |
|---|---|---|
| Cliente (empresa) | cliente@demo.com | 1234 |
| Transportista | transportista@demo.com | 1234 |
| Administrador | admin@demo.com | 1234 |

## Desarrollo local

```bash
npm install
npm run web       # vista previa en el navegador
npm run ios       # requiere macOS + Xcode, o usa Expo Go en tu iPhone
npm run android   # requiere Android Studio, o usa Expo Go en tu Android
```

Para probar en tu propio teléfono sin instalar nada más: instala la app **Expo Go** (App Store / Play Store), ejecuta `npm start` y escanea el código QR.

### Publicar en las tiendas

Este repositorio construye la app completa, pero publicarla en App Store / Google Play requiere cuentas de desarrollador propias (Apple Developer Program y Google Play Console) y un build con [EAS Build](https://docs.expo.dev/build/introduction/).
