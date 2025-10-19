import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'connectivity_service.dart';
import '../models/japa_session_purchase.dart';
import '../models/user_profile.dart';

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
  // ignore: unused_field
  String? _baseUrl;
  // ignore: unused_field
  String? _accessToken;
  final ConnectivityService _connectivityService = ConnectivityService();

  // Flutter Magento plugin instance for e-commerce functionality
  // FlutterMagento? _flutterMagento;  // Временно отключен

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

        // Инициализируем основной Dio клиент для кастомных Japa API
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

        // Инициализируем Flutter Magento plugin для e-commerce функций
        // _flutterMagento = FlutterMagento();
        // await _flutterMagento!.initialize(
        //   baseUrl: baseUrl,
        //   headers: {
        //     'Content-Type': 'application/json',
        //     'Accept': 'application/json',
        //     if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        //   },
        // );

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

  /// Получить экземпляр FlutterMagento для e-commerce операций
  // FlutterMagento? get magento => _flutterMagento;

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

  // ===== E-COMMERCE CONVENIENCE METHODS =====

  /// Аутентификация пользователя через Magento
  Future<bool> authenticateCustomer(String email, String password) async {
    if (!isCloudAvailable) {
      print('E-commerce функции недоступны для аутентификации');
      return false;
    }

    try {
      final response = await _dio!.post(
        '/rest/V1/integration/customer/token',
        data: {'username': email, 'password': password},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Ошибка аутентификации пользователя: $e');
      return false;
    }
  }

  /// Получение продуктов с фильтрами
  Future<dynamic> getProducts({
    int page = 1,
    int pageSize = 20,
    String? searchQuery,
    String? categoryId,
    Map<String, dynamic>? filters,
  }) async {
    if (!isCloudAvailable) {
      print('E-commerce функции недоступны для получения продуктов');
      return null;
    }

    try {
      final response = await _dio!.get(
        '/rest/V1/products',
        queryParameters: {
          'searchCriteria[pageSize]': pageSize,
          'searchCriteria[currentPage]': page,
          if (searchQuery != null)
            'searchCriteria[filterGroups][0][filters][0][field]': 'name',
          if (searchQuery != null)
            'searchCriteria[filterGroups][0][filters][0][value]': searchQuery,
          if (categoryId != null)
            'searchCriteria[filterGroups][1][filters][0][field]': 'category_id',
          if (categoryId != null)
            'searchCriteria[filterGroups][1][filters][0][value]': categoryId,
        },
      );
      return response.data;
    } catch (e) {
      print('Ошибка получения продуктов: $e');
      return null;
    }
  }

  /// Поиск продуктов
  Future<dynamic> searchProducts(
    String query, {
    int page = 1,
    int pageSize = 20,
  }) async {
    if (!isCloudAvailable) {
      print('E-commerce функции недоступны для поиска');
      return null;
    }

    try {
      final response = await _dio!.get(
        '/rest/V1/products',
        queryParameters: {
          'searchCriteria[pageSize]': pageSize,
          'searchCriteria[currentPage]': page,
          'searchCriteria[filterGroups][0][filters][0][field]': 'name',
          'searchCriteria[filterGroups][0][filters][0][value]': query,
        },
      );
      return response.data;
    } catch (e) {
      print('Ошибка поиска продуктов: $e');
      return null;
    }
  }

  /// Создание корзины
  Future<dynamic> createCart() async {
    if (!isCloudAvailable) {
      print('E-commerce функции недоступны для создания корзины');
      return null;
    }

    try {
      final response = await _dio!.post('/rest/V1/carts/mine');
      return response.data;
    } catch (e) {
      print('Ошибка создания корзины: $e');
      return null;
    }
  }

  /// Добавление товара в корзину
  Future<dynamic> addToCart(String cartId, String sku, int quantity) async {
    if (!isCloudAvailable) {
      print('E-commerce функции недоступны для добавления в корзину');
      return null;
    }

    try {
      final response = await _dio!.post(
        '/rest/V1/carts/mine/items',
        data: {
          'cartItem': {'sku': sku, 'qty': quantity},
        },
      );
      return response.data;
    } catch (e) {
      print('Ошибка добавления товара в корзину: $e');
      return null;
    }
  }

  // ===== JAPA SESSION AS PURCHASE METHODS =====

  /// Сохранение сессии джапы как покупки в Magento
  Future<bool> saveJapaSessionAsPurchase(
    JapaSessionPurchase sessionPurchase,
  ) async {
    if (!isCloudAvailable) {
      print('Облачные функции недоступны для сохранения сессии как покупки');
      return false;
    }

    try {
      // Создаем заказ в Magento для сессии
      final orderData = sessionPurchase.toMagentoOrder();

      final response = await _dio!.post('/rest/V1/orders', data: orderData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Сессия джапы успешно сохранена как покупка в Magento');
        return true;
      } else {
        print('Ошибка сохранения сессии как покупки: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Ошибка при сохранении сессии как покупки: $e');
      return false;
    }
  }

  /// Получение истории сессий из Magento профиля
  Future<List<JapaSessionPurchase>> getJapaSessionHistory(
    String customerId,
  ) async {
    if (!isCloudAvailable) {
      print('Облачные функции недоступны для получения истории сессий');
      return [];
    }

    try {
      final response = await _dio!.get(
        '/rest/V1/customers/$customerId/japa-sessions',
      );

      if (response.statusCode == 200) {
        final List<dynamic> sessionsData = response.data['items'] ?? [];
        return sessionsData
            .map((data) => JapaSessionPurchase.fromJson(data))
            .toList();
      } else {
        print('Ошибка получения истории сессий: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Ошибка при получении истории сессий: $e');
      return [];
    }
  }

  /// Получение статистики сессий из Magento
  Future<Map<String, dynamic>?> getJapaSessionStatistics(
    String customerId,
  ) async {
    if (!isCloudAvailable) {
      print('Облачные функции недоступны для получения статистики сессий');
      return null;
    }

    try {
      final response = await _dio!.get(
        '/rest/V1/customers/$customerId/japa-statistics',
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        print('Ошибка получения статистики сессий: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Ошибка при получении статистики сессий: $e');
      return null;
    }
  }

  /// Синхронизация локальных сессий с Magento
  Future<bool> syncLocalSessionsWithMagento(
    List<JapaSessionPurchase> localSessions,
    String customerId,
  ) async {
    if (!isCloudAvailable) {
      print('Облачные функции недоступны для синхронизации сессий');
      return false;
    }

    try {
      // Получаем существующие сессии из Magento
      final existingSessions = await getJapaSessionHistory(customerId);
      final existingSessionIds = existingSessions
          .map((session) => session.sessionId)
          .toSet();

      // Фильтруем только новые сессии
      final newSessions = localSessions
          .where((session) => !existingSessionIds.contains(session.sessionId))
          .toList();

      // Сохраняем новые сессии
      bool allSuccess = true;
      for (final session in newSessions) {
        final success = await saveJapaSessionAsPurchase(session);
        if (!success) {
          allSuccess = false;
        }
      }

      return allSuccess;
    } catch (e) {
      print('Ошибка при синхронизации сессий: $e');
      return false;
    }
  }

  /// Получение достижений пользователя из Magento
  Future<List<Map<String, dynamic>>?> getCustomerAchievements(
    String customerId,
  ) async {
    if (!isCloudAvailable) {
      print('Облачные функции недоступны для получения достижений');
      return null;
    }

    try {
      final response = await _dio!.get(
        '/rest/V1/customers/$customerId/achievements',
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(
          response.data['achievements'] ?? [],
        );
      } else {
        print('Ошибка получения достижений: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Ошибка при получении достижений: $e');
      return null;
    }
  }

  /// Создание или обновление профиля пользователя в Magento
  Future<bool> createOrUpdateCustomerProfile({
    required String customerId,
    required String email,
    required String firstName,
    required String lastName,
    Map<String, dynamic>? japaPreferences,
  }) async {
    if (!isCloudAvailable) {
      print('Облачные функции недоступны для создания профиля');
      return false;
    }

    try {
      final customerData = {
        'customer': {
          'id': customerId,
          'email': email,
          'firstname': firstName,
          'lastname': lastName,
          'custom_attributes': [
            {
              'attribute_code': 'japa_preferences',
              'value': japaPreferences != null
                  ? japaPreferences.toString()
                  : '{}',
            },
            {'attribute_code': 'japa_practitioner', 'value': 'true'},
          ],
        },
      };

      final response = await _dio!.post(
        '/rest/V1/customers',
        data: customerData,
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Ошибка при создании/обновлении профиля: $e');
      return false;
    }
  }

  // ===== PROFILE MANAGEMENT METHODS =====

  /// Получение профиля текущего пользователя
  Future<UserProfile?> getCurrentUserProfile() async {
    if (!isCloudAvailable) {
      print('Облачные функции недоступны для получения профиля');
      return null;
    }

    try {
      final response = await _dio!.get('/rest/V1/customers/me');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        // Получаем дополнительные данные о статистике
        final stats = await _getUserStatistics(data['id'].toString());

        return UserProfile.fromJson({...data, 'statistics': stats?.toJson()});
      } else {
        print('Ошибка получения профиля: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Ошибка при получении профиля: $e');
      return null;
    }
  }

  /// Получение профиля пользователя по ID
  Future<UserProfile?> getUserProfile(String customerId) async {
    if (!isCloudAvailable) {
      print('Облачные функции недоступны для получения профиля');
      return null;
    }

    try {
      final response = await _dio!.get('/rest/V1/customers/$customerId');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        // Получаем дополнительные данные о статистике
        final stats = await _getUserStatistics(customerId);

        return UserProfile.fromJson({...data, 'statistics': stats?.toJson()});
      } else {
        print('Ошибка получения профиля: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Ошибка при получении профиля пользователя: $e');
      return null;
    }
  }

  /// Обновление профиля пользователя
  Future<UserProfile?> updateUserProfile(UserProfile profile) async {
    if (!isCloudAvailable) {
      print('Облачные функции недоступны для обновления профиля');
      return null;
    }

    try {
      final customerData = {
        'customer': {
          'id': profile.customerId,
          'email': profile.email,
          'firstname': profile.firstName,
          'lastname': profile.lastName,
          'custom_attributes': [
            if (profile.japaPreferences != null)
              {
                'attribute_code': 'japa_preferences',
                'value': profile.japaPreferences!.toJson().toString(),
              },
            if (profile.avatarUrl != null)
              {'attribute_code': 'avatar_url', 'value': profile.avatarUrl},
            if (profile.timezone != null)
              {'attribute_code': 'timezone', 'value': profile.timezone},
            if (profile.language != null)
              {'attribute_code': 'language', 'value': profile.language},
          ],
        },
      };

      final response = await _dio!.put(
        '/rest/V1/customers/${profile.customerId}',
        data: customerData,
      );

      if (response.statusCode == 200) {
        return UserProfile.fromJson(response.data);
      } else {
        print('Ошибка обновления профиля: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Ошибка при обновлении профиля: $e');
      return null;
    }
  }

  /// Обновление настроек джапы
  Future<bool> updateJapaPreferences(
    String customerId,
    JapaPreferences preferences,
  ) async {
    if (!isCloudAvailable) {
      print('Облачные функции недоступны для обновления настроек');
      return false;
    }

    try {
      final response = await _dio!.put(
        '/rest/V1/customers/$customerId/japa-preferences',
        data: preferences.toJson(),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Ошибка при обновлении настроек джапы: $e');
      return false;
    }
  }

  /// Получение статистики пользователя
  Future<UserStatistics?> _getUserStatistics(String customerId) async {
    try {
      final response = await _dio!.get(
        '/rest/V1/customers/$customerId/japa-statistics',
      );

      if (response.statusCode == 200) {
        return UserStatistics.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Ошибка при получении статистики: $e');
      return null;
    }
  }

  /// Регистрация нового пользователя
  Future<UserProfile?> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    if (!isCloudAvailable) {
      print('Облачные функции недоступны для регистрации');
      return null;
    }

    try {
      final customerData = {
        'customer': {
          'email': email,
          'firstname': firstName,
          'lastname': lastName,
        },
        'password': password,
      };

      final response = await _dio!.post(
        '/rest/V1/customers',
        data: customerData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Получаем токен для нового пользователя
        final tokenResponse = await _dio!.post(
          '/rest/V1/integration/customer/token',
          data: {'username': email, 'password': password},
        );

        if (tokenResponse.statusCode == 200) {
          final token = tokenResponse.data as String;

          // Обновляем токен в заголовках
          _accessToken = token;
          _dio!.options.headers['Authorization'] = 'Bearer $token';

          // Сохраняем токен
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('magento_access_token', token);
        }

        return UserProfile.fromJson(response.data);
      } else {
        print('Ошибка регистрации: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Ошибка при регистрации пользователя: $e');
      return null;
    }
  }

  /// Вход пользователя
  Future<UserProfile?> loginUser(String email, String password) async {
    if (!isCloudAvailable) {
      print('Облачные функции недоступны для входа');
      return null;
    }

    try {
      // Получаем токен
      final tokenResponse = await _dio!.post(
        '/rest/V1/integration/customer/token',
        data: {'username': email, 'password': password},
      );

      if (tokenResponse.statusCode == 200) {
        final token = tokenResponse.data as String;

        // Обновляем токен в заголовках
        _accessToken = token;
        _dio!.options.headers['Authorization'] = 'Bearer $token';

        // Сохраняем токен
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('magento_access_token', token);
        await prefs.setString('magento_user_email', email);

        // Получаем профиль пользователя
        return await getCurrentUserProfile();
      } else {
        print('Ошибка входа: ${tokenResponse.statusCode}');
        return null;
      }
    } catch (e) {
      print('Ошибка при входе пользователя: $e');
      return null;
    }
  }

  /// Выход пользователя
  Future<void> logoutUser() async {
    try {
      _accessToken = null;
      _dio?.options.headers.remove('Authorization');

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('magento_access_token');
      await prefs.remove('magento_user_email');

      print('Пользователь вышел из системы');
    } catch (e) {
      print('Ошибка при выходе: $e');
    }
  }

  /// Проверка авторизации пользователя
  Future<bool> isUserLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('magento_access_token');

      if (token != null && token.isNotEmpty) {
        _accessToken = token;
        _dio?.options.headers['Authorization'] = 'Bearer $token';
        return true;
      }
      return false;
    } catch (e) {
      print('Ошибка проверки авторизации: $e');
      return false;
    }
  }

  /// Обновление аватара пользователя
  Future<bool> updateAvatar(String customerId, String imageUrl) async {
    if (!isCloudAvailable) {
      print('Облачные функции недоступны для обновления аватара');
      return false;
    }

    try {
      final response = await _dio!.put(
        '/rest/V1/customers/$customerId/avatar',
        data: {'avatar_url': imageUrl},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Ошибка при обновлении аватара: $e');
      return false;
    }
  }

  /// Очистка ресурсов
  void dispose() {
    _dio?.close();
    _dio = null;
    // _flutterMagento = null;
    _isInitialized = false;
  }
}
