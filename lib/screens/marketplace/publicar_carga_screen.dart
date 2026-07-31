import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/constants.dart';
import '../../services/storage_service.dart';
import '../../state/app_state.dart';
import '../../theme/theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_image.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/screen.dart';
import '../../widgets/select_field.dart';
import '../../widgets/upload_zone.dart';

class PublicarCargaScreen extends StatefulWidget {
  const PublicarCargaScreen({super.key});

  @override
  State<PublicarCargaScreen> createState() => _PublicarCargaScreenState();
}

class _PublicarCargaScreenState extends State<PublicarCargaScreen> {
  String _tipoCarga = tiposCarga[0];
  final _pesoCtrl = TextEditingController();
  String _unidadPeso = 'ton';
  String _paisOrigen = paises[0];
  late String _ciudadOrigen = ciudades[paises[0]]![0];
  final _direccionOrigenCtrl = TextEditingController();
  String _paisDestino = paises[1];
  late String _ciudadDestino = ciudades[paises[1]]![0];
  final _direccionDestinoCtrl = TextEditingController();
  final _fechaCtrl = TextEditingController();
  String _vehiculoReq = tiposVehiculo[0];
  bool _abierto = false;
  final _presupuestoCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _volumenCtrl = TextEditingController();
  final _dimensionesCtrl = TextEditingController();
  bool _peligrosa = false;
  final List<String> _fotos = [];
  String? _documento;
  bool _agregandoFoto = false;
  bool _publicando = false;

  Future<void> _agregarFoto() async {
    setState(() => _agregandoFoto = true);
    try {
      final url = await pickAndUploadImage(carpeta: 'cargas');
      if (url != null) setState(() => _fotos.add(url));
    } finally {
      if (mounted) setState(() => _agregandoFoto = false);
    }
  }

  Future<void> _submit() async {
    if (_pesoCtrl.text.isEmpty || _fechaCtrl.text.isEmpty) {
      _alert('Campos requeridos', 'Peso y fecha de recogida son obligatorios.');
      return;
    }
    if (!_abierto && _presupuestoCtrl.text.isEmpty) {
      _alert('Campos requeridos', "Indica un presupuesto o activa 'Abierto a cotizaciones'.");
      return;
    }
    setState(() => _publicando = true);
    final app = context.read<AppState>();
    final yo = app.usuario!;
    try {
      await app.publicarCarga(
        clienteId: yo.id, cliente: yo.nombre, tipoCarga: _tipoCarga,
        peso: double.tryParse(_pesoCtrl.text) ?? 0, unidadPeso: _unidadPeso,
        paisOrigen: _paisOrigen, ciudadOrigen: _ciudadOrigen,
        direccionOrigen: _direccionOrigenCtrl.text.isEmpty ? null : _direccionOrigenCtrl.text,
        paisDestino: _paisDestino, ciudadDestino: _ciudadDestino,
        direccionDestino: _direccionDestinoCtrl.text.isEmpty ? null : _direccionDestinoCtrl.text,
        fecha: _fechaCtrl.text, vehiculoReq: _vehiculoReq,
        presupuesto: _abierto ? null : double.tryParse(_presupuestoCtrl.text),
        descripcion: _descripcionCtrl.text,
        volumen: double.tryParse(_volumenCtrl.text),
        dimensiones: _dimensionesCtrl.text.isEmpty ? null : _dimensionesCtrl.text,
        peligrosa: _peligrosa,
        fotos: List.of(_fotos),
        documentos: _documento != null ? [_documento!] : [],
      );
      if (!mounted) return;
      app.showToast('¡Carga publicada! Los transportistas ya pueden verla.');
      setState(() {
        _pesoCtrl.clear();
        _fechaCtrl.clear();
        _presupuestoCtrl.clear();
        _descripcionCtrl.clear();
        _volumenCtrl.clear();
        _dimensionesCtrl.clear();
        _direccionOrigenCtrl.clear();
        _direccionDestinoCtrl.clear();
        _peligrosa = false;
        _fotos.clear();
        _documento = null;
      });
    } finally {
      if (mounted) setState(() => _publicando = false);
    }
  }

  void _alert(String title, String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Entendido'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Screen(
      title: 'Publicar Carga',
      subtitle: 'Completa los datos de tu envío',
      children: [
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SelectField(label: 'Tipo de mercancía', value: _tipoCarga, options: tiposCarga, onChanged: (v) => setState(() => _tipoCarga = v)),
            SelectField(label: 'Vehículo requerido', value: _vehiculoReq, options: tiposVehiculo, onChanged: (v) => setState(() => _vehiculoReq = v)),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 2, child: AppTextField(label: 'Peso', placeholder: '15', controller: _pesoCtrl, keyboardType: TextInputType.number)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('UNIDAD', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.blue, letterSpacing: 0.4)),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(color: AppColors.gris100, borderRadius: BorderRadius.circular(AppRadius.md)),
                    child: Row(children: [
                      for (final u in ['ton', 'kg'])
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _unidadPeso = u),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(color: _unidadPeso == u ? AppColors.navy : null, borderRadius: BorderRadius.circular(AppRadius.sm)),
                              alignment: Alignment.center,
                              child: Text(u, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _unidadPeso == u ? Colors.white : AppColors.grisM)),
                            ),
                          ),
                        ),
                    ]),
                  ),
                ]),
              ),
            ]),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: AppTextField(label: 'Volumen (m³)', placeholder: '12', controller: _volumenCtrl, keyboardType: TextInputType.number)),
              const SizedBox(width: 10),
              Expanded(child: AppTextField(label: 'Dimensiones (L×A×A)', placeholder: '2.4 × 1.2 × 1.5 m', controller: _dimensionesCtrl)),
            ]),
            InkWell(
              onTap: () => setState(() => _peligrosa = !_peligrosa),
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(children: [
                  Switch(value: _peligrosa, onChanged: (v) => setState(() => _peligrosa = v), activeTrackColor: AppColors.rojo),
                  const SizedBox(width: 10),
                  const Expanded(child: Text('Mercancía peligrosa (requiere manejo especial)', style: TextStyle(fontSize: 12, color: AppColors.grisM))),
                ]),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SelectField(label: 'País de origen', value: _paisOrigen, options: paises, onChanged: (v) => setState(() { _paisOrigen = v; _ciudadOrigen = ciudades[v]![0]; })),
            SelectField(label: 'Ciudad de origen', value: _ciudadOrigen, options: ciudades[_paisOrigen]!, onChanged: (v) => setState(() => _ciudadOrigen = v)),
            AppTextField(label: 'Dirección exacta de recogida (opcional)', placeholder: 'Ej. Bodega 4, Zona Industrial', controller: _direccionOrigenCtrl),
            SelectField(label: 'País de destino', value: _paisDestino, options: paises, onChanged: (v) => setState(() { _paisDestino = v; _ciudadDestino = ciudades[v]![0]; })),
            SelectField(label: 'Ciudad de destino', value: _ciudadDestino, options: ciudades[_paisDestino]!, onChanged: (v) => setState(() => _ciudadDestino = v)),
            AppTextField(label: 'Dirección exacta de entrega (opcional)', placeholder: 'Ej. Col. Miraflores, Calle Principal', controller: _direccionDestinoCtrl),
            AppTextField(label: 'Fecha de recogida (AAAA-MM-DD)', placeholder: '2026-08-15', controller: _fechaCtrl),
            AppTextField(label: 'Presupuesto (USD)', placeholder: '1200', controller: _presupuestoCtrl, keyboardType: TextInputType.number, enabled: !_abierto),
            InkWell(
              onTap: () => setState(() => _abierto = !_abierto),
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(children: [
                  Switch(value: _abierto, onChanged: (v) => setState(() => _abierto = v), activeTrackColor: AppColors.amber),
                  const SizedBox(width: 10),
                  const Expanded(child: Text('Abierto a cotizaciones (sin precio fijo)', style: TextStyle(fontSize: 12, color: AppColors.grisM))),
                ]),
              ),
            ),
            AppTextField(label: 'Descripción', placeholder: 'Detalles de la carga, condiciones de manejo, etc.', controller: _descripcionCtrl, multiline: true),
            const Padding(
              padding: EdgeInsets.only(bottom: 5),
              child: Text('FOTOS DE LA CARGA (OPCIONAL)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.blue, letterSpacing: 0.4)),
            ),
            SizedBox(
              height: 84,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (var i = 0; i < _fotos.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          child: AppImage(path: _fotos[i], width: 84, height: 84, fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: 3, right: 3,
                          child: InkWell(
                            onTap: () => setState(() => _fotos.removeAt(i)),
                            child: Container(
                              width: 20, height: 20,
                              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                              child: const Icon(Icons.close, size: 13, color: Colors.white),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  InkWell(
                    onTap: _agregandoFoto ? null : _agregarFoto,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Container(
                      width: 84, height: 84,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.gris100, width: 2),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        color: AppColors.gris50,
                      ),
                      alignment: Alignment.center,
                      child: _agregandoFoto
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.add_a_photo_outlined, color: AppColors.grisM),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            UploadZone(
              icon: Icons.description_outlined,
              title: 'Subir documento (factura, permiso, etc.)', uploadedTitle: 'Documento adjuntado', sub: 'Opcional — toca para elegir una imagen',
              image: _documento, carpeta: 'cargas', onPicked: (p) => setState(() => _documento = p),
              scanning: false, done: false, doneLabel: '', scanningLabel: '',
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(title: 'Publicar carga', icon: const Icon(Icons.rocket_launch, size: 16, color: Colors.white), onPressed: _submit, loading: _publicando, fullWidth: true),
          ]),
        ),
      ],
    );
  }
}
