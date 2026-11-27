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
  bool _prefilled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pre-fill with the last ID used on this device.
    if (!_prefilled) {
      _prefilled = true;
      _controller.text = AppScope.of(context).lastId;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _enter() {
    final state = AppScope.of(context);
    final input = _controller.text.trim();
    if (input.isEmpty) {
      _toast('Enter your ID first');
      return;
    }
    if (!state.signIn(input)) {
      _toast('ID "$input" not found. Tap "Tap Here" to create it.');
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  Future<void> _createId() async {
    final created = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const GetIdScreen()),
    );
    if (created != null && mounted) {
      setState(() => _controller.text = created);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppScope.of(context).colors;
    return Scaffold(
      backgroundColor: colors.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const SopalMark(size: 250),
              const SizedBox(height: 28),
              const ComicText('Social Palace', fontSize: 48, strokeWidth: 7),
              const ComicText('"Gamify your social life"',
                  fontSize: 12, strokeWidth: 5),
              const SizedBox(height: 20),
              const ComicText('Enter Your ID', fontSize: 26, strokeWidth: 5),
              const SizedBox(height: 20),
              ComicTextField(controller: _controller, hint: 'Enter here...'),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _createId,
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
                          decorationThickness: 2,
                          decorationColor: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 36),
              ComicButton(label: 'ENTER', fontSize: 26, onTap: _enter),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Create your ID": the user types the name themselves
/// (e.g. WorkFriends, HiyaHiya). Each ID keeps its own social links.
class GetIdScreen extends StatefulWidget {
  const GetIdScreen({super.key});

  @override
  State<GetIdScreen> createState() => _GetIdScreenState();
}

class _GetIdScreenState extends State<GetIdScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _copy() {
    final id = _controller.text.trim();
    if (id.isEmpty) {
      _toast('Type an ID first');
      return;
    }
    Clipboard.setData(ClipboardData(text: id));
    _toast('Copied to clipboard');
  }

  void _done() {
    final id = _controller.text.trim();
    if (id.isEmpty) {
      _toast('Type an ID first');
      return;
    }
    final state = AppScope.of(context);
    if (!state.createId(id)) {
      _toast('"$id" is already used. Pick another name.');
      return;
    }
    // Go back to the Enter ID screen (ID is pre-filled); the user logs in there.
    Navigator.of(context).pop(id);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppScope.of(context).colors;
    return Scaffold(
      backgroundColor: colors.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const SopalMark(size: 250),
              const SizedBox(height: 28),
              const ComicText('Social Palace', fontSize: 48, strokeWidth: 7),
              const ComicText('"Gamify your social life"',
                  fontSize: 12, strokeWidth: 5),
              const SizedBox(height: 20),
              const ComicText('Create Your ID', fontSize: 26, strokeWidth: 5),
              const SizedBox(height: 20),
              ComicTextField(controller: _controller, hint: 'e.g. WorkFriends'),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _copy,
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
              ComicButton(label: 'DONE', fontSize: 26, onTap: _done),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
