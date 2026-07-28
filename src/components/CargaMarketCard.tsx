import React from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import { Carga, Usuario } from '../data/types';
import { TCI } from '../data/constants';
import { colors, radius, shadow, spacing } from '../theme/theme';
import Badge from './Badge';
import Avatar from './Avatar';
import Stars from './Stars';
import Button from './Button';
import { fmtMoneda } from '../utils/format';
import { HistorialItem } from '../data/types';
import { avgRating } from '../utils/format';

const HEAD_GRADIENTS: Record<string, [string, string]> = {
  publicada: [colors.marino, colors.marinoL],
  asignada: [colors.ambar, colors.naranja],
  en_transito: [colors.indigo, '#6366f1'],
  entregada: [colors.verde, '#22c55e'],
  cancelada: ['#7f1d1d', colors.rojo],
};

export default function CargaMarketCard({
  carga, cliente, historial, onPress, onAceptar, onCotizar,
}: {
  carga: Carga;
  cliente?: Usuario;
  historial: HistorialItem[];
  onPress: () => void;
  onAceptar: () => void;
  onCotizar: () => void;
}) {
  return (
    <View style={styles.card}>
      <Pressable onPress={onPress}>
        <LinearGradient colors={HEAD_GRADIENTS[carga.estado] ?? HEAD_GRADIENTS.publicada} start={{ x: 0, y: 0 }} end={{ x: 1, y: 1 }} style={styles.head}>
          <Ionicons name={(TCI[carga.tipoCarga] as any) ?? 'cube-outline'} size={30} color="#fff" />
          <View style={{ flex: 1 }}>
            <Text style={styles.headMeta}>{carga.peso} {carga.unidadPeso} · {carga.estado.replace('_', ' ')}</Text>
            <Text style={styles.headTitle} numberOfLines={1}>{carga.tipoCarga}</Text>
          </View>
        </LinearGradient>
      </Pressable>
      <View style={styles.body}>
        <View style={styles.pubRow}>
          <Avatar uri={cliente?.selfie} tipo="cliente" size={30} />
          <View style={{ flex: 1 }}>
            <Text style={styles.pubName}>{carga.cliente}</Text>
            <View style={{ flexDirection: 'row', gap: 6, alignItems: 'center' }}>
              <Badge tone={cliente?.verificado ? 'verificado' : 'sinVerificar'} label={cliente?.verificado ? 'Verificado' : 'Sin verificar'} />
              {cliente && <Stars value={avgRating(historial, cliente)} />}
            </View>
          </View>
        </View>
        <View style={styles.routeBox}>
          <Ionicons name="location" size={13} color={colors.naranja} />
          <Text style={styles.routeText} numberOfLines={1}>{carga.ciudadOrigen}, {carga.paisOrigen}</Text>
          <Ionicons name="arrow-forward" size={12} color={colors.naranja} />
          <Text style={styles.routeText} numberOfLines={1}>{carga.ciudadDestino}, {carga.paisDestino}</Text>
        </View>
        <Row label="Vehículo requerido" value={carga.vehiculoReq} />
        <Row label="Fecha de recogida" value={carga.fecha} />
        <Text style={styles.price}>{carga.presupuesto ? fmtMoneda(carga.presupuesto) : 'Abierto a cotización'}</Text>
        <View style={styles.btnRow}>
          {!!carga.presupuesto && <Button title="Aceptar viaje" size="sm" onPress={onAceptar} style={{ flex: 1 }} />}
          <Button title="Cotizar" size="sm" variant="accent" onPress={onCotizar} style={{ flex: 1 }} />
        </View>
      </View>
    </View>
  );
}

function Row({ label, value }: { label: string; value: string }) {
  return (
    <View style={styles.row}>
      <Text style={styles.rowLabel}>{label}</Text>
      <Text style={styles.rowValue} numberOfLines={1}>{value}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  card: { backgroundColor: colors.blanco, borderRadius: radius.lg, overflow: 'hidden', ...shadow.card },
  head: { padding: spacing.lg, flexDirection: 'row', alignItems: 'center', gap: 12 },
  headMeta: { fontSize: 10, color: 'rgba(255,255,255,0.7)', textTransform: 'uppercase', letterSpacing: 0.5 },
  headTitle: { fontSize: 15, color: '#fff', fontWeight: '700', marginTop: 2 },
  body: { padding: spacing.lg },
  pubRow: { flexDirection: 'row', alignItems: 'center', gap: 10, marginBottom: 12 },
  pubName: { fontSize: 12.5, fontWeight: '700', color: colors.marino },
  routeBox: { flexDirection: 'row', alignItems: 'center', gap: 6, backgroundColor: colors.crema, borderRadius: radius.sm, padding: 9, marginBottom: 10 },
  routeText: { fontSize: 11.5, fontWeight: '700', color: colors.marino, flexShrink: 1 },
  row: { flexDirection: 'row', justifyContent: 'space-between', marginBottom: 7 },
  rowLabel: { fontSize: 11.5, color: colors.grisM },
  rowValue: { fontSize: 11.5, fontWeight: '600', color: colors.marino, flexShrink: 1, textAlign: 'right' },
  price: { fontSize: 19, fontWeight: '800', color: colors.naranja, marginVertical: 8 },
  btnRow: { flexDirection: 'row', gap: 8 },
});
