import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class NuevaContrasenaScreen extends StatefulWidget {
  const NuevaContrasenaScreen({super.key});

  @override
  State<NuevaContrasenaScreen> createState() => _NuevaContrasenaScreenState();
}

class _NuevaContrasenaScreenState extends State<NuevaContrasenaScreen> {
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String _err = '';
  bool _submitting = false;

  Future<void> _guardar() async {
    if (_passCtrl.text.length < 8) {
      setState(() => _err = 'La contraseña debe tener al menos 8 caracteres.');
      return;
    }
    if (_passCtrl.text != _confirmCtrl.text) {
      setState(() => _err = 'Las contraseñas no coinciden.');
      return;
    }
    setState(() { _submitting = true; _err = ''; });
    final err = await context.read<AppState>().actualizarContrasena(_passCtrl.text);
    if (!mounted) return;
    setState(() { _submitting = false; _err = err ?? ''; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.navy, AppColors.navyLight, AppColors.blue], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Container(
                    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppRadius.xl), boxShadow: floatingShadow),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: AppSpacing.xl),
                          color: AppColors.navy,
                          child: const Column(
                            children: [
                              Icon(Icons.lock_reset, size: 34, color: Colors.white),
                              SizedBox(height: 6),
                              Text('Nueva contraseña', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.4)),
                              SizedBox(height: 2),
                              Text('Elige una contraseña nueva para tu cuenta de NexCarg',
                                  textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Color(0xA6FFFFFF))),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (_err.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(color: AppColors.rojoBg, borderRadius: BorderRadius.circular(AppRadius.sm)),
                                  child: Row(children: [
                                    const Icon(Icons.warning, size: 14, color: AppColors.rojo),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(_err, style: const TextStyle(color: AppColors.rojo, fontSize: 12))),
                                  ]),
                                ),
                              AppTextField(label: 'Contraseña nueva', placeholder: 'Mínimo 8 caracteres', controller: _passCtrl, obscureText: true),
                              AppTextField(label: 'Confirmar contraseña', placeholder: '••••••', controller: _confirmCtrl, obscureText: true),
                              const SizedBox(height: 6),
                              AppButton(title: 'Guardar contraseña', onPressed: _guardar, loading: _submitting, fullWidth: true),
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
        ],
      ),
    );
  }
}
