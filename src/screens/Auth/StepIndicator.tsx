import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { colors, spacing } from '../../theme/theme';

export default function StepIndicator({ steps, current }: { steps: string[]; current: number }) {
  return (
    <View style={styles.row}>
      {steps.map((s, i) => {
        const n = i + 1;
        const done = current > n;
        const active = current === n;
        return (
          <React.Fragment key={s}>
            <View style={styles.step}>
              <View style={[styles.dot, done && styles.dotDone, active && styles.dotActive]}>
                {done ? <Ionicons name="checkmark" size={12} color="#fff" /> : <Text style={[styles.dotText, active && { color: '#fff' }]}>{n}</Text>}
              </View>
              <Text style={[styles.label, active && styles.labelActive]}>{s}</Text>
            </View>
            {i < steps.length - 1 && <View style={[styles.line, current > n && styles.lineDone]} />}
          </React.Fragment>
        );
      })}
    </View>
  );
}

const styles = StyleSheet.create({
  row: { flexDirection: 'row', alignItems: 'center', marginBottom: spacing.xl },
  step: { flexDirection: 'row', alignItems: 'center', gap: 6 },
  dot: { width: 22, height: 22, borderRadius: 11, backgroundColor: colors.gris100, alignItems: 'center', justifyContent: 'center' },
  dotDone: { backgroundColor: colors.marino },
  dotActive: { backgroundColor: colors.ambar },
  dotText: { fontSize: 11, fontWeight: '700', color: colors.grisM },
  label: { fontSize: 11, color: colors.grisM, fontWeight: '500' },
  labelActive: { color: colors.marino, fontWeight: '700' },
  line: { flex: 1, height: 2, backgroundColor: colors.gris100, marginHorizontal: 6, borderRadius: 1 },
  lineDone: { backgroundColor: colors.marino },
});
