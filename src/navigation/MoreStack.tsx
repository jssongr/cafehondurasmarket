import React from 'react';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import MoreMenuScreen from '../screens/More/MoreMenuScreen';
import SeguimientoScreen from '../screens/Tracking/SeguimientoScreen';
import HistorialScreen from '../screens/Historial/HistorialScreen';
import FacturacionScreen from '../screens/Facturacion/FacturacionScreen';
import PerfilScreen from '../screens/Profile/PerfilScreen';

const Stack = createNativeStackNavigator();

export default function MoreStack() {
  return (
    <Stack.Navigator screenOptions={{ headerShown: false }}>
      <Stack.Screen name="MoreMenu" component={MoreMenuScreen} />
      <Stack.Screen name="SeguimientoMas">{() => <SeguimientoScreen showBack />}</Stack.Screen>
      <Stack.Screen name="HistorialMas">{() => <HistorialScreen showBack />}</Stack.Screen>
      <Stack.Screen name="FacturasMas">{() => <FacturacionScreen showBack />}</Stack.Screen>
      <Stack.Screen name="PerfilMas">{() => <PerfilScreen showBack />}</Stack.Screen>
    </Stack.Navigator>
  );
}
