import React from 'react';
import { ScrollView, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useNavigation, useRoute } from '@react-navigation/native';
import ModalHeader from '../../components/ModalHeader';
import Badge from '../../components/Badge';
import DetailRow from '../../components/DetailRow';
import Button from '../../components/Button';
import { useApp } from '../../state/AppContext';
import { colors, radius, spacing } from '../../theme/theme';
import { COMISION_PCT } from '../../data/constants';
import { fmtMoneda, fmtTime } from '../../utils/format';

export default function ContratoModal() {
  const navigation = useNavigation<any>();
  const route = useRoute<any>();
  const { cargaId } = route.params as { cargaId: number };
  const { cargas, usuario, firmarContrato } = useApp();
  const c = cargas.find((x) => x.id === cargaId);
  if (!c || !c.contrato) return null;

  const yaFirme = usuario!.tipo === 'cliente' ? c.contrato.firmaCliente : c.contrato.firmaTransportista;
  const ambos = c.contrato.firmaCliente && c.contrato.firmaTransportista;

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: colors.blanco }}>
      <ScrollView contentContainerStyle={styles.content}>
        <ModalHeader
          title="Contrato de transporte"
          badge={<Badge tone={ambos ? 'verificado' : 'asignada'} label={ambos ? 'Firmado por ambas partes' : 'Pendiente de firma'} />}
          onClose={() => navigation.goBack()}
        />
        <View style={styles.textBox}>
          <Text style={styles.p}>
            Contrato digital generado por <Text style={styles.b}>NexCarg</Text> entre <Text style={styles.b}>{c.cliente}</Text> ("el Cliente") y{' '}
            <Text style={styles.b}>{c.transportistaNombre}</Text> ("el Transportista") para el transporte de <Text style={styles.b}>{c.tipoCarga}</Text> ({c.peso} {c.unidadPeso}) desde{' '}
            <Text style={styles.b}>{c.ciudadOrigen}, {c.paisOrigen}</Text> hasta <Text style={styles.b}>{c.ciudadDestino}, {c.paisDestino}</Text>, con fecha de recogida <Text style={styles.b}>{c.fecha}</Text>.
          </Text>
          <Text style={[styles.p, { marginTop: 10 }]}>
            El monto acordado es de <Text style={styles.b}>{fmtMoneda(c.precioAcordado)}</Text>, retenido en garantía (escrow) por NexCarg y liberado al Transportista al confirmarse la entrega.
            NexCarg retiene una comisión de servicio del {COMISION_PCT}% sobre el monto del viaje.
          </Text>
          <Text style={[styles.p, { marginTop: 10 }]}>
            Ambas partes se comprometen a coordinar la recogida y entrega dentro de los plazos acordados, y a calificarse mutuamente al finalizar el viaje.
          </Text>
        </View>

        <DetailRow label="Cliente" value={c.contrato.firmaCliente ? `✅ Firmado ${fmtTime(c.contrato.fechaCliente!)}` : '⏳ Sin firmar'} />
        <DetailRow label="Transportista" value={c.contrato.firmaTransportista ? `✅ Firmado ${fmtTime(c.contrato.fechaTransportista!)}` : '⏳ Sin firmar'} />

        {!yaFirme && (
          <Button title="Firmar contrato" fullWidth style={{ marginTop: spacing.lg }} onPress={() => firmarContrato(c.id, usuario!.tipo as any)} />
        )}
        {yaFirme && !ambos && (
          <Text style={styles.hint}>Ya firmaste. Esperando la firma de la otra parte.</Text>
        )}
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  content: { padding: spacing.xl },
  textBox: { backgroundColor: colors.crema, borderRadius: radius.lg, padding: spacing.lg, marginBottom: spacing.md },
  p: { fontSize: 12.5, lineHeight: 20, color: colors.texto },
  b: { fontWeight: '700' },
  hint: { textAlign: 'center', fontSize: 12, color: colors.grisM, marginTop: spacing.lg },
});
