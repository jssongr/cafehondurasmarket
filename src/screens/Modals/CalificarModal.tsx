import React, { useState } from 'react';
import { ScrollView, StyleSheet, Text } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useNavigation, useRoute } from '@react-navigation/native';
import ModalHeader from '../../components/ModalHeader';
import StarPicker from '../../components/StarPicker';
import TextField from '../../components/TextField';
import Button from '../../components/Button';
import { useApp } from '../../state/AppContext';
import { colors, spacing } from '../../theme/theme';

export default function CalificarModal() {
  const navigation = useNavigation<any>();
  const route = useRoute<any>();
  const { historialId } = route.params as { historialId: number };
  const { historial, usuario, calificar, showToast } = useApp();
  const h = historial.find((x) => x.id === historialId);
  const [estrellas, setEstrellas] = useState(0);
  const [comentario, setComentario] = useState('');
  if (!h) return null;

  const contraparte = usuario!.tipo === 'cliente' ? h.transportista : h.cliente;

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: colors.blanco }}>
      <ScrollView contentContainerStyle={styles.content}>
        <ModalHeader title={`Calificar a ${contraparte}`} onClose={() => navigation.goBack()} />
        <Text style={styles.sub}>{h.tipoCarga} · {h.ruta}</Text>
        <StarPicker value={estrellas} onChange={setEstrellas} />
        <TextField label="Comentario (opcional)" placeholder="¿Cómo fue tu experiencia?" multiline value={comentario} onChangeText={setComentario} />
        <Button
          title="Enviar calificación" fullWidth disabled={!estrellas}
          onPress={() => {
            calificar(h.id, usuario!.tipo as any, estrellas, comentario);
            showToast('¡Gracias por tu calificación!');
            navigation.goBack();
          }}
        />
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  content: { padding: spacing.xl },
  sub: { fontSize: 12, color: colors.grisM, marginBottom: spacing.md },
});
