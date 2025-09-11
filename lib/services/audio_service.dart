import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isInitialized = false;
  bool _soundEnabled = true;
  double _volume = 0.7;
  String _currentSoundType = 'mantra_bell';

  // Кэш для аудио файлов
  final Map<String, AudioPlayer> _soundCache = {};

  // Доступные звуки
  static const Map<String, String> availableSounds = {
    'mantra_bell': 'assets/audio/mantra_bell.mp3',
    'tibetan_bowl': 'assets/audio/tibetan_bowl.mp3',
    'om_sound': 'assets/audio/om_sound.mp3',
    'nature_sounds': 'assets/audio/nature_sounds.mp3',
    'crystal_bowl': 'assets/audio/crystal_bowl.mp3',
    'gong': 'assets/audio/gong.mp3',
    'wind_chimes': 'assets/audio/wind_chimes.mp3',
    'rain_drops': 'assets/audio/rain_drops.mp3',
    'silent': '', // Без звука
  };

  // Типы звуков для разных событий
  static const Map<String, String> eventSounds = {
    'bead_click': 'bead_click',
    'round_complete': 'round_complete',
    'session_start': 'session_start',
    'session_complete': 'session_complete',
    'notification': 'notification',
  };

  /// Инициализация сервиса
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _loadSettings();
      await _preloadSounds();
      _isInitialized = true;
    } catch (e) {
      // silent
    }
  }

  /// Загружает настройки звука
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _soundEnabled = prefs.getBool('japa_sound_enabled') ?? true;
      _volume = prefs.getDouble('japa_sound_volume') ?? 0.7;
      _currentSoundType = prefs.getString('japa_sound_type') ?? 'mantra_bell';
    } catch (e) {
      // silent
    }
  }

  /// Сохраняет настройки звука
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('japa_sound_enabled', _soundEnabled);
      await prefs.setDouble('japa_sound_volume', _volume);
      await prefs.setString('japa_sound_type', _currentSoundType);
    } catch (e) {
      // silent
    }
  }

  /// Предзагружает звуки для быстрого воспроизведения
  Future<void> _preloadSounds() async {
    try {
      for (final entry in availableSounds.entries) {
        if (entry.value.isNotEmpty) {
          final player = AudioPlayer();
          await player.setSource(
            AssetSource(entry.value.replaceFirst('assets/', '')),
          );
          _soundCache[entry.key] = player;
        }
      }
    } catch (e) {
      // silent
    }
  }

  /// Воспроизводит звук для события
  Future<void> playEventSound(String eventType) async {
    if (!_soundEnabled || !_isInitialized) return;

    try {
      String soundType = _currentSoundType;

      // Специальные звуки для разных событий
      switch (eventType) {
        case 'bead_click':
          soundType = _currentSoundType;
          break;
        case 'round_complete':
          soundType = 'tibetan_bowl';
          break;
        case 'session_start':
          soundType = 'om_sound';
          break;
        case 'session_complete':
          soundType = 'gong';
          break;
        case 'notification':
          soundType = 'mantra_bell';
          break;
      }

      await _playSound(soundType);
    } catch (e) {
      // silent
    }
  }

  /// Воспроизводит звук по типу
  Future<void> _playSound(String soundType) async {
    if (soundType == 'silent' || !availableSounds.containsKey(soundType))
      return;

    try {
      final soundPath = availableSounds[soundType];
      if (soundPath == null || soundPath.isEmpty) return;

      // Используем кэшированный плеер или создаем новый
      AudioPlayer? player = _soundCache[soundType];
      if (player == null) {
        player = AudioPlayer();
        await player.setSource(
          AssetSource(soundPath.replaceFirst('assets/', '')),
        );
        _soundCache[soundType] = player;
      }

      await player.setVolume(_volume);
      await player.resume();
    } catch (e) {
      // silent
    }
  }

  /// Воспроизводит тестовый звук
  void playTestSound(String soundType) {
    if (!_isInitialized) return;

    try {
      _playSound(soundType);
    } catch (e) {
      // silent
    }
  }

  /// Включает/выключает звук
  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    await _saveSettings();
  }

  /// Устанавливает громкость
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _saveSettings();
  }

  /// Устанавливает тип звука
  Future<void> setSoundType(String soundType) async {
    if (availableSounds.containsKey(soundType)) {
      _currentSoundType = soundType;
      await _saveSettings();
    }
  }

  /// Получает текущие настройки
  Map<String, Object> getSettings() {
    return {
      'soundEnabled': _soundEnabled,
      'volume': _volume,
      'currentSoundType': _currentSoundType,
      'availableSounds': availableSounds.keys.toList(),
    };
  }

  /// Получает доступные звуки
  List<String> getAvailableSounds() {
    return availableSounds.keys.toList();
  }

  /// Получает название звука
  String getSoundName(String soundType) {
    const soundNames = {
      'mantra_bell': 'Колокольчик мантры',
      'tibetan_bowl': 'Тибетская чаша',
      'om_sound': 'Звук Ом',
      'nature_sounds': 'Звуки природы',
      'crystal_bowl': 'Кристальная чаша',
      'gong': 'Гонг',
      'wind_chimes': 'Колокольчики ветра',
      'rain_drops': 'Капли дождя',
      'silent': 'Без звука',
    };

    return soundNames[soundType] ?? soundType;
  }

  /// Останавливает все звуки
  Future<void> stopAllSounds() async {
    try {
      for (final player in _soundCache.values) {
        await player.stop();
      }
    } catch (e) {
      // silent
    }
  }

  /// Освобождает ресурсы
  Future<void> dispose() async {
    try {
      await stopAllSounds();
      for (final player in _soundCache.values) {
        await player.dispose();
      }
      _soundCache.clear();
      await _audioPlayer.dispose();
    } catch (e) {
      // silent
    }
  }

  // Геттеры
  bool get soundEnabled => _soundEnabled;
  double get volume => _volume;
  String get currentSoundType => _currentSoundType;
  bool get isInitialized => _isInitialized;
}
