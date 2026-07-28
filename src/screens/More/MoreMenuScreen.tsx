import React from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { Ionicons } from '@expo/vector-icons';
import Screen from '../../components/Screen';
import Avatar from '../../components/Avatar';
import Stars from '../../components/Stars';
import Badge from '../../components/Badge';
import { useApp } from '../../state/AppContext';
import { colors, radius, shadow, spacing } from '../../theme/theme';
import { avgRating } from '../../utils/format';

const ITEMS = [
  { key: 'SeguimientoMas', icon: 'location', label: 'Seguimiento GPS', sub: 'Sigue tus viajes activos en el mapa del corredor' },
  { key: 'HistorialMas', icon: 'time', label: 'Historial de viajes', sub: 'Revisa y califica tus entregas completadas' },
  { key: 'FacturasMas', icon: 'receipt', label: 'Facturación', sub: 'Consulta tus facturas y comisiones' },
  { key: 'PerfilMas', icon: 'person', label: 'Mi perfil', sub: 'Datos personales, documentos y verificación' },
] as const;

export default function MoreMenuScreen() {
  const { usuario, historial, logout } = useApp();
  const navigation = useNavigation<any>();
  const rating = usuario!.tipo !== 'admin' ? avgRating(historial, usuario!) : null;

  return (
    <Screen title="Más" subtitle={`NexCarg — ${usuario!.subtipo}`}>
      <View style={styles.profileCard}>
        <Avatar uri={usuario!.selfie} tipo={usuario!.tipo} size={52} />
        <View style={{ flex: 1 }}>
          <Text style={styles.name}>{usuario!.nombre}</Text>
          <View style={{ flexDirection: 'row', gap: 6, marginTop: 3 }}>
            <Badge tone={usuario!.verificado ? 'verificado' : 'sinVerificar'} label={usuario!.verificado ? 'Verificado' : 'Sin verificar'} />
            {rating != null && <Stars value={rating} />}
          </View>
        </View>
      </View>

      <View style={{ gap: spacing.sm }}>
        {ITEMS.map((item) => (
          <Pressable key={item.key} style={styles.item} onPress={() => navigation.navigate(item.key)}>
            <View style={styles.itemIcon}><Ionicons name={item.icon as any} size={19} color={colors.marino} /></View>
            <View style={{ flex: 1 }}>
              <Text style={styles.itemLabel}>{item.label}</Text>
              <Text style={styles.itemSub}>{item.sub}</Text>
            </View>
            <Ionicons name="chevron-forward" size={18} color={colors.grisM} />
          </Pressable>
        ))}
      </View>

      <Pressable style={styles.logout} onPress={logout}>
        <Ionicons name="log-out-outline" size={17} color={colors.rojo} />
        <Text style={styles.logoutText}>Cerrar sesión</Text>
      </Pressable>
    </Screen>
  );
}

const styles = StyleSheet.create({
  profileCard: {
    flexDirection: 'row', alignItems: 'center', gap: spacing.md, backgroundColor: colors.blanco,
    borderRadius: radius.lg, padding: spacing.lg, ...shadow.card, marginBottom: spacing.lg,
  },
  name: { fontSize: 15, fontWeight: '700', color: colors.marino },
  item: { flexDirection: 'row', alignItems: 'center', gap: 12, backgroundColor: colors.blanco, borderRadius: radius.lg, padding: spacing.md, ...shadow.card },
  itemIcon: { width: 40, height: 40, borderRadius: radius.md, backgroundColor: colors.gris50, alignItems: 'center', justifyContent: 'center' },
  itemLabel: { fontSize: 13.5, fontWeight: '700', color: colors.marino },
  itemSub: { fontSize: 11, color: colors.grisM, marginTop: 2 },
  logout: {
    flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 8,
    marginTop: spacing.xl, paddingVertical: 13, borderRadius: radius.md, backgroundColor: colors.rojoBg,
  },
  logoutText: { color: colors.rojo, fontWeight: '700', fontSize: 13 },
});
