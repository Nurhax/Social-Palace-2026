import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Sound effects + background music.
///
/// Files (paths are relative to the assets/ folder) and the matching
/// pubspec.yaml entries:
///   assets/audio/sfx/select.mp3     -> selecting / confirming
///   assets/audio/sfx/confirm.mp3    -> confirming a selection
///   assets/audio/sfx/deselect.mp3   -> going back / deselecting
///   assets/audio/bgm/p5_theme.mp3   -> loops after login
///
///   flutter:
///     assets:
///       - assets/audio/sfx/
///       - assets/audio/bgm/
///
/// Every call is wrapped in try/catch, so a missing file or an audio error
/// never crashes the app. Watch the debug console for lines starting with
/// "AudioService:" to see exactly what happens.
class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  static const String selectSfx = 'audio/sfx/select.mp3';
  static const String confirmSfx = 'audio/sfx/confirm.mp3';
  static const String deselectSfx = 'audio/sfx/deselect.mp3';
  static const String bgmTrack = 'audio/bgm/p5_theme.mp3';
  static const String bgmTrack2 = 'audio/bgm/p3_theme2.mp3';
  static const String bgmTrack3 = 'audio/bgm/p4_theme3.mp3';

  bool sfxEnabled = true;
  bool musicEnabled = true;

  late final _SfxPool _select;
  late final _SfxPool _confirm;
  late final _SfxPool _deselect;
  late final AudioPlayer _bgm;

  Future<void>? _initFuture;
  bool _ready = false;
  bool _bgmWanted = false; // true while logged in

  // Assets that really don't exist in the bundle: don't retry them.
  final Set<String> _missing = {};

  /// Safe to call many times; setup only runs once.
  Future<void> init() => _initFuture ??= _init();

  Future<void> _init() async {
    // 1) Audio context first, so the players created below pick it up.
    //    No audio focus: an SFX must not pause the music.
    try {
      await AudioPlayer.global.setAudioContext(
        AudioContext(
          android: AudioContextAndroid(audioFocus: AndroidAudioFocus.none),
        ),
      );
    } catch (e) {
      debugPrint('AudioService: setAudioContext failed: $e');
    }

    // 2) Players. Each SFX gets a small pool so rapid taps don't cut each
    //    other off.
    _select = _SfxPool(3);
    _confirm = _SfxPool(3);
    _deselect = _SfxPool(3);
    _bgm = AudioPlayer();
    try {
      await _bgm.setReleaseMode(ReleaseMode.loop);
      await _bgm.setVolume(0.55);
    } catch (e) {
      debugPrint('AudioService: BGM setup failed: $e');
    }

    // 3) Load the files once, so the first tap doesn't have to.
    for (final asset in [
      selectSfx,
      confirmSfx,
      deselectSfx,
      bgmTrack,
      bgmTrack2,
      bgmTrack3
    ]) {
      try {
        await AudioCache.instance.load(asset);
        debugPrint('AudioService: loaded $asset');
      } catch (e) {
        _missing.add(asset);
        debugPrint('AudioService: cannot load "assets/$asset" -> $e');
      }
    }

    _ready = true;
    debugPrint('AudioService: ready');
  }

  // ---------------------------------------------------------------- SFX

  Future<void> playSelect() => _playSfx(selectSfx, () => _select);
  Future<void> playConfirm() => _playSfx(confirmSfx, () => _confirm);
  Future<void> playDeselect() => _playSfx(deselectSfx, () => _deselect);

  Future<void> _playSfx(String asset, _SfxPool Function() pool) async {
    if (!sfxEnabled) return;
    await init();
    if (!_ready || _missing.contains(asset)) return;
    try {
      await pool().take().play(AssetSource(asset), volume: 1.0);
    } catch (e) {
      if (e.toString().contains('Unable to load asset')) _missing.add(asset);
      debugPrint('AudioService: SFX failed ($asset): $e');
    }
  }

  // ---------------------------------------------------------------- BGM

  /// Start the looping music (call after a successful login).
  Future<void> playBgm() async {
    _bgmWanted = true;
    if (!musicEnabled) return;
    await init();
    if (!_ready || _missing.contains(bgmTrack)) return;
    try {
      await _bgm.stop();
      await _bgm.play(AssetSource(bgmTrack));
      debugPrint('AudioService: BGM started');
    } catch (e) {
      if (e.toString().contains('Unable to load asset')) {
        _missing.add(bgmTrack);
      }
      debugPrint('AudioService: BGM failed: $e');
    }
  }

  /// Stop the music (call on logout).
  Future<void> stopBgm() async {
    _bgmWanted = false;
    if (!_ready) return;
    try {
      await _bgm.stop();
    } catch (e) {
      debugPrint('AudioService: BGM stop failed: $e');
    }
  }

  Future<void> pauseBgm() async {
    if (!_ready) return;
    try {
      await _bgm.pause();
    } catch (_) {}
  }

  Future<void> resumeBgm() async {
    if (!_ready || !_bgmWanted || !musicEnabled) return;
    try {
      await _bgm.resume();
    } catch (_) {}
  }
}

/// A few players taken in turn, so a new SFX can start while the previous
/// one is still playing.
class _SfxPool {
  final List<AudioPlayer> _players;
  int _next = 0;

  _SfxPool(int size) : _players = List.generate(size, (_) => AudioPlayer());

  AudioPlayer take() => _players[_next++ % _players.length];
}
