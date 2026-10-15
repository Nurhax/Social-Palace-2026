import 'package:flutter/material.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/comic_shapes.dart';
import '../widgets/social_link_card.dart';
import '../widgets/sopal_chrome.dart';

class AddSocialLinkScreen extends StatefulWidget {
  const AddSocialLinkScreen({super.key});

  @override
  State<AddSocialLinkScreen> createState() => _AddSocialLinkScreenState();
}

class _AddSocialLinkScreenState extends State<AddSocialLinkScreen> {
  final _nameController = TextEditingController();
  final _levelController = TextEditingController();
  Arcana _arcana = kArcanaList.first; // NULL

  @override
  Widget build(BuildContext context) {
    final colors = AppScope.of(context).colors;
    return Scaffold(
      backgroundColor: colors.primary,
      appBar: const SopalHeader(title: 'New\nSocial Link'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.black, width: 3),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ComicText('Arcana',
                  fontSize: 26,
                  fillColor: Colors.black,
                  strokeColor: Colors.white,
                  strokeWidth: 0),
              const SizedBox(height: 10),
              Row(
                children: [
                  ArcanaBadge(arcana: _arcana, showLabel: true),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final selected =
                            await Navigator.of(context).push<Arcana>(
                          MaterialPageRoute(
                              builder: (_) => const ArcanaSelectionScreen()),
                        );
                        if (selected != null)
                          setState(() => _arcana = selected);
                      },
                      child: const SlantedBox(
                        color: Colors.black,
                        borderColor: Colors.white,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Select arcana',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic)),
                            SizedBox(width: 8),
                            Icon(Icons.chevron_right, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              const ComicText('Name',
                  fontSize: 26,
                  fillColor: Colors.black,
                  strokeColor: Colors.white,
                  strokeWidth: 0),
              const SizedBox(height: 10),
              ComicTextField(
                  controller: _nameController, hint: 'Enter here...'),
              const SizedBox(height: 26),
              const ComicText('Current Level',
                  fontSize: 26,
                  fillColor: Colors.black,
                  strokeColor: Colors.white,
                  strokeWidth: 0),
              const SizedBox(height: 10),
              ComicTextField(
                controller: _levelController,
                hint: 'Enter here...',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 30),
              Center(
                child: ComicButton(
                  label: 'ADD',
                  fontSize: 26,
                  onTap: () {
                    if (_nameController.text.trim().isEmpty) return;
                    final level = int.tryParse(_levelController.text) ?? 1;
                    Navigator.of(context).pop(
                      SocialLink(
                        name: _nameController.text.trim(),
                        arcana: _arcana,
                        level: level.clamp(1, 10),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ArcanaSelectionScreen extends StatelessWidget {
  const ArcanaSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppScope.of(context).colors;
    return Scaffold(
      backgroundColor: colors.primary,
      appBar: const SopalHeader(title: 'New\nSocial Link'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black, width: 3),
          ),
          child: Column(
            children: [
              const ComicText('Arcana Selection', fontSize: 24, strokeWidth: 5),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  itemCount: kArcanaList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                  itemBuilder: (context, index) {
                    final arcana = kArcanaList[index];
                    return GestureDetector(
                      onTap: () => Navigator.of(context).pop(arcana),
                      child:
                          Center(child: ArcanaBadge(arcana: arcana, size: 84)),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              ComicButton(
                  label: 'DONE',
                  fontSize: 24,
                  onTap: () => Navigator.of(context).pop()),
            ],
          ),
        ),
      ),
    );
  }
}
