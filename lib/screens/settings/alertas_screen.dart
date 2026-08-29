import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/constants.dart';
import '../../state/app_state.dart';
import '../../theme/theme.dart';
import '../../utils/accion.dart';
import '../../widgets/app_button.dart';
import '../../widgets/panel.dart';
import '../../widgets/screen.dart';

/// Sobre qué rutas quiere el transportista que le avisen.
///
/// Existe por una razón concreta: alguien se registra un día en que no hay
/// carga en su ruta, no ve nada y no vuelve. Con el aviso, el día que aparezca
/// algo le llega un correo y vuelve solo. Es la diferencia entre un registro y
/// un usuario.
class AlertasScreen extends StatefulWidget {
  const AlertasScreen({super.key});

  @override
  State<AlertasScreen> createState() => _AlertasScreenState();
}

class _AlertasScreenState extends State<AlertasScreen> {
  bool? _activas;
  Set<String>? _paises;
  bool _guardando = false;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final yo = app.usuario!;

    // Se toma el valor guardado la primera vez y después manda lo que el
    // usuario va tocando, para que no se le deshagan los cambios cuando llegue
    // una actualización del servidor.
    final activas = _activas ??= yo.alertasCarga;
    final misPaises = _paises ??= yo.alertasPaises.isEmpty
        ? {if (yo.pais.isNotEmpty) yo.pais}
        : yo.alertasPaises.toSet();

    return Screen(
      title: 'Avisos de carga',
      subtitle: 'Te escribimos cuando publiquen algo en tus rutas',
      onBack: () => Navigator.of(context).pop(),
      children: [
        Panel(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Avisarme por correo',
                      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.navy)),
                  const SizedBox(height: 2),
                  Text('Cuando se publique una carga en los países que elijas.',
                      style: TextStyle(fontSize: 12.5, color: AppColors.grisM, height: 1.4)),
                ]),
              ),
              Switch(
                value: activas,
                activeThumbColor: AppColors.blue,
                onChanged: (v) => setState(() => _activas = v),
              ),
            ]),
          ]),
        ),
        Panel(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('MIS RUTAS',
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.blue, letterSpacing: 0.6)),
            const SizedBox(height: 6),
            Text('Marcá los países donde cargás o descargás. Te avisamos si la carga sale '
                'de alguno de ellos o llega a alguno de ellos.',
                style: TextStyle(fontSize: 12.5, color: AppColors.grisM, height: 1.45)),
            const SizedBox(height: 14),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final p in paises)
                _ChipPais(
                  pais: p,
                  activo: misPaises.contains(p),
                  habilitado: activas,
                  onTap: () => setState(() {
                    if (!misPaises.remove(p)) misPaises.add(p);
                  }),
                ),
            ]),
            if (activas && misPaises.isEmpty) ...[
              const SizedBox(height: 12),
              Text('Sin ningún país marcado no te vamos a poder avisar nada.',
                  style: TextStyle(fontSize: 12.5, color: AppColors.rojo, fontWeight: FontWeight.w600)),
            ],
          ]),
        ),
        AppButton(
          title: 'Guardar',
          fullWidth: true,
          loading: _guardando,
          onPressed: activas && misPaises.isEmpty ? null : () => _guardar(app, yo.id),
        ),
      ],
    );
  }

  Future<void> _guardar(AppState app, String usuarioId) async {
    setState(() => _guardando = true);
    await ejecutar(
      context,
      () => app.guardarAlertas(usuarioId, activas: _activas!, paises: _paises!.toList()),
      exito: 'Listo, te vamos a avisar',
      fallo: 'No se pudieron guardar los avisos',
    );
    if (mounted) setState(() => _guardando = false);
  }
}

class _ChipPais extends StatelessWidget {
  final String pais;
  final bool activo;
  final bool habilitado;
  final VoidCallback onTap;

  const _ChipPais({
    required this.pais,
    required this.activo,
    required this.habilitado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: habilitado ? 1 : 0.4,
      child: InkWell(
        onTap: habilitado ? onTap : null,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: activo ? AppColors.solido : AppColors.gris50,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: activo ? Colors.transparent : AppColors.gris100),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (activo) ...[
              const Icon(Icons.check, size: 14, color: Colors.white),
              const SizedBox(width: 5),
            ],
            Text(pais,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: activo ? Colors.white : AppColors.grisM)),
          ]),
        ),
      ),
    );
  }
}
