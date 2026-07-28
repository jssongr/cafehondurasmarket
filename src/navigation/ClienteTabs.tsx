import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { Ionicons } from '@expo/vector-icons';
import ClienteDashboard from '../screens/Dashboard/ClienteDashboard';
import PublicarCargaScreen from '../screens/Marketplace/PublicarCargaScreen';
import MisCargasScreen from '../screens/Marketplace/MisCargasScreen';
import MensajesStack from './MensajesStack';
import MoreStack from './MoreStack';
import { useApp } from '../state/AppContext';
import { tabScreenOptions } from './tabOptions';

const Tab = createBottomTabNavigator();

const ICONS: Record<string, [keyof typeof Ionicons.glyphMap, keyof typeof Ionicons.glyphMap]> = {
  Dashboard: ['grid', 'grid-outline'],
  Publicar: ['add-circle', 'add-circle-outline'],
  MisCargas: ['file-tray-full', 'file-tray-full-outline'],
  Mensajes: ['chatbubbles', 'chatbubbles-outline'],
  Mas: ['ellipsis-horizontal-circle', 'ellipsis-horizontal-circle-outline'],
};

export default function ClienteTabs() {
  const { convos, usuario } = useApp();
  const unread = convos.filter((c) => c.participantes.includes(usuario!.id) && c.mensajes.some((m) => m.de !== usuario!.id && !(m as any).leido)).length;

  return (
    <Tab.Navigator screenOptions={(p) => tabScreenOptions(p, ICONS)}>
      <Tab.Screen name="Dashboard" component={ClienteDashboard} options={{ title: 'Panel' }} />
      <Tab.Screen name="Publicar" component={PublicarCargaScreen} options={{ title: 'Publicar' }} />
      <Tab.Screen name="MisCargas" component={MisCargasScreen} options={{ title: 'Mis Cargas' }} />
      <Tab.Screen name="Mensajes" component={MensajesStack} options={{ title: 'Mensajes', tabBarBadge: unread || undefined }} />
      <Tab.Screen name="Mas" component={MoreStack} options={{ title: 'Más' }} />
    </Tab.Navigator>
  );
}
