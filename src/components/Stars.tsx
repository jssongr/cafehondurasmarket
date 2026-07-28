import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { colors } from '../theme/theme';

export default function Stars({ value, size = 12 }: { value: number | null | undefined; size?: number }) {
  if (value == null) return null;
  return (
    <View style={styles.row}>
      <Ionicons name="star" size={size} color={colors.ambar} />
      <Text style={[styles.text, { fontSize: size }]}>{value.toFixed(1)}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  row: { flexDirection: 'row', alignItems: 'center', gap: 3 },
  text: { color: colors.ambar, fontWeight: '700' },
});
