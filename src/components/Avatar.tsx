import React from 'react';
import { Image, StyleSheet, Text, View } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { colors } from '../theme/theme';
import { TipoUsuario } from '../data/types';

const ICONS: Record<TipoUsuario, keyof typeof Ionicons.glyphMap> = {
  cliente: 'business', transportista: 'car-sport', admin: 'shield-checkmark',
};

export default function Avatar({ uri, tipo, size = 40 }: { uri?: string | null; tipo: TipoUsuario; size?: number }) {
  return (
    <View style={[styles.wrap, { width: size, height: size, borderRadius: size / 2 }]}>
      {uri ? (
        <Image source={{ uri }} style={{ width: size, height: size, borderRadius: size / 2 }} />
      ) : (
        <Ionicons name={ICONS[tipo]} size={size * 0.48} color={colors.marino} />
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: { backgroundColor: colors.gris100, alignItems: 'center', justifyContent: 'center', overflow: 'hidden' },
});
