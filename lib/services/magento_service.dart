import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'connectivity_service.dart';

/// Модель для синхронизации данных джапа медитации
class JapaCloudData {
  final String userId;
  final int totalCount;
  final int todayCount;
  final DateTime lastUpdate;
  final Map<String, dynamic> achievements;
  final Map<String, dynamic> statistics;

  JapaCloudData({
    required this.userId,
    required this.totalCount,
    required this.todayCount,
    required this.lastUpdate,
    required this.achievements,
    required this.statistics,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'totalCount': totalCount,
      'todayCount': todayCount,
      'lastUpdate': lastUpdate.toIso8601String(),
      'achievements': achievements,
      'statistics': statistics,
    };
  }

  factory JapaCloudData.fromJson(Map<String, dynamic> json) {
    return JapaCloudData(
      userId: json['userId'] ?? '',
      totalCount: json['totalCount'] ?? 0,
      todayCount: json['todayCount'] ?? 0,
      lastUpdate: DateTime.tryParse(json['lastUpdate'] ?? '') ?? DateTime.now(),
      achievements: json['achievements'] ?? {},
      statistics: json['statistics'] ?? {},
    );
  }
}

/// Сервис для работы с Magento облачными функциями
class MagentoService {
  static final MagentoService _instance = MagentoService._internal();
  factory MagentoService() => _instance;
  MagentoService._internal();

  Dio? _dio;
  String? _baseUrl;
  String? _accessToken;
  final ConnectivityService _connectivityService = ConnectivityService();

  bool _isCloudEnabled = false;
  bool get isCloudEnabled => _isCloudEnabled;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Инициализация Magento клиента
  Future<void> initialize({
    required String baseUrl,
    String? consumerKey,
    String? consumerSecret,
    String? accessToken,
    String? accessTokenSecret,
  }) async {
    try {
      // Загружаем настройки облачных функций
      await _loadCloudSettings();

      if (_isCloudEnabled) {
        _baseUrl = baseUrl;
        _accessToken = accessToken;

        _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              if (accessToken != null) 'Authorization': 'Bearer $accessToken',
            },
          ),
        );

        _isInitialized = true;
      }
    } catch (e) {
      print('Ошибка инициализации Magento сервиса: $e');
      _isInitialized = false;
    }
  }

  /// Загрузка настроек облачных функций
  Future<void> _loadCloudSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isCloudEnabled = prefs.getBool('cloud_features_enabled') ?? false;
  }

  /// Включение/выключение облачных функций
  Future<void> setCloudFeaturesEnabled(bool enabled) async {
    _isCloudEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('cloud_features_enabled', enabled);
  }

  /// Проверка доступности облачных функций
  bool get isCloudAvailable {
    return _isCloudEnabled &&
        _isInitialized &&
        _connectivityService.isOnline &&
        _dio != null;
  }

  /// Синхронизация данных джапа медитации с облаком
  Future<bool> syncJapaData(JapaCloudData data) async {
    if (!isCloudAvailable) {
      print('Облачные функции недоступны для синхронизации');
      return false;
    }

    try {
      // Создаем или обновляем пользовательские данные через Magento API
      final response = await _dio!.post(
        '/rest/V1/japa/sync',
        data: data.toJson(),
      );

      if (response.statusCode == 200) {
        print('Данные джапа успешно синхронизированы с облаком');
        return true;
      } else {
        print('Ошибка синхронизации: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Ошибка при синхронизации данных джапа: $e');
      return false;
    }
  }

  /// Загрузка данных джапа из облака
  Future<JapaCloudData?> loadJapaData(String userId) async {
    if (!isCloudAvailable) {
      print('Облачные функции недоступны для загрузки');
      return null;
    }

    try {
      final response = await _dio!.get('/rest/V1/japa/user/$userId');

      if (response.statusCode == 200) {
        return JapaCloudData.fromJson(response.data);
      } else {
        print('Ошибка загрузки данных: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Ошибка при загрузке данных джапа: $e');
      return null;
    }
  }

  /// Получение глобальной статистики пользователей
  Future<Map<String, dynamic>?> getGlobalStatistics() async {
    if (!isCloudAvailable) {
      print('Облачные функции недоступны для получения статистики');
      return null;
    }

    try {
      final response = await _dio!.get('/rest/V1/japa/statistics/global');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        print('Ошибка получения глобальной статистики: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Ошибка при получении глобальной статистики: $e');
      return null;
    }
  }

  /// Получение рейтинга пользователей
  Future<List<Map<String, dynamic>>?> getLeaderboard({int limit = 10}) async {
    if (!isCloudAvailable) {
      print('Облачные функции недоступны для получения рейтинга');
      return null;
    }

    try {
      final response = await _dio!.get(
        '/rest/V1/japa/leaderboard?limit=$limit',
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['items'] ?? []);
      } else {
        print('Ошибка получения рейтинга: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Ошибка при получении рейтинга: $e');
      return null;
    }
  }

  /// Отправка уведомления о достижении
  Future<bool> reportAchievement(
    String userId,
    String achievementId,
    Map<String, dynamic> data,
  ) async {
    if (!isCloudAvailable) {
      print('Облачные функции недоступны для отправки достижений');
      return false;
    }

    try {
      final response = await _dio!.post(
        '/rest/V1/japa/achievement',
        data: {
          'userId': userId,
          'achievementId': achievementId,
          'data': data,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Ошибка при отправке достижения: $e');
      return false;
    }
  }

  /// Получение персонализированных рекомендаций
  Future<List<Map<String, dynamic>>?> getPersonalizedRecommendations(
    String userId,
  ) async {
    if (!isCloudAvailable) {
      print('Облачные функции недоступны для получения рекомендаций');
      return null;
    }

    try {
      final response = await _dio!.get('/rest/V1/japa/recommendations/$userId');

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(
          response.data['recommendations'] ?? [],
        );
      } else {
        print('Ошибка получения рекомендаций: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Ошибка при получении рекомендаций: $e');
      return null;
    }
  }

  /// Автоматическая синхронизация (вызывается периодически)
  Future<void> autoSync(JapaCloudData data) async {
    if (!isCloudAvailable) {
      return;
    }

    // Проверяем, прошло ли достаточно времени с последней синхронизации
    final prefs = await SharedPreferences.getInstance();
    final lastSyncTime = prefs.getInt('last_cloud_sync') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    // Синхронизируем не чаще чем раз в 5 минут
    if (now - lastSyncTime > 5 * 60 * 1000) {
      final success = await syncJapaData(data);
      if (success) {
        await prefs.setInt('last_cloud_sync', now);
      }
    }
  }

  /// Очистка ресурсов
  void dispose() {
    _dio?.close();
    _dio = null;
    _isInitialized = false;
  }
}
