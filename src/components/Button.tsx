import React from 'react';
import { ActivityIndicator, Pressable, StyleSheet, Text, ViewStyle } from 'react-native';
import { colors, radius, spacing } from '../theme/theme';

type Variant = 'primary' | 'accent' | 'ghost' | 'danger' | 'outline';
type Size = 'md' | 'sm';

export default function Button({
  title, onPress, variant = 'primary', size = 'md', disabled, loading, style, icon, fullWidth,
}: {
  title: string;
  onPress: () => void;
  variant?: Variant;
  size?: Size;
  disabled?: boolean;
  loading?: boolean;
  style?: ViewStyle;
  icon?: React.ReactNode;
  fullWidth?: boolean;
}) {
  const isDisabled = disabled || loading;
  return (
    <Pressable
      onPress={onPress}
      disabled={isDisabled}
      style={({ pressed }) => [
        styles.base,
        size === 'sm' ? styles.sm : styles.md,
        variantStyles[variant],
        fullWidth && { width: '100%' },
        isDisabled && { opacity: 0.5 },
        pressed && !isDisabled && { transform: [{ scale: 0.98 }], opacity: 0.92 },
        style,
      ]}
    >
      {loading ? (
        <ActivityIndicator color={variant === 'ghost' || variant === 'outline' ? colors.marino : '#fff'} size="small" />
      ) : (
        <>
          {icon}
          <Text style={[styles.text, size === 'sm' && styles.textSm, textVariantStyles[variant]]}>{title}</Text>
        </>
      )}
    </Pressable>
  );
}

const styles = StyleSheet.create({
  base: {
    flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 6,
    borderRadius: radius.md,
  },
  md: { paddingVertical: 13, paddingHorizontal: 20 },
  sm: { paddingVertical: 9, paddingHorizontal: 14 },
  text: { fontSize: 14, fontWeight: '700' },
  textSm: { fontSize: 12.5 },
});

const variantStyles = StyleSheet.create({
  primary: { backgroundColor: colors.marino },
  accent: { backgroundColor: colors.naranja },
  ghost: { backgroundColor: colors.gris100 },
  danger: { backgroundColor: colors.rojoBg },
  outline: { backgroundColor: 'transparent', borderWidth: 1.5, borderColor: colors.marino },
});

const textVariantStyles = StyleSheet.create({
  primary: { color: '#fff' },
  accent: { color: '#fff' },
  ghost: { color: colors.texto },
  danger: { color: colors.rojo },
  outline: { color: colors.marino },
});
