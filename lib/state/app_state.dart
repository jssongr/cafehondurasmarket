import 'dart:async';
import 'package:flutter/material.dart';
import '../data/seed.dart';
import '../models/models.dart';
import '../utils/format.dart';

class AppState extends ChangeNotifier {
  final List<Usuario> usuarios = buildSeedUsers();
  Usuario? usuario;
  final List<Carga> cargas = buildSeedCargas();
  final List<Conversacion> convos = buildSeedConvos();
  final List<Notificacion> notifs = buildSeedNotifs();
  final List<HistorialItem> historial = buildSeedHist();
  final List<Factura> facturas = buildSeedFacturas();

  String? _toastMsg;
  int _toastId = 0;
  String? get toastMsg => _toastMsg;
  int get toastId => _toastId;
  Timer? _toastTimer;
  Timer? _gpsTimer;

  ThemeMode themeMode = ThemeMode.system;
  void setThemeMode(ThemeMode mode) {
    themeMode = mode;
    notifyListeners();
  }

  String idioma = 'ES';
  void setIdioma(String v) {
    idioma = v;
    notifyListeners();
  }

  AppState() {
    _gpsTimer = Timer.periodic(const Duration(milliseconds: 2600), (_) => _advanceGps());
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    _gpsTimer?.cancel();
    super.dispose();
  }

  void showToast(String msg) {
    _toastTimer?.cancel();
    _toastId++;
    _toastMsg = msg;
    notifyListeners();
    _toastTimer = Timer(const Duration(milliseconds: 3200), () {
      _toastMsg = null;
      notifyListeners();
    });
  }

  void addNotif(int usuarioId, String tipo, String titulo, String sub) {
    notifs.insert(0, Notificacion(id: uid(), usuarioId: usuarioId, tipo: tipo, titulo: titulo, sub: sub, ts: DateTime.now()));
    notifyListeners();
  }

  void markNotifsRead(int usuarioId) {
    for (final n in notifs) {
      if (n.usuarioId == usuarioId) n.leida = true;
    }
    notifyListeners();
  }

  Usuario? login(String email, String password) {
    Usuario? found;
    for (final u in usuarios) {
      if (u.email == email && u.password == password) {
        found = u;
        break;
      }
    }
    if (found != null) {
      usuario = found;
      notifyListeners();
    }
    return found;
  }

  Usuario registrar({
    required String nombre,
    required String email,
    required String password,
    required TipoUsuario tipo,
    required String subtipo,
    required String telefono,
    String? vehiculo,
    double? capacidad,
    String? placa,
    String? selfie,
    String? doc,
  }) {
    final nuevo = Usuario(
      id: uid(), nombre: nombre, email: email, password: password, tipo: tipo, subtipo: subtipo,
      telefono: telefono, verificado: false, selfie: selfie, doc: doc,
      vehiculo: vehiculo, capacidad: capacidad, placa: placa, fechaRegistro: DateTime.now(),
    );
    usuarios.add(nuevo);
    usuario = nuevo;
    notifyListeners();
    return nuevo;
  }

  void aprobarUsuario(int usuarioId) {
    final u = usuarios.firstWhere((x) => x.id == usuarioId);
    u.verificado = true;
    if (usuario?.id == usuarioId) usuario = u;
    addNotif(usuarioId, 'sistema', 'Cuenta verificada', 'Tu cuenta fue aprobada por un administrador. Ya tenés acceso completo a NexCarg.');
    notifyListeners();
  }

  void logout() {
    usuario = null;
    notifyListeners();
  }

  void publicarCarga(Carga carga) {
    cargas.add(carga);
    notifyListeners();
  }

  void cancelarCarga(int cargaId) {
    final c = cargas.firstWhere((x) => x.id == cargaId);
    c.estado = EstadoCarga.cancelada;
    notifyListeners();
  }

  void asignarCarga(int cargaId, int transportistaId, String transportistaNombre, double monto) {
    final c = cargas.firstWhere((x) => x.id == cargaId);
    c.estado = EstadoCarga.asignada;
    c.transportistaId = transportistaId;
    c.transportistaNombre = transportistaNombre;
    c.precioAcordado = monto;
    c.pago = Pago(estado: EstadoPago.retenido, monto: monto);
    c.contrato = Contrato();
    c.fechaAsignacion = DateTime.now();
    notifyListeners();
  }

  void iniciarViaje(int cargaId) {
    final c = cargas.firstWhere((x) => x.id == cargaId);
    c.estado = EstadoCarga.enTransito;
    c.progreso = 2;
    notifyListeners();
  }

  void _registrarEntrega(Carga c) {
    final ruta = '${c.ciudadOrigen} (${c.paisOrigen}) → ${c.ciudadDestino} (${c.paisDestino})';
    final calc = calcComision(c.precioAcordado!);
    historial.insert(0, HistorialItem(
      id: uid(), cargaId: c.id, clienteId: c.clienteId, cliente: c.cliente,
      transportistaId: c.transportistaId!, transportista: c.transportistaNombre!, tipoCarga: c.tipoCarga,
      ruta: ruta, monto: c.precioAcordado!, fecha: DateTime.now().toIso8601String().split('T')[0], estado: 'completado',
    ));
    facturas.insert(0, Factura(
      id: uid(), numero: 'NX-${(facturas.length + 1).toString().padLeft(4, '0')}', cargaId: c.id,
      clienteId: c.clienteId, cliente: c.cliente, transportistaId: c.transportistaId!, transportista: c.transportistaNombre!,
      tipoCarga: c.tipoCarga, ruta: ruta, monto: c.precioAcordado!, comisionPct: 8, comision: calc.comision,
      montoTransportista: calc.montoTransportista, fecha: DateTime.now().toIso8601String().split('T')[0],
    ));
    addNotif(c.clienteId, 'sistema', 'Carga entregada', '${c.tipoCarga} llegó a ${c.ciudadDestino}. Pago liberado al transportista. Ya puedes calificar el viaje.');
    addNotif(c.transportistaId!, 'sistema', 'Pago liberado', 'Se liberó ${fmtMoneda(calc.montoTransportista)} (neto de comisión) por la entrega de ${c.tipoCarga}.');
  }

  void confirmarEntregaManual(int cargaId) {
    final c = cargas.firstWhere((x) => x.id == cargaId);
    c.progreso = 100;
    c.estado = EstadoCarga.entregada;
    c.pago.estado = EstadoPago.liberado;
    c.fechaEntrega = DateTime.now();
    _registrarEntrega(c);
    notifyListeners();
  }

  void _advanceGps() {
    final entregadas = <Carga>[];
    for (final c in cargas) {
      if (c.estado != EstadoCarga.enTransito) continue;
      final p = (c.progreso + rand(6, 14)).clamp(0, 100).toDouble();
      c.progreso = p;
      if (p >= 100) {
        c.estado = EstadoCarga.entregada;
        c.pago.estado = EstadoPago.liberado;
        c.fechaEntrega = DateTime.now();
        entregadas.add(c);
      }
    }
    if (entregadas.isNotEmpty) {
      for (final c in entregadas) {
        _registrarEntrega(c);
      }
    }
    notifyListeners();
  }

  void firmarContrato(int cargaId, TipoUsuario actorTipo) {
    final c = cargas.firstWhere((x) => x.id == cargaId);
    if (c.contrato == null) return;
    if (actorTipo == TipoUsuario.cliente) {
      c.contrato!.firmaCliente = true;
      c.contrato!.fechaCliente = DateTime.now();
    } else {
      c.contrato!.firmaTransportista = true;
      c.contrato!.fechaTransportista = DateTime.now();
    }
    notifyListeners();
  }

  void calificar(int historialId, TipoUsuario actorTipo, int estrellas, String comentario) {
    final h = historial.firstWhere((x) => x.id == historialId);
    final cal = Calificacion(estrellas: estrellas, comentario: comentario);
    if (actorTipo == TipoUsuario.cliente) {
      h.calTransportista = cal;
    } else {
      h.calCliente = cal;
    }
    notifyListeners();
  }

  int abrirOCrearConvo(Carga carga, int yoId, TipoUsuario yoTipo) {
    final otroId = yoTipo == TipoUsuario.cliente ? carga.transportistaId : carga.clienteId;
    final targetId = otroId ?? carga.clienteId;
    for (final c in convos) {
      if (c.participantes.contains(yoId) && c.participantes.contains(targetId) && c.cargaId == carga.id) {
        return c.id;
      }
    }
    final nuevaId = uid();
    convos.add(Conversacion(id: nuevaId, participantes: [yoId, targetId], cargaId: carga.id));
    notifyListeners();
    return nuevaId;
  }

  void enviarMensaje(int convoId, int deId, String texto) {
    final convo = convos.firstWhere((c) => c.id == convoId);
    convo.mensajes.add(Mensaje.texto(id: uid(), de: deId, texto: texto, ts: DateTime.now()));
    final destId = convo.participantes.firstWhere((p) => p != deId, orElse: () => -1);
    final de = usuarios.firstWhere((u) => u.id == deId, orElse: () => usuarios.first);
    if (destId != -1) {
      addNotif(destId, 'mensaje', 'Nuevo mensaje de ${de.nombre}', texto.length > 60 ? texto.substring(0, 60) : texto);
    }
    notifyListeners();
  }

  void enviarOferta(int convoId, int deId, double precio) {
    final convo = convos.firstWhere((c) => c.id == convoId);
    convo.mensajes.add(Mensaje.oferta(id: uid(), de: deId, precio: precio, ts: DateTime.now()));
    final destId = convo.participantes.firstWhere((p) => p != deId, orElse: () => -1);
    final de = usuarios.firstWhere((u) => u.id == deId, orElse: () => usuarios.first);
    if (destId != -1) {
      addNotif(destId, 'oferta', 'Nueva cotización de ${de.nombre}', '${fmtMoneda(precio)} por el viaje');
    }
    notifyListeners();
  }

  void responderOferta(int convoId, int msgId, String accion) {
    final convo = convos.firstWhere((c) => c.id == convoId);
    Mensaje? ofertaMsg;
    for (final m in convo.mensajes) {
      if (m.id == msgId) {
        m.estadoOferta = accion;
        ofertaMsg = m;
      }
    }
    if (accion == 'aceptada' && ofertaMsg != null) {
      final respondiendoId = usuario?.id;
      final transportistaId = ofertaMsg.de;
      final transportista = usuarios.firstWhere((u) => u.id == transportistaId);
      asignarCarga(convo.cargaId, transportista.id, transportista.nombre, ofertaMsg.precio!);
      final destId = convo.participantes.firstWhere((p) => p != respondiendoId, orElse: () => -1);
      if (destId != -1) {
        addNotif(destId, 'oferta', 'Cotización aceptada', 'Tu cotización de ${fmtMoneda(ofertaMsg.precio)} fue aceptada');
      }
    }
    notifyListeners();
  }

  void actualizarPerfil(int usuarioId, {String? nombre, String? telefono, String? selfie}) {
    final u = usuarios.firstWhere((x) => x.id == usuarioId);
    if (nombre != null) u.nombre = nombre;
    if (telefono != null) u.telefono = telefono;
    if (selfie != null) u.selfie = selfie;
    if (usuario?.id == usuarioId) {
      // usuario is the same object reference from `usuarios`, already mutated above.
    }
    notifyListeners();
  }
}
