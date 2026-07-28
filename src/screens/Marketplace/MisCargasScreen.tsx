import React from 'react';
import { View } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import Screen from '../../components/Screen';
import CargaListItem from '../../components/CargaListItem';
import EmptyState from '../../components/EmptyState';
import Button from '../../components/Button';
import { useApp } from '../../state/AppContext';
import { spacing } from '../../theme/theme';

export default function MisCargasScreen() {
  const { usuario, cargas, cancelarCarga, showToast } = useApp();
  const navigation = useNavigation<any>();
  const mias = cargas.filter((c) => c.clienteId === usuario!.id);

  return (
    <Screen title="Mis Cargas" subtitle={`NexCarg — ${usuario!.subtipo}`}>
      {mias.length === 0 && <EmptyState icon="document-text-outline" title="No tienes cargas publicadas" sub='Crea tu primera en "Publicar Carga"' />}
      <View style={{ gap: spacing.md }}>
        {mias.map((c) => (
          <CargaListItem
            key={c.id}
            carga={c}
            subtitle={`${c.ciudadOrigen} → ${c.ciudadDestino}`}
            onPress={() => navigation.navigate('CargaDetail', { cargaId: c.id })}
            actions={
              <>
                <Button title="Ver" size="sm" variant="ghost" onPress={() => navigation.navigate('CargaDetail', { cargaId: c.id })} />
                {c.estado === 'publicada' && (
                  <Button title="Cancelar" size="sm" variant="danger" onPress={() => { cancelarCarga(c.id); showToast('Publicación cancelada'); }} />
                )}
                {c.contrato && <Button title="Contrato" size="sm" variant="ghost" onPress={() => navigation.navigate('Contrato', { cargaId: c.id })} />}
                {['asignada', 'en_transito'].includes(c.estado) && (
                  <Button title="Seguimiento" size="sm" variant="accent" onPress={() => navigation.navigate('Seguimiento')} />
                )}
              </>
            }
          />
        ))}
      </View>
    </Screen>
  );
}
