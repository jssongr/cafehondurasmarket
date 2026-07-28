import React, { useEffect, useRef, useState } from 'react';
import {
  FlatList, KeyboardAvoidingView, Platform, Pressable, StyleSheet, Text, TextInput, View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useNavigation, useRoute } from '@react-navigation/native';
import { Ionicons } from '@expo/vector-icons';
import { useApp } from '../../state/AppContext';
import { colors, radius, shadow, spacing } from '../../theme/theme';
import { fmtMoneda, fmtTime } from '../../utils/format';
import Avatar from '../../components/Avatar';
import Badge from '../../components/Badge';
import Stars from '../../components/Stars';
import { avgRating } from '../../utils/format';
import { Mensaje } from '../../data/types';
import { TCI } from '../../data/constants';

export default function ChatScreen() {
  const route = useRoute<any>();
  const navigation = useNavigation<any>();
  const { convoId } = route.params as { convoId: number };
  const { usuario, convos, usuarios, cargas, historial, enviarMensaje, enviarOferta, responderOferta } = useApp();
  const [texto, setTexto] = useState('');
  const [showOferta, setShowOferta] = useState(false);
  const [ofertaVal, setOfertaVal] = useState('');
  const listRef = useRef<FlatList>(null);

  const convo = convos.find((c) => c.id === convoId);
  const otro = convo ? usuarios.find((u) => u.id === convo.participantes.find((p) => p !== usuario!.id)) : undefined;
  const carga = convo ? cargas.find((c) => c.id === convo.cargaId) : undefined;

  useEffect(() => {
    navigation.setOptions({ title: otro?.nombre ?? 'Chat' });
  }, [otro?.nombre]);

  useEffect(() => {
    setTimeout(() => listRef.current?.scrollToEnd({ animated: true }), 80);
  }, [convo?.mensajes.length]);

  if (!convo) return null;

  const enviar = () => {
    if (!texto.trim()) return;
    enviarMensaje(convo.id, usuario!.id, texto.trim());
    setTexto('');
  };

  const mandarOferta = () => {
    const val = parseInt(ofertaVal, 10);
    if (!val || val < 1) return;
    enviarOferta(convo.id, usuario!.id, val);
    setOfertaVal(''); setShowOferta(false);
  };

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: colors.crema }} edges={['bottom']}>
      <KeyboardAvoidingView style={{ flex: 1 }} behavior={Platform.OS === 'ios' ? 'padding' : undefined} keyboardVerticalOffset={90}>
        {carga && (
          <View style={styles.cargaBanner}>
            <Ionicons name={(TCI[carga.tipoCarga] as any) ?? 'cube-outline'} size={14} color={colors.marino} />
            <Text style={styles.cargaBannerText} numberOfLines={1}>{carga.tipoCarga} · {carga.paisOrigen} → {carga.paisDestino}</Text>
            {otro && <Stars value={avgRating(historial, otro)} />}
          </View>
        )}
        <FlatList
          ref={listRef}
          data={convo.mensajes}
          keyExtractor={(m) => String(m.id)}
          contentContainerStyle={{ padding: spacing.lg, gap: 10 }}
          renderItem={({ item: m }) => (
            <Bubble m={m} mine={m.de === usuario!.id} onAceptar={() => responderOferta(convo.id, m.id, 'aceptada')} onRechazar={() => responderOferta(convo.id, m.id, 'rechazada')} />
          )}
          ListEmptyComponent={<Text style={styles.emptyText}>Envía un mensaje para coordinar el viaje</Text>}
        />
        {showOferta && (
          <View style={styles.offerBar}>
            <Text style={styles.offerLabel}>💰 $</Text>
            <TextInput
              style={styles.offerInput} placeholder="ej. 950" keyboardType="numeric"
              value={ofertaVal} onChangeText={setOfertaVal} onSubmitEditing={mandarOferta}
            />
            <Pressable style={styles.offerSend} onPress={mandarOferta}><Text style={styles.offerSendText}>Enviar</Text></Pressable>
            <Pressable onPress={() => setShowOferta(false)} hitSlop={8}><Ionicons name="close" size={20} color={colors.grisM} /></Pressable>
          </View>
        )}
        <View style={styles.inputBar}>
          <Pressable style={styles.offerToggle} onPress={() => setShowOferta((v) => !v)}>
            <Ionicons name="cash" size={18} color={colors.naranja} />
          </Pressable>
          <TextInput
            style={styles.textInput} placeholder="Escribe un mensaje…" value={texto} onChangeText={setTexto}
            multiline onSubmitEditing={enviar}
          />
          <Pressable style={styles.sendBtn} onPress={enviar}>
            <Ionicons name="send" size={16} color="#fff" />
          </Pressable>
        </View>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

function Bubble({ m, mine, onAceptar, onRechazar }: { m: Mensaje; mine: boolean; onAceptar: () => void; onRechazar: () => void }) {
  if (m.tipo === 'oferta') {
    return (
      <View style={[styles.offerBubble, mine && styles.offerBubbleMine]}>
        <Text style={[styles.offerBubbleLabel, mine && { color: colors.marino }]}>{mine ? 'Tu cotización enviada' : 'Cotización recibida'}</Text>
        <Text style={styles.offerBubblePrice}>{fmtMoneda(m.precio)} <Text style={styles.offerBubbleUnit}>por el viaje</Text></Text>
        <Text style={styles.bubbleTime}>{fmtTime(m.ts)}</Text>
        {!mine && m.estado === 'pendiente' && (
          <View style={styles.offerBtnRow}>
            <Pressable style={[styles.miniBtn, { backgroundColor: colors.marino }]} onPress={onAceptar}><Text style={styles.miniBtnText}>✅ Aceptar</Text></Pressable>
            <Pressable style={[styles.miniBtn, { backgroundColor: colors.rojoBg }]} onPress={onRechazar}><Text style={[styles.miniBtnText, { color: colors.rojo }]}>❌ Rechazar</Text></Pressable>
          </View>
        )}
        {m.estado !== 'pendiente' && (
          <Text style={[styles.offerStatus, { color: m.estado === 'aceptada' ? colors.verde : colors.rojo }]}>
            {m.estado === 'aceptada' ? '✅ Aceptada' : '❌ Rechazada'}
          </Text>
        )}
      </View>
    );
  }
  return (
    <View style={[styles.bubble, mine ? styles.bubbleMine : styles.bubbleTheirs]}>
      <Text style={[styles.bubbleText, mine && { color: '#fff' }]}>{m.texto}</Text>
      <Text style={[styles.bubbleTime, mine && { color: 'rgba(255,255,255,0.65)' }]}>{fmtTime(m.ts)}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  cargaBanner: { flexDirection: 'row', alignItems: 'center', gap: 8, backgroundColor: colors.blanco, padding: 10, borderBottomWidth: 1, borderBottomColor: colors.gris100 },
  cargaBannerText: { fontSize: 11.5, color: colors.marino, fontWeight: '600', flex: 1 },
  emptyText: { textAlign: 'center', color: colors.grisM, fontSize: 13, marginTop: 40 },
  bubble: { maxWidth: '78%', borderRadius: radius.lg, padding: 12 },
  bubbleMine: { alignSelf: 'flex-end', backgroundColor: colors.marino, borderBottomRightRadius: 4 },
  bubbleTheirs: { alignSelf: 'flex-start', backgroundColor: colors.blanco, borderBottomLeftRadius: 4, ...shadow.card },
  bubbleText: { fontSize: 13.5, color: colors.texto, lineHeight: 19 },
  bubbleTime: { fontSize: 10, color: colors.grisM, marginTop: 4 },
  offerBubble: { maxWidth: '82%', alignSelf: 'flex-start', backgroundColor: colors.amarilloBg, borderWidth: 1.5, borderColor: colors.ambarL, borderRadius: radius.lg, padding: 13 },
  offerBubbleMine: { alignSelf: 'flex-end', backgroundColor: '#EEF3F8', borderColor: colors.marinoL },
  offerBubbleLabel: { fontSize: 10, fontWeight: '700', color: colors.amarilloTxt, textTransform: 'uppercase', marginBottom: 4 },
  offerBubblePrice: { fontSize: 19, fontWeight: '800', color: colors.naranja },
  offerBubbleUnit: { fontSize: 11, fontWeight: '400', color: colors.grisM },
  offerBtnRow: { flexDirection: 'row', gap: 8, marginTop: 8 },
  miniBtn: { paddingVertical: 7, paddingHorizontal: 12, borderRadius: radius.sm },
  miniBtnText: { fontSize: 11.5, fontWeight: '700', color: '#fff' },
  offerStatus: { marginTop: 6, fontSize: 11.5, fontWeight: '700' },
  offerBar: { flexDirection: 'row', alignItems: 'center', gap: 8, backgroundColor: colors.crema, padding: 10, borderTopWidth: 1, borderTopColor: colors.gris100 },
  offerLabel: { fontSize: 13, fontWeight: '700', color: colors.marino },
  offerInput: { flex: 1, backgroundColor: colors.blanco, borderWidth: 1.5, borderColor: colors.gris100, borderRadius: radius.sm, paddingVertical: 8, paddingHorizontal: 12, fontSize: 13 },
  offerSend: { backgroundColor: colors.naranja, paddingVertical: 8, paddingHorizontal: 14, borderRadius: radius.sm },
  offerSendText: { color: '#fff', fontSize: 12, fontWeight: '700' },
  inputBar: { flexDirection: 'row', alignItems: 'flex-end', gap: 8, padding: 10, backgroundColor: colors.blanco, borderTopWidth: 1, borderTopColor: colors.gris100 },
  offerToggle: { width: 40, height: 40, borderRadius: 20, backgroundColor: colors.amarilloBg, alignItems: 'center', justifyContent: 'center' },
  textInput: { flex: 1, borderWidth: 1.5, borderColor: colors.gris100, borderRadius: radius.md, paddingHorizontal: 14, paddingVertical: 10, fontSize: 13.5, maxHeight: 100 },
  sendBtn: { width: 40, height: 40, borderRadius: 20, backgroundColor: colors.marino, alignItems: 'center', justifyContent: 'center' },
});
