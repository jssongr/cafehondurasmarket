import React, { useState } from 'react';
import {
  KeyboardAvoidingView, Platform, Pressable, ScrollView, StyleSheet, Switch, Text, View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons } from '@expo/vector-icons';
import { useApp } from '../../state/AppContext';
import { colors, radius, shadow, spacing, type } from '../../theme/theme';
import TextField from '../../components/TextField';
import SelectField from '../../components/SelectField';
import Button from '../../components/Button';
import UploadZone from '../../components/UploadZone';
import StepIndicator from './StepIndicator';
import { CLIENTE_SUBTIPOS, TIPOS_VEHICULO, TRANSPORTISTA_SUBTIPOS } from '../../data/constants';
import { TipoUsuario } from '../../data/types';

export default function AuthScreen() {
  const { login, registrar, showToast, usuarios } = useApp();
  const [tab, setTab] = useState<'login' | 'reg'>('login');
  const [step, setStep] = useState(1);
  const [err, setErr] = useState('');

  // login state
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  // register state
  const [nombre, setNombre] = useState('');
  const [regEmail, setRegEmail] = useState('');
  const [regPassword, setRegPassword] = useState('');
  const [telefono, setTelefono] = useState('');
  const [tipo, setTipo] = useState<TipoUsuario | ''>('');
  const [subtipo, setSubtipo] = useState('');
  const [vehiculo, setVehiculo] = useState<string>(TIPOS_VEHICULO[0]);
  const [capacidad, setCapacidad] = useState('');
  const [placa, setPlaca] = useState('');
  const [docImg, setDocImg] = useState<string | null>(null);
  const [scanning, setScanning] = useState(false);
  const [scanned, setScanned] = useState(false);
  const [selfieImg, setSelfieImg] = useState<string | null>(null);
  const [selfieScanning, setSelfieScanning] = useState(false);
  const [selfieOk, setSelfieOk] = useState(false);

  const esTransportista = tipo === 'transportista';
  const subtipos = esTransportista ? TRANSPORTISTA_SUBTIPOS : CLIENTE_SUBTIPOS;

  const resetReg = () => {
    setStep(1); setNombre(''); setRegEmail(''); setRegPassword(''); setTelefono('');
    setTipo(''); setSubtipo(''); setDocImg(null); setScanned(false); setSelfieImg(null); setSelfieOk(false);
  };

  const doLogin = () => {
    const u = login(email.trim(), password);
    if (!u) setErr('Correo o contraseña incorrectos.');
    else setErr('');
  };

  const handleDoc = (uri: string) => {
    setDocImg(uri); setScanning(true); setScanned(false);
    setTimeout(() => { setScanning(false); setScanned(true); }, 1800);
  };

  const handleSelfie = (uri: string) => {
    setSelfieImg(uri); setSelfieScanning(true); setSelfieOk(false);
    setTimeout(() => { setSelfieScanning(false); setSelfieOk(true); }, 2200);
  };

  const finalizarRegistro = () => {
    if (!selfieOk) return setErr('Completa la verificación facial.');
    registrar({
      nombre, email: regEmail, password: regPassword, tipo: tipo as TipoUsuario, subtipo, telefono,
      vehiculo: esTransportista ? vehiculo : undefined,
      capacidad: esTransportista ? Number(capacidad) : null,
      placa: esTransportista ? placa : undefined,
      verificado: true, selfie: selfieImg, doc: docImg,
    });
    showToast('¡Cuenta verificada creada!');
  };

  return (
    <View style={styles.bg}>
      <LinearGradient colors={[colors.marino, colors.marinoL, colors.naranja]} start={{ x: 0, y: 0 }} end={{ x: 1, y: 1.4 }} style={StyleSheet.absoluteFill} />
      <SafeAreaView style={{ flex: 1 }}>
        <KeyboardAvoidingView style={{ flex: 1 }} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
          <ScrollView contentContainerStyle={styles.scroll} keyboardShouldPersistTaps="handled">
            <View style={styles.card}>
              <View style={styles.top}>
                <Ionicons name="rocket" size={34} color="#fff" />
                <Text style={styles.h1}>NexCarg</Text>
                <Text style={styles.tagline}>El transporte de carga terrestre de Panamá a México, en un solo lugar</Text>
              </View>

              <View style={styles.body}>
                <View style={styles.tabs}>
                  <Pressable style={[styles.tabBtn, tab === 'login' && styles.tabBtnOn]} onPress={() => { setTab('login'); setErr(''); }}>
                    <Text style={[styles.tabText, tab === 'login' && styles.tabTextOn]}>Iniciar sesión</Text>
                  </Pressable>
                  <Pressable style={[styles.tabBtn, tab === 'reg' && styles.tabBtnOn]} onPress={() => { setTab('reg'); setErr(''); resetReg(); }}>
                    <Text style={[styles.tabText, tab === 'reg' && styles.tabTextOn]}>Crear cuenta</Text>
                  </Pressable>
                </View>

                {!!err && (
                  <View style={styles.errBox}>
                    <Ionicons name="warning" size={14} color={colors.rojo} />
                    <Text style={styles.errText}>{err}</Text>
                  </View>
                )}

                {tab === 'login' ? (
                  <>
                    <TextField label="Correo" placeholder="correo@ejemplo.com" autoCapitalize="none" keyboardType="email-address" value={email} onChangeText={setEmail} />
                    <TextField label="Contraseña" placeholder="••••••" secureTextEntry value={password} onChangeText={setPassword} />
                    <Button title="Entrar a la plataforma" onPress={doLogin} fullWidth style={{ marginTop: 4 }} />
                    <Text style={styles.demoHint}>
                      Demo cliente: cliente@demo.com / 1234{'\n'}Demo transportista: transportista@demo.com / 1234{'\n'}Demo admin: admin@demo.com / 1234
                    </Text>
                  </>
                ) : (
                  <>
                    <StepIndicator steps={['Datos', 'Documento', 'Selfie']} current={step} />

                    {step === 1 && (
                      <>
                        <TextField label="Nombre completo o empresa" placeholder="Ej. Transportes del Norte S.A." value={nombre} onChangeText={setNombre} />
                        <TextField label="Correo electrónico" placeholder="correo@ejemplo.com" autoCapitalize="none" keyboardType="email-address" value={regEmail} onChangeText={setRegEmail} />
                        <TextField label="Contraseña" placeholder="Mínimo 6 caracteres" secureTextEntry value={regPassword} onChangeText={setRegPassword} />
                        <TextField label="Teléfono" placeholder="+(504) 9xxx-xxxx" keyboardType="phone-pad" value={telefono} onChangeText={setTelefono} />
                        <Text style={styles.fieldLabel}>¿Qué necesitas hacer?</Text>
                        <View style={styles.roleGrid}>
                          <RoleCard icon="business" label="Cliente" sub="Necesito transportar carga" selected={tipo === 'cliente'} onPress={() => { setTipo('cliente'); setSubtipo(''); }} />
                          <RoleCard icon="car-sport" label="Transportista" sub="Tengo camión disponible" selected={tipo === 'transportista'} onPress={() => { setTipo('transportista'); setSubtipo(''); }} />
                        </View>
                        {!!tipo && (
                          <SelectField label={esTransportista ? 'Tipo de transportista' : 'Tipo de empresa'} value={subtipo} options={subtipos} onChange={setSubtipo} />
                        )}
                        {esTransportista && (
                          <>
                            <SelectField label="Tipo de vehículo" value={vehiculo} options={TIPOS_VEHICULO} onChange={setVehiculo} />
                            <TextField label="Capacidad (toneladas)" placeholder="28" keyboardType="numeric" value={capacidad} onChangeText={setCapacidad} />
                            <TextField label="Placa del vehículo" placeholder="Ej. HN-1234" value={placa} onChangeText={setPlaca} />
                          </>
                        )}
                        <Button
                          title="Siguiente →" fullWidth
                          onPress={() => {
                            if (!nombre || !regEmail || !regPassword || !tipo || !subtipo || !telefono) return setErr('Completa todos los campos.');
                            if (esTransportista && !capacidad) return setErr('Indica la capacidad del vehículo.');
                            if (usuarios.find((u) => u.email === regEmail)) return setErr('Este correo ya está registrado.');
                            setErr(''); setStep(2);
                          }}
                        />
                      </>
                    )}

                    {step === 2 && (
                      <>
                        <Text style={styles.stepTitle}>{esTransportista ? '🪪 Licencia de conducir vigente' : '📋 Documento de la empresa (RTN / Registro mercantil)'}</Text>
                        <Text style={styles.stepSub}>
                          {esTransportista
                            ? 'Sube una foto clara de tu licencia de conducir. Esto nos ayuda a verificar tu identidad como transportista.'
                            : 'Sube una foto o escaneo de tu documento de registro comercial para verificar tu empresa.'}
                        </Text>
                        <UploadZone
                          icon={esTransportista ? 'card' : 'document-text'}
                          title="Subir documento" uploadedTitle="Documento cargado" sub="Toca para elegir una imagen"
                          image={docImg} onPicked={handleDoc}
                          scanning={scanning} scanningLabel="Leyendo datos del documento con IA…"
                          done={scanned} doneLabel="Documento verificado correctamente — datos extraídos"
                        />
                        <View style={styles.stepBtnRow}>
                          <Button title="← Atrás" variant="ghost" onPress={() => setStep(1)} style={{ flex: 1 }} />
                          <Button
                            title="Siguiente →" style={{ flex: 2 }}
                            onPress={() => { if (!scanned) return setErr('Sube tu documento para continuar.'); setErr(''); setStep(3); }}
                          />
                        </View>
                      </>
                    )}

                    {step === 3 && (
                      <>
                        <Text style={styles.stepTitle}>🤳 Selfie para reconocimiento facial</Text>
                        <Text style={styles.stepSub}>Tómate una selfie clara mirando de frente. Nuestra IA la comparará con tu documento para confirmar tu identidad.</Text>
                        <UploadZone
                          icon="camera" title="Subir selfie" uploadedTitle="Selfie cargada" sub="Toca para elegir una foto"
                          image={selfieImg} onPicked={handleSelfie}
                          scanning={selfieScanning} scanningLabel="Comparando rostro con documento mediante IA…"
                          done={selfieOk} doneLabel="¡Identidad verificada! Coincidencia facial confirmada"
                        />
                        <View style={styles.stepBtnRow}>
                          <Button title="← Atrás" variant="ghost" onPress={() => setStep(2)} style={{ flex: 1 }} />
                          <Button title="✅ Crear cuenta verificada" style={{ flex: 2 }} disabled={!selfieOk} onPress={finalizarRegistro} />
                        </View>
                      </>
                    )}
                  </>
                )}
              </View>
            </View>
          </ScrollView>
        </KeyboardAvoidingView>
      </SafeAreaView>
    </View>
  );
}

function RoleCard({ icon, label, sub, selected, onPress }: { icon: keyof typeof Ionicons.glyphMap; label: string; sub: string; selected: boolean; onPress: () => void }) {
  return (
    <Pressable style={[styles.roleCard, selected && styles.roleCardOn]} onPress={onPress}>
      <Ionicons name={icon} size={24} color={selected ? colors.marino : colors.grisM} />
      <Text style={[styles.roleLabel, selected && { color: colors.marino }]}>{label}</Text>
      <Text style={styles.roleSub}>{sub}</Text>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  bg: { flex: 1 },
  scroll: { flexGrow: 1, alignItems: 'center', justifyContent: 'center', padding: spacing.xl },
  card: { width: '100%', maxWidth: 460, backgroundColor: colors.blanco, borderRadius: radius.xl, overflow: 'hidden', ...shadow.floating },
  top: { paddingVertical: 30, paddingHorizontal: spacing.xl, alignItems: 'center', backgroundColor: colors.marino, gap: 4 },
  h1: { ...type.display, color: '#fff', marginTop: 6 },
  tagline: { fontSize: 12, color: 'rgba(255,255,255,0.65)', textAlign: 'center', marginTop: 2 },
  body: { padding: spacing.xl },
  tabs: { flexDirection: 'row', backgroundColor: colors.gris100, borderRadius: radius.md, padding: 3, marginBottom: spacing.lg },
  tabBtn: { flex: 1, paddingVertical: 9, borderRadius: radius.sm, alignItems: 'center' },
  tabBtnOn: { backgroundColor: colors.marino },
  tabText: { fontSize: 13, fontWeight: '700', color: colors.grisM },
  tabTextOn: { color: '#fff' },
  errBox: { flexDirection: 'row', gap: 8, alignItems: 'center', backgroundColor: colors.rojoBg, borderRadius: radius.sm, padding: 10, marginBottom: 10 },
  errText: { color: colors.rojo, fontSize: 12, flex: 1 },
  demoHint: { textAlign: 'center', fontSize: 10.5, color: colors.grisM, marginTop: 12, lineHeight: 16 },
  fieldLabel: { fontSize: 11, fontWeight: '700', color: colors.naranja, marginBottom: 8, textTransform: 'uppercase', letterSpacing: 0.4 },
  roleGrid: { flexDirection: 'row', gap: 10, marginBottom: 12 },
  roleCard: { flex: 1, borderWidth: 2, borderColor: colors.gris100, borderRadius: radius.lg, padding: 14, alignItems: 'center', gap: 4 },
  roleCardOn: { borderColor: colors.marino, backgroundColor: '#EEF3F8' },
  roleLabel: { fontSize: 12.5, fontWeight: '700', color: colors.grisM },
  roleSub: { fontSize: 10, color: colors.grisM, textAlign: 'center' },
  stepTitle: { fontSize: 13.5, fontWeight: '700', color: colors.marino, marginBottom: 4 },
  stepSub: { fontSize: 12, color: colors.grisM, marginBottom: 14, lineHeight: 17 },
  stepBtnRow: { flexDirection: 'row', gap: 8, marginTop: 14 },
});
