import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/baggage_event.dart';

class BaggageEventRemoteService {
  CollectionReference<Map<String, dynamic>> get _coleccion =>
      FirebaseFirestore.instance.collection('baggageEvent');

  Future<List<BaggageEvent>> getEvents() async {
    final snapshot =
        await _coleccion.get().timeout(const Duration(seconds: 10));
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

  Future<void> saveEvent(BaggageEvent event) {
    return _coleccion.doc(event.id).set({
      'baggageId': event.baggageId,
      'type': event.type,
      'createdAt': Timestamp.fromDate(event.createdAt),
    }).timeout(const Duration(seconds: 10));
  }

  Future<List<BaggageEvent>> getBaggageId(String baggageId) async {
    final snapshot = await _coleccion
        .where('baggageId', isEqualTo: baggageId)
        .get()
        .timeout(const Duration(seconds: 10));
    final events = <BaggageEvent>[];
    for (final doc in snapshot.docs) {
      final event = _fromDoc(doc.id, doc.data());
      if (event != null) events.add(event);
    }
    return events;
  }
}