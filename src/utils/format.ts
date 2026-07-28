import { COMISION_PCT } from '../data/constants';
import { HistorialItem, Usuario } from '../data/types';

export const fmtTime = (ts: string) => {
  const d = new Date(ts);
  const now = new Date();
  const diff = (now.getTime() - d.getTime()) / 60000;
  if (diff < 1) return 'ahora';
  if (diff < 60) return `${Math.floor(diff)}m`;
  if (diff < 1440) return `${Math.floor(diff / 60)}h`;
  return d.toLocaleDateString('es-HN', { day: '2-digit', month: 'short' });
};

export const fmtMoneda = (n: number | null | undefined) => (n == null ? '' : '$' + Number(n).toLocaleString());

export const uid = () => Date.now() + Math.random();

export const rand = (a: number, b: number) => Math.floor(Math.random() * (b - a + 1)) + a;

export const calcComision = (monto: number) => {
  const comision = Number(((monto * COMISION_PCT) / 100).toFixed(2));
  return { comision, montoTransportista: Number((monto - comision).toFixed(2)) };
};

export const avgRating = (historial: HistorialItem[], usuario: Pick<Usuario, 'id' | 'tipo'>): number | null => {
  const campo = usuario.tipo === 'cliente' ? 'calCliente' : 'calTransportista';
  const idCampo = usuario.tipo === 'cliente' ? 'clienteId' : 'transportistaId';
  const vals = historial
    .filter((h) => (h as any)[idCampo] === usuario.id && (h as any)[campo])
    .map((h) => (h as any)[campo].estrellas as number);
  if (!vals.length) return null;
  return vals.reduce((a, b) => a + b, 0) / vals.length;
};
