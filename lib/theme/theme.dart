import 'package:flutter/material.dart';

/// Paleta de NexCarg.
///
/// Los colores que dependen del tema son getters, no constantes: leen la
/// variante clara u oscura según cómo esté puesta la app en ese momento. El
/// cambio se aplica en `AppColors.usarTema()`, que `main.dart` llama antes de
/// dibujar nada.
///
/// Hay tres familias, y la diferencia importa:
///
///  · **Tinta y superficies** (`navy`, `texto`, `white`, `gris*`) — se dan
///    vuelta con el tema. `navy` es el color del texto y de los iconos sobre
///    una superficie normal, así que en oscuro tiene que ser casi blanco.
///  · **Relleno fuerte** (`solido`) — pastillas y burbujas seleccionadas, que
///    siempre llevan texto blanco encima. No puede seguir a `navy`: quedaría
///    blanco sobre blanco.
///  · **Marca** (`marcaFondo*`) — los fondos oscuros del encabezado y de la
///    página de presentación. Son la identidad de NexCarg y no cambian nunca,
///    igual que el logo.
class AppColors {
  AppColors._();

  static bool _oscuro = false;

  /// Se llama una vez por dibujado, desde `main.dart`.
  static void usarTema(Brightness brillo) => _oscuro = brillo == Brightness.dark;

  /// Para las piezas que necesitan ajustar algo más que un color.
  static bool get esOscuro => _oscuro;

  static Color _t(Color claro, Color oscuro) => _oscuro ? oscuro : claro;

  // --- Marca: fondos oscuros que no cambian con el tema -------------------
  static const marcaFondo = Color(0xFF0F1F29);
  static const marcaFondo2 = Color(0xFF1E3A52);
  static const marcaFondo3 = Color(0xFF2C5468);

  // Se mantienen los nombres viejos porque solo aparecen en degradados de
  // marca, que son oscuros en los dos temas.
  static const navyLight = marcaFondo2;
  static const navyXLight = marcaFondo3;

  // --- Tinta ---------------------------------------------------------------
  /// Títulos, iconos y texto fuerte sobre una superficie.
  static Color get navy => _t(const Color(0xFF0F1F29), const Color(0xFFE7EEF6));
  static Color get texto => _t(const Color(0xFF182233), const Color(0xFFDCE4EE));
  static Color get grisM => _t(const Color(0xFF8A93A3), const Color(0xFF8C9AAC));

  /// Relleno de lo que está seleccionado, siempre con contenido blanco encima.
  static Color get solido => _t(const Color(0xFF0F1F29), const Color(0xFF2E5F86));

  // --- Superficies ---------------------------------------------------------
  /// Fondo de la pantalla, por detrás de las tarjetas.
  static Color get bg => _t(const Color(0xFFF1F5F9), const Color(0xFF0B131A));

  /// Las tarjetas y los paneles. Se llama `white` por historia; en oscuro es el
  /// gris azulado que se levanta un paso del fondo.
  static Color get white => _t(const Color(0xFFFFFFFF), const Color(0xFF16222D));

  /// Un relleno apenas separado de la superficie: campos, casillas, filas.
  static Color get gris50 => _t(const Color(0xFFF8F9FB), const Color(0xFF1D2B38));

  /// Bordes y separadores.
  static Color get gris100 => _t(const Color(0xFFE7E9ED), const Color(0xFF2A3A49));
  static Color get gris300 => _t(const Color(0xFFC7CCD4), const Color(0xFF3E5163));

  // --- Marca de color ------------------------------------------------------
  // El azul se aclara en oscuro: el original es muy saturado y sobre fondo
  // negro vibra y cansa la vista.
  static Color get blue => _t(const Color(0xFF0D47FF), const Color(0xFF5C86FF));
  static const blueLight = Color(0xFF5470FF);

  static Color get green => _t(const Color(0xFF00C896), const Color(0xFF2EDCAE));
  static Color get greenBg => _t(const Color(0xFFDDF9F0), const Color(0xFF10362E));

  static Color get amber => _t(const Color(0xFFFFB800), const Color(0xFFFFC736));
  static const amberLight = Color(0xFFFFE59A);
  static Color get amberBg => _t(const Color(0xFFFFF4D6), const Color(0xFF3B2E0B));
  static Color get amberText => _t(const Color(0xFF8A5B00), const Color(0xFFFFD166));

  // --- Estados -------------------------------------------------------------
  // Cada par es color de texto + su fondo pastel. En oscuro el pastel se
  // convierte en un tinte apagado y el texto se aclara, para que la etiqueta
  // siga leyéndose sin brillar.
  static Color get rojo => _t(const Color(0xFFDC2626), const Color(0xFFFF8A80));
  static Color get rojoBg => _t(const Color(0xFFFEF2F2), const Color(0xFF3A1A1A));
  static Color get azul => _t(const Color(0xFF1E40AF), const Color(0xFF8FB0FF));
  static Color get azulBg => _t(const Color(0xFFDBEAFE), const Color(0xFF16294C));
  static Color get verde => _t(const Color(0xFF15803D), const Color(0xFF6EE7A0));
  static Color get verdeBg => _t(const Color(0xFFDCFCE7), const Color(0xFF11331F));
  static Color get indigo => _t(const Color(0xFF4338CA), const Color(0xFFA5A0FF));
  static Color get indigoBg => _t(const Color(0xFFE0E7FF), const Color(0xFF221F4A));
}

class BadgeStyle {
  final Color bg;
  final Color fg;
  const BadgeStyle(this.bg, this.fg);
}

/// Getter, no constante: los colores de estado cambian con el tema.
Map<String, BadgeStyle> get badgeColors => {
  'publicada': BadgeStyle(AppColors.azulBg, AppColors.azul),
  'asignada': BadgeStyle(AppColors.amberBg, AppColors.amberText),
  'en_transito': BadgeStyle(AppColors.indigoBg, AppColors.indigo),
  'entregada': BadgeStyle(AppColors.verdeBg, AppColors.verde),
  'cancelada': BadgeStyle(AppColors.rojoBg, AppColors.rojo),
  'verificado': BadgeStyle(AppColors.verdeBg, AppColors.verde),
  'sinVerificar': BadgeStyle(AppColors.rojoBg, AppColors.rojo),
};

const Map<String, String> badgeLabels = {
  'publicada': 'Publicada',
  'asignada': 'Asignada',
  'en_transito': 'En tránsito',
  'entregada': 'Entregada',
  'cancelada': 'Cancelada',
};

class AppSpacing {
  AppSpacing._();
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 28.0;
  static const xxxl = 36.0;
}

class AppRadius {
  AppRadius._();
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const pill = 999.0;
}

// --- Profundidad -----------------------------------------------------------
//
// Cada nivel son DOS sombras, no una. La de arriba es corta y cerrada: es el
// contacto de la pieza con lo que tiene debajo, y es la que hace que se lea
// como un objeto y no como un rectángulo pintado. La segunda es amplia y
// difusa, y da la distancia. Una sola sombra difusa se ve borrosa; una sola
// sombra dura se ve recortada.
//
// Son getters y no listas `final` porque una lista de nivel superior se calcula
// una sola vez, con el tema que hubiera en ese momento, y se quedaría con esa
// sombra para siempre.

List<BoxShadow> _sombra({required double alto, required double difuso, required double fuerza}) {
  final base = AppColors._oscuro ? Colors.black : AppColors.marcaFondo;
  final f = AppColors._oscuro ? fuerza * 2.6 : fuerza;
  return [
    BoxShadow(color: base.withValues(alpha: f * 0.55), offset: Offset(0, alto * 0.25), blurRadius: difuso * 0.3),
    BoxShadow(color: base.withValues(alpha: f), offset: Offset(0, alto), blurRadius: difuso),
  ];
}

/// Apoyado en la superficie: filas, campos, pastillas.
List<BoxShadow> get sombraApoyo => _sombra(alto: 2, difuso: 6, fuerza: 0.05);

/// Tarjetas y paneles.
List<BoxShadow> get cardShadow => _sombra(alto: 6, difuso: 18, fuerza: 0.07);

/// Lo que está por encima de todo: modales, avisos, botones principales.
List<BoxShadow> get floatingShadow => _sombra(alto: 14, difuso: 34, fuerza: 0.13);

/// Resplandor del color propio de un botón. Es lo que hace que un botón se vea
/// encendido en vez de simplemente pintado.
List<BoxShadow> resplandor(Color color, {double fuerza = 0.4}) => [
      BoxShadow(color: color.withValues(alpha: fuerza), offset: const Offset(0, 8), blurRadius: 22, spreadRadius: -4),
    ];

/// Degradado apenas perceptible para una superficie: arriba un punto más claro
/// que abajo, como si le diera luz de arriba. En claro se logra aclarando; en
/// oscuro, al revés, oscureciendo el borde de abajo.
LinearGradient get degradadoSuperficie => LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: AppColors._oscuro
          ? [const Color(0xFF1B2937), const Color(0xFF141F29)]
          : [Colors.white, const Color(0xFFFAFBFD)],
    );

/// Borde de una tarjeta. Arriba se aclara para simular el canto iluminado.
Border get bordeSuperficie => Border.all(
      color: AppColors._oscuro
          ? Colors.white.withValues(alpha: 0.06)
          : AppColors.marcaFondo.withValues(alpha: 0.06),
    );

/// Degradado de marca, para encabezados y piezas destacadas.
LinearGradient get degradadoMarca => const LinearGradient(
      colors: [AppColors.marcaFondo2, AppColors.marcaFondo],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

/// Degradado del azul de acción. Se aclara arriba para que el botón tenga
/// volumen en vez de ser un bloque plano de color.
LinearGradient get degradadoAzul => LinearGradient(
      colors: AppColors._oscuro
          ? [const Color(0xFF6E93FF), const Color(0xFF3F6BF5)]
          : [const Color(0xFF3A6BFF), const Color(0xFF0D3FE8)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

ThemeData buildAppTheme() {
  final base = ThemeData(useMaterial3: true, fontFamily: 'AppSans');
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.blue,
      secondary: AppColors.amber,
      surface: AppColors.white,
      error: AppColors.rojo,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.texto,
      displayColor: AppColors.navy,
    ),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
  );
}

/// Variante oscura. Las pantallas propias se pintan con `AppColors`, que ya
/// devuelve los valores oscuros cuando corresponde; esto cubre lo que dibuja
/// Material por su cuenta (diálogos, campos, interruptores).
ThemeData buildAppDarkTheme() {
  // Poner el interruptor antes de leer la paleta: si no, este tema se armaría
  // con los colores claros.
  AppColors.usarTema(Brightness.dark);
  final base = ThemeData(useMaterial3: true, brightness: Brightness.dark, fontFamily: 'AppSans');
  final tema = base.copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.blue,
      secondary: AppColors.amber,
      surface: AppColors.white,
      error: AppColors.rojo,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.texto,
      displayColor: AppColors.navy,
    ),
    dialogTheme: base.dialogTheme.copyWith(backgroundColor: AppColors.white),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
  );
  AppColors.usarTema(Brightness.light);
  return tema;
}
