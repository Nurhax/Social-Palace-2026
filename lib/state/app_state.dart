import 'dart:math';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class AppState extends ChangeNotifier {
  String userId = '';
  SopalPalette palette = SopalPalette.p5;

  final List<SocialLink> socialLinks = [
    SocialLink(
      name: 'Ann Takamaki',
      arcana: kArcanaList.firstWhere((a) => a.name == 'LOVERS'),
      level: 10,
      exp: 4,
      favourite: true,
      logs: [
        LogEntry(
            date: DateTime(2025, 7, 13),
            text: 'Jalan ke blokm bareng" yg lain'),
        LogEntry(date: DateTime(2025, 6, 10), text: 'Nonton HTTYD berdua'),
        LogEntry(date: DateTime(2025, 6, 10), text: 'Ke Rangkasbitung'),
        LogEntry(date: DateTime(2025, 5, 13), text: 'Ngawas ujian bareng'),
      ],
    ),
    SocialLink(
      name: 'Futaba Sakura',
      arcana: kArcanaList.firstWhere((a) => a.name == 'HERMIT'),
      level: 5,
      exp: 2,
      logs: [
        LogEntry(date: DateTime(2025, 4, 2), text: 'Ngoding bareng seharian'),
      ],
    ),
  ];

  SopalColors get colors => kPalettes[palette]!;

  SocialLink? get leastFavourite {
    if (socialLinks.isEmpty) return null;
    return socialLinks.reduce((a, b) => a.level <= b.level ? a : b);
  }

  int get totalLogs => socialLinks.fold(0, (sum, s) => sum + s.totalLogs);

  void generateId() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz0123456789';
    final rnd = Random();
    userId =
        '${List.generate(7, (_) => chars[rnd.nextInt(chars.length)]).join()}*';
    notifyListeners();
  }

  void setId(String id) {
    userId = id;
    notifyListeners();
  }

  void setPalette(SopalPalette p) {
    palette = p;
    notifyListeners();
  }

  void addSocialLink(SocialLink link) {
    socialLinks.add(link);
    notifyListeners();
  }

  void removeSocialLink(SocialLink link) {
    socialLinks.remove(link);
    notifyListeners();
  }

  void addExp(SocialLink link, int delta) {
    link.exp += delta;
    while (link.exp >= 10 && link.level < 10) {
      link.exp -= 10;
      link.level += 1;
    }
    while (link.exp < 0 && link.level > 1) {
      link.exp += 10;
      link.level -= 1;
    }
    link.exp = link.exp.clamp(0, 10);
    notifyListeners();
  }

  void toggleFavourite(SocialLink link) {
    link.favourite = !link.favourite;
    notifyListeners();
  }

  void addLog(SocialLink link, String text) {
    link.logs.insert(0, LogEntry(date: DateTime.now(), text: text));
    notifyListeners();
  }

  /// Public wrapper so screens can request a rebuild after mutating a
  /// [SocialLink]'s fields directly (e.g. after inline editing).
  void refresh() => notifyListeners();
}

/// Simple InheritedNotifier wrapper so screens can do
/// `AppScope.of(context)` without pulling in an external state package.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No AppScope found in context');
    return scope!.notifier!;
  }
}
