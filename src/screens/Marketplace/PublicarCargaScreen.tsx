import React, { useState } from 'react';
import { Alert, Pressable, StyleSheet, Switch, Text, View } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import Screen from '../../components/Screen';
import Card from '../../components/Card';
import TextField from '../../components/TextField';
import SelectField from '../../components/SelectField';
import Button from '../../components/Button';
import { useApp } from '../../state/AppContext';
import { CIUDADES, PAISES, TIPOS_CARGA, TIPOS_VEHICULO } from '../../data/constants';
import { colors, radius, spacing } from '../../theme/theme';

export default function PublicarCargaScreen() {
  const { usuario, publicarCarga, showToast } = useApp();
  const [tipoCarga, setTipoCarga] = useState<string>(TIPOS_CARGA[0]);
  const [peso, setPeso] = useState('');
  const [unidadPeso, setUnidadPeso] = useState<'ton' | 'kg'>('ton');
  const [paisOrigen, setPaisOrigen] = useState<string>(PAISES[0]);
  const [ciudadOrigen, setCiudadOrigen] = useState(CIUDADES[PAISES[0]][0]);
  const [paisDestino, setPaisDestino] = useState<string>(PAISES[1]);
  const [ciudadDestino, setCiudadDestino] = useState(CIUDADES[PAISES[1]][0]);
  const [fecha, setFecha] = useState('');
  const [vehiculoReq, setVehiculoReq] = useState<string>(TIPOS_VEHICULO[0]);
  const [abierto, setAbierto] = useState(false);
  const [presupuesto, setPresupuesto] = useState('');
  const [descripcion, setDescripcion] = useState('');

  const submit = () => {
    if (!peso || !fecha) return Alert.alert('Campos requeridos', 'Peso y fecha de recogida son obligatorios.');
    if (!abierto && !presupuesto) return Alert.alert('Campos requeridos', "Indica un presupuesto o activa 'Abierto a cotizaciones'.");
    publicarCarga({
      clienteId: usuario!.id, cliente: usuario!.nombre, tipoCarga, peso: Number(peso), unidadPeso,
      paisOrigen, ciudadOrigen, paisDestino, ciudadDestino, fecha, vehiculoReq,
      presupuesto: abierto ? null : Number(presupuesto), descripcion, estado: 'publicada',
      transportistaId: null, transportistaNombre: null, precioAcordado: null, progreso: 0,
      pago: { estado: 'pendiente', monto: null }, contrato: null, fechaAsignacion: null, fechaEntrega: null,
    });
    showToast('¡Carga publicada! Los transportistas ya pueden verla.');
    setPeso(''); setFecha(''); setPresupuesto(''); setDescripcion('');
  };

  return (
    <Screen title="Publicar Carga" subtitle="Completa los datos de tu envío">
      <Card>
        <SelectField label="Tipo de mercancía" value={tipoCarga} options={TIPOS_CARGA} onChange={setTipoCarga} />
        <SelectField label="Vehículo requerido" value={vehiculoReq} options={TIPOS_VEHICULO} onChange={setVehiculoReq} />
        <View style={styles.row2}>
          <View style={{ flex: 2 }}><TextField label="Peso" placeholder="15" keyboardType="numeric" value={peso} onChangeText={setPeso} /></View>
          <View style={{ flex: 1 }}>
            <Text style={styles.miniLabel}>Unidad</Text>
            <View style={styles.segment}>
              {(['ton', 'kg'] as const).map((u) => (
                <Pressable key={u} style={[styles.segmentBtn, unidadPeso === u && styles.segmentBtnOn]} onPress={() => setUnidadPeso(u)}>
                  <Text style={[styles.segmentText, unidadPeso === u && styles.segmentTextOn]}>{u}</Text>
                </Pressable>
              ))}
            </View>
          </View>
        </View>
        <SelectField label="País de origen" value={paisOrigen} options={PAISES} onChange={(v) => { setPaisOrigen(v); setCiudadOrigen(CIUDADES[v][0]); }} />
        <SelectField label="Ciudad de origen" value={ciudadOrigen} options={CIUDADES[paisOrigen]} onChange={setCiudadOrigen} />
        <SelectField label="País de destino" value={paisDestino} options={PAISES} onChange={(v) => { setPaisDestino(v); setCiudadDestino(CIUDADES[v][0]); }} />
        <SelectField label="Ciudad de destino" value={ciudadDestino} options={CIUDADES[paisDestino]} onChange={setCiudadDestino} />
        <TextField label="Fecha de recogida (AAAA-MM-DD)" placeholder="2026-08-15" value={fecha} onChangeText={setFecha} />
        <TextField
          label="Presupuesto (USD)" placeholder="1200" keyboardType="numeric" value={presupuesto}
          onChangeText={setPresupuesto} editable={!abierto} style={abierto ? { opacity: 0.5 } : undefined}
        />
        <Pressable style={styles.switchRow} onPress={() => setAbierto((v) => !v)}>
          <Switch value={abierto} onValueChange={setAbierto} trackColor={{ true: colors.ambar }} />
          <Text style={styles.switchLabel}>Abierto a cotizaciones (sin precio fijo)</Text>
        </Pressable>
        <TextField label="Descripción" placeholder="Detalles de la carga, condiciones de manejo, etc." multiline value={descripcion} onChangeText={setDescripcion} />
        <Button title="Publicar carga" icon={<Ionicons name="rocket" size={16} color="#fff" />} onPress={submit} fullWidth />
      </Card>
    </Screen>
  );
}

const styles = StyleSheet.create({
  row2: { flexDirection: 'row', gap: 10 },
  miniLabel: { fontSize: 11, fontWeight: '700', color: colors.naranja, marginBottom: 5, textTransform: 'uppercase', letterSpacing: 0.4 },
  segment: { flexDirection: 'row', borderRadius: radius.md, backgroundColor: colors.gris100, padding: 3 },
  segmentBtn: { flex: 1, paddingVertical: 10, alignItems: 'center', borderRadius: radius.sm },
  segmentBtnOn: { backgroundColor: colors.marino },
  segmentText: { fontSize: 12, fontWeight: '700', color: colors.grisM },
  segmentTextOn: { color: '#fff' },
  switchRow: { flexDirection: 'row', alignItems: 'center', gap: 10, marginBottom: spacing.md },
  switchLabel: { fontSize: 12, color: colors.grisM, flex: 1 },
});
