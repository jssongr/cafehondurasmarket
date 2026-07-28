import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { colors } from '../theme/theme';

export default function DetailRow({ label, value, valueStyle }: { label: string; value: React.ReactNode; valueStyle?: any }) {
  return (
    <View style={styles.row}>
      <Text style={styles.label}>{label}</Text>
      {typeof value === 'string' || typeof value === 'number' ? (
        <Text style={[styles.value, valueStyle]} numberOfLines={2}>{value}</Text>
      ) : (
        value
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  row: {
    flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center',
    paddingVertical: 10, borderBottomWidth: 1, borderBottomColor: colors.gris100, gap: 12,
  },
  label: { fontSize: 12.5, color: colors.grisM, flexShrink: 0 },
  value: { fontSize: 13, fontWeight: '700', color: colors.marino, flexShrink: 1, textAlign: 'right' },
});
