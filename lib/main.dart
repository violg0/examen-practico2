import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'pages/baggage_list_page.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('No se pudo inicializar Firebase: $e');
  }

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
