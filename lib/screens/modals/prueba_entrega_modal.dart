import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/storage_service.dart';
import '../../state/app_state.dart';
import '../../theme/theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/badge.dart';
import '../../widgets/firma_pad.dart';
import '../../widgets/modal_header.dart';
import '../../widgets/upload_zone.dart';

/// Lo que el transportista debe entregar para cerrar un viaje: foto de la carga
/// entregada, nombre de quien la recibe y su firma.
class PruebaEntregaModal extends StatefulWidget {
  final int cargaId;
  const PruebaEntregaModal({super.key, required this.cargaId});

  @override
  State<PruebaEntregaModal> createState() => _PruebaEntregaModalState();
}

class _PruebaEntregaModalState extends State<PruebaEntregaModal> {
  final _recibidoPorCtrl = TextEditingController();
  final _firma = FirmaPadController();
  String? _foto;
  String _err = '';
  bool _enviando = false;

  @override
  void dispose() {
    _recibidoPorCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirmar() async {
    if (_foto == null) {
      setState(() => _err = 'Subí una foto de la carga entregada.');
      return;
    }
    if (_recibidoPorCtrl.text.trim().isEmpty) {
      setState(() => _err = 'Escribí el nombre de quien recibe la carga.');
      return;
    }
    if (!_firma.tieneFirma) {
      setState(() => _err = 'Falta la firma de quien recibe.');
      return;
    }

    setState(() {
      _enviando = true;
      _err = '';
    });
    try {
      final png = await _firma.exportarPng();
      if (png == null) throw Exception('firma vacía');
      final firmaUrl = await uploadImageBytes(png, carpeta: 'entregas', filename: 'firma.png');
      if (!mounted) return;
      await context.read<AppState>().confirmarEntregaManual(
            widget.cargaId,
            pruebaFoto: _foto!,
            pruebaFirma: firmaUrl,
            recibidoPor: _recibidoPorCtrl.text.trim(),
          );
      if (!mounted) return;
      context.read<AppState>().showToast('Entrega confirmada — pago liberado');
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _enviando = false;
          _err = 'No se pudo confirmar la entrega: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final c = app.cargas.firstWhere((x) => x.id == widget.cargaId);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ModalHeader(
              title: 'Prueba de entrega',
              badge: const AppBadge(tone: 'enTransito', label: 'Paso final'),
              onClose: () => Navigator.of(context).pop(),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(AppRadius.lg)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${c.tipoCarga} · ${c.peso} ${c.unidadPeso}',
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.navy)),
                const SizedBox(height: 4),
                Text('Entrega en ${c.ciudadDestino}, ${c.paisDestino}',
                    style: TextStyle(fontSize: 12.5, color: AppColors.grisM)),
                const SizedBox(height: 8),
                Text(
                  'Esta constancia queda guardada en el viaje. Protege a ambas partes si después hay un reclamo por la entrega.',
                  style: TextStyle(fontSize: 12, color: AppColors.grisM, height: 1.45),
                ),
              ]),
            ),
            if (_err.isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(color: AppColors.rojoBg, borderRadius: BorderRadius.circular(AppRadius.md)),
                child: Row(children: [
                  Icon(Icons.error_outline, size: 16, color: AppColors.rojo),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_err, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.rojo))),
                ]),
              ),
            Text('Foto de la carga entregada',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.navy)),
            const SizedBox(height: 4),
            Text('Tomá una foto de la mercancía ya descargada en el destino.',
                style: TextStyle(fontSize: 12, color: AppColors.grisM)),
            const SizedBox(height: AppSpacing.sm),
            UploadZone(
              icon: Icons.photo_camera_outlined,
              title: 'Subir foto de la entrega',
              uploadedTitle: 'Foto cargada',
              sub: 'Tocá para elegir una imagen',
              image: _foto,
              carpeta: 'entregas',
              onPicked: (p) => setState(() => _foto = p),
              scanning: false,
              done: _foto != null,
              doneLabel: 'Foto adjuntada',
              scanningLabel: '',
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Recibido por',
              placeholder: 'Nombre de quien recibe la carga',
              controller: _recibidoPorCtrl,
              textCapitalization: TextCapitalization.words,
            ),
            Text('Firma de quien recibe',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.navy)),
            const SizedBox(height: AppSpacing.sm),
            FirmaPad(controller: _firma, onCambio: () => setState(() {})),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              title: 'Confirmar entrega y liberar pago',
              onPressed: _confirmar,
              loading: _enviando,
              fullWidth: true,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Al confirmar, el pago retenido se libera al transportista descontando la comisión de la plataforma.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.5, color: AppColors.grisM, height: 1.4),
            ),
          ]),
        ),
      ),
    );
  }
}
