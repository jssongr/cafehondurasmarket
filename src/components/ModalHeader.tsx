import React from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { colors, spacing, type } from '../theme/theme';

export default function ModalHeader({ title, badge, onClose }: { title: string; badge?: React.ReactNode; onClose: () => void }) {
  return (
    <View style={styles.wrap}>
      <View style={{ flex: 1 }}>
        {badge}
        <Text style={styles.title}>{title}</Text>
      </View>
      <Pressable onPress={onClose} hitSlop={10} style={styles.closeBtn}>
        <Ionicons name="close" size={20} color={colors.grisM} />
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: { flexDirection: 'row', alignItems: 'flex-start', justifyContent: 'space-between', marginBottom: spacing.lg },
  title: { ...type.h1, color: colors.marino, marginTop: 6 },
  closeBtn: { width: 32, height: 32, borderRadius: 16, backgroundColor: colors.gris50, alignItems: 'center', justifyContent: 'center' },
});
