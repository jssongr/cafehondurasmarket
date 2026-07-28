# CargaConecta

Plataforma digital que conecta empresas y personas que necesitan transportar carga con transportistas de carga pesada, en el corredor Panamá–Costa Rica–Nicaragua–Honduras–El Salvador–Guatemala–México. Funciona como un "Uber" para el transporte de mercancías: el cliente publica una carga, los transportistas la aceptan o cotizan, el envío se sigue por GPS en tiempo real y el pago se libera al transportista al confirmarse la entrega.

## Funcionalidad (demo front-end)

- Registro y verificación de identidad con IA simulada (documento + selfie), para clientes y transportistas.
- Publicación de cargas (tipo de mercancía, peso, origen, destino, fecha, vehículo requerido, presupuesto).
- Mercado de cargas disponibles para transportistas: aceptar al precio publicado o enviar cotización.
- Mensajería con negociación de precio integrada.
- Seguimiento GPS simulado sobre el corredor Panamá–México, con liberación automática de pago al completar la entrega.
- Historial de viajes y perfil de usuario.

## Desarrollo local

```bash
npm install
npm run dev
```
