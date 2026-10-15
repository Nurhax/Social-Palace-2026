import 'package:flutter/material.dart';

class Arcana {
  final String name;
  final IconData icon;
  const Arcana(this.name, this.icon);
}

/// The 13-item arcana grid from the "Arcana Selection" screen.
const List<Arcana> kArcanaList = [
  Arcana('NULL', Icons.block),
  Arcana('LOVERS', Icons.favorite),
  Arcana('HERMIT', Icons.self_improvement),
  Arcana('MAGICIAN', Icons.auto_fix_high),
  Arcana('EMPRESS', Icons.workspace_premium),
  Arcana('JUSTICE', Icons.colorize),
  Arcana('FORTUNE', Icons.diamond),
  Arcana('DEATH', Icons.sentiment_very_dissatisfied),
  Arcana('SUN', Icons.wb_sunny),
  Arcana('MOON', Icons.nightlight_round),
  Arcana('JUDGEMENT', Icons.balance),
  Arcana('EMPEROR', Icons.push_pin),
  Arcana('STAR', Icons.star),
];

class LogEntry {
  final DateTime date;
  final String text;
  LogEntry({required this.date, required this.text});

  String get dateLabel =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
}

class SocialLink {
  String name;
  Arcana arcana;
  int level; // 1-10
  int exp; // progress within current level, 0-10
  bool favourite;
  List<LogEntry> logs;

  SocialLink({
    required this.name,
    required this.arcana,
    this.level = 1,
    this.exp = 0,
    this.favourite = false,
    List<LogEntry>? logs,
  }) : logs = logs ?? [];

  int get totalLogs => logs.length;

  String get lastLogLabel => logs.isEmpty ? '-' : logs.first.dateLabel;
}
