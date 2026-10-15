import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/comic_shapes.dart';
import '../widgets/sopal_chrome.dart';
import 'main_screen.dart';

class EnterIdScreen extends StatefulWidget {
  const EnterIdScreen({super.key});

  @override
  State<EnterIdScreen> createState() => _EnterIdScreenState();
}

class _EnterIdScreenState extends State<EnterIdScreen> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final colors = state.colors;
    return Scaffold(
      backgroundColor: colors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const SopalMark(size: 160),
              const ComicText('SoPal', fontSize: 56, strokeWidth: 7),
              const SizedBox(height: 28),
              const ComicText('Enter Your ID', fontSize: 26, strokeWidth: 5),
              const SizedBox(height: 20),
              ComicTextField(controller: _controller, hint: 'Enter here...'),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const GetIdScreen()),
                  );
                },
                child: const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Don't have one? ",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      TextSpan(
                        text: 'Tap Here',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 36),
              ComicButton(
                label: 'ENTER',
                fontSize: 26,
                onTap: () {
                  state.setId(_controller.text.isEmpty ? 'GUEST*' : _controller.text);
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const MainScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GetIdScreen extends StatefulWidget {
  const GetIdScreen({super.key});

  @override
  State<GetIdScreen> createState() => _GetIdScreenState();
}

class _GetIdScreenState extends State<GetIdScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppScope.of(context).generateId();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final colors = state.colors;
    return Scaffold(
      backgroundColor: colors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const SopalMark(size: 160),
              const ComicText('SoPal', fontSize: 56, strokeWidth: 7),
              const SizedBox(height: 28),
              const ComicText('Your ID', fontSize: 26, strokeWidth: 5),
              const SizedBox(height: 20),
              SlantedBox(
                color: Colors.black,
                borderColor: Colors.white,
                child: Text(
                  state.userId.isEmpty ? '...' : state.userId,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    fontSize: 22,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: state.userId));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied to clipboard')),
                  );
                },
                child: const Text(
                  'Copy to clipboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 36),
              ComicButton(
                label: 'DONE',
                fontSize: 26,
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const MainScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
