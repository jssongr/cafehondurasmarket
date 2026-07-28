export const PAISES = ['Panamá', 'Costa Rica', 'Nicaragua', 'Honduras', 'El Salvador', 'Guatemala', 'México'] as const;
export const PAIS_IDX: Record<string, number> = Object.fromEntries(PAISES.map((p, i) => [p, i]));

export const CIUDADES: Record<string, string[]> = {
  'Panamá': ['Ciudad de Panamá', 'Colón', 'David'],
  'Costa Rica': ['San José', 'Limón', 'Alajuela'],
  'Nicaragua': ['Managua', 'León', 'Chinandega'],
  'Honduras': ['Tegucigalpa', 'San Pedro Sula', 'Puerto Cortés'],
  'El Salvador': ['San Salvador', 'Santa Ana', 'Acajutla'],
  'Guatemala': ['Ciudad de Guatemala', 'Puerto Barrios', 'Quetzaltenango'],
  'México': ['Tapachula', 'Ciudad de México', 'Veracruz'],
};

export const TIPOS_CARGA = [
  'Carga general', 'Perecederos', 'Carga refrigerada', "Contenedor 20'", "Contenedor 40'",
  'Graneles', 'Maquinaria/Equipo', 'Materiales de construcción', 'Textiles', 'Electrónicos', 'Químicos (no peligrosos)',
] as const;

export const TCI: Record<string, string> = {
  'Carga general': 'cube-outline',
  'Perecederos': 'nutrition-outline',
  'Carga refrigerada': 'snow-outline',
  "Contenedor 20'": 'boat-outline',
  "Contenedor 40'": 'boat-outline',
  'Graneles': 'leaf-outline',
  'Maquinaria/Equipo': 'construct-outline',
  'Materiales de construcción': 'business-outline',
  'Textiles': 'shirt-outline',
  'Electrónicos': 'laptop-outline',
  'Químicos (no peligrosos)': 'flask-outline',
};

export const TIPOS_VEHICULO = [
  'Camión rabón (3-5 ton)', 'Furgón mediano', 'Cabezal + plataforma',
  'Cabezal + rampla refrigerada (Reefer)', 'Cama baja (maquinaria)', 'Volteo',
] as const;

export const CLIENTE_SUBTIPOS = ['Empresa importadora', 'Empresa exportadora', 'Fabricante', 'Distribuidor', 'Comercio', 'Operador logístico'];
export const TRANSPORTISTA_SUBTIPOS = ['Transportista independiente', 'Conductor de flota', 'Empresa con flota de camiones'];

export const COMISION_PCT = 8;

export const TIPO_ICON: Record<string, string> = { cliente: 'business', transportista: 'car', admin: 'shield-checkmark' };
