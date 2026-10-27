import 'package:drift/drift.dart';

import '../models/baggage_event.dart';
import '../repositories/database.dart';

class BaggageEventLocalService {
  BaggageEvent _aEvent(BaggageEventRow row) => BaggageEvent(
    id: row.id,
    baggageId: row.baggageId,
    type: row.type,
    createdAt: row.createdAt,
  );

  Future<BaggageEvent?> obtenerUltimoPorEquipaje(String baggageId) async {
    final fila =
        await (db.select(db.baggageEvents)
              ..where((n) => n.baggageId.equals(baggageId))
              ..orderBy([(n) => OrderingTerm.desc(n.createdAt)])
              ..limit(1))
            .getSingleOrNull();

    return fila == null ? null : _aEvent(fila);
  }

  Future<List<BaggageEvent>> obtenerPorEquipaje(String baggageId) async {
    final filas =
        await (db.select(db.baggageEvents)
              ..where((n) => n.baggageId.equals(baggageId))
              ..orderBy([(n) => OrderingTerm.desc(n.createdAt)]))
            .get();

    return filas.map(_aEvent).toList();
  }

  Future<void> guardar(BaggageEvent event) {
    return db
        .into(db.baggageEvents)
        .insertOnConflictUpdate( //actualiza los que ya existan
          BaggageEventsCompanion(
            id: Value(event.id),
            baggageId: Value(event.baggageId),
            type: Value(event.type),
            createdAt: Value(event.createdAt),
          ),
        );
  }

  Future<void> eliminar(String id) {
    return (db.delete(db.baggageEvents)..where((c) => c.id.equals(id))).go();
  }
}
