import 'package:intl/intl.dart';
import '../models/models.dart';

const _mesesEs = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];

String fmtTime(DateTime ts) {
  final now = DateTime.now();
  final diffMin = now.difference(ts).inMinutes;
  if (diffMin < 1) return 'ahora';
  if (diffMin < 60) return '${diffMin}m';
  if (diffMin < 1440) return '${(diffMin / 60).floor()}h';
  return '${ts.day.toString().padLeft(2, '0')} ${_mesesEs[ts.month - 1]}';
}

/// Fecha y hora completas, para constancias que hay que poder citar después.
String fechaLarga(DateTime d) =>
    '${d.day} ${_mesesEs[d.month - 1]} ${d.year}, ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

final _moneyFmt = NumberFormat('#,##0.##', 'en_US');

String fmtMoneda(num? n) => n == null ? '' : '\$${_moneyFmt.format(n)}';

double? avgRating(List<HistorialItem> historial, {required String usuarioId, required TipoUsuario tipo}) {
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
