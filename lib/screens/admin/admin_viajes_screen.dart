import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../navigation/app_routes.dart';
import '../../state/app_state.dart';
import '../../theme/theme.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/carga_list_item.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/mapa_flota.dart';
import '../../widgets/screen.dart';

class AdminViajesScreen extends StatefulWidget {
  const AdminViajesScreen({super.key});

  @override
  State<AdminViajesScreen> createState() => _AdminViajesScreenState();
}

class _AdminViajesScreenState extends State<AdminViajesScreen> {
  final _busquedaCtrl = TextEditingController();
  String _busqueda = '';
  EstadoCarga? _filtro;

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final enTransito = app.cargas.where((c) => c.estado == EstadoCarga.enTransito).toList();

    final q = _busqueda.trim().toLowerCase();
    final lista = app.cargas.where((c) {
      if (_filtro != null && c.estado != _filtro) return false;
      if (q.isEmpty) return true;
      return c.cliente.toLowerCase().contains(q) ||
          (c.transportistaNombre ?? '').toLowerCase().contains(q) ||
          c.tipoCarga.toLowerCase().contains(q) ||
          c.ciudadOrigen.toLowerCase().contains(q) ||
          c.ciudadDestino.toLowerCase().contains(q) ||
          c.paisOrigen.toLowerCase().contains(q) ||
          c.paisDestino.toLowerCase().contains(q);
    }).toList()
      ..sort((a, b) => b.id.compareTo(a.id));

    return Screen(
      title: 'Viajes',
      subtitle: enTransito.isEmpty
          ? '${app.cargas.length} viajes en total'
          : '${enTransito.length} en ruta ahora · ${app.cargas.length} en total',
      children: [
        MapaFlota(
          cargas: enTransito,
          onTocarCarga: (c) => openCargaDetail(context, c.id),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (enTransito.isNotEmpty) ...[
          const Text('EN RUTA AHORA',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.blue, letterSpacing: 0.4)),
          const SizedBox(height: 8),
          for (final c in enTransito)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: InkWell(
                onTap: () => openCargaDetail(context, c.id),
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppRadius.md), boxShadow: cardShadow),
                  child: Row(children: [
                    Icon(Icons.local_shipping,
                        size: 18,
                        color: c.lat == null ? AppColors.grisM : AppColors.blue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('${c.transportistaNombre ?? "Sin asignar"} · ${c.tipoCarga}',
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.navy)),
                        const SizedBox(height: 2),
                        Text('${c.ciudadOrigen} → ${c.ciudadDestino} · ${frescuraGps(c)}',
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, color: AppColors.grisM)),
                      ]),
                    ),
                    Text('${c.progreso.round()}%',
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.blue)),
                  ]),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
        ],
        const Text('TODOS LOS VIAJES',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.blue, letterSpacing: 0.4)),
        const SizedBox(height: 8),
        AppTextField(
          placeholder: 'Buscar por cliente, transportista, carga o ciudad',
          controller: _busquedaCtrl,
          onChanged: (v) => setState(() => _busqueda = v),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _chip('Todos', _filtro == null, () => setState(() => _filtro = null)),
            for (final e in EstadoCarga.values)
              _chip(badgeLabels[e.value] ?? e.value, _filtro == e,
                  () => setState(() => _filtro = _filtro == e ? null : e)),
          ]),
        ),
        const SizedBox(height: AppSpacing.md),
        if (lista.isEmpty)
          const EmptyState(icon: Icons.local_shipping_outlined, title: 'Sin resultados', sub: 'Probá con otro texto o quitá los filtros'),
        for (final c in lista)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: CargaListItem(
              carga: c,
              subtitle: '${c.cliente} → ${c.transportistaNombre ?? "sin asignar"}',
              onPressed: () => openCargaDetail(context, c.id),
            ),
          ),
      ],
    );
  }

  Widget _chip(String label, bool on, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
            decoration: BoxDecoration(
              color: on ? AppColors.navy : AppColors.gris100,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(label,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: on ? Colors.white : AppColors.grisM)),
          ),
        ),
      );
}
