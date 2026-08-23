import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/constants.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/theme.dart';
import 'app_button.dart';

/// Pide la ubicación del transportista explicando primero qué se comparte, con
/// quién y hasta cuándo. El aviso del sistema por sí solo no dice nada de eso, y
/// a quien maneja un camión todo el día le corresponde saberlo antes de aceptar.
class TarjetaRastreo extends StatefulWidget {
  const TarjetaRastreo({super.key});

  @override
  State<TarjetaRastreo> createState() => _TarjetaRastreoState();
}

class _TarjetaRastreoState extends State<TarjetaRastreo> {
  bool _pidiendo = false;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final yo = app.usuario;
    if (yo == null || yo.tipo != TipoUsuario.transportista) return const SizedBox.shrink();
    if (app.viajesEnRuta.isEmpty) return const SizedBox.shrink();

    return app.rastreoActivo ? _activo(app) : _pedirPermiso(app);
  }

  Widget _activo(AppState app) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(color: AppColors.verdeBg, borderRadius: BorderRadius.circular(AppRadius.lg)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.my_location, size: 18, color: AppColors.verde),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Compartiendo tu ubicación',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.verde)),
              const SizedBox(height: 2),
              Text(
                'El cliente de ${app.viajesEnRuta.length == 1 ? 'tu viaje' : 'tus ${app.viajesEnRuta.length} viajes'} '
                'puede ver dónde vas. Se corta solo al confirmar la entrega.',
                style: TextStyle(fontSize: 11, color: AppColors.verde, height: 1.35),
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: app.detenerRastreo,
                child: Text('Dejar de compartir',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.rojo)),
              ),
            ]),
          ),
        ]),
      );

  Widget _pedirPermiso(AppState app) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(color: AppColors.amberBg, borderRadius: BorderRadius.circular(AppRadius.lg)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.location_off, size: 18, color: AppColors.amberText),
            const SizedBox(width: 10),
            Expanded(
              child: Text('No estás compartiendo tu ubicación',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.amberText)),
            ),
          ]),
          const SizedBox(height: 8),
          Text(
            'Tenés un viaje en curso. Al activarlo, el cliente de esa carga verá tu posición en el mapa '
            'mientras tengas la app abierta. Nadie más la ve, y deja de compartirse en cuanto confirmás la entrega '
            'o tocás "Dejar de compartir".',
            style: TextStyle(fontSize: 11.5, color: AppColors.amberText, height: 1.4),
          ),
          if (app.rastreoError != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.rojoBg, borderRadius: BorderRadius.circular(AppRadius.sm)),
              child: Text(app.rastreoError!,
                  style: TextStyle(fontSize: 11.5, color: AppColors.rojo, height: 1.35)),
            ),
          ],
          const SizedBox(height: 10),
          AppButton(
            title: 'Compartir mi ubicación',
            fullWidth: true,
            loading: _pidiendo,
            icon: const Icon(Icons.my_location, size: 16, color: Colors.white),
            onPressed: () async {
              setState(() => _pidiendo = true);
              await app.iniciarRastreo();
              if (mounted) setState(() => _pidiendo = false);
            },
          ),
          const SizedBox(height: 6),
          Text('Podés consultar qué hacemos con estos datos en la Política de privacidad, o escribirnos a $soporteEmail.',
              style: TextStyle(fontSize: 10.5, color: AppColors.amberText, height: 1.3)),
        ]),
      );
}
