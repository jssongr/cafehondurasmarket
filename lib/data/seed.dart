import '../models/models.dart';
import 'constants.dart';

List<Usuario> buildSeedUsers() => [
      Usuario(
        id: 1, nombre: 'Importadora del Istmo', email: 'cliente@demo.com', password: '1234',
        tipo: TipoUsuario.cliente, subtipo: 'Empresa importadora', verificado: true,
        telefono: '+(507) 6123-4567',
      ),
      Usuario(
        id: 2, nombre: 'Carlos Rodríguez — Transportes CR', email: 'transportista@demo.com', password: '1234',
        tipo: TipoUsuario.transportista, subtipo: 'Empresa con flota de camiones', vehiculo: 'Cabezal + plataforma',
        capacidad: 28, placa: 'CR-4471', verificado: true, telefono: '+(506) 8877-2345',
      ),
      Usuario(
        id: 3, nombre: 'Administración NexCarg', email: 'admin@demo.com', password: '1234',
        tipo: TipoUsuario.admin, subtipo: 'Administrador de plataforma', verificado: true, telefono: '',
      ),
    ];

List<Carga> buildSeedCargas() => [
      Carga(
        id: 1, clienteId: 1, cliente: 'Importadora del Istmo', tipoCarga: "Contenedor 40'", peso: 22, unidadPeso: 'ton',
        paisOrigen: 'Guatemala', ciudadOrigen: 'Ciudad de Guatemala', paisDestino: 'Honduras', ciudadDestino: 'San Pedro Sula',
        fecha: '2026-08-02', vehiculoReq: 'Cabezal + plataforma', presupuesto: 1450,
        descripcion: 'Repuestos industriales paletizados, requiere manejo cuidadoso.',
        estado: EstadoCarga.publicada,
      ),
      Carga(
        id: 2, clienteId: 1, cliente: 'Importadora del Istmo', tipoCarga: 'Carga refrigerada', peso: 9, unidadPeso: 'ton',
        paisOrigen: 'Costa Rica', ciudadOrigen: 'San José', paisDestino: 'Panamá', ciudadDestino: 'Ciudad de Panamá',
        fecha: '2026-07-25', vehiculoReq: 'Cabezal + rampla refrigerada (Reefer)', presupuesto: 980,
        descripcion: 'Productos lácteos, requiere cadena de frío constante.',
        estado: EstadoCarga.enTransito, transportistaId: 2, transportistaNombre: 'Carlos Rodríguez — Transportes CR',
        precioAcordado: 980, progreso: 42,
        pago: Pago(estado: EstadoPago.retenido, monto: 980),
        contrato: Contrato(firmaCliente: true, firmaTransportista: true, fechaCliente: DateTime.parse('2026-07-23T15:00:00Z'), fechaTransportista: DateTime.parse('2026-07-23T15:05:00Z')),
        fechaAsignacion: DateTime.parse('2026-07-24T09:00:00Z'),
      ),
      Carga(
        id: 3, clienteId: 1, cliente: 'Importadora del Istmo', tipoCarga: 'Materiales de construcción', peso: 15, unidadPeso: 'ton',
        paisOrigen: 'Honduras', ciudadOrigen: 'Tegucigalpa', paisDestino: 'El Salvador', ciudadDestino: 'San Salvador',
        fecha: '2026-07-10', vehiculoReq: 'Volteo', presupuesto: 640,
        descripcion: 'Cemento y varilla, entrega puntual requerida.',
        estado: EstadoCarga.entregada, transportistaId: 2, transportistaNombre: 'Carlos Rodríguez — Transportes CR',
        precioAcordado: 640, progreso: 100,
        pago: Pago(estado: EstadoPago.liberado, monto: 640),
        contrato: Contrato(firmaCliente: true, firmaTransportista: true, fechaCliente: DateTime.parse('2026-07-08T09:10:00Z'), fechaTransportista: DateTime.parse('2026-07-08T09:15:00Z')),
        fechaAsignacion: DateTime.parse('2026-07-08T09:00:00Z'), fechaEntrega: DateTime.parse('2026-07-10T18:20:00Z'),
      ),
    ];

List<Conversacion> buildSeedConvos() => [
      Conversacion(id: 1, participantes: [1, 2], cargaId: 2, mensajes: [
        Mensaje.texto(id: 1, de: 2, texto: 'Buenos días, tengo disponibilidad para su carga refrigerada CR→Panamá.', ts: DateTime.parse('2026-07-23T14:00:00Z')),
        Mensaje.texto(id: 2, de: 1, texto: 'Perfecto, ¿puede recoger el 24 en San José?', ts: DateTime.parse('2026-07-23T14:05:00Z')),
        Mensaje.oferta(id: 3, de: 2, precio: 980, ts: DateTime.parse('2026-07-23T14:10:00Z'), estadoOferta: 'aceptada'),
      ]),
    ];

List<Notificacion> buildSeedNotifs() => [
      Notificacion(id: 1, usuarioId: 1, tipo: 'mensaje', titulo: 'Nuevo mensaje de Carlos Rodríguez', sub: 'Disponibilidad para su carga refrigerada', ts: DateTime.parse('2026-07-23T14:00:00Z'), leida: false),
      Notificacion(id: 2, usuarioId: 2, tipo: 'sistema', titulo: 'Carga asignada', sub: 'CR → Panamá, salida 24 de julio', ts: DateTime.parse('2026-07-23T14:12:00Z'), leida: true),
    ];

List<HistorialItem> buildSeedHist() => [
      HistorialItem(
        id: 1, cargaId: 3, clienteId: 1, cliente: 'Importadora del Istmo', transportistaId: 2,
        transportista: 'Carlos Rodríguez — Transportes CR', tipoCarga: 'Materiales de construcción',
        ruta: 'Tegucigalpa (Honduras) → San Salvador (El Salvador)', monto: 640, fecha: '2026-07-10', estado: 'completado',
        calTransportista: Calificacion(estrellas: 5, comentario: 'Excelente entrega, muy puntual y cuidadoso con la carga.'),
      ),
    ];

List<Factura> buildSeedFacturas() => [
      Factura(
        id: 1, numero: 'NX-0001', cargaId: 3, clienteId: 1, cliente: 'Importadora del Istmo', transportistaId: 2,
        transportista: 'Carlos Rodríguez — Transportes CR', tipoCarga: 'Materiales de construcción',
        ruta: 'Tegucigalpa (Honduras) → San Salvador (El Salvador)', monto: 640, comisionPct: comisionPct,
        comision: 51.2, montoTransportista: 588.8, fecha: '2026-07-10',
      ),
    ];
