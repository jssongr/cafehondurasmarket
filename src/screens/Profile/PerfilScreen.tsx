import React, { useState } from 'react';
import { Image, Pressable, StyleSheet, Text, View } from 'react-native';
import * as ImagePicker from 'expo-image-picker';
import { Ionicons } from '@expo/vector-icons';
import { useNavigation } from '@react-navigation/native';
import Screen from '../../components/Screen';
import Card from '../../components/Card';
import TextField from '../../components/TextField';
import Button from '../../components/Button';
import Badge from '../../components/Badge';
import Stars from '../../components/Stars';
import { useApp } from '../../state/AppContext';
import { colors, radius, spacing } from '../../theme/theme';
import { avgRating } from '../../utils/format';
import { TIPO_ICON } from '../../data/constants';

export default function PerfilScreen({ showBack }: { showBack?: boolean } = {}) {
  const { usuario, actualizarPerfil, historial, logout, showToast } = useApp();
  const navigation = useNavigation<any>();
  const [nombre, setNombre] = useState(usuario!.nombre);
  const [telefono, setTelefono] = useState(usuario!.telefono || '');
  const [selfie, setSelfie] = useState<string | null>(usuario!.selfie);

  const cambiarFoto = async () => {
    const res = await ImagePicker.launchImageLibraryAsync({ mediaTypes: ImagePicker.MediaTypeOptions.Images, quality: 0.7, allowsEditing: true });
    if (!res.canceled && res.assets?.[0]?.uri) setSelfie(res.assets[0].uri);
  };

  const guardar = () => {
    actualizarPerfil(usuario!.id, { nombre, telefono, selfie });
    showToast('Perfil actualizado');
  };

  const rating = usuario!.tipo !== 'admin' ? avgRating(historial, usuario!) : null;

  return (
    <Screen title="Mi Perfil" subtitle={`NexCarg — ${usuario!.subtipo}`} onBack={showBack ? () => navigation.goBack() : undefined}>
      <Card style={{ alignItems: 'center' }}>
        <Pressable onPress={cambiarFoto} style={styles.avatarWrap}>
          {selfie ? <Image source={{ uri: selfie }} style={styles.avatarImg} /> : (
            <Ionicons name={TIPO_ICON[usuario!.tipo] as any} size={36} color={colors.marino} />
          )}
        </Pressable>
        <Pressable onPress={cambiarFoto} style={styles.photoBtn}>
          <Ionicons name="camera" size={13} color={colors.marino} />
          <Text style={styles.photoBtnText}>Cambiar foto</Text>
        </Pressable>
        <View style={styles.badgeRow}>
          <Badge tone={usuario!.verificado ? 'verificado' : 'sinVerificar'} label={usuario!.verificado ? '✅ Cuenta verificada' : '⚠️ Sin verificar'} />
          {rating != null && (
            <View style={styles.ratingPill}><Stars value={rating} /></View>
          )}
        </View>
      </Card>

      <Card>
        <TextField label="Nombre / Empresa" value={nombre} onChangeText={setNombre} />
        <TextField label="Correo electrónico" value={usuario!.email} editable={false} style={styles.disabled} />
        <TextField label="Teléfono" placeholder="+(504) 9xxx-xxxx" value={telefono} onChangeText={setTelefono} />
        <TextField label="Tipo de cuenta" value={usuario!.subtipo} editable={false} style={styles.disabled} />
        {usuario!.tipo === 'transportista' && (
          <>
            <TextField label="Vehículo" value={usuario!.vehiculo ?? ''} editable={false} style={styles.disabled} />
            <TextField label="Capacidad" value={usuario!.capacidad ? `${usuario!.capacidad} ton` : ''} editable={false} style={styles.disabled} />
            <TextField label="Placa" value={usuario!.placa ?? ''} editable={false} style={styles.disabled} />
          </>
        )}
        <Button title="Guardar cambios" onPress={guardar} fullWidth />
      </Card>

      <Button title="Cerrar sesión" variant="outline" onPress={logout} fullWidth icon={<Ionicons name="log-out-outline" size={16} color={colors.marino} />} />
    </Screen>
  );
}

const styles = StyleSheet.create({
  avatarWrap: {
    width: 84, height: 84, borderRadius: 42, backgroundColor: colors.gris100, alignItems: 'center', justifyContent: 'center',
    borderWidth: 3, borderColor: colors.ambar, overflow: 'hidden', marginBottom: 10,
  },
  avatarImg: { width: '100%', height: '100%' },
  photoBtn: { flexDirection: 'row', gap: 5, alignItems: 'center', backgroundColor: colors.gris100, paddingVertical: 6, paddingHorizontal: 12, borderRadius: radius.md },
  photoBtnText: { fontSize: 11.5, fontWeight: '600', color: colors.marino },
  badgeRow: { flexDirection: 'row', gap: 8, marginTop: 12, alignItems: 'center' },
  ratingPill: { backgroundColor: colors.amarilloBg, paddingVertical: 3, paddingHorizontal: 10, borderRadius: radius.pill },
  disabled: { opacity: 0.55 },
});
