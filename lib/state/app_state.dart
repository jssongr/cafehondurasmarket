import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/constants.dart';
import '../models/models.dart';
import '../services/location_service.dart';

class AppState extends ChangeNotifier {
  final SupabaseClient _sb = Supabase.instance.client;

  List<Usuario> usuarios = [];
  Usuario? usuario;
  List<Carga> cargas = [];
  List<Conversacion> convos = [];
  List<Notificacion> notifs = [];
  List<HistorialItem> historial = [];
  List<Factura> facturas = [];
  bool loading = true;

  String? _toastMsg;
  int _toastId = 0;
  String? get toastMsg => _toastMsg;
  int get toastId => _toastId;
  Timer? _toastTimer;

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

  StreamSubscription? _usuariosSub;
  StreamSubscription? _cargasSub;
  StreamSubscription? _convosSub;
  StreamSubscription? _mensajesSub;
  StreamSubscription? _notifsSub;
  StreamSubscription? _historialSub;
  StreamSubscription? _facturasSub;
  StreamSubscription<AuthState>? _authSub;

  List<Map<String, dynamic>> _rawConvos = [];
  List<Map<String, dynamic>> _rawMensajes = [];

  AppState() {
    _authSub = _sb.auth.onAuthStateChange.listen(_onAuthChange, onError: (_) => _dejarDeCargar());
    // Red de seguridad: si la sesión no se resuelve, mostrar el login en vez de
    // dejar al usuario mirando el spinner para siempre.
    _cargaTimeout = Timer(const Duration(seconds: 10), _dejarDeCargar);
  }

  Timer? _cargaTimeout;

  void _dejarDeCargar() {
    if (!loading) return;
    loading = false;
    notifyListeners();
  }

  bool passwordRecovery = false;

  void _onAuthChange(AuthState state) {
    if (state.event == AuthChangeEvent.passwordRecovery) {
      passwordRecovery = true;
      loading = false;
      notifyListeners();
      return;
    }
    final session = state.session;
    if (session != null) {
      _loadUsuarioYDatos(session.user.id);
    } else {
      _teardown();
    }
  }

  Future<void> _loadUsuarioYDatos(String userId) async {
    loading = true;
    notifyListeners();
    try {
      final row = await _sb.from('usuarios').select().eq('id', userId).single();
      usuario = Usuario.fromMap(row);
      _setupRealtimeStreams();
    } catch (_) {
      // profile row not ready yet (rare race right after signup) — leave usuario null.
    }
    loading = false;
    notifyListeners();
  }

  void _teardown() {
    detenerRastreo();
    _usuariosSub?.cancel();
    _cargasSub?.cancel();
    _convosSub?.cancel();
    _mensajesSub?.cancel();
    _notifsSub?.cancel();
    _historialSub?.cancel();
    _facturasSub?.cancel();
    usuario = null;
    usuarios = [];
    cargas = [];
    convos = [];
    notifs = [];
    historial = [];
    facturas = [];
    _rawConvos = [];
    _rawMensajes = [];
    loading = false;
    notifyListeners();
  }

  void _setupRealtimeStreams() {
    _usuariosSub?.cancel();
    _usuariosSub = _sb.from('usuarios').stream(primaryKey: ['id']).listen((rows) {
      usuarios = rows.map(Usuario.fromMap).toList();
      if (usuario != null) {
        final mine = usuarios.where((u) => u.id == usuario!.id);
        if (mine.isNotEmpty) usuario = mine.first;
      }
      notifyListeners();
    });

    _cargasSub?.cancel();
    _cargasSub = _sb.from('cargas').stream(primaryKey: ['id']).listen((rows) {
      cargas = rows.map(Carga.fromMap).toList()..sort((a, b) => a.id.compareTo(b.id));
      notifyListeners();
    });

    _convosSub?.cancel();
    _convosSub = _sb.from('conversaciones').stream(primaryKey: ['id']).listen((rows) {
      _rawConvos = rows;
      _rebuildConvos();
    });

    _mensajesSub?.cancel();
    _mensajesSub = _sb.from('mensajes').stream(primaryKey: ['id']).listen((rows) {
      _rawMensajes = rows;
      _rebuildConvos();
    });

    _notifsSub?.cancel();
    _notifsSub = _sb.from('notificaciones').stream(primaryKey: ['id']).listen((rows) {
      notifs = rows.map(Notificacion.fromMap).toList()..sort((a, b) => b.ts.compareTo(a.ts));
      notifyListeners();
    });

    _historialSub?.cancel();
    _historialSub = _sb.from('historial').stream(primaryKey: ['id']).listen((rows) {
      historial = rows.map(HistorialItem.fromMap).toList()..sort((a, b) => b.id.compareTo(a.id));
      notifyListeners();
    });

    _facturasSub?.cancel();
    _facturasSub = _sb.from('facturas').stream(primaryKey: ['id']).listen((rows) {
      facturas = rows.map(Factura.fromMap).toList()..sort((a, b) => b.id.compareTo(a.id));
      notifyListeners();
    });
  }

  void _rebuildConvos() {
    final mensajesOrdenados = List.of(_rawMensajes)..sort((a, b) => (a['ts'] as String).compareTo(b['ts'] as String));
    convos = _rawConvos.map((c) {
      final propios = mensajesOrdenados.where((m) => m['conversacion_id'] == c['id']).map(Mensaje.fromMap).toList();
      return Conversacion.fromMap(c, mensajes: propios);
    }).toList();
    notifyListeners();
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    _cargaTimeout?.cancel();
    _rastreoTimer?.cancel();
    _usuariosSub?.cancel();
    _cargasSub?.cancel();
    _convosSub?.cancel();
    _mensajesSub?.cancel();
    _notifsSub?.cancel();
    _historialSub?.cancel();
    _facturasSub?.cancel();
    _authSub?.cancel();
    super.dispose();
  }

  // ---- Rastreo GPS ----
  //
  // Vive acá y no en la pantalla de seguimiento para que el transportista pueda
  // moverse por la app —revisar mensajes, ver una carga— sin dejar de reportar
  // su posición. Solo se activa cuando él lo autoriza explícitamente.

  Timer? _rastreoTimer;
  bool rastreoActivo = false;
  String? rastreoError;

  /// Viajes que este transportista está llevando ahora mismo.
  List<Carga> get viajesEnRuta {
    final yo = usuario;
    if (yo == null || yo.tipo != TipoUsuario.transportista) return const [];
    return cargas.where((c) => c.transportistaId == yo.id && c.estado == EstadoCarga.enTransito).toList();
  }

  Future<bool> iniciarRastreo() async {
    rastreoError = null;
    final permitido = await ensureLocationPermission();
    if (!permitido) {
      rastreoError = 'No pudimos acceder a tu ubicación. Revisá que el GPS esté encendido y que le hayas dado permiso a NexCarg.';
      rastreoActivo = false;
      notifyListeners();
      return false;
    }
    rastreoActivo = true;
    notifyListeners();
    await _reportarUbicacion();
    _rastreoTimer?.cancel();
    _rastreoTimer = Timer.periodic(const Duration(seconds: 30), (_) => _reportarUbicacion());
    return true;
  }

  void detenerRastreo() {
    _rastreoTimer?.cancel();
    _rastreoTimer = null;
    rastreoActivo = false;
    notifyListeners();
  }

  Future<void> _reportarUbicacion() async {
    final activos = viajesEnRuta;
    // Al terminar el último viaje se corta solo: nadie debería seguir siendo
    // ubicado cuando ya no está llevando carga de nadie.
    if (activos.isEmpty) {
      detenerRastreo();
      return;
    }
    final pos = await getCurrentPosition();
    if (pos == null) return;
    for (final c in activos) {
      try {
        await actualizarUbicacion(c.id, pos.latitude, pos.longitude);
      } catch (_) {
        // Falla puntual de red: el siguiente ciclo reintenta.
      }
    }
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

  // ---- Auth ----

  /// Supabase returns auth errors in English; surface them in Spanish instead.
  String _mensajeAuth(AuthException e) {
    final m = e.message.toLowerCase();
    if (m.contains('email rate limit') || m.contains('over_email_send_rate_limit')) {
      return 'Se alcanzó el límite de correos por hora. Espera un momento e intenta de nuevo.';
    }
    final espera = RegExp(r'after (\d+) seconds').firstMatch(m);
    if (espera != null) {
      return 'Por seguridad, espera ${espera.group(1)} segundos antes de volver a intentar.';
    }
    if (m.contains('already registered') || m.contains('already been registered')) {
      return 'Ya existe una cuenta con ese correo. Inicia sesión o recupera tu contraseña.';
    }
    if (m.contains('invalid login credentials')) {
      return 'Correo o contraseña incorrectos.';
    }
    if (m.contains('email not confirmed')) {
      return 'Todavía no confirmaste tu correo. Revisa tu bandeja de entrada.';
    }
    if (m.contains('password should be at least')) {
      return 'La contraseña debe tener al menos 8 caracteres.';
    }
    if (m.contains('invalid format') || m.contains('unable to validate email')) {
      return 'El correo no tiene un formato válido.';
    }
    if (m.contains('signups not allowed')) {
      return 'El registro de cuentas nuevas está deshabilitado por el momento.';
    }
    if (m.contains('same password')) {
      return 'La contraseña nueva debe ser distinta a la anterior.';
    }
    return e.message;
  }

  Future<String?> login(String email, String password) async {
    try {
      await _sb.auth.signInWithPassword(email: email, password: password);
      return null;
    } on AuthException catch (e) {
      return _mensajeAuth(e);
    } catch (_) {
      return 'No se pudo iniciar sesión. Intenta de nuevo.';
    }
  }

  Future<String?> recuperarContrasena(String email) async {
    try {
      await _sb.auth.resetPasswordForEmail(email, redirectTo: urlApp);
      return null;
    } on AuthException catch (e) {
      return _mensajeAuth(e);
    } catch (_) {
      return 'No se pudo enviar el correo de recuperación. Intenta de nuevo.';
    }
  }

  Future<String?> actualizarContrasena(String nuevaContrasena) async {
    try {
      await _sb.auth.updateUser(UserAttributes(password: nuevaContrasena));
      final userId = _sb.auth.currentUser?.id;
      passwordRecovery = false;
      if (userId != null) {
        await _loadUsuarioYDatos(userId);
      } else {
        notifyListeners();
      }
      return null;
    } on AuthException catch (e) {
      return _mensajeAuth(e);
    } catch (_) {
      return 'No se pudo actualizar la contraseña. Intenta de nuevo.';
    }
  }

  Future<String?> registrar({
    required String nombre,
    required String email,
    required String password,
    required TipoUsuario tipo,
    required String subtipo,
    required String telefono,
    required String pais,
    String? vehiculo,
    double? capacidad,
    String? placa,
    String? selfie,
    String? doc,
    String? docIdentidad,
    String? seguro,
  }) async {
    try {
      await _sb.auth.signUp(email: email, password: password, data: {
        'nombre': nombre,
        'tipo': tipo.value,
        'subtipo': subtipo,
        'telefono': telefono,
        'pais': pais,
        if (vehiculo != null) 'vehiculo': vehiculo,
        if (capacidad != null) 'capacidad': capacidad.toString(),
        if (placa != null) 'placa': placa,
      });
      final uid = _sb.auth.currentUser?.id;
      if (uid != null && (selfie != null || doc != null || docIdentidad != null || seguro != null)) {
        final updates = <String, dynamic>{};
        if (selfie != null) updates['selfie_url'] = selfie;
        if (doc != null) updates['doc_url'] = doc;
        if (docIdentidad != null) updates['doc_identidad_url'] = docIdentidad;
        if (seguro != null) updates['seguro_url'] = seguro;
        await _sb.from('usuarios').update(updates).eq('id', uid);
      }
      return null;
    } on AuthException catch (e) {
      return _mensajeAuth(e);
    } catch (_) {
      return 'No se pudo crear la cuenta. Intenta de nuevo.';
    }
  }

  Future<void> logout() async {
    await _sb.auth.signOut();
  }

  // ---- Notificaciones ----

  Future<void> markNotifsRead(String usuarioId) async {
    await _sb.from('notificaciones').update({'leida': true}).eq('usuario_id', usuarioId).eq('leida', false);
  }

  // ---- Cargas ----

  Future<void> publicarCarga({
    required String clienteId,
    required String cliente,
    required String tipoCarga,
    required double peso,
    required String unidadPeso,
    required String paisOrigen,
    required String ciudadOrigen,
    String? direccionOrigen,
    required String paisDestino,
    required String ciudadDestino,
    String? direccionDestino,
    required String fecha,
    required String vehiculoReq,
    double? presupuesto,
    String descripcion = '',
    double? volumen,
    String? dimensiones,
    bool peligrosa = false,
    List<String> fotos = const [],
    List<String> documentos = const [],
  }) async {
    await _sb.from('cargas').insert({
      'cliente_id': clienteId,
      'cliente': cliente,
      'tipo_carga': tipoCarga,
      'peso': peso,
      'unidad_peso': unidadPeso,
      'pais_origen': paisOrigen,
      'ciudad_origen': ciudadOrigen,
      'direccion_origen': direccionOrigen,
      'pais_destino': paisDestino,
      'ciudad_destino': ciudadDestino,
      'direccion_destino': direccionDestino,
      'fecha': fecha,
      'vehiculo_req': vehiculoReq,
      'presupuesto': presupuesto,
      'descripcion': descripcion,
      'volumen': volumen,
      'dimensiones': dimensiones,
      'peligrosa': peligrosa,
      'fotos': fotos,
      'documentos': documentos,
    });
  }

  Future<void> cancelarCarga(int cargaId) async {
    await _sb.from('cargas').update({'estado': 'cancelada'}).eq('id', cargaId);
  }

  Future<void> asignarCarga(int cargaId, String transportistaId, String transportistaNombre, double monto) async {
    await _sb.rpc('asignar_carga', params: {'p_carga_id': cargaId, 'p_transportista_id': transportistaId, 'p_monto': monto});
  }

  Future<void> iniciarViaje(int cargaId) async {
    await _sb.rpc('iniciar_viaje', params: {'p_carga_id': cargaId});
  }

  Future<void> actualizarUbicacion(int cargaId, double lat, double lng) async {
    await _sb.rpc('actualizar_ubicacion', params: {'p_carga_id': cargaId, 'p_lat': lat, 'p_lng': lng});
  }

  Future<void> confirmarEntregaManual(
    int cargaId, {
    required String pruebaFoto,
    required String pruebaFirma,
    required String recibidoPor,
  }) async {
    await _sb.rpc('confirmar_entrega_con_prueba', params: {
      'p_carga_id': cargaId,
      'p_prueba_foto': pruebaFoto,
      'p_prueba_firma': pruebaFirma,
      'p_recibido_por': recibidoPor,
    });
  }

  Future<void> firmarContrato(int cargaId, TipoUsuario actorTipo) async {
    await _sb.rpc('firmar_contrato', params: {'p_carga_id': cargaId, 'p_actor_tipo': actorTipo == TipoUsuario.cliente ? 'cliente' : 'transportista'});
  }

  Future<void> calificar(int historialId, TipoUsuario actorTipo, int estrellas, String comentario) async {
    await _sb.rpc('calificar', params: {
      'p_historial_id': historialId,
      'p_actor_tipo': actorTipo == TipoUsuario.cliente ? 'cliente' : 'transportista',
      'p_estrellas': estrellas,
      'p_comentario': comentario,
    });
  }

  // ---- Mensajería ----

  Future<int> abrirOCrearConvo(Carga carga, String yoId, TipoUsuario yoTipo) async {
    final otroId = yoTipo == TipoUsuario.cliente ? carga.transportistaId : carga.clienteId;
    final targetId = otroId ?? carga.clienteId;
    final res = await _sb.rpc('abrir_o_crear_convo', params: {'p_carga_id': carga.id, 'p_yo_id': yoId, 'p_otro_id': targetId});
    return res as int;
  }

  Future<void> enviarMensaje(int convoId, String texto) async {
    await _sb.rpc('enviar_mensaje', params: {'p_convo_id': convoId, 'p_texto': texto});
  }

  Future<void> enviarOferta(int convoId, double precio) async {
    await _sb.rpc('enviar_oferta', params: {'p_convo_id': convoId, 'p_precio': precio});
  }

  Future<void> responderOferta(int mensajeId, String accion) async {
    await _sb.rpc('responder_oferta', params: {'p_mensaje_id': mensajeId, 'p_accion': accion});
  }

  // ---- Perfil / Admin ----

  Future<void> actualizarPerfil(String usuarioId, {String? nombre, String? telefono, String? selfie}) async {
    final updates = <String, dynamic>{};
    if (nombre != null) updates['nombre'] = nombre;
    if (telefono != null) updates['telefono'] = telefono;
    if (selfie != null) updates['selfie_url'] = selfie;
    if (updates.isEmpty) return;
    await _sb.from('usuarios').update(updates).eq('id', usuarioId);
  }

  Future<void> aprobarUsuario(String usuarioId) async {
    await _sb.rpc('aprobar_usuario', params: {'p_usuario_id': usuarioId});
  }

  Future<void> rechazarUsuario(String usuarioId, String motivo) async {
    await _sb.rpc('rechazar_usuario', params: {'p_usuario_id': usuarioId, 'p_motivo': motivo});
  }

  Future<void> suspenderUsuario(String usuarioId, String motivo) async {
    await _sb.rpc('suspender_usuario', params: {'p_usuario_id': usuarioId, 'p_motivo': motivo});
  }

  Future<void> reactivarUsuario(String usuarioId) async {
    await _sb.rpc('reactivar_usuario', params: {'p_usuario_id': usuarioId});
  }
}
