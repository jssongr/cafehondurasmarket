import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/constants.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/panel.dart';
import '../../widgets/screen.dart';

/// A quién le sirve cada pregunta. Un transportista no necesita saber cómo se
/// publica una carga, y mezclarlo todo hace que nadie encuentre lo suyo.
enum _Para { todos, cliente, transportista }

class _Faq {
  final String q;
  final String a;
  final _Para para;
  const _Faq(this.q, this.a, [this.para = _Para.todos]);
}

// Getter y no constante: la comisión y el correo de soporte salen de
// constants.dart, y $comisionTexto no es una constante de compilación.
List<_Faq> get _faqs => [
  // --- Cuenta ---
  _Faq(
    '¿Cuánto tarda la verificación de mi cuenta?',
    'Una persona de NexCarg revisa tus documentos a mano, normalmente el mismo día hábil. '
        'Mientras tanto podés mirar la app, pero no publicar ni aceptar viajes. Te llega un '
        'correo apenas quede aprobada.',
  ),
  _Faq(
    'Rechazaron mis documentos, ¿qué hago?',
    'El aviso te dice el motivo. Corregí lo que se indica y volvé a subir los documentos '
        'desde Más → Documentos. Lo más común es que la foto esté borrosa o que falte una '
        'esquina del documento.',
  ),
  _Faq(
    'Olvidé mi contraseña, ¿qué hago?',
    'En la pantalla de acceso escribí tu correo y tocá "¿Olvidaste tu contraseña?". Te llega '
        'un enlace para elegir una nueva. Si no llega en unos minutos, revisá la carpeta de '
        'spam antes de escribirnos.',
  ),

  // --- Dinero ---
  _Faq(
    '¿Cómo funciona el pago en garantía?',
    'Cuando se acuerda un viaje, el cliente deposita el monto en la cuenta de NexCarg. '
        'Nosotros lo retenemos: no es del cliente ni del transportista mientras dure el viaje. '
        'Al probarse la entrega con foto y firma, se libera al transportista descontando la '
        'comisión.',
  ),
  _Faq(
    '¿Cuándo puedo salir con la carga?',
    'Cuando las dos partes firmaron el contrato Y NexCarg confirmó que el depósito del cliente '
        'entró. Hasta ese momento el botón "Iniciar viaje" está apagado. No salgas antes: es '
        'justamente la garantía de que vas a cobrar.',
    _Para.transportista,
  ),
  _Faq(
    '¿Cuándo me transfieren mi pago?',
    'Al confirmar la entrega, el pago se libera a tu favor y se genera tu factura con el neto '
        'de comisión. NexCarg te transfiere y la factura queda marcada como transferida. Podés '
        'verlo en Más → Facturación.',
    _Para.transportista,
  ),
  _Faq(
    '¿Dónde deposito el pago del viaje?',
    'En el detalle del viaje, apenas se asigna, aparecen los datos de la cuenta. Mandá el '
        'comprobante por el chat del viaje: así lo confirmamos más rápido y el transportista '
        'puede salir antes.',
    _Para.cliente,
  ),
  _Faq(
    '¿Qué cobra NexCarg?',
    'Una comisión del $comisionTexto% sobre cada viaje completado, que se descuenta al liberarse el '
        'pago. Publicar cargas y tener cuenta no cuesta nada.',
  ),

  // --- Operación ---
  _Faq(
    '¿Cómo publico una carga?',
    'Pestaña "Publicar": origen, destino, peso, tipo de mercancía y fecha. Podés poner un '
        'precio fijo o dejarla abierta a cotización. Si ponés precio fijo, un transportista '
        'puede tomarla de una vez; si la dejás abierta, vas a recibir cotizaciones para comparar.',
    _Para.cliente,
  ),
  _Faq(
    '¿Cómo consigo mi primer viaje?',
    'En "Cargas" mirá lo publicado en tus rutas. Si tiene precio y te sirve, tocá "Aceptar '
        'viaje". Si querés proponer otro precio, tocá "Cotizar" y mandá tu monto por el chat. '
        'Te avisamos por correo cuando el cliente responda.',
    _Para.transportista,
  ),
  _Faq(
    '¿Puedo cancelar una carga publicada?',
    'Sí, mientras nadie la haya aceptado. Una vez asignada, escribile al transportista por el '
        'chat para coordinar; si hay que cancelar igual, escribinos a soporte antes de que el '
        'viaje salga.',
    _Para.cliente,
  ),
  _Faq(
    '¿Qué es el contrato digital?',
    'Un acuerdo que las dos partes firman dentro de la app antes de salir, con la ruta, la '
        'fecha y el monto acordado. Queda registrado quién firmó y a qué hora. Sin las dos '
        'firmas el viaje no puede iniciar.',
  ),
  _Faq(
    '¿Cuándo se comparte mi ubicación?',
    'Solo mientras tenés un viaje en curso, y solo si la activás. Te lo pedimos con un aviso '
        'que explica para qué se usa. Podés dejar de compartirla cuando quieras, y al terminar '
        'el viaje se detiene sola.',
    _Para.transportista,
  ),
  _Faq(
    '¿Qué es la prueba de entrega?',
    'Al entregar, el transportista toma una foto de la carga, escribe el nombre de quien recibe '
        'y le pide su firma en la pantalla. Eso es lo que libera el pago, y queda guardado en el '
        'historial del viaje para las dos partes.',
  ),
  _Faq(
    'La carga no llegó o llegó dañada, ¿qué hago?',
    'Escribinos a $soporteEmail con el número del viaje antes de calificar. El pago no se '
        'libera mientras el caso esté en revisión, y tenemos el contrato, el recorrido del GPS '
        'y las fotos para resolverlo.',
  ),
];

class AyudaScreen extends StatelessWidget {
  const AyudaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final yo = context.watch<AppState>().usuario;
    final soyTransportista = yo?.tipo == TipoUsuario.transportista;
    final mias = _faqs.where((f) =>
        f.para == _Para.todos ||
        (f.para == _Para.transportista) == soyTransportista).toList();

    return Screen(
      title: 'Ayuda',
      subtitle: 'Preguntas frecuentes',
      onBack: () => Navigator.of(context).pop(),
      children: [
        for (final f in mias)
          Panel(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(f.q, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.navy)),
              const SizedBox(height: 6),
              Text(f.a, style: TextStyle(fontSize: 13, color: AppColors.grisM, height: 1.5)),
            ]),
          ),
        Panel(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('¿No encontraste lo que buscabas?',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.navy)),
            const SizedBox(height: 6),
            Text('Escribinos y te respondemos. Si es sobre un viaje, mandá el número '
                'para poder buscarlo.',
                style: TextStyle(fontSize: 13, color: AppColors.grisM, height: 1.5)),
            const SizedBox(height: 14),
            AppButton(
              title: soporteEmail,
              icon: const Icon(Icons.email_outlined, size: 16, color: Colors.white),
              fullWidth: true,
              onPressed: () => launchUrl(Uri(scheme: 'mailto', path: soporteEmail)),
            ),
            if (soporteWhatsapp.isNotEmpty) ...[
              const SizedBox(height: 8),
              AppButton(
                title: 'Escribir por WhatsApp',
                variant: AppButtonVariant.outline,
                fullWidth: true,
                icon: Icon(Icons.chat_outlined, size: 16, color: AppColors.navy),
                onPressed: () => launchUrl(Uri.parse('https://wa.me/$soporteWhatsapp'),
                    mode: LaunchMode.externalApplication),
              ),
            ],
          ]),
        ),
      ],
    );
  }
}
