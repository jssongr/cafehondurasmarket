import React, { createContext, useCallback, useContext, useEffect, useMemo, useRef, useState } from 'react';
import { SEED_CARGAS, SEED_CONVOS, SEED_FACTURAS, SEED_HIST, SEED_NOTIFS, SEED_USERS } from '../data/seed';
import { Carga, Conversacion, Factura, HistorialItem, Mensaje, Notificacion, Usuario } from '../data/types';
import { calcComision, fmtMoneda, rand, uid } from '../utils/format';

interface Toast {
  id: number;
  msg: string;
}

interface AppState {
  usuarios: Usuario[];
  usuario: Usuario | null;
  cargas: Carga[];
  convos: Conversacion[];
  notifs: Notificacion[];
  historial: HistorialItem[];
  facturas: Factura[];
  toast: Toast | null;
}

interface AppApi extends AppState {
  login: (email: string, password: string) => Usuario | null;
  registrar: (nuevo: Omit<Usuario, 'id'>) => Usuario;
  logout: () => void;
  showToast: (msg: string) => void;
  addNotif: (usuarioId: number, tipo: Notificacion['tipo'], titulo: string, sub: string) => void;
  markNotifsRead: (usuarioId: number) => void;
  publicarCarga: (carga: Omit<Carga, 'id'>) => void;
  cancelarCarga: (cargaId: number) => void;
  asignarCarga: (cargaId: number, transportistaId: number, transportistaNombre: string, monto: number) => void;
  iniciarViaje: (cargaId: number) => void;
  confirmarEntregaManual: (cargaId: number) => void;
  firmarContrato: (cargaId: number, actorTipo: 'cliente' | 'transportista') => void;
  calificar: (historialId: number, actorTipo: 'cliente' | 'transportista', estrellas: number, comentario: string) => void;
  abrirOCrearConvo: (carga: Carga, yoId: number, yoTipo: 'cliente' | 'transportista') => number;
  enviarMensaje: (convoId: number, deId: number, texto: string) => void;
  enviarOferta: (convoId: number, deId: number, precio: number) => void;
  responderOferta: (convoId: number, msgId: number, accion: 'aceptada' | 'rechazada') => void;
  actualizarPerfil: (usuarioId: number, cambios: Partial<Usuario>) => void;
}

const AppCtx = createContext<AppApi | null>(null);

export function AppProvider({ children }: { children: React.ReactNode }) {
  const [usuarios, setUsuarios] = useState<Usuario[]>(SEED_USERS);
  const [usuario, setUsuario] = useState<Usuario | null>(null);
  const [cargas, setCargas] = useState<Carga[]>(SEED_CARGAS);
  const [convos, setConvos] = useState<Conversacion[]>(SEED_CONVOS);
  const [notifs, setNotifs] = useState<Notificacion[]>(SEED_NOTIFS);
  const [historial, setHistorial] = useState<HistorialItem[]>(SEED_HIST);
  const [facturas, setFacturas] = useState<Factura[]>(SEED_FACTURAS);
  const [toast, setToast] = useState<Toast | null>(null);
  const toastTimer = useRef<ReturnType<typeof setTimeout> | null>(null);

  const showToast = useCallback((msg: string) => {
    if (toastTimer.current) clearTimeout(toastTimer.current);
    setToast({ id: Date.now(), msg });
    toastTimer.current = setTimeout(() => setToast(null), 3200);
  }, []);

  const addNotif = useCallback((usuarioId: number, tipo: Notificacion['tipo'], titulo: string, sub: string) => {
    setNotifs((n) => [{ id: uid(), usuarioId, tipo, titulo, sub, ts: new Date().toISOString(), leida: false }, ...n]);
  }, []);

  const markNotifsRead = useCallback((usuarioId: number) => {
    setNotifs((n) => n.map((x) => (x.usuarioId === usuarioId ? { ...x, leida: true } : x)));
  }, []);

  const registrarEntrega = useCallback((c: Carga) => {
    const ruta = `${c.ciudadOrigen} (${c.paisOrigen}) → ${c.ciudadDestino} (${c.paisDestino})`;
    const { comision, montoTransportista } = calcComision(c.precioAcordado!);
    setHistorial((h) => [
      {
        id: uid(), cargaId: c.id, clienteId: c.clienteId, cliente: c.cliente,
        transportistaId: c.transportistaId!, transportista: c.transportistaNombre!, tipoCarga: c.tipoCarga,
        ruta, monto: c.precioAcordado!, fecha: new Date().toISOString().split('T')[0], estado: 'completado',
        calTransportista: null, calCliente: null,
      },
      ...h,
    ]);
    setFacturas((fs) => [
      {
        id: uid(), numero: `NX-${String(fs.length + 1).padStart(4, '0')}`, cargaId: c.id,
        clienteId: c.clienteId, cliente: c.cliente, transportistaId: c.transportistaId!, transportista: c.transportistaNombre!,
        tipoCarga: c.tipoCarga, ruta, monto: c.precioAcordado!, comisionPct: 8, comision, montoTransportista,
        fecha: new Date().toISOString().split('T')[0],
      },
      ...fs,
    ]);
    addNotif(c.clienteId, 'sistema', '✅ Carga entregada', `${c.tipoCarga} llegó a ${c.ciudadDestino}. Pago liberado al transportista. Ya puedes calificar el viaje.`);
    addNotif(c.transportistaId!, 'sistema', '💰 Pago liberado', `Se liberó ${fmtMoneda(montoTransportista)} (neto de comisión) por la entrega de ${c.tipoCarga}.`);
  }, [addNotif]);

  // GPS simulation: advance en_transito cargas and release payment on arrival
  useEffect(() => {
    const t = setInterval(() => {
      setCargas((prev) => {
        const entregadas: Carga[] = [];
        const next = prev.map((c) => {
          if (c.estado !== 'en_transito') return c;
          const p = Math.min(100, c.progreso + rand(6, 14));
          if (p >= 100) {
            const done: Carga = { ...c, progreso: 100, estado: 'entregada', pago: { ...c.pago, estado: 'liberado' }, fechaEntrega: new Date().toISOString() };
            entregadas.push(done);
            return done;
          }
          return { ...c, progreso: p };
        });
        if (entregadas.length) setTimeout(() => entregadas.forEach((c) => registrarEntrega(c)), 0);
        return next;
      });
    }, 2600);
    return () => clearInterval(t);
  }, [registrarEntrega]);

  const login = useCallback((email: string, password: string) => {
    const u = usuarios.find((x) => x.email === email && x.password === password) || null;
    if (u) setUsuario(u);
    return u;
  }, [usuarios]);

  const registrar = useCallback((nuevo: Omit<Usuario, 'id'>) => {
    const conId: Usuario = { id: uid(), ...nuevo };
    setUsuarios((us) => [...us, conId]);
    setUsuario(conId);
    return conId;
  }, []);

  const logout = useCallback(() => setUsuario(null), []);

  const publicarCarga = useCallback((carga: Omit<Carga, 'id'>) => {
    setCargas((cs) => [...cs, { id: uid(), ...carga }]);
  }, []);

  const cancelarCarga = useCallback((cargaId: number) => {
    setCargas((cs) => cs.map((c) => (c.id === cargaId ? { ...c, estado: 'cancelada' } : c)));
  }, []);

  const asignarCarga = useCallback((cargaId: number, transportistaId: number, transportistaNombre: string, monto: number) => {
    setCargas((cs) => cs.map((c) => (c.id === cargaId ? {
      ...c, estado: 'asignada', transportistaId, transportistaNombre, precioAcordado: monto,
      pago: { estado: 'retenido', monto },
      contrato: { firmaCliente: false, firmaTransportista: false, fechaCliente: null, fechaTransportista: null },
      fechaAsignacion: new Date().toISOString(),
    } : c)));
  }, []);

  const iniciarViaje = useCallback((cargaId: number) => {
    setCargas((cs) => cs.map((c) => (c.id === cargaId ? { ...c, estado: 'en_transito', progreso: 2 } : c)));
  }, []);

  const confirmarEntregaManual = useCallback((cargaId: number) => {
    setCargas((cs) => {
      const c = cs.find((x) => x.id === cargaId);
      if (!c) return cs;
      const done: Carga = { ...c, progreso: 100, estado: 'entregada', pago: { ...c.pago, estado: 'liberado' }, fechaEntrega: new Date().toISOString() };
      setTimeout(() => registrarEntrega(done), 0);
      return cs.map((x) => (x.id === cargaId ? done : x));
    });
  }, [registrarEntrega]);

  const firmarContrato = useCallback((cargaId: number, actorTipo: 'cliente' | 'transportista') => {
    setCargas((cs) => cs.map((c) => {
      if (c.id !== cargaId || !c.contrato) return c;
      const campo = actorTipo === 'cliente' ? 'firmaCliente' : 'firmaTransportista';
      const fcampo = actorTipo === 'cliente' ? 'fechaCliente' : 'fechaTransportista';
      return { ...c, contrato: { ...c.contrato, [campo]: true, [fcampo]: new Date().toISOString() } };
    }));
  }, []);

  const calificar = useCallback((historialId: number, actorTipo: 'cliente' | 'transportista', estrellas: number, comentario: string) => {
    setHistorial((hs) => hs.map((h) => {
      if (h.id !== historialId) return h;
      const campo = actorTipo === 'cliente' ? 'calTransportista' : 'calCliente';
      return { ...h, [campo]: { estrellas, comentario } };
    }));
  }, []);

  const abrirOCrearConvo = useCallback((carga: Carga, yoId: number, yoTipo: 'cliente' | 'transportista') => {
    const otroId = yoTipo === 'cliente' ? carga.transportistaId : carga.clienteId;
    const targetId = otroId ?? carga.clienteId;
    const existente = convos.find((c) => c.participantes.includes(yoId) && c.participantes.includes(targetId) && c.cargaId === carga.id);
    if (existente) return existente.id;
    const nuevaId = uid();
    setConvos((cs) => [...cs, { id: nuevaId, participantes: [yoId, targetId], cargaId: carga.id, mensajes: [] }]);
    return nuevaId;
  }, [convos]);

  const enviarMensaje = useCallback((convoId: number, deId: number, texto: string) => {
    const msg: Mensaje = { id: uid(), de: deId, texto, ts: new Date().toISOString() };
    setConvos((cs) => cs.map((c) => (c.id === convoId ? { ...c, mensajes: [...c.mensajes, msg] } : c)));
    const convo = convos.find((c) => c.id === convoId);
    const destId = convo?.participantes.find((p) => p !== deId);
    const de = usuarios.find((u) => u.id === deId);
    if (destId && de) addNotif(destId, 'mensaje', 'Nuevo mensaje de ' + de.nombre, texto.slice(0, 60));
  }, [convos, usuarios, addNotif]);

  const enviarOferta = useCallback((convoId: number, deId: number, precio: number) => {
    const msg: Mensaje = { id: uid(), de: deId, tipo: 'oferta', precio, ts: new Date().toISOString(), estado: 'pendiente' };
    setConvos((cs) => cs.map((c) => (c.id === convoId ? { ...c, mensajes: [...c.mensajes, msg] } : c)));
    const convo = convos.find((c) => c.id === convoId);
    const destId = convo?.participantes.find((p) => p !== deId);
    const de = usuarios.find((u) => u.id === deId);
    if (destId && de) addNotif(destId, 'oferta', 'Nueva cotización de ' + de.nombre, fmtMoneda(precio) + ' por el viaje');
  }, [convos, usuarios, addNotif]);

  const responderOferta = useCallback((convoId: number, msgId: number, accion: 'aceptada' | 'rechazada') => {
    const convo = convos.find((c) => c.id === convoId);
    const ofertaMsg = convo?.mensajes.find((m) => m.id === msgId) as (Mensaje & { tipo: 'oferta' }) | undefined;
    setConvos((cs) => cs.map((c) => (c.id === convoId ? { ...c, mensajes: c.mensajes.map((m) => (m.id === msgId ? { ...m, estado: accion } as Mensaje : m)) } : c)));
    if (accion === 'aceptada' && ofertaMsg && convo) {
      const respondiendoId = usuario?.id;
      const transportistaId = ofertaMsg.de; // whoever sent the quote is the carrier side of this trip
      const transportista = usuarios.find((u) => u.id === transportistaId);
      if (transportista) asignarCarga(convo.cargaId, transportista.id, transportista.nombre, ofertaMsg.precio);
      const destId = convo.participantes.find((p) => p !== respondiendoId);
      if (destId) addNotif(destId, 'oferta', '✅ Cotización aceptada', 'Tu cotización de ' + fmtMoneda(ofertaMsg.precio) + ' fue aceptada');
    }
  }, [convos, usuarios, usuario, asignarCarga, addNotif]);

  const actualizarPerfil = useCallback((usuarioId: number, cambios: Partial<Usuario>) => {
    setUsuarios((us) => us.map((u) => (u.id === usuarioId ? { ...u, ...cambios } : u)));
    setUsuario((u) => (u && u.id === usuarioId ? { ...u, ...cambios } : u));
  }, []);

  const value = useMemo<AppApi>(() => ({
    usuarios, usuario, cargas, convos, notifs, historial, facturas, toast,
    login, registrar, logout, showToast, addNotif, markNotifsRead,
    publicarCarga, cancelarCarga, asignarCarga, iniciarViaje, confirmarEntregaManual,
    firmarContrato, calificar, abrirOCrearConvo, enviarMensaje, enviarOferta, responderOferta, actualizarPerfil,
  }), [usuarios, usuario, cargas, convos, notifs, historial, facturas, toast,
    login, registrar, logout, showToast, addNotif, markNotifsRead,
    publicarCarga, cancelarCarga, asignarCarga, iniciarViaje, confirmarEntregaManual,
    firmarContrato, calificar, abrirOCrearConvo, enviarMensaje, enviarOferta, responderOferta, actualizarPerfil]);

  return <AppCtx.Provider value={value}>{children}</AppCtx.Provider>;
}

export function useApp() {
  const ctx = useContext(AppCtx);
  if (!ctx) throw new Error('useApp must be used within AppProvider');
  return ctx;
}
