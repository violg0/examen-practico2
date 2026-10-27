import '../models/baggage_event.dart';
import '../services/baggage_event_local_service.dart';
import '../services/baggage_event_remote_service.dart';

/// Punto de inicio para coordinar las fuentes de datos del examen.
class BaggageEventRepository {
  final BaggageEventRemoteService remoteRepository =
      BaggageEventRemoteService();
  final BaggageEventLocalService localRepository = BaggageEventLocalService();

  Future<List<BaggageEvent>> getEventsForBaggage(String baggageId) async {
    //La interfaz debe informar de forma comprensible cuando se estén utilizando datos locales.
    //Al cargar los eventos, intentar primero obtener la información desde Firestore.
    try {
      final todos = await remoteRepository.getEvents();
      final eventos = todos.where((e) => e.baggageId == baggageId).toList();

      //Si la lectura remota funciona, actualizar la caché local y mostrar los datos obtenidos.
      for (final evento in eventos) {
        await localRepository.guardar(evento);
      }
      return eventos;
    } catch (_) {
      //Si Firestore falla, recuperar los últimos eventos disponibles desde Drift y permitir que la aplicación continúe mostrando el último estado conocido.
      return localRepository.obtenerPorEquipaje(baggageId);
    }
  }

  Future<void> registerEvent(BaggageEvent event) async {
    // TODO: implementar el flujo definido en el enunciado.
    throw UnimplementedError();
  }
}
