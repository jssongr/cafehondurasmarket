import React, { useState } from 'react';
import { ActivityIndicator, Image, Pressable, StyleSheet, Text, View } from 'react-native';
import * as ImagePicker from 'expo-image-picker';
import { Ionicons } from '@expo/vector-icons';
import { colors, radius, spacing } from '../theme/theme';

export default function UploadZone({
  icon, title, uploadedTitle, sub, image, onPicked, scanning, done, doneLabel, scanningLabel,
}: {
  icon: keyof typeof Ionicons.glyphMap;
  title: string;
  uploadedTitle: string;
  sub: string;
  image: string | null;
  onPicked: (uri: string) => void;
  scanning: boolean;
  done: boolean;
  doneLabel: string;
  scanningLabel: string;
}) {
  const pick = async () => {
    const res = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ImagePicker.MediaTypeOptions.Images,
      quality: 0.7,
      allowsEditing: true,
    });
    if (!res.canceled && res.assets?.[0]?.uri) onPicked(res.assets[0].uri);
  };

  return (
    <View>
      <Pressable style={styles.zone} onPress={pick}>
        {image ? (
          <Image source={{ uri: image }} style={styles.preview} />
        ) : (
          <Ionicons name={icon} size={34} color={colors.grisM} />
        )}
        <Text style={styles.title}>{image ? uploadedTitle : title}</Text>
        <Text style={styles.sub}>{sub}</Text>
      </Pressable>
      {scanning && (
        <View style={[styles.banner, { backgroundColor: '#F0F9FF' }]}>
          <ActivityIndicator size="small" color={colors.azul} />
          <Text style={[styles.bannerText, { color: colors.azul }]}>{scanningLabel}</Text>
        </View>
      )}
      {done && (
        <View style={[styles.banner, { backgroundColor: colors.verdeBg }]}>
          <Ionicons name="checkmark-circle" size={16} color={colors.verde} />
          <Text style={[styles.bannerText, { color: colors.verde }]}>{doneLabel}</Text>
        </View>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  zone: {
    borderWidth: 2, borderColor: colors.gris100, borderStyle: 'dashed', borderRadius: radius.lg,
    paddingVertical: spacing.xxl, alignItems: 'center', backgroundColor: colors.gris50, overflow: 'hidden',
  },
  preview: { width: '100%', height: 140, borderRadius: radius.md, marginBottom: spacing.sm },
  title: { fontSize: 13.5, fontWeight: '700', color: colors.marino, marginTop: 8 },
  sub: { fontSize: 11, color: colors.grisM, marginTop: 2 },
  banner: { flexDirection: 'row', alignItems: 'center', gap: 8, padding: 11, borderRadius: radius.md, marginTop: spacing.sm },
  bannerText: { fontSize: 12.5, fontWeight: '600', flexShrink: 1 },
});
