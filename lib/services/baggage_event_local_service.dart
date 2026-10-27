import '../models/baggage_event.dart';
import '../repositories/database.dart';

class BaggageEventLocalService {
  BaggageEvent _aEvent(BaggageEvente event) => BaggageEvent(
        id: event.id,
        baggageId: event.baggageId,
        type: event.type,
        createdAt: event.createdAt,
      );

  Future<BaggageEvent?> obtenerPorEquipaje(String idequipaje) async {
    final fila = await (db.select(db.baggageEvente)
          ..where((n) => n.baggageId.equals(idequipaje))
          ..orderBy([(n) => OrderingTerm.desc(n.createdAt)])
          ..limit(1))
        .getSingleOrNull();

    return fila == null ? null : _aEvent(fila);
  }

  Future<List<BaggageEvent>> obtenerPoridequipaje(String idequipaje) async {
    final filas = await (db.select(db.baggageEvente)
          ..where((n) => n.idequipaje.equals(idequipaje))
          ..orderBy([(n) => OrderingTerm.desc(n.createdAt)]))
        .get();

    return filas.map(_aEvent).toList();
  }

  Future<void> guardar(BaggageEvent event) {
    return db.into(db.baggageEvente).insertOnConflictUpdate(
          //actualiza los que ya existan
          baggageEventeCompanion(
            id: Value(event.id),
            baggageId: Value(event.baggageId),
            type: Value(event.type),
            createdAt: Value(event.createdAt),
          ),
        );
  }

  Future<void> eliminar(int id) {
    return (db.delete(db.baggageEvente)..where((c) => c.id.equals(id))).go();
  }
}
