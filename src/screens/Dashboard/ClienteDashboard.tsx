import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { Ionicons } from '@expo/vector-icons';
import Screen from '../../components/Screen';
import StatTile from '../../components/StatTile';
import Card from '../../components/Card';
import EmptyState from '../../components/EmptyState';
import Badge from '../../components/Badge';
import { useApp } from '../../state/AppContext';
import { colors } from '../../theme/theme';
import { TCI } from '../../data/constants';
import { fmtTime } from '../../utils/format';
import NotifBell from '../../components/NotifBell';

export default function ClienteDashboard() {
  const { usuario, cargas, notifs } = useApp();
  const mias = cargas.filter((c) => c.clienteId === usuario!.id);
  const activas = mias.filter((c) => ['publicada', 'asignada', 'en_transito'].includes(c.estado));
  const enTransito = mias.filter((c) => c.estado === 'en_transito');
  const entregadas = mias.filter((c) => c.estado === 'entregada');
  const misNotifs = notifs.filter((n) => n.usuarioId === usuario!.id);

  return (
    <Screen title="Panel Principal" subtitle={`NexCarg — ${usuario!.subtipo}`} right={<NotifBell />}>
      <View style={styles.statsRow}>
        <StatTile label="Cargas activas" value={activas.length} sub="en proceso" icon="cube" accent={colors.ambar} />
        <StatTile label="En tránsito" value={enTransito.length} sub="en camino ahora" icon="car-sport" accent={colors.indigo} />
      </View>
      <View style={styles.statsRow}>
        <StatTile label="Entregadas" value={entregadas.length} sub="completadas" icon="checkmark-circle" accent={colors.verde} />
        <StatTile label="Notificaciones" value={misNotifs.filter((n) => !n.leida).length} sub="sin leer" icon="notifications" accent="#6366f1" />
      </View>

      <Card>
        <Text style={styles.cardTitle}>Mis cargas recientes</Text>
        {mias.length === 0 && <EmptyState icon="cube-outline" title="Aún no has publicado cargas" />}
        {mias.slice(-5).reverse().map((c) => (
          <View key={c.id} style={styles.rowItem}>
            <Ionicons name={(TCI[c.tipoCarga] as any) ?? 'cube-outline'} size={16} color={colors.marino} />
            <Text style={styles.rowText} numberOfLines={1}>
              <Text style={{ fontWeight: '700' }}>{c.tipoCarga}</Text> · {c.paisOrigen} → {c.paisDestino}
            </Text>
            <Badge tone={c.estado} />
          </View>
        ))}
      </Card>

      <Card>
        <Text style={styles.cardTitle}>Actividad reciente</Text>
        {misNotifs.length === 0 && <EmptyState icon="notifications-outline" title="Sin actividad reciente" />}
        {misNotifs.slice(0, 5).map((n) => (
          <View key={n.id} style={styles.notifRow}>
            <Ionicons name={n.tipo === 'mensaje' ? 'chatbubble' : n.tipo === 'oferta' ? 'cash' : 'megaphone'} size={16} color={colors.marino} />
            <View style={{ flex: 1 }}>
              <Text style={styles.notifTitle}>{n.titulo}</Text>
              <Text style={styles.notifSub}>{n.sub}</Text>
              <Text style={styles.notifTime}>{fmtTime(n.ts)}</Text>
            </View>
          </View>
        ))}
      </Card>
    </Screen>
  );
}

const styles = StyleSheet.create({
  statsRow: { flexDirection: 'row', gap: 12 },
  cardTitle: { fontSize: 15, fontWeight: '700', color: colors.marino, marginBottom: 12, paddingBottom: 10, borderBottomWidth: 1, borderBottomColor: colors.gris100 },
  rowItem: { flexDirection: 'row', alignItems: 'center', gap: 8, paddingVertical: 9, borderBottomWidth: 1, borderBottomColor: colors.gris100 },
  rowText: { flex: 1, fontSize: 12.5, color: colors.texto },
  notifRow: { flexDirection: 'row', gap: 10, paddingVertical: 9, borderBottomWidth: 1, borderBottomColor: colors.gris100 },
  notifTitle: { fontSize: 12.5, fontWeight: '700', color: colors.marino },
  notifSub: { fontSize: 11, color: colors.grisM, marginTop: 1 },
  notifTime: { fontSize: 10, color: colors.grisM, marginTop: 2 },
});
