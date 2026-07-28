import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { Ionicons } from '@expo/vector-icons';
import AdminResumenScreen from '../screens/Admin/AdminResumenScreen';
import AdminUsuariosScreen from '../screens/Admin/AdminUsuariosScreen';
import AdminViajesScreen from '../screens/Admin/AdminViajesScreen';
import FacturacionScreen from '../screens/Facturacion/FacturacionScreen';
import PerfilScreen from '../screens/Profile/PerfilScreen';
import { tabScreenOptions } from './tabOptions';

const Tab = createBottomTabNavigator();

const ICONS: Record<string, [keyof typeof Ionicons.glyphMap, keyof typeof Ionicons.glyphMap]> = {
  Resumen: ['grid', 'grid-outline'],
  Usuarios: ['people', 'people-outline'],
  Viajes: ['car-sport', 'car-sport-outline'],
  FacturasAdmin: ['receipt', 'receipt-outline'],
  Perfil: ['person-circle', 'person-circle-outline'],
};

export default function AdminTabs() {
  return (
    <Tab.Navigator screenOptions={(p) => tabScreenOptions(p, ICONS)}>
      <Tab.Screen name="Resumen" component={AdminResumenScreen} />
      <Tab.Screen name="Usuarios" component={AdminUsuariosScreen} />
      <Tab.Screen name="Viajes" component={AdminViajesScreen} options={{ title: 'Viajes' }} />
      <Tab.Screen name="FacturasAdmin" options={{ title: 'Facturas' }}>{() => <FacturacionScreen modoAdmin />}</Tab.Screen>
      <Tab.Screen name="Perfil" component={PerfilScreen} />
    </Tab.Navigator>
  );
}
