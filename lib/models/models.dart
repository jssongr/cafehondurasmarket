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
  final String id; // uuid, matches auth.users.id
  String nombre;
  final String email;
  final TipoUsuario tipo;
  final String subtipo;
  String telefono;
  bool verificado;
  String? selfie;
  final String? doc;
  final String? vehiculo;
  final double? capacidad;
  final String? placa;
  final DateTime fechaRegistro;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.tipo,
    required this.subtipo,
    required this.telefono,
    required this.verificado,
    this.selfie,
    this.doc,
    this.vehiculo,
    this.capacidad,
    this.placa,
    DateTime? fechaRegistro,
  }) : fechaRegistro = fechaRegistro ?? DateTime.now();

  factory Usuario.fromMap(Map<String, dynamic> m) => Usuario(
        id: m['id'] as String,
        nombre: m['nombre'] as String,
        email: m['email'] as String,
        tipo: tipoUsuarioFromString(m['tipo'] as String),
        subtipo: m['subtipo'] as String? ?? '',
        telefono: m['telefono'] as String? ?? '',
        verificado: m['verificado'] as bool? ?? false,
        selfie: m['selfie_url'] as String?,
        doc: m['doc_url'] as String?,
        vehiculo: m['vehiculo'] as String?,
        capacidad: (m['capacidad'] as num?)?.toDouble(),
        placa: m['placa'] as String?,
        fechaRegistro: DateTime.parse(m['fecha_registro'] as String),
      );
}

enum EstadoCarga { publicada, asignada, enTransito, entregada, cancelada }

EstadoCarga estadoCargaFromString(String s) => EstadoCarga.values.firstWhere((e) => e.value == s);

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

EstadoPago estadoPagoFromString(String s) => EstadoPago.values.firstWhere((e) => e.value == s);

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
  final String clienteId;
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
  String? transportistaId;
  String? transportistaNombre;
  double? precioAcordado;
  double progreso;
  Pago pago;
  Contrato? contrato;
  DateTime? fechaAsignacion;
  DateTime? fechaEntrega;
  double? volumen;
  String? dimensiones;
  bool peligrosa;
  List<String> fotos;
  List<String> documentos;

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
    this.volumen,
    this.dimensiones,
    this.peligrosa = false,
    List<String>? fotos,
    List<String>? documentos,
  })  : pago = pago ?? Pago(estado: EstadoPago.pendiente),
        fotos = fotos ?? [],
        documentos = documentos ?? [];

  factory Carga.fromMap(Map<String, dynamic> m) {
    final tieneContrato = m['fecha_asignacion'] != null;
    return Carga(
      id: m['id'] as int,
      clienteId: m['cliente_id'] as String,
      cliente: m['cliente'] as String,
      tipoCarga: m['tipo_carga'] as String,
      peso: (m['peso'] as num).toDouble(),
      unidadPeso: m['unidad_peso'] as String? ?? 'ton',
      paisOrigen: m['pais_origen'] as String,
      ciudadOrigen: m['ciudad_origen'] as String,
      paisDestino: m['pais_destino'] as String,
      ciudadDestino: m['ciudad_destino'] as String,
      fecha: m['fecha'] as String,
      vehiculoReq: m['vehiculo_req'] as String,
      presupuesto: (m['presupuesto'] as num?)?.toDouble(),
      descripcion: m['descripcion'] as String? ?? '',
      estado: estadoCargaFromString(m['estado'] as String),
      transportistaId: m['transportista_id'] as String?,
      transportistaNombre: m['transportista_nombre'] as String?,
      precioAcordado: (m['precio_acordado'] as num?)?.toDouble(),
      progreso: (m['progreso'] as num?)?.toDouble() ?? 0,
      pago: Pago(estado: estadoPagoFromString(m['pago_estado'] as String? ?? 'pendiente'), monto: (m['pago_monto'] as num?)?.toDouble()),
      contrato: tieneContrato
          ? Contrato(
              firmaCliente: m['contrato_firma_cliente'] as bool? ?? false,
              firmaTransportista: m['contrato_firma_transportista'] as bool? ?? false,
              fechaCliente: m['contrato_fecha_cliente'] != null ? DateTime.parse(m['contrato_fecha_cliente'] as String) : null,
              fechaTransportista: m['contrato_fecha_transportista'] != null ? DateTime.parse(m['contrato_fecha_transportista'] as String) : null,
            )
          : null,
      fechaAsignacion: m['fecha_asignacion'] != null ? DateTime.parse(m['fecha_asignacion'] as String) : null,
      fechaEntrega: m['fecha_entrega'] != null ? DateTime.parse(m['fecha_entrega'] as String) : null,
      volumen: (m['volumen'] as num?)?.toDouble(),
      dimensiones: m['dimensiones'] as String?,
      peligrosa: m['peligrosa'] as bool? ?? false,
      fotos: (m['fotos'] as List?)?.cast<String>() ?? [],
      documentos: (m['documentos'] as List?)?.cast<String>() ?? [],
    );
  }
}

class Mensaje {
  final int id;
  final int conversacionId;
  final String de;
  final DateTime ts;
  final String? texto; // null when esOferta
  final bool esOferta;
  final double? precio;
  String? estadoOferta; // pendiente | aceptada | rechazada

  Mensaje.texto({required this.id, required this.conversacionId, required this.de, required this.texto, required this.ts})
      : esOferta = false,
        precio = null,
        estadoOferta = null;

  Mensaje.oferta({required this.id, required this.conversacionId, required this.de, required this.precio, required this.ts, this.estadoOferta = 'pendiente'})
      : esOferta = true,
        texto = null;

  factory Mensaje.fromMap(Map<String, dynamic> m) {
    final ts = DateTime.parse(m['ts'] as String);
    if (m['es_oferta'] as bool? ?? false) {
      return Mensaje.oferta(
        id: m['id'] as int,
        conversacionId: m['conversacion_id'] as int,
        de: m['de_id'] as String,
        precio: (m['precio'] as num?)?.toDouble(),
        ts: ts,
        estadoOferta: m['estado_oferta'] as String? ?? 'pendiente',
      );
    }
    return Mensaje.texto(
      id: m['id'] as int,
      conversacionId: m['conversacion_id'] as int,
      de: m['de_id'] as String,
      texto: m['texto'] as String?,
      ts: ts,
    );
  }
}

class Conversacion {
  final int id;
  final List<String> participantes;
  final int cargaId;
  final List<Mensaje> mensajes;
  Conversacion({required this.id, required this.participantes, required this.cargaId, List<Mensaje>? mensajes})
      : mensajes = mensajes ?? [];

  factory Conversacion.fromMap(Map<String, dynamic> m, {List<Mensaje> mensajes = const []}) => Conversacion(
        id: m['id'] as int,
        participantes: [m['participante_a'] as String, m['participante_b'] as String],
        cargaId: m['carga_id'] as int,
        mensajes: mensajes,
      );
}

class Notificacion {
  final int id;
  final String usuarioId;
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

  factory Notificacion.fromMap(Map<String, dynamic> m) => Notificacion(
        id: m['id'] as int,
        usuarioId: m['usuario_id'] as String,
        tipo: m['tipo'] as String,
        titulo: m['titulo'] as String,
        sub: m['sub'] as String? ?? '',
        ts: DateTime.parse(m['ts'] as String),
        leida: m['leida'] as bool? ?? false,
      );
}

class Calificacion {
  final int estrellas;
  final String comentario;
  Calificacion({required this.estrellas, required this.comentario});
}

class HistorialItem {
  final int id;
  final int cargaId;
  final String clienteId;
  final String cliente;
  final String transportistaId;
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

  factory HistorialItem.fromMap(Map<String, dynamic> m) => HistorialItem(
        id: m['id'] as int,
        cargaId: m['carga_id'] as int,
        clienteId: m['cliente_id'] as String,
        cliente: m['cliente'] as String,
        transportistaId: m['transportista_id'] as String,
        transportista: m['transportista'] as String,
        tipoCarga: m['tipo_carga'] as String,
        ruta: m['ruta'] as String,
        monto: (m['monto'] as num).toDouble(),
        fecha: m['fecha'] as String,
        estado: m['estado'] as String? ?? 'completado',
        calTransportista: m['cal_transportista_estrellas'] != null
            ? Calificacion(estrellas: m['cal_transportista_estrellas'] as int, comentario: m['cal_transportista_comentario'] as String? ?? '')
            : null,
        calCliente: m['cal_cliente_estrellas'] != null
            ? Calificacion(estrellas: m['cal_cliente_estrellas'] as int, comentario: m['cal_cliente_comentario'] as String? ?? '')
            : null,
      );
}

class Factura {
  final int id;
  final String numero;
  final int cargaId;
  final String clienteId;
  final String cliente;
  final String transportistaId;
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

  factory Factura.fromMap(Map<String, dynamic> m) => Factura(
        id: m['id'] as int,
        numero: m['numero'] as String,
        cargaId: m['carga_id'] as int,
        clienteId: m['cliente_id'] as String,
        cliente: m['cliente'] as String,
        transportistaId: m['transportista_id'] as String,
        transportista: m['transportista'] as String,
        tipoCarga: m['tipo_carga'] as String,
        ruta: m['ruta'] as String,
        monto: (m['monto'] as num).toDouble(),
        comisionPct: (m['comision_pct'] as num).toDouble(),
        comision: (m['comision'] as num).toDouble(),
        montoTransportista: (m['monto_transportista'] as num).toDouble(),
        fecha: m['fecha'] as String,
      );
}
