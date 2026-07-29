import 'package:flutter/material.dart';
import '../screens/modals/carga_detail_modal.dart';
import '../screens/modals/contrato_modal.dart';
import '../screens/modals/calificar_modal.dart';
import '../screens/messages/chat_screen.dart';
import '../screens/tracking/seguimiento_screen.dart';

Future<void> openCargaDetail(BuildContext context, int cargaId) {
  return Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
    fullscreenDialog: true,
    builder: (_) => CargaDetailModal(cargaId: cargaId),
  ));
}

Future<void> openContrato(BuildContext context, int cargaId) {
  return Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
    fullscreenDialog: true,
    builder: (_) => ContratoModal(cargaId: cargaId),
  ));
}

Future<void> openCalificar(BuildContext context, int historialId) {
  return Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
    fullscreenDialog: true,
    builder: (_) => CalificarModal(historialId: historialId),
  ));
}

Future<void> openChat(BuildContext context, int convoId) {
  return Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
    builder: (_) => ChatScreen(convoId: convoId),
  ));
}

Future<void> openSeguimiento(BuildContext context) {
  return Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
    builder: (_) => const SeguimientoScreen(showBack: true),
  ));
}
