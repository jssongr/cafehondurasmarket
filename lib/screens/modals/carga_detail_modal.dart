import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/theme.dart';
import '../../utils/accion.dart';
import '../../utils/format.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_image.dart';
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
    final pub = app.perfilDe(c.clienteId);
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
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.gris100))),
              child: Row(children: [
                Avatar(uri: pub?.selfie, tipo: TipoUsuario.cliente, size: 40),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(c.cliente, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.navy)),
                    const SizedBox(height: 4),
                    Row(children: [
                      AppBadge(tone: (pub?.verificado ?? false) ? 'verificado' : 'sinVerificar', label: (pub?.verificado ?? false) ? 'Verificado' : 'Sin verificar'),
                      const SizedBox(width: 6),
                      if (pub != null) Stars(value: avgRating(app.historial, usuarioId: pub.id, tipo: pub.tipo)),
                    ]),
                  ]),
                ),
              ]),
            ),
            if (c.contrato != null) DetailRow(label: 'Contrato digital', value: c.contrato!.ambosFirmaron ? 'Firmado por ambas partes' : 'Pendiente de firma'),
            DetailRow(label: 'Ruta', value: '${c.ciudadOrigen}, ${c.paisOrigen} → ${c.ciudadDestino}, ${c.paisDestino}'),
            if (c.direccionOrigen != null && c.direccionOrigen!.isNotEmpty) DetailRow(label: 'Dirección de recogida', value: c.direccionOrigen!),
            if (c.direccionDestino != null && c.direccionDestino!.isNotEmpty) DetailRow(label: 'Dirección de entrega', value: c.direccionDestino!),
            DetailRow(label: 'Peso', value: '${c.peso} ${c.unidadPeso}'),
            if (c.volumen != null) DetailRow(label: 'Volumen', value: '${c.volumen} m³'),
            if (c.dimensiones != null) DetailRow(label: 'Dimensiones', value: c.dimensiones!),
            DetailRow(label: 'Vehículo requerido', value: c.vehiculoReq),
            DetailRow(label: 'Fecha de recogida', value: c.fecha),
            if (c.peligrosa)
              DetailRow(
                label: 'Mercancía peligrosa',
                valueWidget: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.warning_amber_rounded, size: 15, color: AppColors.rojo),
                  SizedBox(width: 4),
                  Text('Sí, requiere manejo especial', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.rojo)),
                ]),
              ),
            DetailRow(
              label: 'Presupuesto',
              value: c.precioAcordado != null ? fmtMoneda(c.precioAcordado) : (c.presupuesto != null ? fmtMoneda(c.presupuesto) : 'Abierto a cotización'),
              valueStyle: TextStyle(fontSize: 17, color: AppColors.blue, fontWeight: FontWeight.w700),
            ),
            if (c.transportistaNombre != null) DetailRow(label: 'Transportista', value: c.transportistaNombre!),
            if (c.descripcion.isNotEmpty) DetailRow(label: 'Descripción', value: c.descripcion),
            if (c.fotos.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.only(top: AppSpacing.md, bottom: 8),
                child: Text('FOTOS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.blue, letterSpacing: 0.4)),
              ),
              SizedBox(
                height: 84,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final f in c.fotos)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ClipRRect(borderRadius: BorderRadius.circular(AppRadius.md), child: AppImage(path: f, width: 84, height: 84, fit: BoxFit.cover)),
                      ),
                  ],
                ),
              ),
            ],
            if (c.pruebaFoto != null || c.pruebaFirma != null) ...[
              Padding(
                padding: EdgeInsets.only(top: AppSpacing.md, bottom: 8),
                child: Text('PRUEBA DE ENTREGA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.blue, letterSpacing: 0.4)),
              ),
              if (c.recibidoPor != null) DetailRow(label: 'Recibido por', value: c.recibidoPor!),
              if (c.fechaEntrega != null) DetailRow(label: 'Fecha de entrega', value: fechaLarga(c.fechaEntrega!)),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (c.pruebaFoto != null)
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Carga entregada', style: TextStyle(fontSize: 11.5, color: AppColors.grisM)),
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: AppImage(path: c.pruebaFoto!, width: double.infinity, height: 120, fit: BoxFit.cover),
                      ),
                    ]),
                  ),
                if (c.pruebaFoto != null && c.pruebaFirma != null) const SizedBox(width: 10),
                if (c.pruebaFirma != null)
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Firma de quien recibió', style: TextStyle(fontSize: 11.5, color: AppColors.grisM)),
                      const SizedBox(height: 5),
                      Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: AppColors.gris100)),
                        clipBehavior: Clip.antiAlias,
                        child: AppImage(path: c.pruebaFirma!, width: double.infinity, height: 120, fit: BoxFit.contain),
                      ),
                    ]),
                  ),
              ]),
            ],
            if (puedeContactar && c.estado != EstadoCarga.cancelada)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.lg),
                child: AppButton(
                  title: 'Contactar', fullWidth: true,
                  onPressed: () async {
                    final yoTipo = yo.tipo == TipoUsuario.cliente ? TipoUsuario.cliente : TipoUsuario.transportista;
                    int? convoId;
                    final ok = await ejecutar(
                      context,
                      () async => convoId = await app.abrirOCrearConvo(c, yo.id, yoTipo),
                      fallo: 'No se pudo abrir la conversación',
                    );
                    if (!ok || convoId == null || !context.mounted) return;
                    Navigator.of(context).pop();
                    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (_) => ChatScreen(convoId: convoId!)));
                  },
                ),
              ),
          ]),
        ),
      ),
    );
  }
}
