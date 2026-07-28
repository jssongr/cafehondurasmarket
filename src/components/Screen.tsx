import React from 'react';
import { Pressable, RefreshControl, ScrollView, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { colors, spacing, type } from '../theme/theme';

export default function Screen({
  title, subtitle, right, children, scroll = true, refreshing, onRefresh, onBack,
}: {
  title?: string;
  subtitle?: string;
  right?: React.ReactNode;
  children: React.ReactNode;
  scroll?: boolean;
  refreshing?: boolean;
  onRefresh?: () => void;
  onBack?: () => void;
}) {
  const Body = scroll ? ScrollView : View;
  const bodyProps = scroll
    ? {
        contentContainerStyle: styles.scrollContent,
        showsVerticalScrollIndicator: false,
        refreshControl: onRefresh ? (
          <RefreshControl refreshing={!!refreshing} onRefresh={onRefresh} tintColor={colors.marino} />
        ) : undefined,
      }
    : { style: styles.flexContent };

  return (
    <SafeAreaView style={styles.safe} edges={['top']}>
      {title ? (
        <View style={styles.header}>
          {onBack ? (
            <Pressable onPress={onBack} hitSlop={10} style={styles.backBtn}>
              <Ionicons name="chevron-back" size={22} color={colors.marino} />
            </Pressable>
          ) : null}
          <View style={{ flex: 1 }}>
            <Text style={styles.title}>{title}</Text>
            {subtitle ? <Text style={styles.subtitle}>{subtitle}</Text> : null}
          </View>
          {right}
        </View>
      ) : null}
      {/* @ts-ignore polymorphic body */}
      <Body {...bodyProps}>{children}</Body>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: colors.crema },
  header: {
    flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between',
    paddingHorizontal: spacing.xl, paddingTop: spacing.md, paddingBottom: spacing.lg, gap: 10,
  },
  backBtn: { width: 34, height: 34, borderRadius: 17, backgroundColor: colors.gris50, alignItems: 'center', justifyContent: 'center' },
  title: { ...type.display, color: colors.marino },
  subtitle: { fontSize: 12.5, color: colors.grisM, marginTop: 2 },
  scrollContent: { paddingHorizontal: spacing.xl, paddingBottom: spacing.xxxl * 2, gap: spacing.lg },
  flexContent: { flex: 1, paddingHorizontal: spacing.xl },
});
