import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/constants.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/theme.dart';
import '../../utils/format.dart';
import '../../utils/accion.dart';
import '../../widgets/app_button.dart';
import '../../widgets/badge.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/panel.dart';
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
    // Lo que NexCarg todavía le debe a los transportistas. Es la cifra que el
    // administrador necesita ver primero: son entregas ya probadas.
    final porPagar = mias.where((f) => f.pagadoAt == null).toList();
    final montoPorPagar = porPagar.fold<double>(0, (a, f) => a + f.montoTransportista);

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
        if (modoAdmin && porPagar.isNotEmpty)
          Panel(
            filo: AppColors.amber,
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg + 4, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg),
            child: Row(children: [
              Icon(Icons.payments_outlined, size: 19, color: AppColors.amberText),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Por transferir a transportistas: ${fmtMoneda(montoPorPagar)}',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.navy)),
                  Text(
                      porPagar.length == 1
                          ? '1 entrega probada sin liquidar.'
                          : '${porPagar.length} entregas probadas sin liquidar.',
                      style: TextStyle(fontSize: 12, color: AppColors.grisM)),
                ]),
              ),
            ]),
          ),
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
                const SizedBox(height: 6),
                // "Entregado" y "ya le pagamos" son dos cosas distintas, y
                // antes la app no distinguía entre ellas.
                if (f.pagadoAt != null)
                  AppBadge(tone: 'entregada', label: 'Transferido')
                else if (modoAdmin)
                  AppButton(
                    title: 'Marcar transferido',
                    size: AppButtonSize.sm,
                    variant: AppButtonVariant.outline,
                    onPressed: () => _marcarPagada(context, app, f),
                  )
                else if (yo.tipo == TipoUsuario.transportista)
                  AppBadge(tone: 'asignada', label: 'Por transferir'),
              ]),
            ]),
          ),
      ],
    );
  }

  Future<void> _marcarPagada(BuildContext context, AppState app, Factura f) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Marcar como transferido?'),
        content: Text(
          '¿Ya le transferiste ${fmtMoneda(f.montoTransportista)} a ${f.transportista} '
          'por la factura ${f.numero}?\n\n'
          'Se le va a notificar que el pago salió.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sí, ya transferí')),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await ejecutar(
      context,
      () => app.marcarFacturaPagada(f.id),
      exito: 'Factura marcada como transferida',
      fallo: 'No se pudo marcar la factura',
    );
  }
}
