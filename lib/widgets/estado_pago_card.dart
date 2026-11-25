import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/constants.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/theme.dart';
import '../utils/accion.dart';
import '../utils/format.dart';
import 'app_button.dart';
import 'panel.dart';

/// Dónde está el dinero de un viaje, contado desde el lado de quien mira.
///
/// Hasta hace poco la app no lo explicaba en ningún lado: el estado vivía en
/// la base de datos y nadie lo veía. Al cliente hay que decirle qué le toca
/// hacer; al transportista, si ya puede salir y con qué respaldo; al
/// administrador, qué tiene que confirmar.
///
/// Hay dos modos y cuentan historias distintas, así que la tarjeta se bifurca
/// entera (ver [ModoPago]):
///
/// - **garantía** — el cliente deposita, NexCarg retiene y libera contra la
///   prueba de entrega. Mientras no haya pasarela de pago, el depósito se hace
///   por fuera y el administrador lo confirma a mano. Eso no lo vuelve menos
///   real —el dinero está retenido de verdad— pero sí obliga a decirlo así.
/// - **comisión** — el cliente le paga directo al transportista y NexCarg
///   factura su 5% aparte. Acá hay que ser explícito en que **no hay
///   retención**: un transportista que cree estar cubierto y no lo está es
///   peor que uno que sabe que el cobro corre por su cuenta.
class EstadoPagoCard extends StatelessWidget {
  final Carga carga;
  const EstadoPagoCard({super.key, required this.carga});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final yo = app.usuario;
    if (yo == null || carga.estado == EstadoCarga.publicada || carga.estado == EstadoCarga.cancelada) {
      return const SizedBox.shrink();
    }

    final soyCliente = yo.id == carga.clienteId;
    final soyTransportista = yo.id == carga.transportistaId;
    final soyAdmin = yo.tipo == TipoUsuario.admin;
    final monto = fmtMoneda(carga.pago.monto ?? carga.precioAcordado);

    if (carga.pago.modo == ModoPago.comision) {
      return _tarjetaComision(soyCliente: soyCliente, soyTransportista: soyTransportista, monto: monto);
    }

    final (icono, color, titulo, texto) = switch (carga.pago.estado) {
      EstadoPago.pendiente when soyCliente => (
          Icons.account_balance_outlined,
          AppColors.amberText,
          'Falta tu depósito de $monto',
          'El transportista no puede salir con la carga hasta que NexCarg confirme que el '
              'dinero entró. Así funciona la garantía: nosotros lo retenemos y no se lo damos '
              'a nadie hasta que la entrega esté probada.',
        ),
      EstadoPago.pendiente when soyTransportista => (
          Icons.hourglass_top,
          AppColors.amberText,
          'Esperando el depósito del cliente',
          'No salgas con la carga todavía. Cuando NexCarg tenga el dinero retenido te avisamos '
              'y recién ahí se habilita "Iniciar viaje".',
        ),
      EstadoPago.pendiente => (
          Icons.account_balance_outlined,
          AppColors.amberText,
          'Pago pendiente de confirmar',
          'El cliente tiene que depositar $monto. Confirmá acá cuando el dinero haya entrado.',
        ),
      EstadoPago.retenido when soyTransportista => (
          Icons.verified_user_outlined,
          AppColors.verde,
          'Pago asegurado: $monto',
          'NexCarg ya tiene el dinero retenido. Podés salir con la carga. Se libera a tu favor '
              'cuando subas la prueba de entrega.',
        ),
      EstadoPago.retenido => (
          Icons.lock_outline,
          AppColors.verde,
          'Pago retenido: $monto',
          'El dinero está en garantía. No se libera al transportista hasta que la entrega esté '
              'probada con foto y firma.',
        ),
      EstadoPago.liberado => (
          Icons.check_circle_outline,
          AppColors.verde,
          'Pago liberado: $monto',
          'La entrega quedó probada y el pago se liberó al transportista, menos la comisión de '
              '$comisionTexto%.',
        ),
    };

    return Panel(
      filo: color,
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg + 4, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icono, size: 19, color: color),
          const SizedBox(width: 9),
          Expanded(
            child: Text(titulo,
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.navy)),
          ),
        ]),
        const SizedBox(height: 7),
        Text(texto, style: TextStyle(fontSize: 12.5, height: 1.5, color: AppColors.grisM)),

        // Al cliente hay que decirle a dónde deposita. Si todavía no se
        // configuraron los datos de la cuenta, es mejor mandarlo a soporte que
        // dejarlo adivinando.
        if (carga.pago.estado == EstadoPago.pendiente && soyCliente) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.gris50,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.gris100),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(hayDatosDeposito ? 'DEPOSITAR A' : 'CÓMO DEPOSITAR',
                  style: TextStyle(
                      fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.grisM, letterSpacing: 0.6)),
              const SizedBox(height: 6),
              if (hayDatosDeposito)
                for (final linea in datosDeposito)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(linea,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.navy)),
                  )
              else
                Text('Escribinos a $soporteEmail con el número de este viaje y te pasamos los '
                    'datos de la cuenta.',
                    style: TextStyle(fontSize: 12.5, height: 1.45, color: AppColors.texto)),
              const SizedBox(height: 8),
              Text('Mandanos el comprobante por el chat del viaje para que lo confirmemos más rápido.',
                  style: TextStyle(fontSize: 11.5, height: 1.4, color: AppColors.grisM)),
            ]),
          ),
        ],

        if (carga.pago.estado == EstadoPago.pendiente && soyAdmin) ...[
          const SizedBox(height: 14),
          AppButton(
            title: 'Confirmar que entró el depósito',
            size: AppButtonSize.sm,
            fullWidth: true,
            onPressed: () => _confirmar(context, app),
          ),
        ],
      ]),
    );
  }

  /// Modo comisión: NexCarg no toca el dinero del viaje.
  ///
  /// El estado de la base sigue siendo `pendiente` → `liberado`, pero acá no
  /// significan "depositado" y "liberado" sino simplemente antes y después de
  /// la entrega probada, que es lo que dispara la comisión.
  Widget _tarjetaComision({
    required bool soyCliente,
    required bool soyTransportista,
    required String monto,
  }) {
    final entregado = carga.pago.entregado;
    final comision = fmtMoneda((carga.pago.monto ?? carga.precioAcordado ?? 0) * comisionPct / 100);
    final quien = carga.transportistaNombre ?? 'el transportista';

    final (icono, color, titulo, texto) = switch ((entregado, soyCliente, soyTransportista)) {
      // --- antes de la entrega ---
      (false, true, _) => (
          Icons.handshake_outlined,
          AppColors.blue,
          'El pago lo arreglás directo con $quien',
          'En este viaje NexCarg no retiene el dinero: acordá con $quien cómo y cuándo le '
              'pagás, y dejalo por escrito en el chat del viaje. Nosotros cobramos nuestra '
              'comisión del $comisionTexto% aparte, cuando la entrega quede probada.',
        ),
      (false, _, true) => (
          Icons.info_outline,
          AppColors.amberText,
          'Cobrás directo al cliente: $monto',
          'Ojo: en este viaje NexCarg no está reteniendo el dinero, así que el cobro corre '
              'por tu cuenta. Acordá la forma de pago con el cliente antes de cargar y dejala '
              'escrita en el chat. Al entregar te facturamos nuestra comisión de $comision.',
        ),
      (false, _, _) => (
          Icons.handshake_outlined,
          AppColors.blue,
          'Modo comisión · $monto',
          'El cliente le paga directo al transportista. No hay depósito que confirmar: '
              'NexCarg factura $comision cuando la entrega quede probada.',
        ),
      // --- entregado ---
      (true, true, _) => (
          Icons.check_circle_outline,
          AppColors.verde,
          'Entregado — pagale a $quien',
          'La entrega quedó probada con foto y firma. Lo acordado es $monto y se lo pagás '
              'directo. Ya podés calificar el viaje.',
        ),
      (true, _, true) => (
          Icons.check_circle_outline,
          AppColors.verde,
          'Entrega probada — cobrá $monto',
          'Ya podés cobrarle al cliente lo acordado. La comisión de NexCarg por este viaje '
              'es $comision y la ves en Más → Facturación.',
        ),
      (true, _, _) => (
          Icons.request_quote_outlined,
          AppColors.verde,
          'Comisión por cobrar: $comision',
          'El viaje se entregó con prueba. El cliente le paga $monto directo al '
              'transportista; a NexCarg le corresponde $comision.',
        ),
    };

    return Panel(
      filo: color,
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg + 4, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icono, size: 19, color: color),
          const SizedBox(width: 9),
          Expanded(
            child: Text(titulo,
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.navy)),
          ),
        ]),
        const SizedBox(height: 7),
        Text(texto, style: TextStyle(fontSize: 12.5, height: 1.5, color: AppColors.grisM)),
      ]),
    );
  }

  Future<void> _confirmar(BuildContext context, AppState app) async {
    // Confirmar un depósito habilita a un camión a salir. Si se toca por error,
    // alguien maneja mil kilómetros contra un dinero que no entró.
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Confirmar el depósito?'),
        content: Text(
          '¿Ya verificaste en la cuenta bancaria que entraron '
          '${fmtMoneda(carga.pago.monto ?? carga.precioAcordado)}?\n\n'
          'Al confirmar, el transportista queda habilitado para salir con la carga.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sí, ya entró')),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await ejecutar(
      context,
      () => app.confirmarPagoRecibido(carga.id),
      exito: 'Pago confirmado — el transportista ya puede salir',
      fallo: 'No se pudo confirmar el pago',
    );
  }
}
