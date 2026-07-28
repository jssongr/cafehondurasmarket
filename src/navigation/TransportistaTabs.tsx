import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { Ionicons } from '@expo/vector-icons';
import TransportistaDashboard from '../screens/Dashboard/TransportistaDashboard';
import CargasDisponiblesScreen from '../screens/Marketplace/CargasDisponiblesScreen';
import MisViajesScreen from '../screens/Marketplace/MisViajesScreen';
import MensajesStack from './MensajesStack';
import MoreStack from './MoreStack';
import { useApp } from '../state/AppContext';
import { tabScreenOptions } from './tabOptions';

const Tab = createBottomTabNavigator();

const ICONS: Record<string, [keyof typeof Ionicons.glyphMap, keyof typeof Ionicons.glyphMap]> = {
  Dashboard: ['grid', 'grid-outline'],
  Disponibles: ['storefront', 'storefront-outline'],
  MisViajes: ['car-sport', 'car-sport-outline'],
  Mensajes: ['chatbubbles', 'chatbubbles-outline'],
  Mas: ['ellipsis-horizontal-circle', 'ellipsis-horizontal-circle-outline'],
};

export default function TransportistaTabs() {
  const { convos, usuario } = useApp();
  const unread = convos.filter((c) => c.participantes.includes(usuario!.id) && c.mensajes.some((m) => m.de !== usuario!.id && !(m as any).leido)).length;

  return (
    <Tab.Navigator screenOptions={(p) => tabScreenOptions(p, ICONS)}>
      <Tab.Screen name="Dashboard" component={TransportistaDashboard} options={{ title: 'Panel' }} />
      <Tab.Screen name="Disponibles" component={CargasDisponiblesScreen} options={{ title: 'Cargas' }} />
      <Tab.Screen name="MisViajes" component={MisViajesScreen} options={{ title: 'Mis Viajes' }} />
      <Tab.Screen name="Mensajes" component={MensajesStack} options={{ title: 'Mensajes', tabBarBadge: unread || undefined }} />
      <Tab.Screen name="Mas" component={MoreStack} options={{ title: 'Más' }} />
    </Tab.Navigator>
  );
}
