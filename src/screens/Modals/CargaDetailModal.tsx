import React from 'react';
import { ScrollView, StyleSheet, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useNavigation, useRoute } from '@react-navigation/native';
import Avatar from '../../components/Avatar';
import Badge from '../../components/Badge';
import Stars from '../../components/Stars';
import DetailRow from '../../components/DetailRow';
import ModalHeader from '../../components/ModalHeader';
import Button from '../../components/Button';
import { useApp } from '../../state/AppContext';
import { colors, spacing } from '../../theme/theme';
import { fmtMoneda } from '../../utils/format';
import { avgRating } from '../../utils/format';
import { Text } from 'react-native';

export default function CargaDetailModal() {
  const navigation = useNavigation<any>();
  const route = useRoute<any>();
  const { cargaId } = route.params as { cargaId: number };
  const { cargas, usuarios, usuario, historial, abrirOCrearConvo } = useApp();
  const c = cargas.find((x) => x.id === cargaId);
  if (!c) return null;
  const pub = usuarios.find((u) => u.id === c.clienteId);
  const puedeContactar = usuario!.tipo === 'cliente' ? c.clienteId !== usuario!.id : true;

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: colors.blanco }}>
      <ScrollView contentContainerStyle={styles.content}>
        <ModalHeader
          title={`${c.tipoCarga}`}
          badge={<Badge tone={c.estado} />}
          onClose={() => navigation.goBack()}
        />
        <View style={styles.pubRow}>
          <Avatar uri={pub?.selfie} tipo="cliente" size={40} />
          <View style={{ flex: 1 }}>
            <Text style={styles.pubName}>{c.cliente}</Text>
            <View style={{ flexDirection: 'row', gap: 6, alignItems: 'center' }}>
              <Badge tone={pub?.verificado ? 'verificado' : 'sinVerificar'} label={pub?.verificado ? 'Verificado' : 'Sin verificar'} />
              {pub && <Stars value={avgRating(historial, pub)} />}
            </View>
          </View>
        </View>
        {c.contrato && <DetailRow label="Contrato digital" value={c.contrato.firmaCliente && c.contrato.firmaTransportista ? '✅ Firmado por ambas partes' : '⏳ Pendiente de firma'} />}
        <DetailRow label="Ruta" value={`${c.ciudadOrigen} → ${c.ciudadDestino}`} />
        <DetailRow label="Peso" value={`${c.peso} ${c.unidadPeso}`} />
        <DetailRow label="Vehículo requerido" value={c.vehiculoReq} />
        <DetailRow label="Fecha de recogida" value={c.fecha} />
        <DetailRow label="Presupuesto" value={c.precioAcordado ? fmtMoneda(c.precioAcordado) : (c.presupuesto ? fmtMoneda(c.presupuesto) : 'Abierto a cotización')} valueStyle={{ fontSize: 17, color: colors.naranja }} />
        {c.transportistaNombre && <DetailRow label="Transportista" value={c.transportistaNombre} />}
        {!!c.descripcion && <DetailRow label="Descripción" value={c.descripcion} />}

        {puedeContactar && c.estado !== 'cancelada' && (
          <Button
            title="Contactar" fullWidth style={{ marginTop: spacing.lg }}
            onPress={() => {
              const yoTipo = usuario!.tipo === 'cliente' ? 'cliente' : 'transportista';
              const convoId = abrirOCrearConvo(c, usuario!.id, yoTipo as any);
              navigation.goBack();
              navigation.navigate('Tabs', { screen: 'Mensajes', params: { screen: 'Chat', params: { convoId } } });
            }}
          />
        )}
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  content: { padding: spacing.xl },
  pubRow: { flexDirection: 'row', alignItems: 'center', gap: 10, paddingBottom: spacing.md, marginBottom: 4, borderBottomWidth: 1, borderBottomColor: colors.gris100 },
  pubName: { fontSize: 14, fontWeight: '700', color: colors.marino },
});
