import '../models/baggage_event.dart';
import '../services/baggage_event_local_service.dart';
import '../services/baggage_event_remote_service.dart';

enum typo { CHEKED_IN, SECURITY, LOADED, IN_TRANSIT,DELIVERED}
/// Punto de inicio para coordinar las fuentes de datos del examen.
class BaggageEventRepository {
  BaggageEventRemoteService remoteRepository = BaggageEventRemoteService();
  BaggageEventLocalService localRepository = BaggageEventLocalService();

  Future<List<BaggageEvent>> getEventsForBaggage(String baggageId) async {
    //La interfaz debe informar de forma comprensible cuando se estén utilizando datos locales.
    //Al cargar los eventos, intentar primero obtener la información desde Firestore.
    var respuesta = await obtenerPorProductos(baggageId);

    if (respuesta != null) {
      //Si la lectura remota funciona, actualizar la caché local y mostrar los datos obtenidos.
      for (var evento in respuesta) {
        localRepository.guardar(evento);
      }
      return respuesta;
    }
    //Si Firestore falla, recuperar los últimos eventos disponibles desde Drift y permitir que la aplicación continúe mostrando el último estado conocido.
    respuesta = localRepository.obtenerPorEquipaje(baggageId);
    return respuesta;
  }

  Future<void> registerEvent(BaggageEvent event) async {
    /*
    Al registrar un evento, primero debe validarse la transición. Para el flujo base, no se permite saltar estados. Si la
transición es válida, el evento debe guardarse remotamente en Firestore y después mantenerse también en Drift
para conservar el estado local. Si la escritura remota falla, la aplicación debe informar el error y no presentar el
evento como confirmado.*/

    final actuales = await this.getEventsForBaggage(event.baggageId);
    if (actuales == null) {
      if()
    }
  }
}
