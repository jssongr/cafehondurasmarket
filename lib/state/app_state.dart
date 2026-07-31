import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

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
    _authSub = _sb.auth.onAuthStateChange.listen(_onAuthChange);
  }

  void _onAuthChange(AuthState state) {
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

  Future<String?> login(String email, String password) async {
    try {
      await _sb.auth.signInWithPassword(email: email, password: password);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'No se pudo iniciar sesión. Intenta de nuevo.';
    }
  }

  Future<String?> recuperarContrasena(String email) async {
    try {
      await _sb.auth.resetPasswordForEmail(email);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'No se pudo enviar el correo de recuperación. Intenta de nuevo.';
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
      if (uid != null && (selfie != null || doc != null)) {
        final updates = <String, dynamic>{};
        if (selfie != null) updates['selfie_url'] = selfie;
        if (doc != null) updates['doc_url'] = doc;
        await _sb.from('usuarios').update(updates).eq('id', uid);
      }
      return null;
    } on AuthException catch (e) {
      return e.message;
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

  Future<void> confirmarEntregaManual(int cargaId) async {
    await _sb.rpc('confirmar_entrega_manual', params: {'p_carga_id': cargaId});
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
}
