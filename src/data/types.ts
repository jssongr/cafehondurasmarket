export type TipoUsuario = 'cliente' | 'transportista' | 'admin';

export interface Usuario {
  id: number;
  nombre: string;
  email: string;
  password: string;
  tipo: TipoUsuario;
  subtipo: string;
  telefono: string;
  verificado: boolean;
  selfie: string | null;
  doc: string | null;
  vehiculo?: string;
  capacidad?: number | null;
  placa?: string;
}

export type EstadoCarga = 'publicada' | 'asignada' | 'en_transito' | 'entregada' | 'cancelada';

export interface Contrato {
  firmaCliente: boolean;
  firmaTransportista: boolean;
  fechaCliente: string | null;
  fechaTransportista: string | null;
}

export interface Pago {
  estado: 'pendiente' | 'retenido' | 'liberado';
  monto: number | null;
}

export interface Carga {
  id: number;
  clienteId: number;
  cliente: string;
  tipoCarga: string;
  peso: number;
  unidadPeso: 'ton' | 'kg';
  paisOrigen: string;
  ciudadOrigen: string;
  paisDestino: string;
  ciudadDestino: string;
  fecha: string;
  vehiculoReq: string;
  presupuesto: number | null;
  descripcion: string;
  estado: EstadoCarga;
  transportistaId: number | null;
  transportistaNombre: string | null;
  precioAcordado: number | null;
  progreso: number;
  pago: Pago;
  contrato: Contrato | null;
  fechaAsignacion: string | null;
  fechaEntrega: string | null;
}

export interface MensajeTexto {
  id: number;
  de: number;
  texto: string;
  ts: string;
  tipo?: undefined;
}

export interface MensajeOferta {
  id: number;
  de: number;
  tipo: 'oferta';
  precio: number;
  ts: string;
  estado: 'pendiente' | 'aceptada' | 'rechazada';
}

export type Mensaje = MensajeTexto | MensajeOferta;

export interface Conversacion {
  id: number;
  participantes: [number, number];
  cargaId: number;
  mensajes: Mensaje[];
}

export interface Notificacion {
  id: number;
  usuarioId: number;
  tipo: 'mensaje' | 'oferta' | 'sistema';
  titulo: string;
  sub: string;
  ts: string;
  leida: boolean;
}

export interface Calificacion {
  estrellas: number;
  comentario: string;
}

export interface HistorialItem {
  id: number;
  cargaId: number;
  clienteId: number;
  cliente: string;
  transportistaId: number;
  transportista: string;
  tipoCarga: string;
  ruta: string;
  monto: number;
  fecha: string;
  estado: string;
  calTransportista: Calificacion | null;
  calCliente: Calificacion | null;
}

export interface Factura {
  id: number;
  numero: string;
  cargaId: number;
  clienteId: number;
  cliente: string;
  transportistaId: number;
  transportista: string;
  tipoCarga: string;
  ruta: string;
  monto: number;
  comisionPct: number;
  comision: number;
  montoTransportista: number;
  fecha: string;
}
