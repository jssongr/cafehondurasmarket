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
import '../../widgets/verification_banner.dart';
import '../../utils/accion.dart';
import '../../utils/format.dart';

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

  /// Aceptar un viaje compromete el camión a una ruta y a un precio, así que
  /// se confirma antes. Un toque por error en una lista de tarjetas es fácil.
  Future<void> _aceptar(Carga c, Usuario yo) async {
    if (!await _cuentaLista(yo)) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Aceptar este viaje?'),
        content: Text(
          '${c.tipoCarga} · ${c.peso.toStringAsFixed(0)} ${c.unidadPeso}\n'
          '${c.ciudadOrigen}, ${c.paisOrigen} → ${c.ciudadDestino}, ${c.paisDestino}\n'
          'Recogida: ${c.fecha}\n\n'
          'Te comprometés por ${fmtMoneda(c.presupuesto)}. Se genera el contrato y '
          'el cliente queda notificado.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Aceptar viaje')),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    final app = context.read<AppState>();
    try {
      await app.asignarCarga(c.id, yo.id, yo.nombre, c.presupuesto!);
      await app.abrirOCrearConvo(c, yo.id, TipoUsuario.transportista);
      if (!mounted) return;
      app.showToast('¡Viaje aceptado! Coordina la recogida en Mensajes.');
      context.read<TabShellController>().goTo(Pestana.propias);
    } catch (e) {
      if (!mounted) return;
      // Lo más común acá es que otro transportista la haya tomado primero,
      // y antes eso no decía absolutamente nada.
      _aviso('No se pudo aceptar el viaje',
          'Puede que otro transportista la haya tomado antes que vos. Actualizá la '
          'lista y revisá.\n\n${mensajeDeError(e)}');
    }
  }

  Future<void> _cotizar(Carga c, Usuario yo) async {
    if (!await _cuentaLista(yo)) return;
    final app = context.read<AppState>();
    try {
      final convoId = await app.abrirOCrearConvo(c, yo.id, TipoUsuario.transportista);
      if (!mounted) return;
      openChat(context, convoId);
    } catch (e) {
      if (!mounted) return;
      _aviso('No se pudo abrir la conversación', mensajeDeError(e));
    }
  }

  /// La base rechaza estas acciones si la cuenta no está aprobada. Decirlo acá
  /// evita que la persona toque el botón y no pase nada visible.
  Future<bool> _cuentaLista(Usuario yo) async {
    if (yo.verificado) return true;
    await _aviso('Tu cuenta todavía está en revisión',
        'Podés mirar el mercado, pero para aceptar o cotizar cargas hace falta que un '
        'administrador apruebe tus documentos. Te avisamos apenas quede lista.');
    return false;
  }

  Future<void> _aviso(String titulo, String texto) => showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(titulo),
          content: Text(texto),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Entendido'))],
        ),
      );

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
        const VerificationBanner(),
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
                Expanded(child: Text('Ocultar mercancía peligrosa', style: TextStyle(fontSize: 12, color: AppColors.grisM))),
              ]),
            ),
            if (_paisOrigen.isNotEmpty || _paisDestino.isNotEmpty || _tipoCarga.isNotEmpty || _buscar.isNotEmpty || _ocultarPeligrosas)
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () => setState(() { _paisOrigen = ''; _paisDestino = ''; _tipoCarga = ''; _buscar = ''; _buscarCtrl.clear(); _ocultarPeligrosas = false; }),
                  child: Text('Limpiar filtros', style: TextStyle(fontSize: 12, color: AppColors.blue, fontWeight: FontWeight.w700)),
                ),
              ),
          ]),
        ),
        if (res.isEmpty)
          EmptyState(
            icon: Icons.search_off,
            title: 'Ninguna carga coincide con esos filtros',
            sub: 'Probá quitando alguno, o revisá más tarde: las cargas van apareciendo a lo largo del día.',
            accion: 'Quitar los filtros',
            onAccion: () => setState(() {
              _paisOrigen = '';
              _paisDestino = '';
              _tipoCarga = '';
              _buscar = '';
              _buscarCtrl.clear();
              _ocultarPeligrosas = false;
            }),
          ),
        for (final c in res)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: CargaMarketCard(
              carga: c,
              cliente: app.perfilDe(c.clienteId),
              historial: app.historial,
              onPressed: () => openCargaDetail(context, c.id),
              onAceptar: () => _aceptar(c, yo),
              onCotizar: () => _cotizar(c, yo),
            ),
          ),
      ],
    );
  }
}
