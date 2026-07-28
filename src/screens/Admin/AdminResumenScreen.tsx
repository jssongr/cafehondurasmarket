import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import Screen from '../../components/Screen';
import StatTile from '../../components/StatTile';
import Card from '../../components/Card';
import Badge from '../../components/Badge';
import { useApp } from '../../state/AppContext';
import { colors } from '../../theme/theme';
import { TIPO_ICON, COMISION_PCT } from '../../data/constants';
import { fmtMoneda } from '../../utils/format';
import NotifBell from '../../components/NotifBell';

export default function AdminResumenScreen() {
  const { usuarios, cargas, historial, facturas, usuario } = useApp();
  const users = usuarios.filter((u) => u.tipo !== 'admin');
  const activos = cargas.filter((c) => c.estado === 'en_transito').length;
  const comision = facturas.reduce((a, f) => a + f.comision, 0);

  return (
    <Screen title="Resumen" subtitle={`NexCarg — ${usuario!.subtipo}`} right={<NotifBell />}>
      <View style={styles.row}>
        <StatTile label="Usuarios" value={users.length} sub="clientes y transportistas" icon="people" accent={colors.ambar} />
        <StatTile label="En tránsito" value={activos} sub="ahora mismo" icon="car-sport" accent={colors.indigo} />
      </View>
      <View style={styles.row}>
        <StatTile label="Completados" value={historial.length} sub="entregados" icon="checkmark-circle" accent={colors.verde} />
        <StatTile label="Comisión" value={fmtMoneda(comision)} sub={`${COMISION_PCT}% por viaje`} icon="cash" accent="#6366f1" />
      </View>

      <Card>
        <Text style={styles.cardTitle}>Usuarios recientes</Text>
        {users.slice(-5).reverse().map((u) => (
          <View key={u.id} style={styles.row2}>
            <Ionicons name={TIPO_ICON[u.tipo] as any} size={16} color={colors.marino} />
            <Text style={styles.rowText} numberOfLines={1}><Text style={{ fontWeight: '700' }}>{u.nombre}</Text> · {u.subtipo}</Text>
            <Badge tone={u.verificado ? 'verificado' : 'sinVerificar'} label={u.verificado ? 'Verificado' : 'Sin verificar'} />
          </View>
        ))}
      </Card>

      <Card>
        <Text style={styles.cardTitle}>Viajes recientes</Text>
        {cargas.slice(-5).reverse().map((c) => (
          <View key={c.id} style={styles.row2}>
            <Text style={styles.rowText} numberOfLines={1}><Text style={{ fontWeight: '700' }}>{c.tipoCarga}</Text> · {c.paisOrigen} → {c.paisDestino}</Text>
            <Badge tone={c.estado} />
          </View>
        ))}
      </Card>
    </Screen>
  );
}

const styles = StyleSheet.create({
  row: { flexDirection: 'row', gap: 12 },
  row2: { flexDirection: 'row', alignItems: 'center', gap: 8, paddingVertical: 9, borderBottomWidth: 1, borderBottomColor: colors.gris100 },
  rowText: { flex: 1, fontSize: 12.5, color: colors.texto },
  cardTitle: { fontSize: 15, fontWeight: '700', color: colors.marino, marginBottom: 12, paddingBottom: 10, borderBottomWidth: 1, borderBottomColor: colors.gris100 },
});
