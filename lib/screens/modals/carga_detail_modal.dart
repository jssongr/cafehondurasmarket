import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/theme.dart';
import '../../utils/format.dart';
import '../../widgets/app_button.dart';
import '../../widgets/avatar.dart';
import '../../widgets/badge.dart';
import '../../widgets/detail_row.dart';
import '../../widgets/modal_header.dart';
import '../../widgets/stars.dart';
import '../messages/chat_screen.dart';

class CargaDetailModal extends StatelessWidget {
  final int cargaId;
  const CargaDetailModal({super.key, required this.cargaId});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final yo = app.usuario!;
    final c = app.cargas.firstWhere((x) => x.id == cargaId);
    final pub = app.usuarios.firstWhere((u) => u.id == c.clienteId, orElse: () => app.usuarios.first);
    final puedeContactar = yo.tipo == TipoUsuario.cliente ? c.clienteId != yo.id : true;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ModalHeader(title: c.tipoCarga, badge: AppBadge(tone: c.estado.value), onClose: () => Navigator.of(context).pop()),
            Container(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              margin: const EdgeInsets.only(bottom: 4),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.gris100))),
              child: Row(children: [
                Avatar(uri: pub.selfie, tipo: TipoUsuario.cliente, size: 40),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(c.cliente, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.navy)),
                    const SizedBox(height: 4),
                    Row(children: [
                      AppBadge(tone: pub.verificado ? 'verificado' : 'sinVerificar', label: pub.verificado ? 'Verificado' : 'Sin verificar'),
                      const SizedBox(width: 6),
                      Stars(value: avgRating(app.historial, usuarioId: pub.id, tipo: pub.tipo)),
                    ]),
                  ]),
                ),
              ]),
            ),
            if (c.contrato != null) DetailRow(label: 'Contrato digital', value: c.contrato!.ambosFirmaron ? 'Firmado por ambas partes' : 'Pendiente de firma'),
            DetailRow(label: 'Ruta', value: '${c.ciudadOrigen} → ${c.ciudadDestino}'),
            DetailRow(label: 'Peso', value: '${c.peso} ${c.unidadPeso}'),
            DetailRow(label: 'Vehículo requerido', value: c.vehiculoReq),
            DetailRow(label: 'Fecha de recogida', value: c.fecha),
            DetailRow(
              label: 'Presupuesto',
              value: c.precioAcordado != null ? fmtMoneda(c.precioAcordado) : (c.presupuesto != null ? fmtMoneda(c.presupuesto) : 'Abierto a cotización'),
              valueStyle: const TextStyle(fontSize: 17, color: AppColors.blue, fontWeight: FontWeight.w700),
            ),
            if (c.transportistaNombre != null) DetailRow(label: 'Transportista', value: c.transportistaNombre!),
            if (c.descripcion.isNotEmpty) DetailRow(label: 'Descripción', value: c.descripcion),
            if (puedeContactar && c.estado != EstadoCarga.cancelada)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.lg),
                child: AppButton(
                  title: 'Contactar', fullWidth: true,
                  onPressed: () {
                    final yoTipo = yo.tipo == TipoUsuario.cliente ? TipoUsuario.cliente : TipoUsuario.transportista;
                    final convoId = app.abrirOCrearConvo(c, yo.id, yoTipo);
                    Navigator.of(context).pop();
                    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (_) => ChatScreen(convoId: convoId)));
                  },
                ),
              ),
          ]),
        ),
      ),
    );
  }
}
