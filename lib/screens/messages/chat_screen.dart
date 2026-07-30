import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/constants.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/theme.dart';
import '../../utils/format.dart';
import '../../widgets/stars.dart';

class ChatScreen extends StatefulWidget {
  final int convoId;
  const ChatScreen({super.key, required this.convoId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textoCtrl = TextEditingController();
  final _ofertaCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _showOferta = false;

  void _enviar() {
    if (_textoCtrl.text.trim().isEmpty) return;
    context.read<AppState>().enviarMensaje(widget.convoId, _textoCtrl.text.trim());
    _textoCtrl.clear();
    _scrollToEnd();
  }

  void _mandarOferta() {
    final val = double.tryParse(_ofertaCtrl.text);
    if (val == null || val < 1) return;
    context.read<AppState>().enviarOferta(widget.convoId, val);
    _ofertaCtrl.clear();
    setState(() => _showOferta = false);
    _scrollToEnd();
  }

  void _scrollToEnd() {
    Future.delayed(const Duration(milliseconds: 80), () {
      if (_scrollCtrl.hasClients) _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final yo = app.usuario!;
    final convo = app.convos.firstWhere((c) => c.id == widget.convoId);
    final otroId = convo.participantes.firstWhere((p) => p != yo.id, orElse: () => '');
    final otro = otroId.isEmpty ? null : app.usuarios.firstWhere((u) => u.id == otroId);
    final carga = app.cargas.where((c) => c.id == convo.cargaId).isNotEmpty ? app.cargas.firstWhere((c) => c.id == convo.cargaId) : null;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.navy,
        title: Text(otro?.nombre ?? 'Chat', style: const TextStyle(fontWeight: FontWeight.w700)),
        elevation: 0.5,
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (carga != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                color: AppColors.white,
                child: Row(children: [
                  Icon(tci[carga.tipoCarga] ?? Icons.inventory_2_outlined, size: 14, color: AppColors.navy),
                  const SizedBox(width: 8),
                  Expanded(child: Text('${carga.tipoCarga} · ${carga.paisOrigen} → ${carga.paisDestino}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, color: AppColors.navy, fontWeight: FontWeight.w600))),
                  if (otro != null) Stars(value: avgRating(app.historial, usuarioId: otro.id, tipo: otro.tipo)),
                ]),
              ),
            Expanded(
              child: convo.mensajes.isEmpty
                  ? const Center(child: Text('Envía un mensaje para coordinar el viaje', style: TextStyle(color: AppColors.grisM, fontSize: 13)))
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: convo.mensajes.length,
                      itemBuilder: (ctx, i) {
                        final m = convo.mensajes[i];
                        final mine = m.de == yo.id;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: m.esOferta ? _ofertaBubble(app, m, mine) : _textBubble(m, mine),
                        );
                      },
                    ),
            ),
            if (_showOferta)
              Container(
                padding: const EdgeInsets.all(10),
                color: AppColors.bg,
                child: Row(children: [
                  const Text('\$', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.navy)),
                  Expanded(
                    child: TextField(
                      controller: _ofertaCtrl,
                      keyboardType: TextInputType.number,
                      onSubmitted: (_) => _mandarOferta(),
                      decoration: InputDecoration(
                        hintText: 'ej. 950', isDense: true, filled: true, fillColor: AppColors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm), borderSide: const BorderSide(color: AppColors.gris100, width: 1.5)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _mandarOferta,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                      decoration: BoxDecoration(color: AppColors.blue, borderRadius: BorderRadius.circular(AppRadius.sm)),
                      child: const Text('Enviar', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(onTap: () => setState(() => _showOferta = false), child: const Icon(Icons.close, size: 20, color: AppColors.grisM)),
                ]),
              ),
            Container(
              padding: const EdgeInsets.all(10),
              color: AppColors.white,
              child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                InkWell(
                  onTap: () => setState(() => _showOferta = !_showOferta),
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 40, height: 40,
                    decoration: const BoxDecoration(color: AppColors.amberBg, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: const Icon(Icons.attach_money, size: 18, color: AppColors.blue),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _textoCtrl,
                    minLines: 1, maxLines: 4,
                    onSubmitted: (_) => _enviar(),
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje…', isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: const BorderSide(color: AppColors.gris100, width: 1.5)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _enviar,
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 40, height: 40,
                    decoration: const BoxDecoration(color: AppColors.navy, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: const Icon(Icons.send, size: 16, color: Colors.white),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textBubble(Mensaje m, bool mine) {
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: mine ? AppColors.navy : AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppRadius.lg),
            topRight: const Radius.circular(AppRadius.lg),
            bottomLeft: Radius.circular(mine ? AppRadius.lg : 4),
            bottomRight: Radius.circular(mine ? 4 : AppRadius.lg),
          ),
          boxShadow: mine ? null : cardShadow,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(m.texto ?? '', style: TextStyle(fontSize: 13.5, color: mine ? Colors.white : AppColors.texto, height: 1.35)),
          const SizedBox(height: 4),
          Text(fmtTime(m.ts), style: TextStyle(fontSize: 10, color: mine ? const Color(0xA6FFFFFF) : AppColors.grisM)),
        ]),
      ),
    );
  }

  Widget _ofertaBubble(AppState app, Mensaje m, bool mine) {
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: mine ? const Color(0xFFEEF3F8) : AppColors.amberBg,
          border: Border.all(color: mine ? AppColors.navyLight : AppColors.amberLight, width: 1.5),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(mine ? 'TU COTIZACIÓN ENVIADA' : 'COTIZACIÓN RECIBIDA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: mine ? AppColors.navy : AppColors.amberText)),
          const SizedBox(height: 4),
          Text.rich(TextSpan(children: [
            TextSpan(text: fmtMoneda(m.precio), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.blue)),
            const TextSpan(text: ' por el viaje', style: TextStyle(fontSize: 11, color: AppColors.grisM)),
          ])),
          Text(fmtTime(m.ts), style: const TextStyle(fontSize: 10, color: AppColors.grisM)),
          if (!mine && m.estadoOferta == 'pendiente')
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(children: [
                InkWell(
                  onTap: () => app.responderOferta(m.id, 'aceptada'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 12),
                    decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(AppRadius.sm)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: const [
                      Icon(Icons.check, size: 13, color: Colors.white),
                      SizedBox(width: 4),
                      Text('Aceptar', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white)),
                    ]),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => app.responderOferta(m.id, 'rechazada'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 12),
                    decoration: BoxDecoration(color: AppColors.rojoBg, borderRadius: BorderRadius.circular(AppRadius.sm)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: const [
                      Icon(Icons.close, size: 13, color: AppColors.rojo),
                      SizedBox(width: 4),
                      Text('Rechazar', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.rojo)),
                    ]),
                  ),
                ),
              ]),
            ),
          if (m.estadoOferta != null && m.estadoOferta != 'pendiente')
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                m.estadoOferta == 'aceptada' ? 'Aceptada' : 'Rechazada',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: m.estadoOferta == 'aceptada' ? AppColors.verde : AppColors.rojo),
              ),
            ),
        ]),
      ),
    );
  }
}
