import React, { useState } from 'react';
import { FlatList, Modal, Pressable, StyleSheet, Text, View } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { colors, radius, spacing } from '../theme/theme';

export default function SelectField({
  label, value, options, onChange, placeholder = 'Selecciona…',
}: {
  label?: string;
  value: string;
  options: readonly string[];
  onChange: (v: string) => void;
  placeholder?: string;
}) {
  const [open, setOpen] = useState(false);
  return (
    <View style={{ marginBottom: spacing.md }}>
      {label ? <Text style={styles.label}>{label}</Text> : null}
      <Pressable style={styles.field} onPress={() => setOpen(true)}>
        <Text style={[styles.value, !value && { color: colors.grisM }]} numberOfLines={1}>
          {value || placeholder}
        </Text>
        <Ionicons name="chevron-down" size={16} color={colors.grisM} />
      </Pressable>
      <Modal visible={open} transparent animationType="fade" onRequestClose={() => setOpen(false)}>
        <Pressable style={styles.overlay} onPress={() => setOpen(false)}>
          <View style={styles.sheet} onStartShouldSetResponder={() => true}>
            <View style={styles.sheetHandle} />
            <Text style={styles.sheetTitle}>{label ?? 'Selecciona una opción'}</Text>
            <FlatList
              data={options}
              keyExtractor={(item) => item}
              style={{ maxHeight: 360 }}
              renderItem={({ item }) => (
                <Pressable
                  style={({ pressed }) => [styles.option, pressed && { backgroundColor: colors.gris50 }]}
                  onPress={() => { onChange(item); setOpen(false); }}
                >
                  <Text style={[styles.optionText, item === value && { color: colors.marino, fontWeight: '700' }]}>{item}</Text>
                  {item === value && <Ionicons name="checkmark" size={18} color={colors.marino} />}
                </Pressable>
              )}
            />
          </View>
        </Pressable>
      </Modal>
    </View>
  );
}

const styles = StyleSheet.create({
  label: { fontSize: 11, fontWeight: '700', color: colors.naranja, marginBottom: 5, textTransform: 'uppercase', letterSpacing: 0.4 },
  field: {
    borderWidth: 1.5, borderColor: colors.gris100, borderRadius: radius.md, backgroundColor: colors.blanco,
    paddingVertical: 12, paddingHorizontal: 14, flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between',
  },
  value: { fontSize: 14.5, color: colors.texto, flex: 1 },
  overlay: { flex: 1, backgroundColor: 'rgba(15,41,66,0.45)', justifyContent: 'flex-end' },
  sheet: { backgroundColor: colors.blanco, borderTopLeftRadius: radius.xl, borderTopRightRadius: radius.xl, padding: spacing.lg, paddingBottom: spacing.xxl },
  sheetHandle: { width: 40, height: 4, borderRadius: 2, backgroundColor: colors.gris300, alignSelf: 'center', marginBottom: 12 },
  sheetTitle: { fontSize: 13, fontWeight: '700', color: colors.marino, marginBottom: 8, textTransform: 'uppercase', letterSpacing: 0.4 },
  option: { paddingVertical: 13, paddingHorizontal: 8, borderRadius: radius.sm, flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  optionText: { fontSize: 15, color: colors.texto },
});
