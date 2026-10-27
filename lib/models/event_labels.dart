/// Secuencia válida de eventos del equipaje (sin saltar estados).
const List<String> eventSequence = [
  'CHECKED_IN',
  'SECURITY',
  'LOADED',
  'IN_TRANSIT',
  'DELIVERED',
];

/// Texto legible de cada tipo de evento.
String eventLabel(String type) {
  switch (type) {
    case 'CHEKED_IN':
    case 'CHECKED_IN':
      return 'Registrado';
    case 'SECURITY':
      return 'Control de seguridad';
    case 'LOADED':
      return 'Cargado';
    case 'IN_TRANSIT':
      return 'En tránsito';
    case 'DELIVERED':
      return 'Entregado';
    default:
      return type;
  }
}
