import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/screen.dart';

class _Section {
  final String title;
  final String body;
  const _Section(this.title, this.body);
}

const _terminos = [
  _Section('1. Qué es NexCarg',
      'NexCarg es una plataforma que conecta a clientes que necesitan transportar carga con transportistas independientes y empresas de transporte en el corredor Panamá–Costa Rica–Nicaragua–Honduras–El Salvador–Guatemala. NexCarg actúa como intermediario tecnológico: no es transportista ni propietario de la carga, y no se hace responsable por el transporte físico de la mercancía.'),
  _Section('2. Cuentas y verificación',
      'Para usar NexCarg debes registrarte con datos reales, incluyendo un documento de identidad y una selfie de verificación. Un administrador revisa manualmente estos documentos antes de habilitar todas las funciones de tu cuenta. Eres responsable de mantener la confidencialidad de tu contraseña y de toda actividad que ocurra en tu cuenta.'),
  _Section('3. Publicación y aceptación de cargas',
      'Los clientes publican cargas con información veraz (peso, ruta, presupuesto, naturaleza de la mercancía). Los transportistas aceptan o cotizan viajes según su capacidad real. Publicar información falsa, o aceptar un viaje sin capacidad para cumplirlo, puede resultar en la suspensión de la cuenta.'),
  _Section('4. Pagos y comisión',
      'NexCarg cobra una comisión de servicio del 5% sobre el monto acordado de cada viaje. Cuando el pago se procese dentro de la plataforma, el monto queda retenido en garantía hasta que se confirme la entrega, momento en el cual se libera al transportista menos la comisión correspondiente.'),
  _Section('5. Cancelaciones',
      'Una carga publicada puede cancelarse libremente mientras ningún transportista la haya aceptado. Una vez asignada, ambas partes deben coordinar cualquier cambio o cancelación directamente por el chat de la plataforma.'),
  _Section('6. Conducta prohibida',
      'No está permitido: publicar cargas o documentos falsos, suplantar la identidad de otra persona o empresa, usar la plataforma para transportar mercancía ilegal, o acosar/discriminar a otros usuarios. El incumplimiento puede resultar en suspensión o cierre permanente de la cuenta.'),
  _Section('7. Limitación de responsabilidad',
      'NexCarg facilita el contacto y la coordinación entre las partes, pero no garantiza la condición de la carga durante el transporte ni el cumplimiento de los acuerdos entre cliente y transportista. Cada parte es responsable de verificar la información de la otra antes de acordar un viaje.'),
  _Section('8. Cambios a estos términos',
      'Podemos actualizar estos términos ocasionalmente. Los cambios importantes se notificarán dentro de la app. Seguir usando NexCarg después de un cambio implica que lo aceptas.'),
  _Section('9. Contacto', 'Dudas sobre estos términos: soporte@nexcarg.com'),
];

const _privacidad = [
  _Section('1. Qué datos recolectamos',
      'Nombre o razón social, correo electrónico, teléfono, país, documento de identidad, selfie de verificación, y — si eres transportista — datos del vehículo. Durante un viaje activo también registramos el progreso de la ruta para el seguimiento GPS.'),
  _Section('2. Para qué usamos tus datos',
      'Para verificar tu identidad, operar el mercado de cargas (mostrar tu perfil a la contraparte de un viaje), procesar pagos y comisiones, calcular tu calificación, y comunicarnos contigo sobre tu cuenta.'),
  _Section('3. Con quién se comparte',
      'La contraparte de un viaje (cliente o transportista) puede ver tu nombre, calificación, estado de verificación y foto de perfil para coordinar el envío. No vendemos ni compartimos tus datos con terceros ajenos a la operación de la plataforma.'),
  _Section('4. Dónde se almacenan',
      'Tus datos se guardan en una base de datos con acceso restringido por permisos a nivel de fila: cada usuario solo puede leer y modificar la información que le corresponde. Los documentos de identidad y selfies se almacenan en un espacio de archivos separado.'),
  _Section('5. Tus derechos',
      'Puedes revisar y actualizar tus datos personales desde "Mi perfil". Para solicitar la eliminación completa de tu cuenta y tus datos, escribe a soporte@nexcarg.com.'),
  _Section('6. Retención de datos',
      'Conservamos tu información mientras tu cuenta esté activa. El historial de viajes completados se conserva por motivos de facturación y resolución de disputas incluso después de cerrar la cuenta.'),
  _Section('7. Contacto', 'Dudas sobre esta política: soporte@nexcarg.com'),
];

class LegalScreen extends StatelessWidget {
  final bool esTerminos;
  const LegalScreen({super.key, required this.esTerminos});

  @override
  Widget build(BuildContext context) {
    final secciones = esTerminos ? _terminos : _privacidad;
    return Screen(
      title: esTerminos ? 'Términos de Uso' : 'Política de Privacidad',
      subtitle: 'Última actualización: julio 2026',
      onBack: () => Navigator.of(context).pop(),
      children: [
        for (final s in secciones)
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.title, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.navy)),
              const SizedBox(height: 6),
              Text(s.body, style: TextStyle(fontSize: 12.5, color: AppColors.grisM, height: 1.5)),
            ]),
          ),
      ],
    );
  }
}
