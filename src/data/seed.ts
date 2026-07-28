import { Carga, Conversacion, Factura, HistorialItem, Notificacion, Usuario } from './types';
import { COMISION_PCT } from './constants';

export const SEED_USERS: Usuario[] = [
  {
    id: 1, nombre: 'Importadora del Istmo', email: 'cliente@demo.com', password: '1234',
    tipo: 'cliente', subtipo: 'Empresa importadora', verificado: true, selfie: null, doc: null,
    telefono: '+(507) 6123-4567',
  },
  {
    id: 2, nombre: 'Carlos Rodríguez — Transportes CR', email: 'transportista@demo.com', password: '1234',
    tipo: 'transportista', subtipo: 'Empresa con flota de camiones', vehiculo: 'Cabezal + plataforma',
    capacidad: 28, placa: 'CR-4471', verificado: true, selfie: null, doc: null, telefono: '+(506) 8877-2345',
  },
  {
    id: 3, nombre: 'Administración NexCarg', email: 'admin@demo.com', password: '1234',
    tipo: 'admin', subtipo: 'Administrador de plataforma', verificado: true, selfie: null, doc: null, telefono: '',
  },
];

export const SEED_CARGAS: Carga[] = [
  {
    id: 1, clienteId: 1, cliente: 'Importadora del Istmo', tipoCarga: "Contenedor 40'", peso: 22, unidadPeso: 'ton',
    paisOrigen: 'Guatemala', ciudadOrigen: 'Ciudad de Guatemala', paisDestino: 'Honduras', ciudadDestino: 'San Pedro Sula',
    fecha: '2026-08-02', vehiculoReq: 'Cabezal + plataforma', presupuesto: 1450,
    descripcion: 'Repuestos industriales paletizados, requiere manejo cuidadoso.',
    estado: 'publicada', transportistaId: null, transportistaNombre: null, precioAcordado: null, progreso: 0,
    pago: { estado: 'pendiente', monto: null }, contrato: null, fechaAsignacion: null, fechaEntrega: null,
  },
  {
    id: 2, clienteId: 1, cliente: 'Importadora del Istmo', tipoCarga: 'Carga refrigerada', peso: 9, unidadPeso: 'ton',
    paisOrigen: 'Costa Rica', ciudadOrigen: 'San José', paisDestino: 'Panamá', ciudadDestino: 'Ciudad de Panamá',
    fecha: '2026-07-25', vehiculoReq: 'Cabezal + rampla refrigerada (Reefer)', presupuesto: 980,
    descripcion: 'Productos lácteos, requiere cadena de frío constante.',
    estado: 'en_transito', transportistaId: 2, transportistaNombre: 'Carlos Rodríguez — Transportes CR', precioAcordado: 980,
    progreso: 42, pago: { estado: 'retenido', monto: 980 },
    contrato: { firmaCliente: true, firmaTransportista: true, fechaCliente: '2026-07-23T15:00:00Z', fechaTransportista: '2026-07-23T15:05:00Z' },
    fechaAsignacion: '2026-07-24T09:00:00Z', fechaEntrega: null,
  },
  {
    id: 3, clienteId: 1, cliente: 'Importadora del Istmo', tipoCarga: 'Materiales de construcción', peso: 15, unidadPeso: 'ton',
    paisOrigen: 'Honduras', ciudadOrigen: 'Tegucigalpa', paisDestino: 'El Salvador', ciudadDestino: 'San Salvador',
    fecha: '2026-07-10', vehiculoReq: 'Volteo', presupuesto: 640,
    descripcion: 'Cemento y varilla, entrega puntual requerida.',
    estado: 'entregada', transportistaId: 2, transportistaNombre: 'Carlos Rodríguez — Transportes CR', precioAcordado: 640,
    progreso: 100, pago: { estado: 'liberado', monto: 640 },
    contrato: { firmaCliente: true, firmaTransportista: true, fechaCliente: '2026-07-08T09:10:00Z', fechaTransportista: '2026-07-08T09:15:00Z' },
    fechaAsignacion: '2026-07-08T09:00:00Z', fechaEntrega: '2026-07-10T18:20:00Z',
  },
];

export const SEED_CONVOS: Conversacion[] = [
  {
    id: 1, participantes: [1, 2], cargaId: 2,
    mensajes: [
      { id: 1, de: 2, texto: 'Buenos días, tengo disponibilidad para su carga refrigerada CR→Panamá.', ts: '2026-07-23T14:00:00Z' },
      { id: 2, de: 1, texto: 'Perfecto, ¿puede recoger el 24 en San José?', ts: '2026-07-23T14:05:00Z' },
      { id: 3, de: 2, tipo: 'oferta', precio: 980, ts: '2026-07-23T14:10:00Z', estado: 'aceptada' },
    ],
  },
];

export const SEED_NOTIFS: Notificacion[] = [
  { id: 1, usuarioId: 1, tipo: 'mensaje', titulo: 'Nuevo mensaje de Carlos Rodríguez', sub: 'Disponibilidad para su carga refrigerada', ts: '2026-07-23T14:00:00Z', leida: false },
  { id: 2, usuarioId: 2, tipo: 'sistema', titulo: 'Carga asignada', sub: 'CR → Panamá, salida 24 de julio', ts: '2026-07-23T14:12:00Z', leida: true },
];

export const SEED_HIST: HistorialItem[] = [
  {
    id: 1, cargaId: 3, clienteId: 1, cliente: 'Importadora del Istmo', transportistaId: 2,
    transportista: 'Carlos Rodríguez — Transportes CR', tipoCarga: 'Materiales de construcción',
    ruta: 'Tegucigalpa (Honduras) → San Salvador (El Salvador)', monto: 640, fecha: '2026-07-10', estado: 'completado',
    calTransportista: { estrellas: 5, comentario: 'Excelente entrega, muy puntual y cuidadoso con la carga.' },
    calCliente: null,
  },
];

export const SEED_FACTURAS: Factura[] = [
  {
    id: 1, numero: 'NX-0001', cargaId: 3, clienteId: 1, cliente: 'Importadora del Istmo', transportistaId: 2,
    transportista: 'Carlos Rodríguez — Transportes CR', tipoCarga: 'Materiales de construcción',
    ruta: 'Tegucigalpa (Honduras) → San Salvador (El Salvador)', monto: 640, comisionPct: COMISION_PCT,
    comision: 51.2, montoTransportista: 588.8, fecha: '2026-07-10',
  },
];
