import React from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import Screen from '../../components/Screen';
import Avatar from '../../components/Avatar';
import EmptyState from '../../components/EmptyState';
import { useApp } from '../../state/AppContext';
import { colors, radius, shadow, spacing } from '../../theme/theme';
import { fmtMoneda, fmtTime } from '../../utils/format';

export default function ConversationsScreen() {
  const { usuario, convos, usuarios } = useApp();
  const navigation = useNavigation<any>();
  const mis = convos.filter((c) => c.participantes.includes(usuario!.id));
  const otro = (c: typeof mis[number]) => usuarios.find((u) => u.id === c.participantes.find((p) => p !== usuario!.id));

  return (
    <Screen title="Mensajes" subtitle={`${mis.length} conversaciones`}>
      {mis.length === 0 && <EmptyState icon="chatbubbles-outline" title="Sin conversaciones" sub="Contacta desde el mercado de cargas" />}
      <View style={{ gap: spacing.sm }}>
        {mis.map((c) => {
          const o = otro(c);
          const last = c.mensajes[c.mensajes.length - 1];
          return (
            <Pressable key={c.id} style={styles.item} onPress={() => navigation.navigate('Chat', { convoId: c.id })}>
              <Avatar uri={o?.selfie} tipo={o?.tipo ?? 'cliente'} size={44} />
              <View style={{ flex: 1, minWidth: 0 }}>
                <View style={styles.topRow}>
                  <Text style={styles.name} numberOfLines={1}>{o?.nombre ?? 'Usuario'}</Text>
                  {last && <Text style={styles.time}>{fmtTime(last.ts)}</Text>}
                </View>
                <Text style={styles.last} numberOfLines={1}>
                  {last ? (last.tipo === 'oferta' ? `💰 Cotización: ${fmtMoneda(last.precio)}` : last.texto) : 'Sin mensajes'}
                </Text>
              </View>
            </Pressable>
          );
        })}
      </View>
    </Screen>
  );
}

const styles = StyleSheet.create({
  item: { flexDirection: 'row', alignItems: 'center', gap: 12, backgroundColor: colors.blanco, borderRadius: radius.lg, padding: spacing.md, ...shadow.card },
  topRow: { flexDirection: 'row', justifyContent: 'space-between', gap: 8 },
  name: { fontSize: 13.5, fontWeight: '700', color: colors.marino, flexShrink: 1 },
  time: { fontSize: 10.5, color: colors.grisM },
  last: { fontSize: 12, color: colors.grisM, marginTop: 2 },
});
