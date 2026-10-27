import 'package:flutter/material.dart';

import '../models/baggage.dart';

class BaggageCard extends StatelessWidget {
  const BaggageCard({
    super.key,
    required this.baggage,
    required this.onTap,
    this.statusLabel = 'Sin eventos',
  });

  final Baggage baggage;
  final VoidCallback onTap;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(baggage.id),
      subtitle: Text(
        '${baggage.passenger} - ${baggage.flight} - ${baggage.destination}',
      ),
      trailing: Text(statusLabel),
    );
  }
}
