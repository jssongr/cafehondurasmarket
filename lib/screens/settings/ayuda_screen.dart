import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/screen.dart';

class _Faq {
  final String q;
  final String a;
  const _Faq(this.q, this.a);
}

const _faqs = [
  _Faq('¿Cómo publico una carga?', 'Andá a la pestaña "Publicar", completá los datos del envío y presioná "Publicar carga". Los transportistas verificados van a poder verla de inmediato en el mercado.'),
  _Faq('¿Cómo funciona el pago en garantía?', 'Cuando aceptás un viaje, el monto queda retenido por NexCarg. Se libera al transportista automáticamente al confirmarse la entrega, descontando la comisión de la plataforma.'),
  _Faq('¿Qué es el contrato digital?', 'Es un acuerdo que ambas partes firman dentro de la app antes de iniciar el viaje. El transportista no puede comenzar el trayecto hasta que las dos firmas estén completas.'),
  _Faq('¿Cuánto tarda la verificación de mi cuenta?', 'Un administrador revisa tu documento y tu selfie manualmente. Mientras tanto podés explorar la app, pero algunas acciones quedan bloqueadas hasta que te aprueben.'),
  _Faq('¿Puedo cancelar una carga publicada?', 'Sí, mientras nadie la haya aceptado. Una vez asignada a un transportista, contactalo por el chat para coordinar.'),
  _Faq('Olvidé mi contraseña, ¿qué hago?', 'En la pantalla de inicio de sesión, escribí tu correo y tocá "¿Olvidaste tu contraseña?". Te llega un correo con un enlace para elegir una contraseña nueva. Si no te llega, revisá spam o escribinos a soporte.'),
];

class AyudaScreen extends StatelessWidget {
  const AyudaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Screen(
      title: 'Ayuda',
      subtitle: 'Preguntas frecuentes',
      onBack: () => Navigator.of(context).pop(),
      children: [
        for (final f in _faqs)
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(f.q, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.navy)),
              const SizedBox(height: 6),
              Text(f.a, style: const TextStyle(fontSize: 12.5, color: AppColors.grisM, height: 1.45)),
            ]),
          ),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('¿No encontraste lo que buscabas?', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.navy)),
            const SizedBox(height: 6),
            const Text('Escribinos a soporte@nexcarg.com y te respondemos en menos de 24 horas.', style: TextStyle(fontSize: 12.5, color: AppColors.grisM, height: 1.45)),
          ]),
        ),
      ],
    );
  }
}
