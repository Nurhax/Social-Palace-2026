import 'dart:async';
import 'package:flutter/material.dart';
import 'audio/audio_service.dart';
import 'screens/splash_screen.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = await AppState.load();
  runApp(SopalApp(state: state));
  // Don't block the first frame on audio setup.
  unawaited(AudioService.instance.init());
}

class SopalApp extends StatefulWidget {
  final AppState state;
  const SopalApp({super.key, required this.state});

  @override
  State<SopalApp> createState() => _SopalAppState();
}

class _SopalAppState extends State<SopalApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final binding = WidgetsBinding.instance;
      // Observers run in reverse order, so register last to hear back first.
      binding
        ..removeObserver(this)
        ..addObserver(this);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Pause the music when the app goes to the background.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      AudioService.instance.pauseBgm();
    } else if (state == AppLifecycleState.resumed) {
      AudioService.instance.resumeBgm();
    }
  }

  @override
  Future<bool> didPopRoute() async {
    unawaited(AudioService.instance.playDeselect());
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // AppScope is an InheritedNotifier: widgets that read it rebuild by
    // themselves when the state changes, so the whole app doesn't need to
    // be rebuilt from the root on every change.
    return AppScope(
      state: widget.state,
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
