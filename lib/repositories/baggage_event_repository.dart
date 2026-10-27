import '../models/baggage_event.dart';

/// Punto de inicio para coordinar las fuentes de datos del examen.
class BaggageEventRepository {

  BaggageEventRemoteService remoteRepository = BaggageEventRepoteService();
  BaggageEventLocalService localRepository = BaggageEventLocalService();


  Future<List<BaggageEvent>> getEventsForBaggage(String baggageId) async {
    //La interfaz debe informar de forma comprensible cuando se estén utilizando datos locales.
    //Al cargar los eventos, intentar primero obtener la información desde Firestore.
    final respuesta = await obtenerPorProductos(baggageId);

    if(respuesta != null){
      
      //Si la lectura remota funciona, actualizar la caché local y mostrar los datos obtenidos.
      for(var evento in respuesta){
      localRepository.guardar(evento);
      }
      return respuesta;
      
    }
    //Si Firestore falla, recuperar los últimos eventos disponibles desde Drift y permitir que la aplicación continúe mostrando el último estado conocido.
    respuesta = localRepository.obtenerPorEquipaje(baggageId);
    return respuesta;
  }

  Future<void> registerEvent(BaggageEvent event) async {
    // TODO: implementar el flujo definido en el enunciado.
    throw UnimplementedError();
  }
}
