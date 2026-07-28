import React from 'react';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import AuthScreen from '../screens/Auth/AuthScreen';
import ClienteTabs from './ClienteTabs';
import TransportistaTabs from './TransportistaTabs';
import AdminTabs from './AdminTabs';
import CargaDetailModal from '../screens/Modals/CargaDetailModal';
import ContratoModal from '../screens/Modals/ContratoModal';
import CalificarModal from '../screens/Modals/CalificarModal';
import { useApp } from '../state/AppContext';

const Stack = createNativeStackNavigator();

function RoleTabs() {
  const { usuario } = useApp();
  if (usuario!.tipo === 'cliente') return <ClienteTabs />;
  if (usuario!.tipo === 'transportista') return <TransportistaTabs />;
  return <AdminTabs />;
}

export default function RootNavigator() {
  const { usuario } = useApp();

  return (
    <Stack.Navigator screenOptions={{ headerShown: false }}>
      {!usuario ? (
        <Stack.Screen name="Auth" component={AuthScreen} />
      ) : (
        <>
          <Stack.Screen name="Tabs" component={RoleTabs} />
          <Stack.Group screenOptions={{ presentation: 'modal' }}>
            <Stack.Screen name="CargaDetail" component={CargaDetailModal} />
            <Stack.Screen name="Contrato" component={ContratoModal} />
            <Stack.Screen name="Calificar" component={CalificarModal} />
          </Stack.Group>
        </>
      )}
    </Stack.Navigator>
  );
}
