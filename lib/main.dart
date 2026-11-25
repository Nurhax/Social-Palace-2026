import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = await AppState.load();
  runApp(SopalApp(state: state));
}

class SopalApp extends StatefulWidget {
  final AppState state;
  const SopalApp({super.key, required this.state});

  @override
  State<SopalApp> createState() => _SopalAppState();
}

class _SopalAppState extends State<SopalApp> {
  void _onChanged() => setState(() {});

  @override
  void initState() {
    super.initState();
    widget.state.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.state.removeListener(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: widget.state,
      child: MaterialApp(
        title: 'SoPal',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Arsenal',
          useMaterial3: true,
          colorSchemeSeed: Colors.red,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
