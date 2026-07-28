import React, { useMemo, useState } from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import Screen from '../../components/Screen';
import SelectField from '../../components/SelectField';
import TextField from '../../components/TextField';
import CargaMarketCard from '../../components/CargaMarketCard';
import EmptyState from '../../components/EmptyState';
import { useApp } from '../../state/AppContext';
import { PAISES, TIPOS_CARGA } from '../../data/constants';
import { colors, radius, shadow, spacing } from '../../theme/theme';

export default function CargasDisponiblesScreen() {
  const { usuario, cargas, usuarios, asignarCarga, abrirOCrearConvo, addNotif, showToast } = useApp();
  const navigation = useNavigation<any>();
  const [paisOrigen, setPaisOrigen] = useState('');
  const [paisDestino, setPaisDestino] = useState('');
  const [tipoCarga, setTipoCarga] = useState('');
  const [buscar, setBuscar] = useState('');

  const res = useMemo(() => cargas.filter((c) => {
    if (c.estado !== 'publicada') return false;
    if (paisOrigen && c.paisOrigen !== paisOrigen) return false;
    if (paisDestino && c.paisDestino !== paisDestino) return false;
    if (tipoCarga && c.tipoCarga !== tipoCarga) return false;
    if (buscar && !c.cliente.toLowerCase().includes(buscar.toLowerCase()) && !c.tipoCarga.toLowerCase().includes(buscar.toLowerCase())) return false;
    return true;
  }), [cargas, paisOrigen, paisDestino, tipoCarga, buscar]);

  const { historial } = useApp();

  return (
    <Screen title="Cargas Disponibles" subtitle={`NexCarg — ${usuario!.subtipo}`}>
      <View style={styles.filters}>
        <View style={styles.filterRow}>
          <View style={{ flex: 1 }}><SelectField label="Origen" value={paisOrigen} options={PAISES} onChange={setPaisOrigen} placeholder="Todos" /></View>
          <View style={{ flex: 1 }}><SelectField label="Destino" value={paisDestino} options={PAISES} onChange={setPaisDestino} placeholder="Todos" /></View>
        </View>
        <SelectField label="Tipo de carga" value={tipoCarga} options={TIPOS_CARGA} onChange={setTipoCarga} placeholder="Todos" />
        <TextField label="Buscar" placeholder="Cliente, tipo de carga…" value={buscar} onChangeText={setBuscar} />
        {!!(paisOrigen || paisDestino || tipoCarga || buscar) && (
          <Text style={styles.clear} onPress={() => { setPaisOrigen(''); setPaisDestino(''); setTipoCarga(''); setBuscar(''); }}>Limpiar filtros</Text>
        )}
      </View>

      {res.length === 0 && <EmptyState icon="search" title="Sin cargas disponibles con esos filtros" />}

      {res.map((c) => (
        <CargaMarketCard
          key={c.id}
          carga={c}
          cliente={usuarios.find((u) => u.id === c.clienteId)}
          historial={historial}
          onPress={() => navigation.navigate('CargaDetail', { cargaId: c.id })}
          onAceptar={() => {
            asignarCarga(c.id, usuario!.id, usuario!.nombre, c.presupuesto!);
            abrirOCrearConvo(c, usuario!.id, 'transportista');
            addNotif(c.clienteId, 'sistema', '🚚 Viaje aceptado', `${usuario!.nombre} aceptó transportar tu ${c.tipoCarga}.`);
            showToast('¡Viaje aceptado! Coordina la recogida en Mensajes.');
            navigation.navigate('MisViajes');
          }}
          onCotizar={() => {
            const convoId = abrirOCrearConvo(c, usuario!.id, 'transportista');
            navigation.navigate('Mensajes', { screen: 'Chat', params: { convoId } });
          }}
        />
      ))}
    </Screen>
  );
}

const styles = StyleSheet.create({
  filters: { backgroundColor: colors.blanco, borderRadius: radius.lg, padding: spacing.lg, ...shadow.card },
  filterRow: { flexDirection: 'row', gap: 10 },
  clear: { fontSize: 12, color: colors.naranja, fontWeight: '700', textAlign: 'right' },
});
