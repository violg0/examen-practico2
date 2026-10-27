import 'package:flutter/material.dart';

import 'pages/baggage_list_page.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const BaggageTrackApp());
}

class BaggageTrackApp extends StatelessWidget {
  const BaggageTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BaggageTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const BaggageListPage(),
    );
  }
}
