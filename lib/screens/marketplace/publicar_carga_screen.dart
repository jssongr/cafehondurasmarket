import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/constants.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/theme.dart';
import '../../utils/format.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/screen.dart';
import '../../widgets/select_field.dart';

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
  String _paisDestino = paises[1];
  late String _ciudadDestino = ciudades[paises[1]]![0];
  final _fechaCtrl = TextEditingController();
  String _vehiculoReq = tiposVehiculo[0];
  bool _abierto = false;
  final _presupuestoCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();

  void _submit() {
    if (_pesoCtrl.text.isEmpty || _fechaCtrl.text.isEmpty) {
      _alert('Campos requeridos', 'Peso y fecha de recogida son obligatorios.');
      return;
    }
    if (!_abierto && _presupuestoCtrl.text.isEmpty) {
      _alert('Campos requeridos', "Indica un presupuesto o activa 'Abierto a cotizaciones'.");
      return;
    }
    final app = context.read<AppState>();
    final yo = app.usuario!;
    app.publicarCarga(Carga(
      id: uid(), clienteId: yo.id, cliente: yo.nombre, tipoCarga: _tipoCarga,
      peso: double.tryParse(_pesoCtrl.text) ?? 0, unidadPeso: _unidadPeso,
      paisOrigen: _paisOrigen, ciudadOrigen: _ciudadOrigen, paisDestino: _paisDestino, ciudadDestino: _ciudadDestino,
      fecha: _fechaCtrl.text, vehiculoReq: _vehiculoReq,
      presupuesto: _abierto ? null : double.tryParse(_presupuestoCtrl.text),
      descripcion: _descripcionCtrl.text, estado: EstadoCarga.publicada,
    ));
    app.showToast('¡Carga publicada! Los transportistas ya pueden verla.');
    setState(() {
      _pesoCtrl.clear();
      _fechaCtrl.clear();
      _presupuestoCtrl.clear();
      _descripcionCtrl.clear();
    });
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
            const SizedBox(height: AppSpacing.md),
            SelectField(label: 'País de origen', value: _paisOrigen, options: paises, onChanged: (v) => setState(() { _paisOrigen = v; _ciudadOrigen = ciudades[v]![0]; })),
            SelectField(label: 'Ciudad de origen', value: _ciudadOrigen, options: ciudades[_paisOrigen]!, onChanged: (v) => setState(() => _ciudadOrigen = v)),
            SelectField(label: 'País de destino', value: _paisDestino, options: paises, onChanged: (v) => setState(() { _paisDestino = v; _ciudadDestino = ciudades[v]![0]; })),
            SelectField(label: 'Ciudad de destino', value: _ciudadDestino, options: ciudades[_paisDestino]!, onChanged: (v) => setState(() => _ciudadDestino = v)),
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
            AppButton(title: 'Publicar carga', icon: const Icon(Icons.rocket_launch, size: 16, color: Colors.white), onPressed: _submit, fullWidth: true),
          ]),
        ),
      ],
    );
  }
}
