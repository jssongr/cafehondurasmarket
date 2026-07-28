import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import Screen from '../../components/Screen';
import Card from '../../components/Card';
import Badge from '../../components/Badge';
import Button from '../../components/Button';
import EmptyState from '../../components/EmptyState';
import CorridorTrack from '../../components/CorridorTrack';
import { useApp } from '../../state/AppContext';
import { TCI } from '../../data/constants';
import { colors } from '../../theme/theme';
import { useNavigation } from '@react-navigation/native';

export default function SeguimientoScreen({ showBack }: { showBack?: boolean }) {
  const { usuario, cargas, iniciarViaje, confirmarEntregaManual } = useApp();
  const navigation = useNavigation<any>();
  const mios = cargas.filter((c) => {
    const esParticipante = usuario!.tipo === 'cliente' ? c.clienteId === usuario!.id : c.transportistaId === usuario!.id;
    return esParticipante && ['asignada', 'en_transito'].includes(c.estado);
  });

  return (
    <Screen title="Seguimiento GPS" subtitle={`NexCarg — ${usuario!.subtipo}`} onBack={showBack ? () => navigation.goBack() : undefined}>
      {mios.length === 0 && <EmptyState icon="location-outline" title="No tienes viajes en curso" sub="Aquí verás el seguimiento GPS en tiempo real de tus cargas asignadas" />}
      {mios.map((c) => {
        const firmado = c.contrato && c.contrato.firmaCliente && c.contrato.firmaTransportista;
        return (
          <Card key={c.id}>
            <View style={styles.head}>
              <View style={{ flex: 1 }}>
                <View style={styles.titleRow}>
                  <Ionicons name={(TCI[c.tipoCarga] as any) ?? 'cube-outline'} size={16} color={colors.marino} />
                  <Text style={styles.title}>{c.tipoCarga} · {c.peso} {c.unidadPeso}</Text>
                </View>
                <Text style={styles.sub}>{c.ciudadOrigen}, {c.paisOrigen} → {c.ciudadDestino}, {c.paisDestino}</Text>
                <Text style={styles.sub}>{usuario!.tipo === 'cliente' ? `Transportista: ${c.transportistaNombre}` : `Cliente: ${c.cliente}`}</Text>
              </View>
              <Badge tone={c.estado} label={c.estado === 'asignada' ? 'Esperando inicio' : 'En tránsito'} />
            </View>
            <CorridorTrack carga={c} />
            {usuario!.tipo === 'transportista' && c.estado === 'asignada' && (
              firmado
                ? <Button title="Iniciar viaje" size="sm" onPress={() => iniciarViaje(c.id)} style={{ marginTop: 10 }} />
                : <Button title="Firmar contrato para iniciar" size="sm" variant="accent" onPress={() => navigation.navigate('Contrato', { cargaId: c.id })} style={{ marginTop: 10 }} />
            )}
            {usuario!.tipo === 'transportista' && c.estado === 'en_transito' && (
              <Button title="Confirmar entrega" size="sm" variant="ghost" onPress={() => confirmarEntregaManual(c.id)} style={{ marginTop: 10 }} />
            )}
          </Card>
        );
      })}
    </Screen>
  );
}

const styles = StyleSheet.create({
  head: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'flex-start', gap: 8, marginBottom: 4 },
  titleRow: { flexDirection: 'row', alignItems: 'center', gap: 6 },
  title: { fontSize: 14, fontWeight: '700', color: colors.marino },
  sub: { fontSize: 11, color: colors.grisM, marginTop: 3 },
});
