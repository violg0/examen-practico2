import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/baggage_event.dart';

class BaggageEventRemoteService {
  CollectionReference<Map<String, dynamic>> get _coleccion =>
      FirebaseFirestore.instance.collection('baggage_events');

  Future<List<BaggageEvent>> getEvents() async {
    final snapshot =
        await _coleccion
        .get(const GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 10));
    final events = <BaggageEvent>[];
    for (final doc in snapshot.docs) {
      final event = _fromDoc(doc.id, doc.data());
      if (event != null) events.add(event);
    }
    return events;
  }

  BaggageEvent? _fromDoc(String id, Map<String, dynamic> data) {
    final baggageId = data['baggageId'];
    final type = data['type'];
    final createdAt = data['createdAt'];
    if (baggageId is! String || type is! String || createdAt is! Timestamp) {
      return null;
    }
    return BaggageEvent(
      id: id,
      baggageId: baggageId,
      type: type,
      createdAt: createdAt.toDate(),
    );
  }

  /// Guarda el evento como un documento independiente. Se usa una transacción
  /// para que falle si no hay conexión (en vez de quedar en cola y enviarse
  /// después), así la app no confirma un evento que no llegó al servidor.
  Future<void> saveEvent(BaggageEvent event) {
    final doc = _coleccion.doc(event.id);
    return FirebaseFirestore.instance.runTransaction((tx) async {
      tx.set(doc, {
        'id': event.id,
        'baggageId': event.baggageId,
        'type': event.type,
        'createdAt': Timestamp.fromDate(event.createdAt),
      });
    }).timeout(const Duration(seconds: 10));
  }

  Future<List<BaggageEvent>> getBaggageId(String baggageId) async {
    final snapshot = await _coleccion
        .where('baggageId', isEqualTo: baggageId)
        .get(const GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 10));
    final events = <BaggageEvent>[];
    for (final doc in snapshot.docs) {
      final event = _fromDoc(doc.id, doc.data());
      if (event != null) events.add(event);
    }
    return events;
  }
}