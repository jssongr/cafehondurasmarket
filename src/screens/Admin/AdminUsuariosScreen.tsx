import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import Screen from '../../components/Screen';
import Avatar from '../../components/Avatar';
import Badge from '../../components/Badge';
import Stars from '../../components/Stars';
import { useApp } from '../../state/AppContext';
import { colors, radius, shadow, spacing } from '../../theme/theme';
import { avgRating } from '../../utils/format';

export default function AdminUsuariosScreen() {
  const { usuarios, historial, usuario } = useApp();
  const users = usuarios.filter((u) => u.tipo !== 'admin');

  return (
    <Screen title="Usuarios" subtitle={`NexCarg — ${usuario!.subtipo}`}>
      <View style={{ gap: spacing.md }}>
        {users.map((u) => (
          <View key={u.id} style={styles.card}>
            <Avatar uri={u.selfie} tipo={u.tipo} size={40} />
            <View style={{ flex: 1, minWidth: 0 }}>
              <Text style={styles.name} numberOfLines={1}>{u.nombre}</Text>
              <Text style={styles.sub} numberOfLines={1}>{u.subtipo} · {u.email}</Text>
            </View>
            <View style={{ alignItems: 'flex-end', gap: 4 }}>
              <Badge tone={u.verificado ? 'verificado' : 'sinVerificar'} label={u.verificado ? 'Verificado' : 'Sin verificar'} />
              <Stars value={avgRating(historial, u)} />
            </View>
          </View>
        ))}
      </View>
    </Screen>
  );
}

const styles = StyleSheet.create({
  card: { flexDirection: 'row', alignItems: 'center', gap: spacing.md, backgroundColor: colors.blanco, borderRadius: radius.lg, padding: spacing.md, ...shadow.card },
  name: { fontSize: 13.5, fontWeight: '700', color: colors.marino },
  sub: { fontSize: 11, color: colors.grisM, marginTop: 2 },
});
