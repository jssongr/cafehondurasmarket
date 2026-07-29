import 'dart:math';
import 'package:intl/intl.dart';
import '../data/constants.dart';
import '../models/models.dart';

final _rng = Random();

const _mesesEs = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];

String fmtTime(DateTime ts) {
  final now = DateTime.now();
  final diffMin = now.difference(ts).inMinutes;
  if (diffMin < 1) return 'ahora';
  if (diffMin < 60) return '${diffMin}m';
  if (diffMin < 1440) return '${(diffMin / 60).floor()}h';
  return '${ts.day.toString().padLeft(2, '0')} ${_mesesEs[ts.month - 1]}';
}

final _moneyFmt = NumberFormat('#,##0.##', 'en_US');

String fmtMoneda(num? n) => n == null ? '' : '\$${_moneyFmt.format(n)}';

int _uidCounter = 0;
int uid() {
  _uidCounter += 1;
  return DateTime.now().millisecondsSinceEpoch * 1000 + _uidCounter;
}

int rand(int a, int b) => a + _rng.nextInt(b - a + 1);

class Comision {
  final double comision;
  final double montoTransportista;
  Comision(this.comision, this.montoTransportista);
}

Comision calcComision(double monto) {
  final comision = double.parse((monto * comisionPct / 100).toStringAsFixed(2));
  final neto = double.parse((monto - comision).toStringAsFixed(2));
  return Comision(comision, neto);
}

double? avgRating(List<HistorialItem> historial, {required int usuarioId, required TipoUsuario tipo}) {
  final vals = <int>[];
  for (final h in historial) {
    if (tipo == TipoUsuario.cliente && h.clienteId == usuarioId && h.calCliente != null) {
      vals.add(h.calCliente!.estrellas);
    } else if (tipo != TipoUsuario.cliente && h.transportistaId == usuarioId && h.calTransportista != null) {
      vals.add(h.calTransportista!.estrellas);
    }
  }
  if (vals.isEmpty) return null;
  return vals.reduce((a, b) => a + b) / vals.length;
}
