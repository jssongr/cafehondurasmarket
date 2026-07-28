export const colors = {
  marino: '#0F2942',
  marinoL: '#1E4468',
  marinoXL: '#2C5C87',
  naranja: '#EA580C',
  naranjaL: '#FB923C',
  ambar: '#F59E0B',
  ambarL: '#FDE68A',
  crema: '#F6F5F2',
  blanco: '#FFFFFF',
  gris50: '#F8F9FB',
  gris100: '#E7E9ED',
  gris300: '#C7CCD4',
  grisM: '#8A93A3',
  texto: '#182233',
  rojo: '#DC2626',
  rojoBg: '#FEF2F2',
  azul: '#1E40AF',
  azulBg: '#DBEAFE',
  verde: '#15803D',
  verdeBg: '#DCFCE7',
  amarilloTxt: '#92400E',
  amarilloBg: '#FEF3C7',
  indigo: '#4338CA',
  indigoBg: '#E0E7FF',
} as const;

export const badgeColors: Record<string, { bg: string; fg: string }> = {
  publicada: { bg: colors.azulBg, fg: colors.azul },
  asignada: { bg: colors.amarilloBg, fg: colors.amarilloTxt },
  en_transito: { bg: colors.indigoBg, fg: colors.indigo },
  entregada: { bg: colors.verdeBg, fg: colors.verde },
  cancelada: { bg: colors.rojoBg, fg: colors.rojo },
  verificado: { bg: colors.verdeBg, fg: colors.verde },
  sinVerificar: { bg: colors.rojoBg, fg: colors.rojo },
};

export const spacing = { xs: 4, sm: 8, md: 12, lg: 16, xl: 20, xxl: 28, xxxl: 36 };

export const radius = { sm: 8, md: 12, lg: 16, xl: 20, pill: 999 };

export const type = {
  display: { fontSize: 26, fontWeight: '800' as const, letterSpacing: -0.4 },
  h1: { fontSize: 20, fontWeight: '800' as const, letterSpacing: -0.2 },
  h2: { fontSize: 17, fontWeight: '700' as const },
  h3: { fontSize: 15, fontWeight: '700' as const },
  body: { fontSize: 14, fontWeight: '400' as const },
  bodyStrong: { fontSize: 14, fontWeight: '600' as const },
  small: { fontSize: 12, fontWeight: '500' as const },
  micro: { fontSize: 11, fontWeight: '600' as const },
  label: { fontSize: 11, fontWeight: '700' as const, letterSpacing: 0.4, textTransform: 'uppercase' as const },
};

export const shadow = {
  card: {
    shadowColor: '#0F2942',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.08,
    shadowRadius: 12,
    elevation: 3,
  },
  floating: {
    shadowColor: '#0F2942',
    shadowOffset: { width: 0, height: 10 },
    shadowOpacity: 0.18,
    shadowRadius: 24,
    elevation: 8,
  },
};
