import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/theme.dart';
import '../../utils/format.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_image.dart';
import '../../widgets/avatar.dart';
import '../../widgets/badge.dart';
import '../../widgets/detail_row.dart';
import '../../widgets/modal_header.dart';
import '../../widgets/stars.dart';
import '../../widgets/visor_documento.dart';

/// Ficha completa de un usuario para que el administrador pueda decidir con los
/// documentos a la vista, en vez de aprobar a ciegas.
class AdminUsuarioDetalleModal extends StatefulWidget {
  final String usuarioId;
  const AdminUsuarioDetalleModal({super.key, required this.usuarioId});

  @override
  State<AdminUsuarioDetalleModal> createState() => _AdminUsuarioDetalleModalState();
}

class _AdminUsuarioDetalleModalState extends State<AdminUsuarioDetalleModal> {
  bool _procesando = false;

  Future<void> _correr(Future<void> Function() accion, String exito) async {
    setState(() => _procesando = true);
    try {
      await accion();
      if (!mounted) return;
      context.read<AppState>().showToast(exito);
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _procesando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo completar: $e'), backgroundColor: AppColors.rojo),
      );
    }
  }

  /// Rechazar y suspender exigen motivo: el usuario tiene que saber qué corregir.
  Future<String?> _pedirMotivo({required String titulo, required String ayuda, required String textoBoton}) {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(ayuda, style: TextStyle(fontSize: 12.5, color: AppColors.grisM, height: 1.4)),
          const SizedBox(height: 12),
          TextField(
            controller: ctrl,
            autofocus: true,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Ej: la foto del DNI está borrosa y no se lee el número',
              border: OutlineInputBorder(),
            ),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              final t = ctrl.text.trim();
              if (t.isNotEmpty) Navigator.pop(ctx, t);
            },
            child: Text(textoBoton, style: TextStyle(color: AppColors.rojo, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final u = app.usuarios.where((x) => x.id == widget.usuarioId).firstOrNull;
    if (u == null) return const SizedBox.shrink();

    final docs = <({String titulo, String url})>[
      if (u.doc != null)
        (titulo: u.tipo == TipoUsuario.transportista ? 'Licencia de conducir' : 'Documento de la empresa', url: u.doc!),
      if (u.docIdentidad != null) (titulo: 'Documento de identidad (DNI/cédula)', url: u.docIdentidad!),
      if (u.seguro != null) (titulo: 'Comprobante de seguro', url: u.seguro!),
      if (u.selfie != null) (titulo: 'Selfie de verificación', url: u.selfie!),
    ];

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ModalHeader(
              title: 'Revisar usuario',
              badge: AppBadge(tone: u.estadoCuenta.tono, label: u.estadoCuenta.etiqueta),
              onClose: () => Navigator.of(context).pop(),
            ),
            Row(children: [
              Avatar(uri: u.selfie, tipo: u.tipo, size: 52),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(u.nombre, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.navy)),
                  const SizedBox(height: 2),
                  Text(u.subtipo, style: TextStyle(fontSize: 12.5, color: AppColors.grisM)),
                  const SizedBox(height: 4),
                  Stars(value: avgRating(app.historial, usuarioId: u.id, tipo: u.tipo)),
                ]),
              ),
            ]),
            const SizedBox(height: AppSpacing.lg),

            if (u.motivoRechazo != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(color: AppColors.rojoBg, borderRadius: BorderRadius.circular(AppRadius.md)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Motivo registrado', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.rojo)),
                  const SizedBox(height: 4),
                  Text(u.motivoRechazo!, style: TextStyle(fontSize: 12.5, color: AppColors.rojo, height: 1.4)),
                ]),
              ),

            DetailRow(label: 'Correo', value: u.email),
            DetailRow(label: 'Teléfono', value: u.telefono.isEmpty ? '—' : u.telefono),
            DetailRow(label: 'País', value: u.pais.isEmpty ? '—' : u.pais),
            DetailRow(label: 'Tipo', value: u.tipo == TipoUsuario.cliente ? 'Cliente' : 'Transportista'),
            if (u.vehiculo != null) DetailRow(label: 'Vehículo', value: u.vehiculo!),
            if (u.capacidad != null) DetailRow(label: 'Capacidad', value: '${u.capacidad} ton'),
            if (u.placa != null) DetailRow(label: 'Placa', value: u.placa!),
            DetailRow(label: 'Registrado', value: fechaLarga(u.fechaRegistro)),

            Padding(
              padding: EdgeInsets.only(top: AppSpacing.lg, bottom: 8),
              child: Text('DOCUMENTOS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.blue, letterSpacing: 0.4)),
            ),
            if (docs.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(color: AppColors.gris50, borderRadius: BorderRadius.circular(AppRadius.md)),
                child: Text('Este usuario no subió ningún documento.',
                    style: TextStyle(fontSize: 12.5, color: AppColors.grisM)),
              )
            else
              for (final d in docs)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: InkWell(
                    onTap: () => abrirDocumento(context, d.url, d.titulo),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(child: Text(d.titulo, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.navy))),
                        Icon(Icons.zoom_in, size: 16, color: AppColors.blue),
                        const SizedBox(width: 4),
                        Text('Ampliar', style: TextStyle(fontSize: 11.5, color: AppColors.blue, fontWeight: FontWeight.w600)),
                      ]),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: AppImage(path: d.url, width: double.infinity, height: 200, fit: BoxFit.cover),
                      ),
                    ]),
                  ),
                ),

            const SizedBox(height: AppSpacing.lg),
            ..._acciones(u),
          ]),
        ),
      ),
    );
  }

  List<Widget> _acciones(Usuario u) {
    final app = context.read<AppState>();

    Widget aprobar({required String titulo}) => AppButton(
          title: titulo,
          fullWidth: true,
          loading: _procesando,
          icon: const Icon(Icons.check_circle_outline, size: 16, color: Colors.white),
          onPressed: () => _correr(() => app.aprobarUsuario(u.id), 'Cuenta de ${u.nombre} aprobada'),
        );

    Widget rechazar() => AppButton(
          title: 'Rechazar documentos',
          fullWidth: true,
          variant: AppButtonVariant.danger,
          onPressed: () async {
            final motivo = await _pedirMotivo(
              titulo: 'Rechazar documentos',
              ayuda: 'Explicá qué está mal. El usuario va a ver este texto y podrá volver a subir los documentos corregidos.',
              textoBoton: 'Rechazar',
            );
            if (motivo != null) await _correr(() => app.rechazarUsuario(u.id, motivo), 'Documentos rechazados');
          },
        );

    Widget suspender() => AppButton(
          title: 'Suspender cuenta',
          fullWidth: true,
          variant: AppButtonVariant.danger,
          onPressed: () async {
            final motivo = await _pedirMotivo(
              titulo: 'Suspender cuenta',
              ayuda: 'La cuenta queda bloqueada y no va a poder operar hasta que la reactives. El usuario verá este motivo.',
              textoBoton: 'Suspender',
            );
            if (motivo != null) await _correr(() => app.suspenderUsuario(u.id, motivo), 'Cuenta suspendida');
          },
        );

    Widget reactivar() => AppButton(
          title: 'Reactivar cuenta',
          fullWidth: true,
          loading: _procesando,
          icon: const Icon(Icons.lock_open, size: 16, color: Colors.white),
          onPressed: () => _correr(() => app.reactivarUsuario(u.id), 'Cuenta de ${u.nombre} reactivada'),
        );

    switch (u.estadoCuenta) {
      case EstadoCuenta.pendiente:
        return [aprobar(titulo: 'Aprobar documentos'), const SizedBox(height: AppSpacing.sm), rechazar()];
      case EstadoCuenta.rechazado:
        return [aprobar(titulo: 'Aprobar de todas formas'), const SizedBox(height: AppSpacing.sm), suspender()];
      case EstadoCuenta.aprobado:
        return [suspender()];
      case EstadoCuenta.suspendido:
        return [reactivar()];
    }
  }
}

Future<void> abrirUsuarioAdmin(BuildContext context, String usuarioId) {
  return Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
    fullscreenDialog: true,
    builder: (_) => AdminUsuarioDetalleModal(usuarioId: usuarioId),
  ));
}
