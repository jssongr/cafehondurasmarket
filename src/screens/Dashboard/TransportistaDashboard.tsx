import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { Ionicons } from '@expo/vector-icons';
import Screen from '../../components/Screen';
import StatTile from '../../components/StatTile';
import Card from '../../components/Card';
import EmptyState from '../../components/EmptyState';
import Button from '../../components/Button';
import { useApp } from '../../state/AppContext';
import { colors } from '../../theme/theme';
import { TCI } from '../../data/constants';
import { fmtMoneda, fmtTime } from '../../utils/format';
import NotifBell from '../../components/NotifBell';

export default function TransportistaDashboard() {
  const { usuario, cargas, notifs, historial } = useApp();
  const navigation = useNavigation<any>();
  const disponibles = cargas.filter((c) => c.estado === 'publicada');
  const misViajes = cargas.filter((c) => c.transportistaId === usuario!.id && ['asignada', 'en_transito'].includes(c.estado));
  const misHist = historial.filter((h) => h.transportistaId === usuario!.id);
  const ingresos = misHist.reduce((a, h) => a + h.monto, 0);
  const misNotifs = notifs.filter((n) => n.usuarioId === usuario!.id);

  return (
    <Screen title="Panel Principal" subtitle={`NexCarg — ${usuario!.subtipo}`} right={<NotifBell />}>
      <View style={styles.statsRow}>
        <StatTile label="Cargas disponibles" value={disponibles.length} sub="en el corredor" icon="storefront" accent={colors.ambar} />
        <StatTile label="Viajes activos" value={misViajes.length} sub="en curso" icon="car-sport" accent={colors.indigo} />
      </View>
      <View style={styles.statsRow}>
        <StatTile label="Completados" value={misHist.length} sub="entregados" icon="checkmark-circle" accent={colors.verde} />
        <StatTile label="Ingresos totales" value={fmtMoneda(ingresos)} sub="histórico" icon="cash" accent="#6366f1" />
      </View>

      <Card>
        <Text style={styles.cardTitle}>Últimas cargas publicadas</Text>
        {disponibles.length === 0 && <EmptyState icon="storefront-outline" title="No hay cargas disponibles ahora" />}
        {disponibles.slice(-5).reverse().map((c) => (
          <View key={c.id} style={styles.rowItem}>
            <Ionicons name={(TCI[c.tipoCarga] as any) ?? 'cube-outline'} size={16} color={colors.marino} />
            <Text style={styles.rowText} numberOfLines={1}>
              <Text style={{ fontWeight: '700' }}>{c.tipoCarga}</Text> · {c.paisOrigen} → {c.paisDestino}
            </Text>
            <Text style={styles.rowPrice}>{c.presupuesto ? fmtMoneda(c.presupuesto) : 'Cotizar'}</Text>
          </View>
        ))}
        <Button title="Ver todas →" variant="ghost" size="sm" onPress={() => navigation.navigate('Disponibles')} style={{ marginTop: 10 }} />
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
  rowPrice: { fontSize: 12.5, fontWeight: '700', color: colors.naranja },
  notifRow: { flexDirection: 'row', gap: 10, paddingVertical: 9, borderBottomWidth: 1, borderBottomColor: colors.gris100 },
  notifTitle: { fontSize: 12.5, fontWeight: '700', color: colors.marino },
  notifSub: { fontSize: 11, color: colors.grisM, marginTop: 1 },
  notifTime: { fontSize: 10, color: colors.grisM, marginTop: 2 },
});
