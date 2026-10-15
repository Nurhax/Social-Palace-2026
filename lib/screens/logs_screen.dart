import 'package:flutter/material.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/comic_shapes.dart';
import '../widgets/social_link_card.dart';
import '../widgets/sopal_chrome.dart';

class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final colors = state.colors;
    return Scaffold(
      backgroundColor: colors.primary,
      appBar: const SopalHeader(title: 'LOGS'),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: state.socialLinks.length,
        itemBuilder: (context, index) {
          final link = state.socialLinks[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                ArcanaBadge(arcana: link.arcana),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => LogDetailScreen(link: link)),
                    ),
                    child: SlantedBox(
                      color: Colors.black,
                      borderColor: Colors.white,
                      skew: 14,
                      shadowOffset: 4,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              link.name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class LogDetailScreen extends StatefulWidget {
  final SocialLink link;
  const LogDetailScreen({super.key, required this.link});

  @override
  State<LogDetailScreen> createState() => _LogDetailScreenState();
}

class _LogDetailScreenState extends State<LogDetailScreen> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final colors = state.colors;
    final link = widget.link;

    return Scaffold(
      backgroundColor: colors.primary,
      appBar: const SopalHeader(title: 'LOGS'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ArcanaBadge(arcana: link.arcana),
                const SizedBox(width: 8),
                Expanded(
                  child: SlantedBox(
                    color: Colors.black,
                    borderColor: Colors.white,
                    child: Text(
                      link.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: Colors.white, width: 3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        itemCount: link.logs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final log = link.logs[index];
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${log.dateLabel}:',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  log.text,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Fill the log here...',
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ComicButton(
                        label: 'ADD',
                        fontSize: 18,
                        onTap: () {
                          if (_controller.text.trim().isEmpty) return;
                          state.addLog(link, _controller.text.trim());
                          _controller.clear();
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
