import React from 'react';
import { StyleSheet, Text, TextInput, TextInputProps, View } from 'react-native';
import { colors, radius, spacing } from '../theme/theme';

export default function TextField({
  label, style, multiline, ...rest
}: { label?: string } & TextInputProps) {
  const [focused, setFocused] = React.useState(false);
  return (
    <View style={{ marginBottom: spacing.md }}>
      {label ? <Text style={styles.label}>{label}</Text> : null}
      <TextInput
        placeholderTextColor={colors.grisM}
        onFocus={(e) => { setFocused(true); rest.onFocus?.(e); }}
        onBlur={(e) => { setFocused(false); rest.onBlur?.(e); }}
        style={[
          styles.input,
          multiline && { minHeight: 84, textAlignVertical: 'top', paddingTop: 12 },
          focused && styles.inputFocused,
          style,
        ]}
        multiline={multiline}
        {...rest}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  label: { fontSize: 11, fontWeight: '700', color: colors.naranja, marginBottom: 5, textTransform: 'uppercase', letterSpacing: 0.4 },
  input: {
    borderWidth: 1.5, borderColor: colors.gris100, borderRadius: radius.md,
    paddingVertical: 12, paddingHorizontal: 14, fontSize: 14.5, color: colors.texto, backgroundColor: colors.blanco,
  },
  inputFocused: { borderColor: colors.ambar },
});
