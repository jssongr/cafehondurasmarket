import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { colors, radius, shadow, spacing } from '../theme/theme';

export default function StatTile({
  label, value, sub, icon, accent = colors.ambar,
}: {
  label: string;
  value: string | number;
  sub?: string;
  icon: keyof typeof Ionicons.glyphMap;
  accent?: string;
}) {
  return (
    <View style={[styles.tile, { borderLeftColor: accent }]}>
      <View style={styles.headRow}>
        <Text style={styles.label}>{label}</Text>
        <View style={[styles.iconWrap, { backgroundColor: accent + '1A' }]}>
          <Ionicons name={icon} size={14} color={accent} />
        </View>
      </View>
      <Text style={styles.value}>{value}</Text>
      {sub ? <Text style={styles.sub}>{sub}</Text> : null}
    </View>
  );
}

const styles = StyleSheet.create({
  tile: {
    flex: 1, minWidth: 150, backgroundColor: colors.blanco, borderRadius: radius.lg,
    padding: spacing.lg, borderLeftWidth: 4, ...shadow.card, gap: 2,
  },
  headRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  label: { fontSize: 10.5, fontWeight: '700', color: colors.grisM, textTransform: 'uppercase', letterSpacing: 0.4 },
  iconWrap: { width: 24, height: 24, borderRadius: 8, alignItems: 'center', justifyContent: 'center' },
  value: { fontSize: 24, fontWeight: '800', color: colors.marino, marginTop: 2 },
  sub: { fontSize: 11.5, color: colors.grisM },
});
