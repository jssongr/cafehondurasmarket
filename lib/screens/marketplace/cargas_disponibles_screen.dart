import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/constants.dart';
import '../../models/models.dart';
import '../../navigation/app_routes.dart';
import '../../navigation/tab_shell.dart';
import '../../state/app_state.dart';
import '../../theme/theme.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/carga_market_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/screen.dart';
import '../../widgets/select_field.dart';

class CargasDisponiblesScreen extends StatefulWidget {
  const CargasDisponiblesScreen({super.key});

  @override
  State<CargasDisponiblesScreen> createState() => _CargasDisponiblesScreenState();
}

class _CargasDisponiblesScreenState extends State<CargasDisponiblesScreen> {
  String _paisOrigen = '';
  String _paisDestino = '';
  String _tipoCarga = '';
  final _buscarCtrl = TextEditingController();
  String _buscar = '';
  bool _ocultarPeligrosas = false;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final yo = app.usuario!;
    final res = app.cargas.where((c) {
      if (c.estado != EstadoCarga.publicada) return false;
      if (_paisOrigen.isNotEmpty && c.paisOrigen != _paisOrigen) return false;
      if (_paisDestino.isNotEmpty && c.paisDestino != _paisDestino) return false;
      if (_tipoCarga.isNotEmpty && c.tipoCarga != _tipoCarga) return false;
      if (_ocultarPeligrosas && c.peligrosa) return false;
      if (_buscar.isNotEmpty &&
          !c.cliente.toLowerCase().contains(_buscar.toLowerCase()) &&
          !c.tipoCarga.toLowerCase().contains(_buscar.toLowerCase())) return false;
      return true;
    }).toList();

    return Screen(
      title: 'Cargas Disponibles',
      subtitle: 'NexCarg — ${yo.subtipo}',
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: cardShadow),
          child: Column(children: [
            Row(children: [
              Expanded(child: SelectField(label: 'Origen', value: _paisOrigen, options: paises, onChanged: (v) => setState(() => _paisOrigen = v), placeholder: 'Todos')),
              const SizedBox(width: 10),
              Expanded(child: SelectField(label: 'Destino', value: _paisDestino, options: paises, onChanged: (v) => setState(() => _paisDestino = v), placeholder: 'Todos')),
            ]),
            SelectField(label: 'Tipo de carga', value: _tipoCarga, options: tiposCarga, onChanged: (v) => setState(() => _tipoCarga = v), placeholder: 'Todos'),
            AppTextField(label: 'Buscar', placeholder: 'Cliente, tipo de carga…', controller: _buscarCtrl, onChanged: (v) => setState(() => _buscar = v)),
            InkWell(
              onTap: () => setState(() => _ocultarPeligrosas = !_ocultarPeligrosas),
              child: Row(children: [
                Switch(value: _ocultarPeligrosas, onChanged: (v) => setState(() => _ocultarPeligrosas = v), activeTrackColor: AppColors.rojo),
                const SizedBox(width: 8),
                const Expanded(child: Text('Ocultar mercancía peligrosa', style: TextStyle(fontSize: 12, color: AppColors.grisM))),
              ]),
            ),
            if (_paisOrigen.isNotEmpty || _paisDestino.isNotEmpty || _tipoCarga.isNotEmpty || _buscar.isNotEmpty || _ocultarPeligrosas)
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () => setState(() { _paisOrigen = ''; _paisDestino = ''; _tipoCarga = ''; _buscar = ''; _buscarCtrl.clear(); _ocultarPeligrosas = false; }),
                  child: const Text('Limpiar filtros', style: TextStyle(fontSize: 12, color: AppColors.blue, fontWeight: FontWeight.w700)),
                ),
              ),
          ]),
        ),
        if (res.isEmpty) const EmptyState(icon: Icons.search, title: 'Sin cargas disponibles con esos filtros'),
        for (final c in res)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: CargaMarketCard(
              carga: c,
              cliente: app.usuarios.firstWhere((u) => u.id == c.clienteId),
              historial: app.historial,
              onPressed: () => openCargaDetail(context, c.id),
              onAceptar: () {
                app.asignarCarga(c.id, yo.id, yo.nombre, c.presupuesto!);
                app.abrirOCrearConvo(c, yo.id, TipoUsuario.transportista);
                app.addNotif(c.clienteId, 'sistema', 'Viaje aceptado', '${yo.nombre} aceptó transportar tu ${c.tipoCarga}.');
                app.showToast('¡Viaje aceptado! Coordina la recogida en Mensajes.');
                context.read<TabShellController>().goTo(2);
              },
              onCotizar: () {
                final convoId = app.abrirOCrearConvo(c, yo.id, TipoUsuario.transportista);
                openChat(context, convoId);
              },
            ),
          ),
      ],
    );
  }
}
