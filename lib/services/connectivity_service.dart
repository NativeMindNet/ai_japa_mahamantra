import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Сервис для проверки подключения к интернету
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  bool _isOnline = false;
  bool get isOnline => _isOnline;

  final StreamController<bool> _connectivityController =
      StreamController<bool>.broadcast();
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Инициализация сервиса
  Future<void> initialize() async {
    // Проверяем текущее состояние подключения
    await _checkConnectivity();

    // Подписываемся на изменения подключения
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      _updateConnectivityStatus(results);
    });
  }

  /// Проверка текущего состояния подключения
  Future<void> _checkConnectivity() async {
    try {
      final List<ConnectivityResult> results = await _connectivity
          .checkConnectivity();
      _updateConnectivityStatus(results);
    } catch (e) {
      _isOnline = false;
      _connectivityController.add(false);
    }
  }

  /// Обновление статуса подключения
  void _updateConnectivityStatus(List<ConnectivityResult> results) {
    final bool wasOnline = _isOnline;

    // Проверяем, есть ли хотя бы одно активное подключение
    _isOnline = results.any(
      (result) =>
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet,
    );

    // Уведомляем слушателей только при изменении статуса
    if (wasOnline != _isOnline) {
      _connectivityController.add(_isOnline);
    }
  }

  /// Принудительная проверка подключения
  Future<bool> checkConnection() async {
    await _checkConnectivity();
    return _isOnline;
  }

  /// Освобождение ресурсов
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityController.close();
  }
}
