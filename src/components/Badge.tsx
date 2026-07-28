import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { badgeColors, radius } from '../theme/theme';

const LABELS: Record<string, string> = {
  publicada: 'Publicada',
  asignada: 'Asignada',
  en_transito: 'En tránsito',
  entregada: 'Entregada',
  cancelada: 'Cancelada',
};

export default function Badge({ tone, label }: { tone: keyof typeof badgeColors; label?: string }) {
  const c = badgeColors[tone] ?? badgeColors.publicada;
  return (
    <View style={[styles.pill, { backgroundColor: c.bg }]}>
      <Text style={[styles.text, { color: c.fg }]}>{label ?? LABELS[tone] ?? tone}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  pill: { paddingVertical: 3, paddingHorizontal: 10, borderRadius: radius.pill, alignSelf: 'flex-start' },
  text: { fontSize: 11, fontWeight: '700' },
});
