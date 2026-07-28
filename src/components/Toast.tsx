import React, { useEffect, useRef } from 'react';
import { Animated, StyleSheet, Text } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useApp } from '../state/AppContext';
import { colors, radius, shadow, spacing } from '../theme/theme';

export default function Toast() {
  const { toast } = useApp();
  const opacity = useRef(new Animated.Value(0)).current;
  const translate = useRef(new Animated.Value(20)).current;

  useEffect(() => {
    if (toast) {
      opacity.setValue(0);
      translate.setValue(20);
      Animated.parallel([
        Animated.timing(opacity, { toValue: 1, duration: 220, useNativeDriver: true }),
        Animated.timing(translate, { toValue: 0, duration: 220, useNativeDriver: true }),
      ]).start();
    }
  }, [toast?.id]);

  if (!toast) return null;
  return (
    <Animated.View style={[styles.toast, { opacity, transform: [{ translateY: translate }] }]} pointerEvents="none">
      <Ionicons name="checkmark-circle" size={18} color="#4ade80" />
      <Text style={styles.text} numberOfLines={2}>{toast.msg}</Text>
    </Animated.View>
  );
}

const styles = StyleSheet.create({
  toast: {
    position: 'absolute', left: spacing.xl, right: spacing.xl, bottom: 28,
    backgroundColor: colors.marino, borderRadius: radius.lg, paddingVertical: 13, paddingHorizontal: 16,
    flexDirection: 'row', alignItems: 'center', gap: 10, ...shadow.floating, zIndex: 999,
  },
  text: { color: '#fff', fontSize: 13, fontWeight: '600', flex: 1 },
});
