import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mahabharata_comic.dart';

/// Сервис для работы с комиксами Махабхараты
/// Поддерживает форматы .comics и .boranko (старый формат)
class MahabharataService {
  static MahabharataService? _instance;
  
  bool _isInitialized = false;
  List<MahabharataComic> _comics = [];
  Map<String, MahabharataComic> _comicsById = {};
  MahabharataComicCollection? _collection;
  
  // Статистика
  int _totalRead = 0;
  int _totalFavorites = 0;
  Map<String, double> _readProgress = {};
  
  // Настройки
  static const String _prefKeyReadProgress = 'mahabharata_read_progress';
  static const String _prefKeyFavorites = 'mahabharata_favorites';
  static const String _prefKeyTotalRead = 'mahabharata_total_read';
  
  // Пути к файлам
  static const String _assetsPath = 'assets/comics/';
  static const String _comicsExtension = '.comics';
  static const String _borankoExtension = '.boranko';

  MahabharataService._();

  /// Получить singleton экземпляр
  static MahabharataService get instance {
    _instance ??= MahabharataService._();
    return _instance!;
  }

  /// Инициализация сервиса
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      debugPrint('🕉️ Инициализация MahabharataService...');
      
      // Загружаем настройки
      await _loadSettings();
      
      // Загружаем комиксы из assets
      await _loadComicsFromAssets();
      
      // Загружаем комиксы из внешних источников
      await _loadComicsFromExternalSources();
      
      _isInitialized = true;
      debugPrint('✅ MahabharataService инициализирован. Загружено комиксов: ${_comics.length}');
      
      return true;
    } catch (e) {
      debugPrint('❌ Ошибка инициализации MahabharataService: $e');
      return false;
    }
  }

  /// Загружает настройки из SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Загружаем прогресс чтения
      final progressJson = prefs.getString(_prefKeyReadProgress);
      if (progressJson != null) {
        final progressMap = jsonDecode(progressJson) as Map<String, dynamic>;
        _readProgress = progressMap.map((key, value) => MapEntry(key, value as double));
      }
      
      // Загружаем избранное
      final favoritesJson = prefs.getString(_prefKeyFavorites);
      if (favoritesJson != null) {
        final favoritesList = jsonDecode(favoritesJson) as List;
        _totalFavorites = favoritesList.length;
      }
      
      // Загружаем статистику
      _totalRead = prefs.getInt(_prefKeyTotalRead) ?? 0;
      
      debugPrint('ℹ️ Настройки загружены: прогресс=${_readProgress.length}, избранное=$_totalFavorites, прочитано=$_totalRead');
    } catch (e) {
      debugPrint('⚠️ Ошибка загрузки настроек: $e');
    }
  }

  /// Сохраняет настройки в SharedPreferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Сохраняем прогресс чтения
      await prefs.setString(_prefKeyReadProgress, jsonEncode(_readProgress));
      
      // Сохраняем избранное
      final favorites = _comics.where((c) => c.isFavorite).map((c) => c.id).toList();
      await prefs.setString(_prefKeyFavorites, jsonEncode(favorites));
      
      // Сохраняем статистику
      await prefs.setInt(_prefKeyTotalRead, _totalRead);
      
      debugPrint('💾 Настройки сохранены');
    } catch (e) {
      debugPrint('⚠️ Ошибка сохранения настроек: $e');
    }
  }

  /// Загружает комиксы из assets
  Future<void> _loadComicsFromAssets() async {
    try {
      debugPrint('📦 Загрузка комиксов из assets...');
      
      // Пытаемся загрузить коллекцию по умолчанию
      try {
        final collectionData = await rootBundle.loadString('${_assetsPath}mahabharata_collection.comics');
        final collectionJson = jsonDecode(collectionData) as Map<String, dynamic>;
        _collection = MahabharataComicCollection.fromJson(collectionJson);
        
        _comics.addAll(_collection!.comics);
        debugPrint('✅ Загружена коллекция: ${_collection!.name} (${_collection!.comics.length} комиксов)');
      } catch (e) {
        debugPrint('ℹ️ Коллекция не найдена в assets: $e');
      }
      
      // Индексируем комиксы по ID
      for (var comic in _comics) {
        _comicsById[comic.id] = comic;
      }
      
    } catch (e) {
      debugPrint('⚠️ Ошибка загрузки из assets: $e');
    }
  }

  /// Загружает комиксы из внешних источников (Documents, Downloads)
  Future<void> _loadComicsFromExternalSources() async {
    try {
      debugPrint('📂 Поиск комиксов в Documents и Downloads...');
      
      final documentsDir = await getApplicationDocumentsDirectory();
      final comicsDir = Directory('${documentsDir.path}/comics');
      
      if (await comicsDir.exists()) {
        final files = comicsDir.listSync();
        
        for (var file in files) {
          if (file is File) {
            final fileName = file.path.split('/').last;
            
            // Проверяем расширение
            if (fileName.endsWith(_comicsExtension) || fileName.endsWith(_borankoExtension)) {
              try {
                await _loadComicFromFile(file);
              } catch (e) {
                debugPrint('⚠️ Ошибка загрузки файла $fileName: $e');
              }
            }
          }
        }
      }
      
      debugPrint('✅ Внешние комиксы обработаны');
    } catch (e) {
      debugPrint('⚠️ Ошибка загрузки внешних комиксов: $e');
    }
  }

  /// Загружает комикс из файла
  Future<void> _loadComicFromFile(File file) async {
    try {
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      
      // Определяем формат файла
      if (json.containsKey('comics')) {
        // Формат коллекции
        final collection = MahabharataComicCollection.fromJson(json);
        _comics.addAll(collection.comics);
        debugPrint('✅ Загружена коллекция из файла: ${collection.name}');
      } else {
        // Формат одиночного комикса
        final comic = MahabharataComic.fromJson(json);
        _comics.add(comic);
        _comicsById[comic.id] = comic;
        debugPrint('✅ Загружен комикс: ${comic.title}');
      }
    } catch (e) {
      debugPrint('❌ Ошибка парсинга файла: $e');
      rethrow;
    }
  }

  /// Получает все комиксы
  List<MahabharataComic> getAllComics() {
    return List.unmodifiable(_comics);
  }

  /// Получает комикс по ID
  MahabharataComic? getComicById(String id) {
    return _comicsById[id];
  }

  /// Получает комиксы по тегам
  List<MahabharataComic> getComicsByTags(List<String> tags) {
    return _comics.where((comic) {
      return tags.any((tag) => comic.tags.contains(tag));
    }).toList();
  }

  /// Получает комиксы по персонажам
  List<MahabharataComic> getComicsByCharacters(List<String> characters) {
    return _comics.where((comic) {
      return characters.any((char) => comic.characters.contains(char));
    }).toList();
  }

  /// Получает комиксы, связанные с определенной бусиной/кругом
  List<MahabharataComic> getComicsByJapaConnection({
    int? beadNumber,
    int? roundNumber,
  }) {
    return _comics.where((comic) {
      if (comic.japaConnection == null) return false;
      
      if (beadNumber != null && comic.japaConnection!.beadNumber == beadNumber) {
        return true;
      }
      
      if (roundNumber != null && comic.japaConnection!.roundNumber == roundNumber) {
        return true;
      }
      
      return false;
    }).toList();
  }

  /// Получает комиксы-награды (разблокируются после определенного количества кругов)
  List<MahabharataComic> getRewardComics(int completedRounds) {
    return _comics.where((comic) {
      if (comic.japaConnection == null) return false;
      
      return comic.japaConnection!.showAsReward &&
          completedRounds >= comic.japaConnection!.minRoundsToUnlock;
    }).toList();
  }

  /// Получает избранные комиксы
  List<MahabharataComic> getFavoriteComics() {
    return _comics.where((comic) => comic.isFavorite).toList();
  }

  /// Получает комиксы, отсортированные по номеру эпизода
  List<MahabharataComic> getComicsSortedByEpisode() {
    final sorted = List<MahabharataComic>.from(_comics);
    sorted.sort((a, b) => a.episodeNumber.compareTo(b.episodeNumber));
    return sorted;
  }

  /// Отмечает комикс как избранный/не избранный
  Future<void> toggleFavorite(String comicId) async {
    final comic = _comicsById[comicId];
    if (comic == null) return;
    
    final updatedComic = comic.copyWith(isFavorite: !comic.isFavorite);
    _comicsById[comicId] = updatedComic;
    
    // Обновляем в списке
    final index = _comics.indexWhere((c) => c.id == comicId);
    if (index != -1) {
      _comics[index] = updatedComic;
    }
    
    _totalFavorites = _comics.where((c) => c.isFavorite).length;
    
    await _saveSettings();
    debugPrint('${updatedComic.isFavorite ? "❤️" : "🤍"} Комикс ${comic.title} ${updatedComic.isFavorite ? "добавлен в" : "удален из"} избранное');
  }

  /// Обновляет прогресс чтения комикса
  Future<void> updateReadProgress(String comicId, double progress) async {
    if (progress < 0.0 || progress > 1.0) {
      debugPrint('⚠️ Некорректный прогресс: $progress');
      return;
    }
    
    _readProgress[comicId] = progress;
    
    if (progress >= 1.0) {
      _totalRead++;
      debugPrint('✅ Комикс $comicId прочитан полностью');
    }
    
    await _saveSettings();
  }

  /// Получает прогресс чтения комикса
  double getReadProgress(String comicId) {
    return _readProgress[comicId] ?? 0.0;
  }

  /// Получает статистику
  Map<String, dynamic> getStatistics() {
    return {
      'total_comics': _comics.length,
      'total_read': _totalRead,
      'total_favorites': _totalFavorites,
      'read_percentage': _comics.isNotEmpty
          ? (_totalRead / _comics.length * 100).round()
          : 0,
      'collection_name': _collection?.name ?? 'Неизвестная коллекция',
      'is_initialized': _isInitialized,
    };
  }

  /// Экспортирует комикс в файл
  Future<String?> exportComic(String comicId, {String? directory}) async {
    try {
      final comic = _comicsById[comicId];
      if (comic == null) {
        debugPrint('❌ Комикс не найден: $comicId');
        return null;
      }
      
      // Определяем директорию для экспорта
      final dir = directory ?? (await getApplicationDocumentsDirectory()).path;
      final fileName = '${comic.id}$_comicsExtension';
      final filePath = '$dir/$fileName';
      
      // Сохраняем в файл
      final file = File(filePath);
      await file.writeAsString(jsonEncode(comic.toJson()));
      
      debugPrint('💾 Комикс экспортирован: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('❌ Ошибка экспорта комикса: $e');
      return null;
    }
  }

  /// Импортирует комикс из файла
  Future<bool> importComic(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        debugPrint('❌ Файл не найден: $filePath');
        return false;
      }
      
      await _loadComicFromFile(file);
      debugPrint('✅ Комикс импортирован: $filePath');
      return true;
    } catch (e) {
      debugPrint('❌ Ошибка импорта комикса: $e');
      return false;
    }
  }

  /// Очищает кэш и перезагружает комиксы
  Future<void> reload() async {
    debugPrint('🔄 Перезагрузка комиксов...');
    
    _comics.clear();
    _comicsById.clear();
    _collection = null;
    _isInitialized = false;
    
    await initialize();
  }

  /// Проверяет доступность сервиса
  bool get isAvailable => _isInitialized && _comics.isNotEmpty;
  
  /// Получает количество загруженных комиксов
  int get totalComics => _comics.length;
  
  /// Получает коллекцию
  MahabharataComicCollection? get collection => _collection;
}

