import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/constants.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/theme.dart';
import '../../utils/format.dart';
import '../../widgets/app_button.dart';
import '../../widgets/badge.dart';
import '../../widgets/detail_row.dart';
import '../../widgets/modal_header.dart';

class ContratoModal extends StatelessWidget {
  final int cargaId;
  const ContratoModal({super.key, required this.cargaId});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final yo = app.usuario!;
    final c = app.cargas.firstWhere((x) => x.id == cargaId);
    if (c.contrato == null) return const SizedBox.shrink();
    final contrato = c.contrato!;
    final yaFirme = yo.tipo == TipoUsuario.cliente ? contrato.firmaCliente : contrato.firmaTransportista;
    final ambos = contrato.ambosFirmaron;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ModalHeader(
              title: 'Contrato de transporte',
              badge: AppBadge(tone: ambos ? 'verificado' : 'asignada', label: ambos ? 'Firmado por ambas partes' : 'Pendiente de firma'),
              onClose: () => Navigator.of(context).pop(),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(AppRadius.lg)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _p('Contrato digital generado por NexCarg entre ${c.cliente} ("el Cliente") y ${c.transportistaNombre} ("el Transportista") '
                    'para el transporte de ${c.tipoCarga} (${c.peso} ${c.unidadPeso}) desde ${c.ciudadOrigen}, ${c.paisOrigen} hasta ${c.ciudadDestino}, ${c.paisDestino}, '
                    'con fecha de recogida ${c.fecha}.'),
                const SizedBox(height: 10),
                // El contrato describe el procedimiento tal como ocurre hoy: el
                // depósito se hace por fuera y NexCarg lo confirma a mano. Poner
                // "escrow automático" sería prometer algo que todavía no pasa.
                _p('El monto acordado es de ${fmtMoneda(c.precioAcordado)}. El Cliente lo deposita en la cuenta que NexCarg le indica, '
                    'y NexCarg lo retiene en garantía. El Transportista queda habilitado para iniciar el viaje únicamente después de que '
                    'NexCarg confirme la recepción del depósito.'),
                const SizedBox(height: 10),
                _p('El monto retenido se libera al Transportista una vez que la entrega quede probada con fotografía y firma de quien recibe. '
                    'NexCarg retiene una comisión de servicio del $comisionTexto% sobre el monto del viaje.'),
                const SizedBox(height: 10),
                _p('Ambas partes se comprometen a coordinar la recogida y entrega dentro de los plazos acordados, y a calificarse mutuamente al finalizar el viaje.'),
              ]),
            ),
            DetailRow(label: 'Cliente', value: contrato.firmaCliente ? 'Firmado ${fmtTime(contrato.fechaCliente!)}' : 'Sin firmar'),
            DetailRow(label: 'Transportista', value: contrato.firmaTransportista ? 'Firmado ${fmtTime(contrato.fechaTransportista!)}' : 'Sin firmar'),
            if (!yaFirme)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.lg),
                child: AppButton(title: 'Firmar contrato', fullWidth: true, onPressed: () => app.firmarContrato(c.id, yo.tipo)),
              ),
            if (yaFirme && !ambos)
              Padding(
                padding: EdgeInsets.only(top: AppSpacing.lg),
                child: Text('Ya firmaste. Esperando la firma de la otra parte.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.grisM, fontSize: 12)),
              ),
          ]),
        ),
      ),
    );
  }

  Widget _p(String t) => Text(t, style: TextStyle(fontSize: 12.5, height: 1.45, color: AppColors.texto));
}
