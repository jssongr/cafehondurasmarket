import React from 'react';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import ConversationsScreen from '../screens/Messages/ConversationsScreen';
import ChatScreen from '../screens/Messages/ChatScreen';
import { colors } from '../theme/theme';

const Stack = createNativeStackNavigator();

export default function MensajesStack() {
  return (
    <Stack.Navigator screenOptions={{ headerStyle: { backgroundColor: colors.blanco }, headerTintColor: colors.marino, headerTitleStyle: { fontWeight: '700' } }}>
      <Stack.Screen name="Conversaciones" component={ConversationsScreen} options={{ headerShown: false }} />
      <Stack.Screen name="Chat" component={ChatScreen} />
    </Stack.Navigator>
  );
}
