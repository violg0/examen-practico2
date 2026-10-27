import 'package:flutter/foundation.dart';

import '../models/baggage_event.dart';
import '../models/event_labels.dart';
import '../services/baggage_event_local_service.dart';
import '../services/baggage_event_remote_service.dart';

const Map<String, int> mapeo = {
  'CHEKED_IN': 0,
  'CHECKED_IN': 0,
  'SECURITY': 1,
  'LOADED': 2,
  'IN_TRANSIT': 3,
  'DELIVERED': 4,
};

/// Resultado de cargar eventos: indica si vinieron de la caché local (Drift).
class BaggageEventsResult {
  const BaggageEventsResult({required this.events, required this.fromLocal});

  /// Ordenados del más reciente al más antiguo.
  final List<BaggageEvent> events;

  /// true cuando Firestore falló y se usó el último estado conocido en Drift.
  final bool fromLocal;
}

/// Coordina Firestore (remoto) y Drift (caché local).
class BaggageEventRepository {
  BaggageEventRemoteService remoteRepository = BaggageEventRemoteService();
  BaggageEventLocalService localRepository = BaggageEventLocalService();

  /// Siguiente tipo de evento válido según el historial, o null si el
  /// recorrido ya terminó (DELIVERED).
  static String? nextEventType(List<BaggageEvent> history) {
    final ultimo = history
        .map((e) => mapeo[e.type] ?? -1)
        .fold<int>(-1, (a, b) => b > a ? b : a);
    if (ultimo + 1 >= eventSequence.length) return null;
    return eventSequence[ultimo + 1];
  }

  static List<BaggageEvent> _newestFirst(List<BaggageEvent> events) {
    return [...events]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Primero intenta Firestore; si funciona actualiza la caché de Drift.
  /// Si falla, devuelve lo último guardado en Drift (fromLocal = true).
  Future<BaggageEventsResult> getEventsForBaggage(String baggageId) async {
    try {
      final remotos = await remoteRepository.getBaggageId(baggageId);
      try {
        for (final evento in remotos) {
          await localRepository.guardar(evento);
        }
      } catch (e) {
        // Si falla la caché local, igual se muestran los datos remotos.
        debugPrint('No se pudo actualizar la caché local: $e');
      }
      return BaggageEventsResult(
        events: _newestFirst(remotos),
        fromLocal: false,
      );
    } catch (_) {
      final locales = await localRepository.obtenerPoridequipaje(baggageId);
      return BaggageEventsResult(
        events: _newestFirst(locales),
        fromLocal: true,
      );
    }
  }

  /// Valida la transición, guarda en Firestore y después en Drift.
  /// Si falla la escritura remota se propaga el error y no se guarda local.
  Future<void> registerEvent(BaggageEvent event) async {
    final nuevo = mapeo[event.type];
    if (nuevo == null) {
      throw ArgumentError('Tipo de evento desconocido: ${event.type}');
    }

    final actuales = await getEventsForBaggage(event.baggageId);
    final ultimo = actuales.events
        .map((e) => mapeo[e.type] ?? -1)
        .fold<int>(-1, (a, b) => b > a ? b : a);

    if (nuevo != ultimo + 1) {
      throw StateError('Transición no permitida: ${event.type}');
    }

    await remoteRepository.saveEvent(event);
    await localRepository.guardar(event);
  }

  /// Registra el siguiente evento válido del equipaje.
  Future<BaggageEvent> registerNextEvent(String baggageId) async {
    final actuales = await getEventsForBaggage(baggageId);
    final siguiente = nextEventType(actuales.events);
    if (siguiente == null) {
      throw StateError('El recorrido de este equipaje ya finalizó.');
    }
    final ahora = DateTime.now();
    final event = BaggageEvent(
      id: '$baggageId-${ahora.microsecondsSinceEpoch}',
      baggageId: baggageId,
      type: siguiente,
      createdAt: ahora,
    );
    await registerEvent(event);
    return event;
  }

  /// Último evento (estado actual) de un equipaje, o null si no tiene.
  Future<BaggageEvent?> getCurrentEvent(String baggageId) async {
    final r = await getEventsForBaggage(baggageId);
    return r.events.isEmpty ? null : r.events.first;
  }
}
