import React from 'react';
import { Ionicons } from '@expo/vector-icons';
import { colors } from '../theme/theme';

export function tabScreenOptions(
  { route }: { route: { name: string } },
  icons: Record<string, [keyof typeof Ionicons.glyphMap, keyof typeof Ionicons.glyphMap]>,
) {
  return {
    headerShown: false,
    tabBarActiveTintColor: colors.naranja,
    tabBarInactiveTintColor: colors.grisM,
    tabBarStyle: {
      backgroundColor: '#fff',
      borderTopColor: colors.gris100,
      height: 62,
      paddingBottom: 8,
      paddingTop: 6,
    },
    tabBarLabelStyle: { fontSize: 10.5, fontWeight: '700' as const },
    tabBarBadgeStyle: { backgroundColor: '#ef4444', fontSize: 10 },
    tabBarIcon: ({ focused, color, size }: { focused: boolean; color: string; size: number }) => {
      const pair = icons[route.name];
      const name = pair ? (focused ? pair[0] : pair[1]) : 'ellipse';
      return React.createElement(Ionicons, { name, size: size - 2, color });
    },
  };
}
