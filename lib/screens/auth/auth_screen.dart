import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/constants.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/select_field.dart';
import '../../widgets/upload_zone.dart';
import '../settings/legal_screen.dart';
import 'step_indicator.dart';

class AuthScreen extends StatefulWidget {
  /// La página de presentación tiene botones que dicen "Crear cuenta" y
  /// "Publicar mi primera carga". Caer en el formulario de acceso después de
  /// tocarlos obligaría a buscar el enlace de registro; con esto se abre
  /// directo en el paso 1 del registro.
  final bool iniciarEnRegistro;
  const AuthScreen({super.key, this.iniciarEnRegistro = false});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool _isLogin = !widget.iniciarEnRegistro;
  int _step = 1;
  String _err = '';

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _recordarme = true;

  final _nombreCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPassCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _capacidadCtrl = TextEditingController();
  final _placaCtrl = TextEditingController();

  TipoUsuario? _tipo;
  String _pais = '';
  String _subtipo = '';
  String _vehiculo = tiposVehiculo[0];
  String? _docImg;
  bool _scanning = false;
  bool _scanned = false;
  String? _docIdentidadImg;
  bool _scanningIdentidad = false;
  bool _scannedIdentidad = false;
  String? _seguroImg;
  String? _selfieImg;
  bool _selfieScanning = false;
  bool _selfieOk = false;
  bool _aceptaTerminos = false;

  bool get _esTransportista => _tipo == TipoUsuario.transportista;
  List<String> get _subtipos => _esTransportista ? transportistaSubtipos : clienteSubtipos;

  void _resetReg() {
    setState(() {
      _step = 1;
      _nombreCtrl.clear();
      _regEmailCtrl.clear();
      _regPassCtrl.clear();
      _telefonoCtrl.clear();
      _tipo = null;
      _pais = '';
      _subtipo = '';
      _docImg = null;
      _scanned = false;
      _docIdentidadImg = null;
      _scannedIdentidad = false;
      _seguroImg = null;
      _selfieImg = null;
      _selfieOk = false;
      _aceptaTerminos = false;
    });
  }

  bool _submitting = false;

  /// Esta pantalla se abre encima de la presentación. Al entrar, el navegador
  /// raíz ya muestra las pestañas del usuario detrás, así que hay que quitar
  /// este formulario de la pila o quedaría tapándolas.
  void _cerrarSiSeAbrioEncima() {
    final nav = Navigator.of(context);
    if (nav.canPop()) nav.pop();
  }

  Future<void> _doLogin() async {
    if (_emailCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) {
      setState(() => _err = 'Completa correo y contraseña.');
      return;
    }
    setState(() { _submitting = true; _err = ''; });
    final err = await context.read<AppState>().login(_emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    setState(() { _submitting = false; _err = err ?? ''; });
    if (err == null) _cerrarSiSeAbrioEncima();
  }

  Future<void> _recuperarContrasena() async {
    if (_emailCtrl.text.trim().isEmpty) {
      setState(() => _err = 'Escribe tu correo arriba para poder enviarte el enlace de recuperación.');
      return;
    }
    setState(() { _submitting = true; _err = ''; });
    final err = await context.read<AppState>().recuperarContrasena(_emailCtrl.text.trim());
    if (!mounted) return;
    setState(() => _submitting = false);
    if (err != null) { setState(() => _err = err); return; }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Revisa tu correo'),
        content: Text('Si existe una cuenta con ${_emailCtrl.text.trim()}, te enviamos un enlace para restablecer tu contraseña.'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Entendido'))],
      ),
    );
  }

  void _handleDoc(String path) {
    setState(() { _docImg = path; _scanning = true; _scanned = false; });
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      setState(() { _scanning = false; _scanned = true; });
    });
  }

  void _handleDocIdentidad(String path) {
    setState(() { _docIdentidadImg = path; _scanningIdentidad = true; _scannedIdentidad = false; });
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      setState(() { _scanningIdentidad = false; _scannedIdentidad = true; });
    });
  }

  void _handleSelfie(String path) {
    setState(() { _selfieImg = path; _selfieScanning = true; _selfieOk = false; });
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      setState(() { _selfieScanning = false; _selfieOk = true; });
    });
  }

  Future<void> _finalizarRegistro() async {
    if (!_selfieOk) { setState(() => _err = 'Completa la verificación facial.'); return; }
    if (!_aceptaTerminos) { setState(() => _err = 'Debes aceptar los Términos de Uso y la Política de Privacidad.'); return; }
    setState(() { _submitting = true; _err = ''; });
    final app = context.read<AppState>();
    final err = await app.registrar(
      nombre: _nombreCtrl.text, email: _regEmailCtrl.text, password: _regPassCtrl.text,
      tipo: _tipo!, subtipo: _subtipo, telefono: _telefonoCtrl.text, pais: _pais,
      vehiculo: _esTransportista ? _vehiculo : null,
      capacidad: _esTransportista ? double.tryParse(_capacidadCtrl.text) : null,
      placa: _esTransportista ? _placaCtrl.text : null,
      selfie: _selfieImg, doc: _docImg, docIdentidad: _docIdentidadImg, seguro: _seguroImg,
    );
    if (!mounted) return;
    setState(() { _submitting = false; _err = err ?? ''; });
    if (err == null) {
      app.showToast('¡Cuenta creada! Un administrador va a revisar tus documentos.');
      _cerrarSiSeAbrioEncima();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.marcaFondo, AppColors.marcaFondo2, AppColors.blue], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Container(
                    decoration: BoxDecoration(gradient: degradadoSuperficie, borderRadius: BorderRadius.circular(AppRadius.xl), border: bordeSuperficie, boxShadow: floatingShadow),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: AppSpacing.xl),
                          color: AppColors.marcaFondo,
                          child: const Column(
                            children: [
                              Image(image: AssetImage('assets/logo-blanco.png'), height: 34),
                              SizedBox(height: 10),
                              Text('El transporte de carga terrestre de Panamá a México, en un solo lugar',
                                  textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Color(0xA6FFFFFF))),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(color: AppColors.gris100, borderRadius: BorderRadius.circular(AppRadius.md)),
                                child: Row(children: [
                                  Expanded(child: _tabBtn('Iniciar sesión', _isLogin, () => setState(() { _isLogin = true; _err = ''; }))),
                                  Expanded(child: _tabBtn('Crear cuenta', !_isLogin, () { setState(() { _isLogin = false; _err = ''; }); _resetReg(); })),
                                ]),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              if (_err.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(color: AppColors.rojoBg, borderRadius: BorderRadius.circular(AppRadius.sm)),
                                  child: Row(children: [
                                    Icon(Icons.warning, size: 14, color: AppColors.rojo),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(_err, style: TextStyle(color: AppColors.rojo, fontSize: 12))),
                                  ]),
                                ),
                              if (_isLogin) _loginForm() else _registerForm(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Solo aparece si esta pantalla se abrió desde la presentación; si es
          // la raíz de la app no hay a dónde volver.
          if (Navigator.of(context).canPop())
            Positioned(
              top: 0,
              left: 4,
              child: SafeArea(
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  tooltip: 'Volver',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _tabBtn(String label, bool on, VoidCallback onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(color: on ? AppColors.solido : Colors.transparent, borderRadius: BorderRadius.circular(AppRadius.sm)),
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: on ? Colors.white : AppColors.grisM)),
        ),
      );

  Widget _loginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(label: 'Correo', placeholder: 'correo@ejemplo.com', controller: _emailCtrl, keyboardType: TextInputType.emailAddress),
        AppTextField(label: 'Contraseña', placeholder: '••••••', controller: _passCtrl, obscureText: true),
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(children: [
            SizedBox(
              width: 22, height: 22,
              child: Checkbox(
                value: _recordarme, onChanged: (v) => setState(() => _recordarme = v ?? true),
                activeColor: AppColors.navy, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 8),
            Text('Recordarme', style: TextStyle(fontSize: 12, color: AppColors.grisM)),
            const Spacer(),
            InkWell(
              onTap: _recuperarContrasena,
              child: Text('¿Olvidaste tu contraseña?', style: TextStyle(fontSize: 12, color: AppColors.blue, fontWeight: FontWeight.w600)),
            ),
          ]),
        ),
        AppButton(title: 'Entrar a la plataforma', onPressed: _doLogin, loading: _submitting, fullWidth: true),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: Divider(color: AppColors.gris100)),
          Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('o continuá con', style: TextStyle(fontSize: 11, color: AppColors.grisM))),
          Expanded(child: Divider(color: AppColors.gris100)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _socialButton('Google', Icons.g_mobiledata)),
          const SizedBox(width: 8),
          Expanded(child: _socialButton('Apple', Icons.apple)),
        ]),
      ],
    );
  }

  Widget _socialButton(String label, IconData icon) {
    return Opacity(
      opacity: 0.5,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(border: Border.all(color: AppColors.gris100, width: 1.5), borderRadius: BorderRadius.circular(AppRadius.md)),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 18, color: AppColors.grisM),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.grisM)),
          ]),
          const SizedBox(height: 2),
          Text('Próximamente', style: TextStyle(fontSize: 9, color: AppColors.grisM)),
        ]),
      ),
    );
  }

  Widget _registerForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StepIndicator(steps: const ['Datos', 'Documento', 'Selfie'], current: _step),
        if (_step == 1) _step1(),
        if (_step == 2) _step2(),
        if (_step == 3) _step3(),
      ],
    );
  }

  Widget _step1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(label: 'Nombre completo o empresa', placeholder: 'Ej. Transportes del Norte S.A.', controller: _nombreCtrl),
        AppTextField(label: 'Correo electrónico', placeholder: 'correo@ejemplo.com', controller: _regEmailCtrl, keyboardType: TextInputType.emailAddress),
        AppTextField(label: 'Contraseña', placeholder: 'Mínimo 8 caracteres', controller: _regPassCtrl, obscureText: true),
        AppTextField(label: 'Teléfono', placeholder: '+(504) 9xxx-xxxx', controller: _telefonoCtrl, keyboardType: TextInputType.phone),
        SelectField(label: 'País', value: _pais, options: paises, onChanged: (v) => setState(() => _pais = v), placeholder: 'Selecciona tu país'),
        Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text('¿QUÉ NECESITAS HACER?', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.blue, letterSpacing: 0.4)),
        ),
        Row(children: [
          Expanded(child: _roleCard(Icons.apartment, 'Cliente', 'Necesito transportar carga', _tipo == TipoUsuario.cliente, () => setState(() { _tipo = TipoUsuario.cliente; _subtipo = ''; }))),
          const SizedBox(width: 10),
          Expanded(child: _roleCard(Icons.local_shipping, 'Transportista', 'Tengo camión disponible', _tipo == TipoUsuario.transportista, () => setState(() { _tipo = TipoUsuario.transportista; _subtipo = ''; }))),
        ]),
        const SizedBox(height: 12),
        if (_tipo != null)
          SelectField(
            label: _esTransportista ? 'Tipo de transportista' : 'Tipo de empresa',
            value: _subtipo, options: _subtipos, onChanged: (v) => setState(() => _subtipo = v),
          ),
        if (_esTransportista) ...[
          SelectField(label: 'Tipo de vehículo', value: _vehiculo, options: tiposVehiculo, onChanged: (v) => setState(() => _vehiculo = v)),
          AppTextField(label: 'Capacidad (toneladas)', placeholder: '28', controller: _capacidadCtrl, keyboardType: TextInputType.number),
          AppTextField(label: 'Placa del vehículo', placeholder: 'Ej. HN-1234', controller: _placaCtrl),
        ],
        AppButton(
          title: 'Siguiente →', fullWidth: true,
          onPressed: () {
            if (_nombreCtrl.text.isEmpty || _regEmailCtrl.text.isEmpty || _regPassCtrl.text.isEmpty || _tipo == null || _subtipo.isEmpty || _telefonoCtrl.text.isEmpty || _pais.isEmpty) {
              setState(() => _err = 'Completa todos los campos.');
              return;
            }
            if (_regPassCtrl.text.length < 8) { setState(() => _err = 'La contraseña debe tener al menos 8 caracteres.'); return; }
            if (_esTransportista && _capacidadCtrl.text.isEmpty) { setState(() => _err = 'Indica la capacidad del vehículo.'); return; }
            setState(() { _err = ''; _step = 2; });
          },
        ),
      ],
    );
  }

  Widget _step2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _esTransportista ? 'Licencia de conducir vigente' : 'Documento de la empresa (RTN / Registro mercantil)',
          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.navy),
        ),
        const SizedBox(height: 4),
        Text(
          _esTransportista
              ? 'Sube una foto clara de tu licencia de conducir. Esto nos ayuda a verificar tu identidad como transportista.'
              : 'Sube una foto o escaneo de tu documento de registro comercial para verificar tu empresa.',
          style: TextStyle(fontSize: 12, color: AppColors.grisM, height: 1.4),
        ),
        const SizedBox(height: 14),
        UploadZone(
          icon: _esTransportista ? Icons.badge : Icons.description,
          title: 'Subir documento', uploadedTitle: 'Documento cargado', sub: 'Toca para elegir una imagen',
          image: _docImg, carpeta: 'documentos', onPicked: _handleDoc,
          scanning: _scanning, scanningLabel: 'Leyendo datos del documento con IA…',
          done: _scanned, doneLabel: 'Documento verificado correctamente — datos extraídos',
        ),
        const SizedBox(height: 18),
        Text('Documento de identidad (DNI, cédula o pasaporte)', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.navy)),
        const SizedBox(height: 4),
        Text('Sube una foto clara de tu documento de identidad personal, para confirmar quién eres.',
            style: TextStyle(fontSize: 12, color: AppColors.grisM, height: 1.4)),
        const SizedBox(height: 14),
        UploadZone(
          icon: Icons.badge_outlined,
          title: 'Subir DNI/cédula', uploadedTitle: 'Documento de identidad cargado', sub: 'Toca para elegir una imagen',
          image: _docIdentidadImg, carpeta: 'documentos', onPicked: _handleDocIdentidad,
          scanning: _scanningIdentidad, scanningLabel: 'Leyendo datos del documento con IA…',
          done: _scannedIdentidad, doneLabel: 'Documento de identidad verificado correctamente',
        ),
        if (_esTransportista) ...[
          const SizedBox(height: 18),
          Text('Comprobante de seguro (opcional)', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.navy)),
          const SizedBox(height: 4),
          Text('Si tienes seguro para tu vehículo o para ingresar carga a otro país, súbelo aquí — útil sobre todo en fletes internacionales.',
              style: TextStyle(fontSize: 12, color: AppColors.grisM, height: 1.4)),
          const SizedBox(height: 14),
          UploadZone(
            icon: Icons.shield_outlined,
            title: 'Subir comprobante de seguro', uploadedTitle: 'Comprobante de seguro cargado', sub: 'Opcional — toca para elegir una imagen',
            image: _seguroImg, carpeta: 'documentos', onPicked: (p) => setState(() => _seguroImg = p),
            scanning: false, done: false, doneLabel: '', scanningLabel: '',
          ),
        ],
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: AppButton(title: '← Atrás', variant: AppButtonVariant.ghost, onPressed: () => setState(() => _step = 1))),
          const SizedBox(width: 8),
          Expanded(flex: 2, child: AppButton(title: 'Siguiente →', onPressed: () {
            if (!_scanned) { setState(() => _err = 'Sube tu documento para continuar.'); return; }
            if (!_scannedIdentidad) { setState(() => _err = 'Sube tu documento de identidad (DNI/cédula) para continuar.'); return; }
            setState(() { _err = ''; _step = 3; });
          })),
        ]),
      ],
    );
  }

  Widget _step3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Selfie para reconocimiento facial', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.navy)),
        const SizedBox(height: 4),
        Text('Tómate una selfie clara mirando de frente. Nuestra IA la comparará con tu documento para confirmar tu identidad.',
            style: TextStyle(fontSize: 12, color: AppColors.grisM, height: 1.4)),
        const SizedBox(height: 14),
        UploadZone(
          icon: Icons.camera_alt, title: 'Subir selfie', uploadedTitle: 'Selfie cargada', sub: 'Toca para elegir una foto',
          image: _selfieImg, carpeta: 'selfies', onPicked: _handleSelfie,
          scanning: _selfieScanning, scanningLabel: 'Comparando rostro con documento mediante IA…',
          done: _selfieOk, doneLabel: '¡Identidad verificada! Coincidencia facial confirmada',
        ),
        const SizedBox(height: 14),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            width: 22, height: 22,
            child: Checkbox(
              value: _aceptaTerminos, onChanged: (v) => setState(() => _aceptaTerminos = v ?? false),
              activeColor: AppColors.navy, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Wrap(children: [
                Text('Acepto los ', style: TextStyle(fontSize: 11.5, color: AppColors.grisM)),
                InkWell(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LegalScreen(esTerminos: true))),
                  child: Text('Términos de Uso', style: TextStyle(fontSize: 11.5, color: AppColors.blue, fontWeight: FontWeight.w700)),
                ),
                Text(' y la ', style: TextStyle(fontSize: 11.5, color: AppColors.grisM)),
                InkWell(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LegalScreen(esTerminos: false))),
                  child: Text('Política de Privacidad', style: TextStyle(fontSize: 11.5, color: AppColors.blue, fontWeight: FontWeight.w700)),
                ),
              ]),
            ),
          ),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: AppButton(title: '← Atrás', variant: AppButtonVariant.ghost, onPressed: () => setState(() => _step = 2))),
          const SizedBox(width: 8),
          Expanded(flex: 2, child: AppButton(title: 'Crear cuenta', onPressed: (_selfieOk && _aceptaTerminos) ? _finalizarRegistro : null, loading: _submitting)),
        ]),
      ],
    );
  }

  Widget _roleCard(IconData icon, String label, String sub, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: selected ? AppColors.navy : AppColors.gris100, width: 2),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          color: selected ? const Color(0xFFEEF3F8) : null,
        ),
        child: Column(children: [
          Icon(icon, size: 24, color: selected ? AppColors.navy : AppColors.grisM),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: selected ? AppColors.navy : AppColors.grisM)),
          const SizedBox(height: 2),
          Text(sub, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: AppColors.grisM)),
        ]),
      ),
    );
  }
}
