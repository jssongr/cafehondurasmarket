import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/modal_header.dart';
import '../../widgets/star_picker.dart';

class CalificarModal extends StatefulWidget {
  final int historialId;
  const CalificarModal({super.key, required this.historialId});

  @override
  State<CalificarModal> createState() => _CalificarModalState();
}

class _CalificarModalState extends State<CalificarModal> {
  int _estrellas = 0;
  final _comentarioCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final yo = app.usuario!;
    final h = app.historial.firstWhere((x) => x.id == widget.historialId);
    final contraparte = yo.tipo == TipoUsuario.cliente ? h.transportista : h.cliente;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ModalHeader(title: 'Calificar a $contraparte', onClose: () => Navigator.of(context).pop()),
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Text('${h.tipoCarga} · ${h.ruta}', style: TextStyle(fontSize: 12, color: AppColors.grisM)),
            ),
            StarPicker(value: _estrellas, onChanged: (v) => setState(() => _estrellas = v)),
            AppTextField(label: 'Comentario (opcional)', placeholder: '¿Cómo fue tu experiencia?', controller: _comentarioCtrl, multiline: true),
            AppButton(
              title: 'Enviar calificación', fullWidth: true,
              onPressed: _estrellas == 0 ? null : () {
                app.calificar(h.id, yo.tipo, _estrellas, _comentarioCtrl.text);
                app.showToast('¡Gracias por tu calificación!');
                Navigator.of(context).pop();
              },
            ),
          ]),
        ),
      ),
    );
  }
}
