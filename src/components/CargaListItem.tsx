import React from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { Carga } from '../data/types';
import { TCI } from '../data/constants';
import { colors, radius, shadow, spacing } from '../theme/theme';
import Badge from './Badge';
import { fmtMoneda } from '../utils/format';

export default function CargaListItem({
  carga, subtitle, onPress, right, actions,
}: {
  carga: Carga;
  subtitle: string;
  onPress?: () => void;
  right?: React.ReactNode;
  actions?: React.ReactNode;
}) {
  return (
    <Pressable style={styles.card} onPress={onPress}>
      <View style={styles.iconWrap}>
        <Ionicons name={(TCI[carga.tipoCarga] as any) ?? 'cube-outline'} size={22} color={colors.marino} />
      </View>
      <View style={{ flex: 1, minWidth: 0 }}>
        <Text style={styles.title} numberOfLines={1}>{carga.tipoCarga} · {carga.peso} {carga.unidadPeso}</Text>
        <View style={styles.subRow}>
          <Text style={styles.subtitle} numberOfLines={1}>{subtitle}</Text>
          <Badge tone={carga.estado} />
        </View>
        {actions ? <View style={styles.actionsRow}>{actions}</View> : null}
      </View>
      {right ?? (
        <View style={{ alignItems: 'flex-end' }}>
          <Text style={styles.price}>{carga.precioAcordado ? fmtMoneda(carga.precioAcordado) : (carga.presupuesto ? fmtMoneda(carga.presupuesto) : '—')}</Text>
          {carga.pago.estado !== 'pendiente' && <Text style={styles.priceSub}>Pago {carga.pago.estado}</Text>}
        </View>
      )}
    </Pressable>
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: colors.blanco, borderRadius: radius.lg, padding: spacing.md,
    flexDirection: 'row', alignItems: 'center', gap: spacing.md, ...shadow.card,
  },
  iconWrap: { width: 44, height: 44, borderRadius: radius.md, backgroundColor: colors.gris50, alignItems: 'center', justifyContent: 'center' },
  title: { fontSize: 13.5, fontWeight: '700', color: colors.marino },
  subRow: { flexDirection: 'row', alignItems: 'center', gap: 8, marginTop: 3, flexWrap: 'wrap' },
  subtitle: { fontSize: 11.5, color: colors.grisM, flexShrink: 1 },
  actionsRow: { flexDirection: 'row', gap: 8, marginTop: 9, flexWrap: 'wrap' },
  price: { fontSize: 16, fontWeight: '800', color: colors.naranja },
  priceSub: { fontSize: 9.5, color: colors.grisM },
});
