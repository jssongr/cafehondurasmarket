import React from 'react';
import { StatusBar } from 'expo-status-bar';
import { NavigationContainer, DefaultTheme } from '@react-navigation/native';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { AppProvider } from './src/state/AppContext';
import RootNavigator from './src/navigation/RootNavigator';
import Toast from './src/components/Toast';
import { colors } from './src/theme/theme';

const navTheme = {
  ...DefaultTheme,
  colors: { ...DefaultTheme.colors, background: colors.crema, primary: colors.marino, card: colors.blanco },
};

export default function App() {
  return (
    <SafeAreaProvider>
      <AppProvider>
        <NavigationContainer theme={navTheme}>
          <StatusBar style="dark" />
          <RootNavigator />
          <Toast />
        </NavigationContainer>
      </AppProvider>
    </SafeAreaProvider>
  );
}
