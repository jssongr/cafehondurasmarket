export type RootStackParamList = {
  Auth: undefined;
  Tabs: undefined;
  CargaDetail: { cargaId: number };
  Contrato: { cargaId: number };
  Calificar: { historialId: number };
  Chat: { convoId: number };
};

export type ClienteTabParamList = {
  Dashboard: undefined;
  Publicar: undefined;
  MisCargas: undefined;
  Seguimiento: undefined;
  Mensajes: undefined;
  Historial: undefined;
  Facturas: undefined;
  Perfil: undefined;
};

export type TransportistaTabParamList = {
  Dashboard: undefined;
  Disponibles: undefined;
  MisViajes: undefined;
  Seguimiento: undefined;
  Mensajes: undefined;
  Historial: undefined;
  Facturas: undefined;
  Perfil: undefined;
};

export type AdminTabParamList = {
  Resumen: undefined;
  Usuarios: undefined;
  Viajes: undefined;
  FacturasAdmin: undefined;
  Perfil: undefined;
};

export type MensajesStackParamList = {
  Conversaciones: undefined;
  Chat: { convoId: number };
};
