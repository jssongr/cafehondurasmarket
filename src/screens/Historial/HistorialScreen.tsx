import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { Ionicons } from '@expo/vector-icons';
import Screen from '../../components/Screen';
import Card from '../../components/Card';
import Badge from '../../components/Badge';
import Button from '../../components/Button';
import Stars from '../../components/Stars';
import EmptyState from '../../components/EmptyState';
import { useApp } from '../../state/AppContext';
import { colors, radius, shadow, spacing } from '../../theme/theme';
import { TCI } from '../../data/constants';
import { fmtMoneda } from '../../utils/format';

export default function HistorialScreen({ showBack }: { showBack?: boolean }) {
  const { usuario, historial } = useApp();
  const navigation = useNavigation<any>();
  const mis = historial.filter((h) => h.clienteId === usuario!.id || h.transportistaId === usuario!.id);

  return (
    <Screen title="Historial de Viajes" subtitle={`NexCarg — ${usuario!.subtipo}`} onBack={showBack ? () => navigation.goBack() : undefined}>
      {mis.length === 0 && <EmptyState icon="time-outline" title="Sin viajes completados" sub="Las entregas confirmadas aparecerán aquí" />}
      {mis.map((h) => {
        const miCal = usuario!.tipo === 'cliente' ? h.calTransportista : h.calCliente;
        const suCal = usuario!.tipo === 'cliente' ? h.calCliente : h.calTransportista;
        return (
          <View key={h.id} style={styles.card}>
            <View style={styles.iconWrap}><Ionicons name={(TCI[h.tipoCarga] as any) ?? 'cube-outline'} size={20} color={colors.marino} /></View>
            <View style={{ flex: 1, minWidth: 0 }}>
              <Text style={styles.title} numberOfLines={1}>{h.tipoCarga} · {usuario!.tipo === 'cliente' ? `Transportado por ${h.transportista}` : `Para ${h.cliente}`}</Text>
              <View style={styles.subRow}>
                <Text style={styles.sub} numberOfLines={1}>{h.ruta}</Text>
              </View>
              <View style={styles.subRow}><Text style={styles.sub}>{h.fecha}</Text><Badge tone="entregada" label="completado" /></View>
              {suCal && <Text style={styles.calRecibida}>Te calificaron: {suCal.estrellas}★ "{suCal.comentario}"</Text>}
              <View style={{ marginTop: 8 }}>
                {miCal ? (
                  <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
                    <Text style={styles.miCalLabel}>Tu calificación:</Text>
                    <Stars value={miCal.estrellas} />
                  </View>
                ) : (
                  <Button title="Calificar" size="sm" variant="accent" onPress={() => navigation.navigate('Calificar', { historialId: h.id })} />
                )}
              </View>
            </View>
            <View style={{ alignItems: 'flex-end' }}>
              <Text style={styles.val}>{fmtMoneda(h.monto)}</Text>
              <Text style={styles.valSub}>Pago liberado</Text>
            </View>
          </View>
        );
      })}
    </Screen>
  );
}

const styles = StyleSheet.create({
  card: { flexDirection: 'row', gap: spacing.md, backgroundColor: colors.blanco, borderRadius: radius.lg, padding: spacing.md, ...shadow.card },
  iconWrap: { width: 42, height: 42, borderRadius: radius.md, backgroundColor: colors.gris50, alignItems: 'center', justifyContent: 'center' },
  title: { fontSize: 13.5, fontWeight: '700', color: colors.marino },
  subRow: { flexDirection: 'row', alignItems: 'center', gap: 8, marginTop: 3 },
  sub: { fontSize: 11, color: colors.grisM, flexShrink: 1 },
  calRecibida: { fontSize: 10.5, color: colors.grisM, marginTop: 4 },
  miCalLabel: { fontSize: 11, color: colors.grisM },
  val: { fontSize: 16, fontWeight: '800', color: colors.naranja },
  valSub: { fontSize: 9.5, color: colors.grisM },
});
