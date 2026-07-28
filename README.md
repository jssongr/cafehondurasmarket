# NexCarg

Plataforma tecnológica que conecta empresas que necesitan transportar mercancías con transportistas y empresas de transporte, en el corredor Panamá–Costa Rica–Nicaragua–Honduras–El Salvador–Guatemala–México. Digitaliza la contratación de transporte terrestre: las empresas publican cargas, los transportistas las aceptan o cotizan, el pago queda en garantía (escrow) dentro de la plataforma y se libera automáticamente al confirmarse la entrega.

## Funcionalidad (demo front-end)

- **Registro y verificación** de identidad con IA simulada (documento + selfie), para clientes (empresas) y transportistas (independientes, conductores de flota o empresas con flota).
- **Publicación de cargas** y **búsqueda/filtrado** de cargas disponibles para transportistas.
- **Negociación**: aceptar al precio publicado o enviar/recibir cotizaciones por chat interno.
- **Contrato digital**: se genera al asignar un viaje y ambas partes deben firmarlo antes de iniciar el trayecto.
- **Pago en garantía (escrow)**: el monto queda retenido y se libera al transportista, descontando la comisión de la plataforma, cuando se confirma la entrega.
- **Seguimiento GPS simulado** sobre el corredor Panamá–México, con progreso en vivo.
- **Calificaciones** mutuas entre cliente y transportista al finalizar cada viaje.
- **Facturación**: cada viaje completado genera una factura con el desglose de comisión.
- **Panel administrativo**: resumen de usuarios, viajes e ingresos por comisión, listado de usuarios y de todos los viajes de la plataforma.
- **Notificaciones** en tiempo real dentro de la app.

## Modelo de negocio

Comisión por cada viaje realizado dentro de la plataforma (configurable, `COMISION_PCT` en `src/App.jsx`). El MVP deja la base para incorporar después seguros, financiamiento, publicidad y suscripciones premium.

## Cuentas de demostración

| Rol | Correo | Contraseña |
|---|---|---|
| Cliente (empresa) | cliente@demo.com | 1234 |
| Transportista | transportista@demo.com | 1234 |
| Administrador | admin@demo.com | 1234 |

## Desarrollo local

```bash
npm install
npm run dev
```
