import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { PAISES, PAIS_IDX } from '../data/constants';
import { colors, spacing } from '../theme/theme';
import { Carga } from '../data/types';

export default function CorridorTrack({ carga }: { carga: Carga }) {
  const oi = PAIS_IDX[carga.paisOrigen];
  const di = PAIS_IDX[carga.paisDestino];
  const lo = Math.min(oi, di);
  const hi = Math.max(oi, di);
  const pos = oi + (di - oi) * (carga.progreso / 100);
  const pct = (pos / (PAISES.length - 1)) * 100;
  const eta = carga.estado === 'en_transito' ? Math.max(1, Math.round((100 - carga.progreso) / 10)) : null;

  return (
    <View style={styles.wrap}>
      <View style={styles.lineTrack}>
        <View style={[styles.lineFill, { width: `${pct}%` }]} />
        <View style={[styles.truck, { left: `${pct}%` }]}>
          <Ionicons name="car-sport" size={20} color={colors.naranja} />
        </View>
      </View>
      <View style={styles.ticksRow}>
        {PAISES.map((p, i) => {
          const active = i >= lo && i <= hi;
          return (
            <View key={p} style={styles.tick}>
              <View style={[styles.dot, active && styles.dotActive]} />
              <Text style={[styles.tickLabel, active && styles.tickLabelActive]} numberOfLines={1}>{p}</Text>
            </View>
          );
        })}
      </View>
      <View style={styles.metaRow}>
        <Text style={styles.meta}>Progreso: <Text style={styles.metaStrong}>{carga.progreso}%</Text></Text>
        {eta != null && <Text style={styles.meta}>ETA: <Text style={styles.metaStrong}>~{eta} h</Text></Text>}
        <Text style={styles.meta}>Pago: <Text style={styles.metaStrong}>{carga.pago.estado}</Text></Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: { paddingTop: 8, paddingBottom: 4 },
  lineTrack: { height: 6, borderRadius: 3, backgroundColor: colors.gris100, position: 'relative', marginHorizontal: 12 },
  lineFill: { position: 'absolute', top: 0, left: 0, height: 6, borderRadius: 3, backgroundColor: colors.naranja },
  truck: { position: 'absolute', top: -8, marginLeft: -10 },
  ticksRow: { flexDirection: 'row', justifyContent: 'space-between', marginTop: 14 },
  tick: { alignItems: 'center', width: 46 },
  dot: { width: 8, height: 8, borderRadius: 4, backgroundColor: colors.gris300, marginBottom: 4 },
  dotActive: { backgroundColor: colors.naranja },
  tickLabel: { fontSize: 8.5, color: colors.grisM, fontWeight: '600', textAlign: 'center' },
  tickLabelActive: { color: colors.marino, fontWeight: '800' },
  metaRow: { flexDirection: 'row', gap: spacing.lg, marginTop: spacing.lg, flexWrap: 'wrap' },
  meta: { fontSize: 11.5, color: colors.grisM },
  metaStrong: { color: colors.marino, fontWeight: '700' },
});
