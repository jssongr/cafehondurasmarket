import 'package:flutter/material.dart';
import '../models/models.dart';

const List<String> paises = ['Panamá', 'Costa Rica', 'Nicaragua', 'Honduras', 'El Salvador', 'Guatemala', 'México'];

final Map<String, int> paisIdx = {for (var i = 0; i < paises.length; i++) paises[i]: i};

const Map<String, List<String>> ciudades = {
  'Panamá': ['Ciudad de Panamá', 'Colón', 'David'],
  'Costa Rica': ['San José', 'Limón', 'Alajuela'],
  'Nicaragua': ['Managua', 'León', 'Chinandega'],
  'Honduras': ['Tegucigalpa', 'San Pedro Sula', 'Puerto Cortés'],
  'El Salvador': ['San Salvador', 'Santa Ana', 'Acajutla'],
  'Guatemala': ['Ciudad de Guatemala', 'Puerto Barrios', 'Quetzaltenango'],
  'México': ['Tapachula', 'Ciudad de México', 'Veracruz'],
};

const List<String> tiposCarga = [
  'Carga general', 'Perecederos', 'Carga refrigerada', "Contenedor 20'", "Contenedor 40'",
  'Graneles', 'Maquinaria/Equipo', 'Materiales de construcción', 'Textiles', 'Electrónicos', 'Químicos (no peligrosos)',
];

const Map<String, IconData> tci = {
  'Carga general': Icons.inventory_2_outlined,
  'Perecederos': Icons.eco_outlined,
  'Carga refrigerada': Icons.ac_unit_outlined,
  "Contenedor 20'": Icons.directions_boat_outlined,
  "Contenedor 40'": Icons.directions_boat_outlined,
  'Graneles': Icons.grass_outlined,
  'Maquinaria/Equipo': Icons.construction_outlined,
  'Materiales de construcción': Icons.apartment_outlined,
  'Textiles': Icons.checkroom_outlined,
  'Electrónicos': Icons.laptop_mac_outlined,
  'Químicos (no peligrosos)': Icons.science_outlined,
};

const List<String> tiposVehiculo = [
  'Camión rabón (3-5 ton)', 'Furgón mediano', 'Cabezal + plataforma',
  'Cabezal + rampla refrigerada (Reefer)', 'Cama baja (maquinaria)', 'Volteo',
];

const List<String> clienteSubtipos = ['Empresa importadora', 'Empresa exportadora', 'Fabricante', 'Distribuidor', 'Comercio', 'Operador logístico'];
const List<String> transportistaSubtipos = ['Transportista independiente', 'Conductor de flota', 'Empresa con flota de camiones'];

const double comisionPct = 5;

/// `comisionPct` es un double: interpolarlo directo escribe "5.0%" en pantalla.
/// Esto lo deja en "5%" mientras sea entero, y en "4.5%" si algún día no lo es.
final String comisionTexto =
    comisionPct == comisionPct.roundToDouble() ? comisionPct.toStringAsFixed(0) : '$comisionPct';

/// Dirección pública de la app. La usa Supabase como destino del enlace de
/// recuperación de contraseña, así que debe estar también en la lista de
/// "Redirect URLs" de Supabase → Authentication → URL Configuration.
const String urlApp = 'https://nexcarg.com';

const String soporteEmail = 'soporte@nexcarg.com';
// Número de WhatsApp de soporte en formato internacional sin signos (ej: '50499998888').
// Se deja vacío hasta tener un número real; el botón de WhatsApp no se muestra mientras esté vacío.
const String soporteWhatsapp = '';

const Map<TipoUsuario, IconData> tipoIcon = {
  TipoUsuario.cliente: Icons.apartment,
  TipoUsuario.transportista: Icons.local_shipping,
  TipoUsuario.admin: Icons.verified_user,
};
