import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/theme.dart';
import '../../utils/format.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/avatar.dart';
import '../../widgets/badge.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/screen.dart';
import '../../widgets/stars.dart';
import 'admin_usuario_detalle_modal.dart';

class AdminUsuariosScreen extends StatefulWidget {
  const AdminUsuariosScreen({super.key});

  @override
  State<AdminUsuariosScreen> createState() => _AdminUsuariosScreenState();
}

class _AdminUsuariosScreenState extends State<AdminUsuariosScreen> {
  final _busquedaCtrl = TextEditingController();
  String _busqueda = '';
  EstadoCuenta? _filtroEstado;
  TipoUsuario? _filtroTipo;

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final yo = app.usuario!;
    final todos = app.usuarios.where((u) => u.tipo != TipoUsuario.admin).toList();

    final q = _busqueda.trim().toLowerCase();
    final users = todos.where((u) {
      if (_filtroEstado != null && u.estadoCuenta != _filtroEstado) return false;
      if (_filtroTipo != null && u.tipo != _filtroTipo) return false;
      if (q.isEmpty) return true;
      return u.nombre.toLowerCase().contains(q) ||
          u.email.toLowerCase().contains(q) ||
          u.telefono.toLowerCase().contains(q) ||
          u.pais.toLowerCase().contains(q);
    }).toList()
      // Los pendientes primero: son los que exigen una decisión.
      ..sort((a, b) {
        final pa = a.estadoCuenta == EstadoCuenta.pendiente ? 0 : 1;
        final pb = b.estadoCuenta == EstadoCuenta.pendiente ? 0 : 1;
        if (pa != pb) return pa - pb;
        return b.fechaRegistro.compareTo(a.fechaRegistro);
      });

    final pendientes = todos.where((u) => u.estadoCuenta == EstadoCuenta.pendiente).length;

    return Screen(
      title: 'Usuarios',
      subtitle: pendientes == 0
          ? '${todos.length} registrados · nada pendiente'
          : '$pendientes esperando revisión de ${todos.length}',
      children: [
        AppTextField(
          placeholder: 'Buscar por nombre, correo, teléfono o país',
          controller: _busquedaCtrl,
          onChanged: (v) => setState(() => _busqueda = v),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _chip('Todos', _filtroEstado == null && _filtroTipo == null, () => setState(() {
                  _filtroEstado = null;
                  _filtroTipo = null;
                })),
            for (final e in EstadoCuenta.values)
              _chip(e.etiqueta, _filtroEstado == e, () => setState(() => _filtroEstado = _filtroEstado == e ? null : e)),
            _chip('Clientes', _filtroTipo == TipoUsuario.cliente,
                () => setState(() => _filtroTipo = _filtroTipo == TipoUsuario.cliente ? null : TipoUsuario.cliente)),
            _chip('Transportistas', _filtroTipo == TipoUsuario.transportista,
                () => setState(() => _filtroTipo = _filtroTipo == TipoUsuario.transportista ? null : TipoUsuario.transportista)),
          ]),
        ),
        const SizedBox(height: AppSpacing.md),
        if (users.isEmpty)
          const EmptyState(icon: Icons.person_search, title: 'Sin resultados', sub: 'Probá con otro texto o quitá los filtros'),
        for (final u in users)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: InkWell(
              onTap: () => abrirUsuarioAdmin(context, u.id),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: cardShadow),
                child: Row(children: [
                  Avatar(uri: u.selfie, tipo: u.tipo, size: 40),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(u.nombre, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.navy)),
                      const SizedBox(height: 2),
                      Text('${u.subtipo} · ${u.email}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: AppColors.grisM)),
                      const SizedBox(height: 4),
                      Stars(value: avgRating(app.historial, usuarioId: u.id, tipo: u.tipo)),
                    ]),
                  ),
                  const SizedBox(width: 8),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    AppBadge(tone: u.estadoCuenta.tono, label: u.estadoCuenta.etiqueta),
                    const SizedBox(height: 6),
                    Icon(Icons.chevron_right, size: 18, color: AppColors.grisM),
                  ]),
                ]),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: Text('Sesión de administrador · ${yo.email}',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: AppColors.grisM)),
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
              color: on ? AppColors.solido : AppColors.gris100,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(label,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: on ? Colors.white : AppColors.grisM)),
          ),
        ),
      );
}
