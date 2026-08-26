import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/constants.dart';
import '../../theme/theme.dart';
import '../auth/auth_screen.dart';
import '../settings/legal_screen.dart';
import 'secciones.dart';
import 'viaje_vivo.dart';

/// Lo primero que ve alguien que llega desde un anuncio. Antes caía directo en
/// el formulario de acceso, sin saber qué es NexCarg ni por qué darle sus datos.
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _entrar({bool registro = false}) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AuthScreen(iniciarEnRegistro: registro),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.sizeOf(context).width;
    final amplio = ancho >= 900;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(children: [
        _BarraSuperior(amplio: amplio, onEntrar: _entrar),
        Expanded(
          child: SingleChildScrollView(
            controller: _scroll,
            child: Column(children: [
              HeroPrincipal(amplio: amplio, onEntrar: _entrar),
              const Corredor(),
              ComoFunciona(amplio: amplio),
              ParaQuien(amplio: amplio, onEntrar: _entrar),
              TiposDeCarga(amplio: amplio),
              PorQueConfiar(amplio: amplio),
              Preguntas(amplio: amplio),
              Contacto(amplio: amplio),
              _Cierre(amplio: amplio, onEntrar: _entrar),
              const _PieDePagina(),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _BarraSuperior extends StatelessWidget {
  final bool amplio;
  final void Function({bool registro}) onEntrar;
  const _BarraSuperior({required this.amplio, required this.onEntrar});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.marcaFondo,
      padding: EdgeInsets.symmetric(horizontal: amplio ? 40 : 18, vertical: 12),
      child: SafeArea(
        bottom: false,
        child: Row(children: [
          Image.asset('assets/logo-blanco.png', height: amplio ? 34 : 28),
          const Spacer(),
          TextButton(
            onPressed: () => onEntrar(),
            child: Text(amplio ? 'Iniciar sesión' : 'Entrar',
                style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 6),
          _BotonRelieve(
            texto: amplio ? 'Crear cuenta gratis' : 'Crear cuenta',
            onTap: () => onEntrar(registro: true),
          ),
        ]),
      ),
    );
  }
}

/// Botón con volumen: degradado, luz arriba y sombra proyectada. Es el detalle
/// que separa "una app hecha en un rato" de una plataforma que inspira confianza.
class _BotonRelieve extends StatelessWidget {
  final String texto;
  final VoidCallback onTap;
  final bool grande;
  const _BotonRelieve({required this.texto, required this.onTap, this.grande = false});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: LinearGradient(
          colors: [AppColors.blueLight, AppColors.blue],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(color: AppColors.blue.withValues(alpha: 0.45), blurRadius: 22, offset: const Offset(0, 8)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: grande ? 30 : 18, vertical: grande ? 17 : 11),
            child: Text(texto,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: grande ? 15.5 : 13.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1)),
          ),
        ),
      ),
    );
  }
}

class HeroPrincipal extends StatelessWidget {
  final bool amplio;
  final void Function({bool registro}) onEntrar;
  const HeroPrincipal({super.key, required this.amplio, required this.onEntrar});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.marcaFondo, AppColors.marcaFondo2, AppColors.marcaFondo3],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(children: [
        // Halo de luz detrás del texto: da profundidad sin cargar la pantalla.
        Positioned(
          right: -120,
          top: -80,
          child: Container(
            width: 420,
            height: 420,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppColors.blue.withValues(alpha: 0.35),
                AppColors.blue.withValues(alpha: 0),
              ]),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: amplio ? 40 : 22, vertical: amplio ? 76 : 48),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: amplio
                  // En pantalla ancha, el texto solo dejaba la mitad derecha
                  // vacía. La pieza del viaje llena ese lado y de paso muestra
                  // el producto, que es lo que de verdad convence.
                  ? Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                      Expanded(flex: 6, child: _Texto(amplio: amplio, onEntrar: onEntrar)),
                      const SizedBox(width: 48),
                      Expanded(flex: 5, child: ViajeVivo(amplio: amplio)),
                    ])
                  : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _Texto(amplio: amplio, onEntrar: onEntrar),
                      const SizedBox(height: 36),
                      ViajeVivo(amplio: amplio),
                    ]),
            ),
          ),
        ),
      ]),
    );
  }
}

class _Texto extends StatelessWidget {
  final bool amplio;
  final void Function({bool registro}) onEntrar;
  const _Texto({required this.amplio, required this.onEntrar});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // La lista completa de países se repite abajo en su propia
      // franja; en el teléfono ocupaba dos renglones acá arriba.
      Etiqueta(texto: 'De Panamá a Guatemala · ${paises.length} países'),
      const SizedBox(height: 22),
      Text(
        // El corte de línea solo se fuerza en pantalla ancha: en el
        // teléfono el texto ya se acomoda solo y el salto le abría un
        // hueco raro en medio del titular.
        amplio
            ? 'Tu carga por toda\nCentroamérica, con quien\npuedas verificar.'
            : 'Tu carga por toda Centroamérica, con quien puedas verificar.',
        style: TextStyle(
          fontSize: amplio ? 44 : 31,
          height: 1.12,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -1.2,
        ),
      ),
      const SizedBox(height: 18),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Text(
          'NexCarg conecta a las empresas que necesitan mover mercancía con transportistas '
          'verificados del corredor centroamericano. Publicás tu carga, recibís ofertas, '
          'firmás un contrato digital y el pago queda retenido hasta que la entrega esté probada.',
          style: TextStyle(
            fontSize: amplio ? 17 : 14.5,
            height: 1.6,
            color: Colors.white.withValues(alpha: 0.82),
          ),
        ),
      ),
      const SizedBox(height: 30),
      Wrap(spacing: 12, runSpacing: 12, children: [
        _BotonRelieve(texto: 'Publicar mi primera carga', grande: true, onTap: () => onEntrar(registro: true)),
        _BotonBorde(texto: 'Soy transportista', onTap: () => onEntrar(registro: true)),
      ]),
      const SizedBox(height: 40),
      const CifrasClave(),
    ]);
  }
}

class _BotonBorde extends StatelessWidget {
  final String texto;
  final VoidCallback onTap;
  const _BotonBorde({required this.texto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.28), width: 1.4),
          ),
          child: Text(texto,
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}

class _Cierre extends StatelessWidget {
  final bool amplio;
  final void Function({bool registro}) onEntrar;
  const _Cierre({required this.amplio, required this.onEntrar});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: amplio ? 40 : 22, vertical: amplio ? 72 : 52),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.marcaFondo2, AppColors.marcaFondo],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(children: [
            Text('Empezá hoy. Crear la cuenta es gratis.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: amplio ? 34 : 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.6)),
            const SizedBox(height: 12),
            Text(
              'Solo cobramos cuando movés carga: $comisionTexto% sobre cada viaje completado. '
              'Sin mensualidad ni costo por publicar.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.5, height: 1.55, color: Colors.white.withValues(alpha: 0.78)),
            ),
            const SizedBox(height: 26),
            _BotonRelieve(texto: 'Crear mi cuenta', grande: true, onTap: () => onEntrar(registro: true)),
          ]),
        ),
      ),
    );
  }
}

class _PieDePagina extends StatelessWidget {
  const _PieDePagina();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.marcaFondo,
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 30),
      child: Column(children: [
        Image.asset('assets/logo-blanco.png', height: 26),
        const SizedBox(height: 14),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 20,
          runSpacing: 8,
          children: [
            _EnlacePie(
              texto: 'Términos de uso',
              onTap: (c) => Navigator.of(c).push(
                  MaterialPageRoute(builder: (_) => const LegalScreen(esTerminos: true))),
            ),
            _EnlacePie(
              texto: 'Política de privacidad',
              onTap: (c) => Navigator.of(c).push(
                  MaterialPageRoute(builder: (_) => const LegalScreen(esTerminos: false))),
            ),
            _EnlacePie(
              texto: soporteEmail,
              onTap: (_) => launchUrl(Uri(scheme: 'mailto', path: soporteEmail)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('© ${DateTime.now().year} NexCarg. Transporte de carga terrestre en el corredor centroamericano.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.5, color: Colors.white.withValues(alpha: 0.5), height: 1.4)),
      ]),
    );
  }
}

class _EnlacePie extends StatelessWidget {
  final String texto;
  final void Function(BuildContext) onTap;
  const _EnlacePie({required this.texto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(context),
      child: Text(texto,
          style: TextStyle(fontSize: 12.5, color: Colors.white.withValues(alpha: 0.72), fontWeight: FontWeight.w600)),
    );
  }
}
