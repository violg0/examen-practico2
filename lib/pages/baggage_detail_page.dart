import 'package:flutter/material.dart';

import '../models/baggage.dart';
import '../models/baggage_event.dart';
import '../models/event_labels.dart';
import '../repositories/baggage_event_repository.dart';

class BaggageDetailPage extends StatefulWidget {
  BaggageDetailPage({
    super.key,
    required this.baggage,
    BaggageEventRepository? repository,
  }) : repository = repository ?? BaggageEventRepository();

  final Baggage baggage;
  final BaggageEventRepository repository;

  @override
  State<BaggageDetailPage> createState() => _BaggageDetailPageState();
}

class _BaggageDetailPageState extends State<BaggageDetailPage> {
  List<BaggageEvent> _events = [];
  bool _loading = true;
  bool _fromLocal = false;
  bool _registering = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result =
          await widget.repository.getEventsForBaggage(widget.baggage.id);
      if (!mounted) return;
      setState(() {
        _events = result.events; // más reciente primero
        _fromLocal = result.fromLocal;
      });
    } catch (_) {
      if (mounted) setState(() => _error = 'No se pudieron cargar los eventos');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _registerNext() async {
    setState(() => _registering = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final event =
          await widget.repository.registerNextEvent(widget.baggage.id);
      await _loadEvents();
      messenger.showSnackBar(
        SnackBar(content: Text('Evento registrado: ${eventLabel(event.type)}')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('No se pudo registrar el evento: $e')),
      );
    } finally {
      if (mounted) setState(() => _registering = false);
    }
  }

  String _formatDate(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)}/${date.year} '
        '${two(date.hour)}:${two(date.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final baggage = widget.baggage;
    final last = _events.isEmpty ? null : _events.first;
    final next = BaggageEventRepository.nextEventType(_events);

    return Scaffold(
      appBar: AppBar(title: Text(baggage.id)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Pasajero: ${baggage.passenger}'),
          Text('Vuelo: ${baggage.flight}'),
          Text('Destino: ${baggage.destination}'),
          const SizedBox(height: 12),
          Text(
            'Estado actual: ${last == null ? 'Sin eventos' : eventLabel(last.type)}',
          ),
          if (last != null) ...[
            Text('Última actualización: ${_formatDate(last.createdAt)}'),
            Text('Total de eventos: ${_events.length}'),
          ],
          if (_fromLocal && !_loading && _error == null) ...[
            const SizedBox(height: 12),
            const Text(
              'Sin conexión con el servidor. Mostrando datos locales.',
            ),
          ],
          const Divider(height: 32),
          const Text('Historial de eventos'),
          const SizedBox(height: 8),
          _buildHistory(),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: (_loading || _registering || _error != null || next == null)
                ? null
                : _registerNext,
            child: Text(
              next == null
                  ? 'Recorrido finalizado'
                  : 'Registrar ${eventLabel(next)}',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistory() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Column(
        children: [
          Text(_error!),
          TextButton(onPressed: _loadEvents, child: const Text('Reintentar')),
        ],
      );
    }

    if (_events.isEmpty) {
      return const Text('Este equipaje aún no tiene eventos.');
    }

    return Column(
      children: [
        for (final event in _events)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(eventLabel(event.type)),
            subtitle: Text(_formatDate(event.createdAt)),
          ),
      ],
    );
  }
}
