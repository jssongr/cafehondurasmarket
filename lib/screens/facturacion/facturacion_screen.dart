import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/constants.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/theme.dart';
import '../../utils/format.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/screen.dart';
import '../../widgets/stat_tile.dart';

class FacturacionScreen extends StatelessWidget {
  final bool modoAdmin;
  final bool showBack;
  const FacturacionScreen({super.key, this.modoAdmin = false, this.showBack = false});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final yo = app.usuario!;
    final mias = modoAdmin
        ? app.facturas
        : app.facturas.where((f) => yo.tipo == TipoUsuario.cliente ? f.clienteId == yo.id : f.transportistaId == yo.id).toList();
    final totalComision = mias.fold<double>(0, (a, f) => a + f.comision);

    return Screen(
      title: 'Facturación',
      subtitle: modoAdmin ? 'NexCarg — Todas las facturas' : 'NexCarg — ${yo.subtipo}',
      onBack: showBack ? () => Navigator.of(context).pop() : null,
      children: [
        if (modoAdmin)
          Row(children: [
            StatTile(label: 'Facturas emitidas', value: '${mias.length}', sub: 'total', icon: Icons.receipt, accent: AppColors.amber),
            const SizedBox(width: 12),
            StatTile(label: 'Ingresos comisión', value: fmtMoneda(totalComision), sub: '$comisionTexto% por viaje', icon: Icons.attach_money, accent: AppColors.verde),
          ]),
        if (mias.isEmpty)
          const EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'Sin facturas todavía',
            sub: 'Se generan solas al liberarse el pago de cada viaje entregado.',
          ),
        for (final f in mias)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: cardShadow),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(color: AppColors.gris50, borderRadius: BorderRadius.circular(AppRadius.md)),
                alignment: Alignment.center,
                child: Icon(tci[f.tipoCarga] ?? Icons.receipt_outlined, size: 20, color: AppColors.navy),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${f.numero} · ${f.tipoCarga}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.navy)),
                  Text(f.ruta, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: AppColors.grisM)),
                  Text(f.fecha, style: TextStyle(fontSize: 11, color: AppColors.grisM)),
                  if (modoAdmin) Text('${f.cliente} → ${f.transportista}', style: TextStyle(fontSize: 11, color: AppColors.grisM)),
                  if (!modoAdmin && yo.tipo == TipoUsuario.transportista)
                    Text('Bruto ${fmtMoneda(f.monto)} − comisión $comisionTexto% (${fmtMoneda(f.comision)})', style: TextStyle(fontSize: 11, color: AppColors.grisM)),
                ]),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(
                  modoAdmin ? fmtMoneda(f.comision) : fmtMoneda(yo.tipo == TipoUsuario.transportista ? f.montoTransportista : f.monto),
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.blue),
                ),
                Text(modoAdmin ? 'comisión' : (yo.tipo == TipoUsuario.transportista ? 'neto recibido' : 'total pagado'), style: TextStyle(fontSize: 9.5, color: AppColors.grisM)),
              ]),
            ]),
          ),
      ],
    );
  }
}
