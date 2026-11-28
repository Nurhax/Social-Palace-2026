import 'package:flutter/material.dart';
import '../audio/audio_service.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_assets.dart';
import '../theme/app_theme.dart';
import '../widgets/comic_shapes.dart';
import '../widgets/social_link_card.dart';
import '../widgets/sopal_chrome.dart';

/// Logs per social link. A link's logs only show after its name is tapped
/// (tap again to collapse). When the year changes between logs, the year is
/// shown as a divider.
class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  SocialLink? _open;
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle(SocialLink link) {
    // opening a panel = select sound, closing it = deselect sound
    if (identical(_open, link)) {
      AudioService.instance.playDeselect();
    } else {
      AudioService.instance.playSelect();
    }
    setState(() {
      _open = identical(_open, link) ? null : link;
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final colors = state.colors;
    final links = state.socialLinks;

    return Scaffold(
      backgroundColor: colors.primary,
      appBar: const SopalHeader(
        title: 'Logs',
        iconAsset: AppAssets.headerLogsIcon,
        fallbackIcon: Icons.forum,
        scrollableTitle: true,
      ),
      body: links.isEmpty
          ? const Center(
              child: ComicText(
                'No social links yet.\nAdd one in Social Links.',
                textAlign: TextAlign.center,
                fontSize: 18,
                strokeWidth: 5,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: links.length,
              itemBuilder: (context, index) => _section(links[index]),
            ),
    );
  }

  Widget _section(SocialLink link) {
    final isOpen = identical(_open, link);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ArcanaBadge(arcana: link.arcana),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => _toggle(link),
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
                        Icon(
                          isOpen
                              ? Icons.keyboard_arrow_down
                              : Icons.chevron_right,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (isOpen) _panel(link),
        ],
      ),
    );
  }

  Widget _panel(SocialLink link) {
    final state = AppScope.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (link.logs.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: ComicText('No logs yet.', fontSize: 16, strokeWidth: 4),
            )
          else
            ..._logRows(link),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: _controller,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
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
                final text = _controller.text.trim();
                if (text.isEmpty) return;
                state.addLog(link, text);
                _controller.clear();
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Log rows (newest first). A year divider is inserted whenever the year
  /// differs from the previous row; the first row is compared with the
  /// current year, so older-year logs at the top are labelled too.
  List<Widget> _logRows(SocialLink link) {
    final rows = <Widget>[];
    var previousYear = DateTime.now().year;
    for (final log in link.logs) {
      if (log.date.year != previousYear) {
        rows.add(_yearDivider(log.date.year));
        previousYear = log.date.year;
      }
      rows.add(_logRow(log));
    }
    return rows;
  }

  Widget _yearDivider(int year) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          const Expanded(child: Divider(color: Colors.white54, thickness: 2)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '$year',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                fontSize: 18,
                letterSpacing: 2,
              ),
            ),
          ),
          const Expanded(child: Divider(color: Colors.white54, thickness: 2)),
        ],
      ),
    );
  }

  Widget _logRow(LogEntry log) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
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
      ),
    );
  }
}
