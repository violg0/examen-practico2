import 'package:flutter/material.dart';

import '../data/baggage_seed.dart';
import '../models/baggage.dart';
import '../models/event_labels.dart';
import '../repositories/baggage_event_repository.dart';
import 'baggage_detail_page.dart';
import '../widgets/baggage_card.dart';

class BaggageListPage extends StatefulWidget {
  const BaggageListPage({super.key});

  @override
  State<BaggageListPage> createState() => _BaggageListPageState();
}

class _BaggageListPageState extends State<BaggageListPage> {
  final BaggageEventRepository _repository = BaggageEventRepository();

  /// Estado actual por equipaje (baggageId -> etiqueta).
  final Map<String, String> _status = {};

  @override
  void initState() {
    super.initState();
    _loadStatuses();
  }

  Future<void> _loadStatuses() async {
    for (final baggage in baggageSeed) {
      try {
        final last = await _repository.getCurrentEvent(baggage.id);
        if (!mounted) return;
        setState(() {
          _status[baggage.id] =
              last == null ? 'Sin eventos' : eventLabel(last.type);
        });
      } catch (_) {
        // Si falla todo, se conserva "Sin eventos".
      }
    }
  }

  Future<void> _openDetail(BuildContext context, Baggage baggage) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            BaggageDetailPage(baggage: baggage, repository: _repository),
      ),
    );
    if (mounted) _loadStatuses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BaggageTrack')),
      body: SafeArea(
        child: ListView.separated(
          itemCount: baggageSeed.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final baggage = baggageSeed[index];
            return BaggageCard(
              baggage: baggage,
              statusLabel: _status[baggage.id] ?? 'Sin eventos',
              onTap: () => _openDetail(context, baggage),
            );
          },
        ),
      ),
    );
  }
}
