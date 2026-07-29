enum TipoUsuario { cliente, transportista, admin }

TipoUsuario tipoUsuarioFromString(String s) {
  switch (s) {
    case 'cliente':
      return TipoUsuario.cliente;
    case 'transportista':
      return TipoUsuario.transportista;
    default:
      return TipoUsuario.admin;
  }
}

extension TipoUsuarioX on TipoUsuario {
  String get value {
    switch (this) {
      case TipoUsuario.cliente:
        return 'cliente';
      case TipoUsuario.transportista:
        return 'transportista';
      case TipoUsuario.admin:
        return 'admin';
    }
  }
}

class Usuario {
  final int id;
  String nombre;
  final String email;
  final String password;
  final TipoUsuario tipo;
  final String subtipo;
  String telefono;
  bool verificado;
  String? selfie;
  final String? doc;
  final String? vehiculo;
  final double? capacidad;
  final String? placa;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.password,
    required this.tipo,
    required this.subtipo,
    required this.telefono,
    required this.verificado,
    this.selfie,
    this.doc,
    this.vehiculo,
    this.capacidad,
    this.placa,
  });

  Usuario copyWith({String? nombre, String? telefono, String? selfie}) {
    return Usuario(
      id: id,
      nombre: nombre ?? this.nombre,
      email: email,
      password: password,
      tipo: tipo,
      subtipo: subtipo,
      telefono: telefono ?? this.telefono,
      verificado: verificado,
      selfie: selfie ?? this.selfie,
      doc: doc,
      vehiculo: vehiculo,
      capacidad: capacidad,
      placa: placa,
    );
  }
}

enum EstadoCarga { publicada, asignada, enTransito, entregada, cancelada }

extension EstadoCargaX on EstadoCarga {
  String get value {
    switch (this) {
      case EstadoCarga.publicada:
        return 'publicada';
      case EstadoCarga.asignada:
        return 'asignada';
      case EstadoCarga.enTransito:
        return 'en_transito';
      case EstadoCarga.entregada:
        return 'entregada';
      case EstadoCarga.cancelada:
        return 'cancelada';
    }
  }
}

class Contrato {
  bool firmaCliente;
  bool firmaTransportista;
  DateTime? fechaCliente;
  DateTime? fechaTransportista;

  Contrato({
    this.firmaCliente = false,
    this.firmaTransportista = false,
    this.fechaCliente,
    this.fechaTransportista,
  });

  bool get ambosFirmaron => firmaCliente && firmaTransportista;
}

enum EstadoPago { pendiente, retenido, liberado }

extension EstadoPagoX on EstadoPago {
  String get value {
    switch (this) {
      case EstadoPago.pendiente:
        return 'pendiente';
      case EstadoPago.retenido:
        return 'retenido';
      case EstadoPago.liberado:
        return 'liberado';
    }
  }
}

class Pago {
  EstadoPago estado;
  double? monto;
  Pago({required this.estado, this.monto});
}

class Carga {
  final int id;
  final int clienteId;
  final String cliente;
  String tipoCarga;
  double peso;
  String unidadPeso;
  String paisOrigen;
  String ciudadOrigen;
  String paisDestino;
  String ciudadDestino;
  String fecha;
  String vehiculoReq;
  double? presupuesto;
  String descripcion;
  EstadoCarga estado;
  int? transportistaId;
  String? transportistaNombre;
  double? precioAcordado;
  double progreso;
  Pago pago;
  Contrato? contrato;
  DateTime? fechaAsignacion;
  DateTime? fechaEntrega;

  Carga({
    required this.id,
    required this.clienteId,
    required this.cliente,
    required this.tipoCarga,
    required this.peso,
    required this.unidadPeso,
    required this.paisOrigen,
    required this.ciudadOrigen,
    required this.paisDestino,
    required this.ciudadDestino,
    required this.fecha,
    required this.vehiculoReq,
    this.presupuesto,
    this.descripcion = '',
    this.estado = EstadoCarga.publicada,
    this.transportistaId,
    this.transportistaNombre,
    this.precioAcordado,
    this.progreso = 0,
    Pago? pago,
    this.contrato,
    this.fechaAsignacion,
    this.fechaEntrega,
  }) : pago = pago ?? Pago(estado: EstadoPago.pendiente);
}

class Mensaje {
  final int id;
  final int de;
  final DateTime ts;
  final String? texto; // null when tipo == oferta
  final bool esOferta;
  final double? precio;
  String? estadoOferta; // pendiente | aceptada | rechazada

  Mensaje.texto({required this.id, required this.de, required this.texto, required this.ts})
      : esOferta = false,
        precio = null,
        estadoOferta = null;

  Mensaje.oferta({required this.id, required this.de, required this.precio, required this.ts, this.estadoOferta = 'pendiente'})
      : esOferta = true,
        texto = null;
}

class Conversacion {
  final int id;
  final List<int> participantes;
  final int cargaId;
  final List<Mensaje> mensajes;
  Conversacion({required this.id, required this.participantes, required this.cargaId, List<Mensaje>? mensajes})
      : mensajes = mensajes ?? [];
}

class Notificacion {
  final int id;
  final int usuarioId;
  final String tipo; // mensaje | oferta | sistema
  final String titulo;
  final String sub;
  final DateTime ts;
  bool leida;

  Notificacion({
    required this.id,
    required this.usuarioId,
    required this.tipo,
    required this.titulo,
    required this.sub,
    required this.ts,
    this.leida = false,
  });
}

class Calificacion {
  final int estrellas;
  final String comentario;
  Calificacion({required this.estrellas, required this.comentario});
}

class HistorialItem {
  final int id;
  final int cargaId;
  final int clienteId;
  final String cliente;
  final int transportistaId;
  final String transportista;
  final String tipoCarga;
  final String ruta;
  final double monto;
  final String fecha;
  final String estado;
  Calificacion? calTransportista;
  Calificacion? calCliente;

  HistorialItem({
    required this.id,
    required this.cargaId,
    required this.clienteId,
    required this.cliente,
    required this.transportistaId,
    required this.transportista,
    required this.tipoCarga,
    required this.ruta,
    required this.monto,
    required this.fecha,
    required this.estado,
    this.calTransportista,
    this.calCliente,
  });
}

class Factura {
  final int id;
  final String numero;
  final int cargaId;
  final int clienteId;
  final String cliente;
  final int transportistaId;
  final String transportista;
  final String tipoCarga;
  final String ruta;
  final double monto;
  final double comisionPct;
  final double comision;
  final double montoTransportista;
  final String fecha;

  Factura({
    required this.id,
    required this.numero,
    required this.cargaId,
    required this.clienteId,
    required this.cliente,
    required this.transportistaId,
    required this.transportista,
    required this.tipoCarga,
    required this.ruta,
    required this.monto,
    required this.comisionPct,
    required this.comision,
    required this.montoTransportista,
    required this.fecha,
  });
}
