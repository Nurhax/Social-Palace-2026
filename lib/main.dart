import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'state/app_state.dart';

void main() {
  runApp(const SopalApp());
}

class SopalApp extends StatefulWidget {
  const SopalApp({super.key});

  @override
  State<SopalApp> createState() => _SopalAppState();
}

class _SopalAppState extends State<SopalApp> {
  final AppState _state = AppState();

  @override
  void initState() {
    super.initState();
    _state.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: _state,
      child: MaterialApp(
        title: 'SoPal',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Roboto',
          useMaterial3: true,
          colorSchemeSeed: Colors.red,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
