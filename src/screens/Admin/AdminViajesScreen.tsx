import React from 'react';
import { View } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import Screen from '../../components/Screen';
import CargaListItem from '../../components/CargaListItem';
import { useApp } from '../../state/AppContext';
import { spacing } from '../../theme/theme';

export default function AdminViajesScreen() {
  const { cargas, usuario } = useApp();
  const navigation = useNavigation<any>();

  return (
    <Screen title="Viajes" subtitle={`NexCarg — ${usuario!.subtipo}`}>
      <View style={{ gap: spacing.md }}>
        {cargas.map((c) => (
          <CargaListItem
            key={c.id}
            carga={c}
            subtitle={`${c.cliente} → ${c.transportistaNombre ?? 'sin asignar'}`}
            onPress={() => navigation.navigate('CargaDetail', { cargaId: c.id })}
          />
        ))}
      </View>
    </Screen>
  );
}
