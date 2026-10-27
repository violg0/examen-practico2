import 'package:baggage_track_shell/models/baggage_event.dart'
    show BaggageEvent;
import 'package:drift/drift.dart';

import '../repositories/database.dart';

class BaggageEventLocalService {
  BaggageEvent _aEvent(BaggageEvents event) => BaggageEvent(
        id: event.id,
        baggageId: event.baggageId,
        type: event.type,
        createdAt: event.createdAt,
      );

  Future<List<BaggageEvent>> obtenerPoridequipaje(String idequipaje) async {
    final filas = await (db.select(db.baggageEvente)
          ..where((n) => n.baggageId.equals(idequipaje))
          ..orderBy([(n) => OrderingTerm.desc(n.createdAt)]))
        .get();

    return filas.map(_aEvent).toList();
  }

  Future<void> guardar(BaggageEvent event) {
    return db.into(db.baggageEvente).insertOnConflictUpdate(
          //actualiza los que ya existan
          BaggageEventeCompanion(
            id: Value(event.id),
            baggageId: Value(event.baggageId),
            type: Value(event.type),
            createdAt: Value(event.createdAt),
          ),
        );
  }
}
