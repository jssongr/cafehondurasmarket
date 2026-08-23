import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/constants.dart';
import '../../theme/theme.dart';

/// Piezas de la página de presentación. Viven aparte de `landing_screen.dart`
/// porque son texto de marketing que se va a retocar seguido, y no conviene
/// tocar el armado de la pantalla cada vez que cambia una frase.

/// Envoltura común: ancho máximo de lectura y aire alrededor. Sin esto, en una
/// pantalla de escritorio el texto cruza 1900 px y se vuelve ilegible.
class Seccion extends StatelessWidget {
  final bool amplio;
  /// Nulo = el fondo normal de página. No se puede dejar `AppColors.white` como
  /// valor por omisión porque ahora depende del tema y ya no es constante.
  final Color? fondo;
  final Widget child;
  const Seccion({super.key, required this.amplio, required this.child, this.fondo});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: fondo ?? AppColors.white,
      padding: EdgeInsets.symmetric(horizontal: amplio ? 40 : 22, vertical: amplio ? 72 : 48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          // El SizedBox no es decorativo: sin él, una sección cuyo contenido es
          // más angosto que 1120 se encoge y queda centrada, y los títulos de
          // unas secciones no alinean con los de las otras.
          child: SizedBox(width: double.infinity, child: child),
        ),
      ),
    );
  }
}

/// Pastilla de texto pequeño sobre fondo oscuro (encabezado del hero).
class Etiqueta extends StatelessWidget {
  final String texto;
  const Etiqueta({super.key, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
          color: Colors.white.withValues(alpha: 0.88),
        ),
      ),
    );
  }
}

/// Título de sección con antetítulo azul. Repetido en cinco secciones, así que
/// vive acá una sola vez.
class TituloSeccion extends StatelessWidget {
  final bool amplio;
  final String ante;
  final String titulo;
  final String? bajada;
  const TituloSeccion({super.key, required this.amplio, required this.ante, required this.titulo, this.bajada});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(ante.toUpperCase(),
          style: TextStyle(
              fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.blue, letterSpacing: 1.1)),
      const SizedBox(height: 10),
      // Los títulos traen el corte de línea puesto a mano para que en escritorio
      // queden en dos renglones parejos. En el teléfono ese corte estorba, así
      // que se quita y el texto se acomoda al ancho que haya.
      Text(amplio ? titulo : titulo.replaceAll('\n', ' '),
          style: TextStyle(
              fontSize: amplio ? 36 : 25,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
              height: 1.2,
              letterSpacing: -0.8)),
      if (bajada != null) ...[
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Text(bajada!,
              style: TextStyle(fontSize: 15, height: 1.6, color: AppColors.grisM)),
        ),
      ],
    ]);
  }
}

/// Los tres números que contestan "¿esto qué tan serio es?" antes de que
/// alguien tenga que leer nada.
class CifrasClave extends StatelessWidget {
  const CifrasClave({super.key});

  @override
  Widget build(BuildContext context) {
    final datos = [
      ('${paises.length}', 'países conectados'),
      ('$comisionTexto%', 'de comisión, solo al completar'),
      ('0', 'costo por publicar carga'),
    ];
    return Wrap(spacing: 44, runSpacing: 22, children: [
      for (final (numero, texto) in datos)
        Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(numero,
              style: const TextStyle(
                  fontSize: 34, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1.2)),
          const SizedBox(height: 2),
          Text(texto,
              style: TextStyle(fontSize: 12.5, color: Colors.white.withValues(alpha: 0.62), height: 1.35)),
        ]),
    ]);
  }
}

/// Franja con los países del corredor. Es la duda número uno de quien llega:
/// "¿trabajan en mi país?".
class Corredor extends StatelessWidget {
  const Corredor({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.gris50,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Column(children: [
            Text('OPERAMOS EN EL CORREDOR CENTROAMERICANO',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.grisM, letterSpacing: 1.2)),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final p in paises)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.gris100),
                      boxShadow: cardShadow,
                    ),
                    child: Text(p,
                        style: TextStyle(
                            fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.navy)),
                  ),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}

/// Los cinco pasos del viaje, de publicar a cobrar. Es la sección que más
/// preguntas contesta: quien no entiende el flujo no se registra.
class ComoFunciona extends StatelessWidget {
  final bool amplio;
  const ComoFunciona({super.key, required this.amplio});

  static const _pasos = [
    (
      Icons.edit_note_outlined,
      'Publicás tu carga',
      'Origen, destino, peso, tipo de mercancía y fecha. Publicar no cuesta nada y la ven todos los transportistas verificados de la ruta.',
    ),
    (
      Icons.gavel_outlined,
      'Recibís ofertas y elegís',
      'Los transportistas cotizan tu carga. Vos comparás precio, calificación y vehículo, y elegís con quién trabajar.',
    ),
    (
      Icons.description_outlined,
      'Firman el contrato digital',
      'Ambas partes firman dentro de la app. Queda registrado quién se comprometió a qué, con fecha y hora.',
    ),
    (
      Icons.lock_outline,
      'El pago queda retenido',
      'El dinero se guarda en garantía. El transportista sabe que existe y está reservado; vos sabés que no sale hasta que la carga llegue.',
    ),
    (
      Icons.my_location_outlined,
      'Seguís el viaje en vivo',
      'Mientras la carga va en camino podés ver dónde está en el mapa, con la ubicación que comparte el transportista desde su teléfono.',
    ),
    (
      Icons.verified_outlined,
      'Prueba de entrega y pago',
      'Al entregar se toma foto de la carga y firma de quien recibe. Con esa prueba se libera el pago automáticamente.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Seccion(
      amplio: amplio,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TituloSeccion(
          amplio: amplio,
          ante: 'Cómo funciona',
          titulo: 'De publicar la carga a cobrarla,\nen seis pasos.',
          bajada: 'Todo pasa dentro de NexCarg: la negociación, el contrato, el pago y la prueba '
              'de que la carga llegó. No hay que confiar en la palabra de nadie.',
        ),
        const SizedBox(height: 34),
        _Rejilla(
          amplio: amplio,
          columnas: amplio ? 3 : 1,
          hijos: [
            for (var i = 0; i < _pasos.length; i++)
              _TarjetaPaso(numero: i + 1, icono: _pasos[i].$1, titulo: _pasos[i].$2, texto: _pasos[i].$3),
          ],
        ),
      ]),
    );
  }
}

class _TarjetaPaso extends StatelessWidget {
  final int numero;
  final IconData icono;
  final String titulo;
  final String texto;
  const _TarjetaPaso({required this.numero, required this.icono, required this.titulo, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.gris100),
        boxShadow: cardShadow,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                colors: [AppColors.blueLight, AppColors.blue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(color: AppColors.blue.withValues(alpha: 0.32), blurRadius: 14, offset: const Offset(0, 6)),
              ],
            ),
            child: Icon(icono, color: Colors.white, size: 22),
          ),
          const Spacer(),
          Text('$numero',
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppColors.gris300.withValues(alpha: 0.7),
                  height: 1)),
        ]),
        const SizedBox(height: 16),
        Text(titulo,
            style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: AppColors.navy)),
        const SizedBox(height: 8),
        Text(texto, style: TextStyle(fontSize: 13.5, height: 1.55, color: AppColors.grisM)),
      ]),
    );
  }
}

/// Las dos caras del marketplace. Quien llega tiene que reconocerse en una de
/// las dos columnas en menos de cinco segundos.
class ParaQuien extends StatelessWidget {
  final bool amplio;
  final void Function({bool registro}) onEntrar;
  const ParaQuien({super.key, required this.amplio, required this.onEntrar});

  @override
  Widget build(BuildContext context) {
    final columnas = [
      _TarjetaPublico(
        icono: Icons.apartment_rounded,
        titulo: 'Si necesitás mover carga',
        texto: 'Publicás lo que hay que transportar y recibís cotizaciones de transportistas '
            'verificados, sin llamar a nadie ni buscar contactos.',
        lista: clienteSubtipos,
        boton: 'Publicar mi primera carga',
        onTap: () => onEntrar(registro: true),
        oscuro: false,
      ),
      _TarjetaPublico(
        icono: Icons.local_shipping_rounded,
        titulo: 'Si tenés camión',
        texto: 'Encontrás carga en tus rutas, cotizás desde el teléfono y cobrás con el respaldo '
            'de un contrato y el pago ya retenido antes de salir.',
        lista: transportistaSubtipos,
        boton: 'Buscar carga disponible',
        onTap: () => onEntrar(registro: true),
        oscuro: true,
      ),
    ];

    return Seccion(
      amplio: amplio,
      fondo: AppColors.gris50,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TituloSeccion(
          amplio: amplio,
          ante: 'Para quién es',
          titulo: 'Dos lados, una sola plataforma.',
          bajada: 'NexCarg junta a quien tiene mercancía con quien tiene camión. '
              'Ambos lados pasan por verificación de identidad antes de poder operar.',
        ),
        const SizedBox(height: 34),
        _Rejilla(amplio: amplio, columnas: amplio ? 2 : 1, hijos: columnas),
      ]),
    );
  }
}

class _TarjetaPublico extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String texto;
  final List<String> lista;
  final String boton;
  final VoidCallback onTap;
  final bool oscuro;
  const _TarjetaPublico({
    required this.icono,
    required this.titulo,
    required this.texto,
    required this.lista,
    required this.boton,
    required this.onTap,
    required this.oscuro,
  });

  @override
  Widget build(BuildContext context) {
    final fg = oscuro ? Colors.white : AppColors.navy;
    final fgSuave = oscuro ? Colors.white.withValues(alpha: 0.72) : AppColors.grisM;

    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: oscuro ? null : AppColors.white,
        gradient: oscuro
            ? LinearGradient(
                colors: [AppColors.marcaFondo2, AppColors.marcaFondo],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: oscuro ? Colors.transparent : AppColors.gris100),
        boxShadow: oscuro ? floatingShadow : cardShadow,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: oscuro ? Colors.white.withValues(alpha: 0.12) : AppColors.azulBg,
          ),
          child: Icon(icono, size: 25, color: oscuro ? Colors.white : AppColors.blue),
        ),
        const SizedBox(height: 18),
        Text(titulo, style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: fg, letterSpacing: -0.4)),
        const SizedBox(height: 10),
        Text(texto, style: TextStyle(fontSize: 14, height: 1.6, color: fgSuave)),
        const SizedBox(height: 18),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final s in lista)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                color: oscuro ? Colors.white.withValues(alpha: 0.10) : AppColors.gris50,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: oscuro ? Colors.white.withValues(alpha: 0.14) : AppColors.gris100),
              ),
              child: Text(s, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fgSuave)),
            ),
        ]),
        const SizedBox(height: 22),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(boton,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: oscuro ? AppColors.blueLight : AppColors.blue)),
            const SizedBox(width: 6),
            Icon(Icons.arrow_forward_rounded, size: 17, color: oscuro ? AppColors.blueLight : AppColors.blue),
          ]),
        ),
      ]),
    );
  }
}

/// Qué se puede mover. Sale de la misma lista que usa el formulario de
/// publicación, así que nunca se desactualiza respecto a la app.
class TiposDeCarga extends StatelessWidget {
  final bool amplio;
  const TiposDeCarga({super.key, required this.amplio});

  @override
  Widget build(BuildContext context) {
    return Seccion(
      amplio: amplio,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TituloSeccion(
          amplio: amplio,
          ante: 'Qué se mueve',
          titulo: 'Desde un pallet suelto hasta\nun contenedor de 40 pies.',
          bajada: 'Si tu mercancía cabe en un camión del corredor, cabe en NexCarg. '
              'La carga peligrosa se marca aparte para que solo la coticen transportistas habilitados.',
        ),
        const SizedBox(height: 30),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final t in tiposCarga)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                decoration: BoxDecoration(
                  color: AppColors.gris50,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.gris100),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(tci[t] ?? Icons.inventory_2_outlined, size: 19, color: AppColors.blue),
                  const SizedBox(width: 9),
                  Text(t,
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.navy)),
                ]),
              ),
          ],
        ),
        const SizedBox(height: 26),
        Text('Vehículos disponibles: ${tiposVehiculo.join(' · ')}.',
            style: TextStyle(fontSize: 13, height: 1.6, color: AppColors.grisM)),
      ]),
    );
  }
}

/// Por qué confiar. El transporte de carga en la región se mueve por
/// recomendación; esta sección tiene que reemplazar a la persona que
/// normalmente te recomienda un transportista.
class PorQueConfiar extends StatelessWidget {
  final bool amplio;
  const PorQueConfiar({super.key, required this.amplio});

  static const _puntos = [
    (
      Icons.badge_outlined,
      'Identidad verificada a mano',
      'Nadie opera sin que una persona de NexCarg revise su documento de identidad, su licencia o los papeles de la empresa. No es un registro automático.',
    ),
    (
      Icons.draw_outlined,
      'Contrato digital firmado',
      'Cada viaje genera un contrato que ambas partes firman antes de mover nada, con las condiciones y el precio acordado.',
    ),
    (
      Icons.account_balance_wallet_outlined,
      'Pago retenido en garantía',
      'El cliente deposita y el dinero queda retenido. No se libera hasta que la entrega esté probada, y el transportista sabe desde el inicio que el pago existe.',
    ),
    (
      Icons.map_outlined,
      'Ubicación en tiempo real',
      'El transportista comparte su ubicación desde el teléfono durante el viaje, siempre avisándole antes y pudiendo dejar de compartirla cuando quiera.',
    ),
    (
      Icons.photo_camera_outlined,
      'Prueba de entrega',
      'Foto de la carga entregada, nombre y firma de quien recibió. Queda guardado en el historial del viaje para las dos partes.',
    ),
    (
      Icons.reviews_outlined,
      'Calificaciones reales',
      'Solo califica quien de verdad hizo el viaje. La calificación acompaña al perfil en cada cotización.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Seccion(
      amplio: amplio,
      fondo: AppColors.gris50,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TituloSeccion(
          amplio: amplio,
          ante: 'Seguridad',
          titulo: 'Mover carga con alguien que\nno conocés, sin apostar.',
          bajada: 'La confianza no se pide, se construye con controles. Estos son los que trae '
              'la plataforma de fábrica, en cada viaje.',
        ),
        const SizedBox(height: 34),
        _Rejilla(
          amplio: amplio,
          columnas: amplio ? 3 : 1,
          hijos: [
            for (final (icono, titulo, texto) in _puntos)
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: AppColors.gris100),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(icono, size: 24, color: AppColors.blue),
                  const SizedBox(height: 14),
                  Text(titulo,
                      style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: AppColors.navy)),
                  const SizedBox(height: 7),
                  Text(texto, style: TextStyle(fontSize: 13, height: 1.55, color: AppColors.grisM)),
                ]),
              ),
          ],
        ),
      ]),
    );
  }
}

/// Contacto. Sin esto, una empresa que quiere mover volumen no tiene a quién
/// escribirle y se va.
class Contacto extends StatelessWidget {
  final bool amplio;
  const Contacto({super.key, required this.amplio});

  @override
  Widget build(BuildContext context) {
    return Seccion(
      amplio: amplio,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TituloSeccion(
          amplio: amplio,
          ante: 'Contacto',
          titulo: '¿Movés volumen? Hablemos.',
          bajada: 'Si tu empresa mueve carga seguido por el corredor, escribinos y te acompañamos '
              'en el registro y en las primeras publicaciones.',
        ),
        const SizedBox(height: 26),
        Wrap(spacing: 12, runSpacing: 12, children: [
          _TarjetaContacto(
            icono: Icons.mail_outline_rounded,
            titulo: 'Correo',
            valor: soporteEmail,
            onTap: () => launchUrl(Uri(scheme: 'mailto', path: soporteEmail)),
          ),
          if (soporteWhatsapp.isNotEmpty)
            _TarjetaContacto(
              icono: Icons.chat_bubble_outline_rounded,
              titulo: 'WhatsApp',
              valor: 'Escribir por WhatsApp',
              onTap: () => launchUrl(
                Uri.parse('https://wa.me/$soporteWhatsapp'),
                mode: LaunchMode.externalApplication,
              ),
            ),
          const _TarjetaContacto(
            icono: Icons.schedule_rounded,
            titulo: 'Horario de atención',
            valor: 'Lunes a viernes, 8:00 a 18:00 (hora de Honduras)',
          ),
        ]),
      ]),
    );
  }
}

class _TarjetaContacto extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String valor;
  final VoidCallback? onTap;
  const _TarjetaContacto({required this.icono, required this.titulo, required this.valor, this.onTap});

  @override
  Widget build(BuildContext context) {
    final tarjeta = Container(
      width: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.gris100),
        boxShadow: cardShadow,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icono, size: 22, color: AppColors.blue),
        const SizedBox(height: 12),
        Text(titulo, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.grisM)),
        const SizedBox(height: 4),
        Text(valor,
            style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                height: 1.4,
                color: onTap != null ? AppColors.blue : AppColors.navy)),
      ]),
    );

    if (onTap == null) return tarjeta;
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(AppRadius.lg), child: tarjeta);
  }
}

/// Rejilla simple de N columnas con todas las tarjetas del mismo alto por fila.
/// GridView no sirve acá: exige una relación de aspecto fija y el texto de cada
/// tarjeta tiene largo distinto.
class _Rejilla extends StatelessWidget {
  final bool amplio;
  final int columnas;
  final List<Widget> hijos;
  const _Rejilla({required this.amplio, required this.columnas, required this.hijos});

  @override
  Widget build(BuildContext context) {
    const espacio = 16.0;
    if (columnas <= 1) {
      return Column(
        children: [
          for (var i = 0; i < hijos.length; i++)
            Padding(padding: EdgeInsets.only(bottom: i == hijos.length - 1 ? 0 : espacio), child: hijos[i]),
        ],
      );
    }

    final filas = <Widget>[];
    for (var i = 0; i < hijos.length; i += columnas) {
      final fila = hijos.sublist(i, (i + columnas).clamp(0, hijos.length));
      filas.add(Padding(
        padding: EdgeInsets.only(bottom: i + columnas >= hijos.length ? 0 : espacio),
        // IntrinsicHeight es lo que iguala el alto de las tarjetas de una fila:
        // dentro de un scroll el alto es ilimitado y `stretch` solo por sí solo
        // reventaría con una restricción infinita.
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var j = 0; j < columnas; j++) ...[
                if (j > 0) const SizedBox(width: espacio),
                // Los huecos de la última fila se rellenan para que las tarjetas
                // no se estiren al ancho completo cuando sobran columnas.
                Expanded(child: j < fila.length ? fila[j] : const SizedBox.shrink()),
              ],
            ],
          ),
        ),
      ));
    }
    return Column(children: filas);
  }
}
