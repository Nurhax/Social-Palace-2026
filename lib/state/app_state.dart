import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

/// Holds everything the UI needs and persists it on the device.
///
/// Storage layout (shared_preferences):
///   sopal.ids         -> list of every ID created on this device
///   sopal.lastId      -> the ID last entered (pre-filled on the Enter ID screen)
///   sopal.palette     -> selected theme
///   sopal.data.<id>   -> JSON list of that ID's social links (+ logs)
///
/// Every ID (e.g. "WorkFriends", "HiyaHiya") has its own separate social links.
class AppState extends ChangeNotifier {
  AppState._(this._prefs);

  final SharedPreferences _prefs;

  static const _kIds = 'sopal.ids';
  static const _kLastId = 'sopal.lastId';
  static const _kPalette = 'sopal.palette';
  static String _kData(String id) => 'sopal.data.${id.toLowerCase()}';

  /// Call once before runApp().
  static Future<AppState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final state = AppState._(prefs);
    state._loadPrefs();
    return state;
  }

  List<String> savedIds = [];
  String lastId = '';
  String userId = ''; // the ID currently signed in ('' = signed out)
  SopalPalette palette = SopalPalette.p5;
  List<SocialLink> socialLinks = [];

  SopalColors get colors => kPalettes[palette]!;

  /// Ranks links by level, then EXP, then star, then number of logs.
  int _compare(SocialLink a, SocialLink b) {
    var c = a.level.compareTo(b.level);
    if (c != 0) return c;
    c = a.exp.compareTo(b.exp);
    if (c != 0) return c;
    c = (a.favourite ? 1 : 0).compareTo(b.favourite ? 1 : 0);
    if (c != 0) return c;
    return a.totalLogs.compareTo(b.totalLogs);
  }

  /// Highest ranked social link (null when there are none).
  SocialLink? get mostFavourite {
    if (socialLinks.isEmpty) return null;
    return socialLinks.reduce((a, b) => _compare(a, b) >= 0 ? a : b);
  }

  /// Lowest ranked social link (null when there are none).
  SocialLink? get leastFavourite {
    if (socialLinks.isEmpty) return null;
    return socialLinks.reduce((a, b) => _compare(a, b) <= 0 ? a : b);
  }

  /// The most recent log across all social links, with the link it belongs to.
  LatestLog? get latestLog {
    LatestLog? best;
    for (final link in socialLinks) {
      for (final log in link.logs) {
        if (best == null || log.date.isAfter(best.log.date)) {
          best = LatestLog(link, log);
        }
      }
    }
    return best;
  }

  int get totalLogs => socialLinks.fold(0, (sum, s) => sum + s.totalLogs);

  void _loadPrefs() {
    savedIds = List<String>.from(_prefs.getStringList(_kIds) ?? const []);
    lastId = _prefs.getString(_kLastId) ?? '';
    final saved = _prefs.getString(_kPalette);
    palette = SopalPalette.values.firstWhere(
      (p) => p.name == saved,
      orElse: () => SopalPalette.p5,
    );
  }

  // ---------------------------------------------------------------- IDs

  /// Returns the stored spelling of an ID (case-insensitive), or null.
  String? findId(String input) {
    final key = input.trim().toLowerCase();
    for (final id in savedIds) {
      if (id.toLowerCase() == key) return id;
    }
    return null;
  }

  /// Creates a new empty ID. Returns false if it's empty or already used.
  bool createId(String input) {
    final id = input.trim();
    if (id.isEmpty || findId(id) != null) return false;
    savedIds.add(id);
    _prefs.setStringList(_kIds, savedIds);
    _prefs.setString(_kData(id), jsonEncode(<dynamic>[]));
    lastId = id;
    _prefs.setString(_kLastId, id);
    notifyListeners();
    return true;
  }

  /// Signs in to an existing ID and loads its social links.
  bool signIn(String input) {
    final id = findId(input);
    if (id == null) return false;
    userId = id;
    lastId = id;
    _prefs.setString(_kLastId, id);
    socialLinks = _readLinks(id);
    notifyListeners();
    return true;
  }

  void signOut() {
    userId = '';
    socialLinks = [];
    notifyListeners();
  }

  // ------------------------------------------------------------ storage

  List<SocialLink> _readLinks(String id) {
    final raw = _prefs.getString(_kData(id));
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => SocialLink.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  void _saveLinks() {
    if (userId.isEmpty) return;
    _prefs.setString(
      _kData(userId),
      jsonEncode(socialLinks.map((l) => l.toJson()).toList()),
    );
  }

  // ------------------------------------------------------------- theme

  void setPalette(SopalPalette p) {
    palette = p;
    _prefs.setString(_kPalette, p.name);
    notifyListeners();
  }

  // ------------------------------------------------------ social links

  void addSocialLink(SocialLink link) {
    socialLinks.add(link);
    _saveLinks();
    notifyListeners();
  }

  void removeSocialLink(SocialLink link) {
    socialLinks.remove(link);
    _saveLinks();
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
    _saveLinks();
    notifyListeners();
  }

  void toggleFavourite(SocialLink link) {
    link.favourite = !link.favourite;
    _saveLinks();
    notifyListeners();
  }

  void addLog(SocialLink link, String text) {
    link.logs.insert(0, LogEntry(date: DateTime.now(), text: text));
    _saveLinks();
    notifyListeners();
  }

  /// Call after mutating a [SocialLink] directly (e.g. after editing it):
  /// saves to local storage and rebuilds the UI.
  void refresh() {
    _saveLinks();
    notifyListeners();
  }
}

/// A log entry together with the social link it belongs to.
class LatestLog {
  final SocialLink link;
  final LogEntry log;
  const LatestLog(this.link, this.log);
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
