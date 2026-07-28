import React from 'react';
import { View } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import Screen from '../../components/Screen';
import CargaListItem from '../../components/CargaListItem';
import EmptyState from '../../components/EmptyState';
import Button from '../../components/Button';
import { useApp } from '../../state/AppContext';
import { spacing } from '../../theme/theme';

export default function MisViajesScreen() {
  const { usuario, cargas, iniciarViaje, confirmarEntregaManual, showToast } = useApp();
  const navigation = useNavigation<any>();
  const mios = cargas.filter((c) => c.transportistaId === usuario!.id);

  return (
    <Screen title="Mis Viajes" subtitle={`NexCarg — ${usuario!.subtipo}`}>
      {mios.length === 0 && <EmptyState icon="car-sport-outline" title="Aún no tienes viajes asignados" sub='Acepta o cotiza una carga en "Cargas Disponibles"' />}
      <View style={{ gap: spacing.md }}>
        {mios.map((c) => {
          const firmado = c.contrato && c.contrato.firmaCliente && c.contrato.firmaTransportista;
          return (
            <CargaListItem
              key={c.id}
              carga={c}
              subtitle={`${c.cliente} · Recogida ${c.fecha}`}
              onPress={() => navigation.navigate('CargaDetail', { cargaId: c.id })}
              actions={
                <>
                  <Button title="Ver" size="sm" variant="ghost" onPress={() => navigation.navigate('CargaDetail', { cargaId: c.id })} />
                  {c.contrato && <Button title="Contrato" size="sm" variant="ghost" onPress={() => navigation.navigate('Contrato', { cargaId: c.id })} />}
                  {c.estado === 'asignada' && (
                    firmado
                      ? <Button title="Iniciar viaje" size="sm" onPress={() => { iniciarViaje(c.id); showToast('Viaje iniciado — seguimiento GPS activado'); }} />
                      : <Button title="Firmar para iniciar" size="sm" variant="accent" onPress={() => navigation.navigate('Contrato', { cargaId: c.id })} />
                  )}
                  {c.estado === 'en_transito' && (
                    <>
                      <Button title="Seguimiento" size="sm" variant="accent" onPress={() => navigation.navigate('Seguimiento')} />
                      <Button title="Confirmar entrega" size="sm" variant="ghost" onPress={() => { confirmarEntregaManual(c.id); showToast('Entrega confirmada — pago liberado'); }} />
                    </>
                  )}
                </>
              }
            />
          );
        })}
      </View>
    </Screen>
  );
}
