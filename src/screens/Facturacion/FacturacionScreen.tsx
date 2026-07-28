import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useNavigation } from '@react-navigation/native';
import Screen from '../../components/Screen';
import StatTile from '../../components/StatTile';
import EmptyState from '../../components/EmptyState';
import { useApp } from '../../state/AppContext';
import { colors, radius, shadow, spacing } from '../../theme/theme';
import { TCI, COMISION_PCT } from '../../data/constants';
import { fmtMoneda } from '../../utils/format';

export default function FacturacionScreen({ modoAdmin, showBack }: { modoAdmin?: boolean; showBack?: boolean }) {
  const { usuario, facturas } = useApp();
  const navigation = useNavigation<any>();
  const mias = modoAdmin ? facturas : facturas.filter((f) => (usuario!.tipo === 'cliente' ? f.clienteId === usuario!.id : f.transportistaId === usuario!.id));
  const totalComision = mias.reduce((a, f) => a + f.comision, 0);

  return (
    <Screen title="Facturación" subtitle={modoAdmin ? 'NexCarg — Todas las facturas' : `NexCarg — ${usuario!.subtipo}`} onBack={showBack ? () => navigation.goBack() : undefined}>
      {modoAdmin && (
        <View style={{ flexDirection: 'row', gap: 12 }}>
          <StatTile label="Facturas emitidas" value={mias.length} sub="total" icon="receipt" accent={colors.ambar} />
          <StatTile label="Ingresos comisión" value={fmtMoneda(totalComision)} sub={`${COMISION_PCT}% por viaje`} icon="cash" accent={colors.verde} />
        </View>
      )}
      {mias.length === 0 && <EmptyState icon="receipt-outline" title="Sin facturas todavía" sub="Se generan automáticamente al liberarse el pago de un viaje" />}
      {mias.map((f) => (
        <View key={f.id} style={styles.card}>
          <View style={styles.iconWrap}><Ionicons name={(TCI[f.tipoCarga] as any) ?? 'receipt-outline'} size={20} color={colors.marino} /></View>
          <View style={{ flex: 1, minWidth: 0 }}>
            <Text style={styles.title} numberOfLines={1}>{f.numero} · {f.tipoCarga}</Text>
            <Text style={styles.sub} numberOfLines={1}>{f.ruta}</Text>
            <Text style={styles.sub}>{f.fecha}</Text>
            {modoAdmin && <Text style={styles.sub}>{f.cliente} → {f.transportista}</Text>}
            {!modoAdmin && usuario!.tipo === 'transportista' && (
              <Text style={styles.sub}>Bruto {fmtMoneda(f.monto)} − comisión {COMISION_PCT}% ({fmtMoneda(f.comision)})</Text>
            )}
          </View>
          <View style={{ alignItems: 'flex-end' }}>
            <Text style={styles.val}>{modoAdmin ? fmtMoneda(f.comision) : fmtMoneda(usuario!.tipo === 'transportista' ? f.montoTransportista : f.monto)}</Text>
            <Text style={styles.valSub}>{modoAdmin ? 'comisión' : usuario!.tipo === 'transportista' ? 'neto recibido' : 'total pagado'}</Text>
          </View>
        </View>
      ))}
    </Screen>
  );
}

const styles = StyleSheet.create({
  card: { flexDirection: 'row', gap: spacing.md, backgroundColor: colors.blanco, borderRadius: radius.lg, padding: spacing.md, ...shadow.card },
  iconWrap: { width: 42, height: 42, borderRadius: radius.md, backgroundColor: colors.gris50, alignItems: 'center', justifyContent: 'center' },
  title: { fontSize: 13.5, fontWeight: '700', color: colors.marino },
  sub: { fontSize: 11, color: colors.grisM, marginTop: 2 },
  val: { fontSize: 15, fontWeight: '800', color: colors.naranja },
  valSub: { fontSize: 9.5, color: colors.grisM },
});
