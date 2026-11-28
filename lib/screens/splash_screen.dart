import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme/app_assets.dart';
import '../theme/app_theme.dart';
import '../widgets/persona_transitions.dart';
import '../widgets/sopal_chrome.dart';
import 'auth_screens.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  );

  // Logo "slams" in: big -> normal, tilted -> straight.
  late final Animation<double> _logoFade = CurvedAnimation(
    parent: _intro,
    curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
  );
  late final Animation<double> _logoScale =
      Tween<double>(begin: 1.7, end: 1.0).animate(CurvedAnimation(
    parent: _intro,
    curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
  ));
  late final Animation<double> _logoTilt =
      Tween<double>(begin: -0.25, end: 0.0).animate(CurvedAnimation(
    parent: _intro,
    curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
  ));

  // Title slides in from the left, tagline fades in last.
  late final Animation<double> _titleIn = CurvedAnimation(
    parent: _intro,
    curve: const Interval(0.35, 0.75, curve: Curves.easeOutCubic),
  );
  late final Animation<double> _tagIn = CurvedAnimation(
    parent: _intro,
    curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
  );

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      _run();
    }
  }

  Future<void> _run() async {
    // Decode all images while the intro plays, so later screens and
    // transitions don't have to (this avoids dropped frames).
    await Future.wait([
      _intro.forward(),
      AppAssets.precacheAll(context),
      Future<void>.delayed(const Duration(milliseconds: 1900)),
    ]);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PersonaRoute<void>(
        builder: (_) => const EnterIdScreen(),
        style: PersonaWipeStyle.opening,
      ),
    );
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppScope.of(context).colors;
    return Scaffold(
      backgroundColor: colors.primary,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FadeTransition(
                opacity: _logoFade,
                child: AnimatedBuilder(
                  animation: _intro,
                  child: const SopalMark(size: 200),
                  builder: (context, child) => Transform.rotate(
                    angle: _logoTilt.value,
                    child:
                        Transform.scale(scale: _logoScale.value, child: child),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FadeTransition(
                opacity: _titleIn,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-0.4, 0),
                    end: Offset.zero,
                  ).animate(_titleIn),
                  child: const ComicText(
                    'Social Palace',
                    fontSize: 56,
                    strokeWidth: 8,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FadeTransition(
                opacity: _tagIn,
                child: const ComicText(
                  '"Gamify your social life"',
                  fontSize: 16,
                  strokeWidth: 5,
                ),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
