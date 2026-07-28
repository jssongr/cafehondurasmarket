import React, { useState } from 'react';
import { FlatList, Modal, Pressable, StyleSheet, Text, View } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useNavigation } from '@react-navigation/native';
import { useApp } from '../state/AppContext';
import { colors, radius, shadow, spacing } from '../theme/theme';
import { fmtTime } from '../utils/format';
import EmptyState from './EmptyState';

const ICONS: Record<string, keyof typeof Ionicons.glyphMap> = { mensaje: 'chatbubble', oferta: 'cash', sistema: 'megaphone' };

export default function NotifBell() {
  const { usuario, notifs, markNotifsRead } = useApp();
  const [open, setOpen] = useState(false);
  const navigation = useNavigation<any>();
  const mis = notifs.filter((n) => n.usuarioId === usuario!.id);
  const unread = mis.filter((n) => !n.leida).length;

  return (
    <>
      <Pressable style={styles.btn} onPress={() => { setOpen(true); markNotifsRead(usuario!.id); }}>
        <Ionicons name="notifications-outline" size={22} color={colors.marino} />
        {unread > 0 && <View style={styles.dot} />}
      </Pressable>
      <Modal visible={open} transparent animationType="fade" onRequestClose={() => setOpen(false)}>
        <Pressable style={styles.overlay} onPress={() => setOpen(false)}>
          <View style={styles.panel} onStartShouldSetResponder={() => true}>
            <View style={styles.panelHead}>
              <Text style={styles.panelTitle}>Notificaciones</Text>
              <Pressable onPress={() => setOpen(false)} hitSlop={8}><Ionicons name="close" size={18} color={colors.grisM} /></Pressable>
            </View>
            <FlatList
              data={mis}
              keyExtractor={(n) => String(n.id)}
              style={{ maxHeight: 420 }}
              ListEmptyComponent={<EmptyState icon="notifications-outline" title="Sin notificaciones" />}
              renderItem={({ item: n }) => (
                <Pressable
                  style={[styles.item, !n.leida && { backgroundColor: '#FFFBF2' }]}
                  onPress={() => {
                    setOpen(false);
                    if (n.tipo === 'mensaje' || n.tipo === 'oferta') navigation.navigate('Mensajes');
                  }}
                >
                  <Ionicons name={ICONS[n.tipo] ?? 'megaphone'} size={18} color={colors.marino} />
                  <View style={{ flex: 1 }}>
                    <Text style={styles.itemTitle}>{n.titulo}</Text>
                    <Text style={styles.itemSub}>{n.sub}</Text>
                    <Text style={styles.itemTime}>{fmtTime(n.ts)}</Text>
                  </View>
                </Pressable>
              )}
            />
          </View>
        </Pressable>
      </Modal>
    </>
  );
}

const styles = StyleSheet.create({
  btn: { width: 40, height: 40, borderRadius: 20, alignItems: 'center', justifyContent: 'center', backgroundColor: colors.blanco, ...shadow.card },
  dot: { position: 'absolute', top: 8, right: 9, width: 8, height: 8, borderRadius: 4, backgroundColor: colors.rojo, borderWidth: 1.5, borderColor: colors.blanco },
  overlay: { flex: 1, backgroundColor: 'rgba(15,41,66,0.4)', alignItems: 'flex-end', paddingTop: 60, paddingRight: spacing.lg },
  panel: { width: 320, maxWidth: '92%', backgroundColor: colors.blanco, borderRadius: radius.lg, overflow: 'hidden', ...shadow.floating },
  panelHead: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', padding: spacing.lg, borderBottomWidth: 1, borderBottomColor: colors.gris100 },
  panelTitle: { fontSize: 14, fontWeight: '700', color: colors.marino },
  item: { flexDirection: 'row', gap: 10, padding: spacing.lg, borderBottomWidth: 1, borderBottomColor: colors.gris100 },
  itemTitle: { fontSize: 12.5, fontWeight: '600', color: colors.marino },
  itemSub: { fontSize: 11, color: colors.grisM, marginTop: 2 },
  itemTime: { fontSize: 10, color: colors.grisM, marginTop: 3 },
});
