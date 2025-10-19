import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../services/magento_service.dart';

/// Провайдер для управления состоянием профиля пользователя
class ProfileProvider with ChangeNotifier {
  final MagentoService _magentoService = MagentoService();

  UserProfile? _currentProfile;
  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;

  UserProfile? get currentProfile => _currentProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;

  /// Инициализация провайдера
  Future<void> initialize() async {
    _isLoggedIn = await _magentoService.isUserLoggedIn();
    if (_isLoggedIn) {
      await loadCurrentProfile();
    }
  }

  /// Загрузка профиля текущего пользователя
  Future<void> loadCurrentProfile() async {
    if (!_magentoService.isCloudAvailable) {
      _error = 'Облачные функции недоступны';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentProfile = await _magentoService.getCurrentUserProfile();
      _isLoggedIn = _currentProfile != null;
      _error = null;
    } catch (e) {
      _error = 'Ошибка загрузки профиля: $e';
      _isLoggedIn = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Обновление профиля
  Future<bool> updateProfile(UserProfile profile) async {
    if (!_magentoService.isCloudAvailable) {
      _error = 'Облачные функции недоступны';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedProfile = await _magentoService.updateUserProfile(profile);
      if (updatedProfile != null) {
        _currentProfile = updatedProfile;
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = 'Не удалось обновить профиль';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Ошибка обновления профиля: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Обновление настроек джапы
  Future<bool> updateJapaPreferences(JapaPreferences preferences) async {
    if (_currentProfile == null) {
      _error = 'Профиль не загружен';
      notifyListeners();
      return false;
    }

    if (!_magentoService.isCloudAvailable) {
      _error = 'Облачные функции недоступны';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _magentoService.updateJapaPreferences(
        _currentProfile!.customerId,
        preferences,
      );

      if (success) {
        _currentProfile = _currentProfile!.copyWith(
          japaPreferences: preferences,
        );
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = 'Не удалось обновить настройки';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Ошибка обновления настроек: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Регистрация нового пользователя
  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    if (!_magentoService.isCloudAvailable) {
      _error = 'Облачные функции недоступны';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentProfile = await _magentoService.registerUser(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      if (_currentProfile != null) {
        _isLoggedIn = true;
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = 'Ошибка регистрации';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Ошибка регистрации: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Вход пользователя
  Future<bool> login(String email, String password) async {
    if (!_magentoService.isCloudAvailable) {
      _error = 'Облачные функции недоступны';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentProfile = await _magentoService.loginUser(email, password);

      if (_currentProfile != null) {
        _isLoggedIn = true;
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = 'Неверный email или пароль';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Ошибка входа: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Выход пользователя
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _magentoService.logoutUser();
      _currentProfile = null;
      _isLoggedIn = false;
      _error = null;
    } catch (e) {
      _error = 'Ошибка выхода: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Обновление аватара
  Future<bool> updateAvatar(String imageUrl) async {
    if (_currentProfile == null) {
      _error = 'Профиль не загружен';
      notifyListeners();
      return false;
    }

    if (!_magentoService.isCloudAvailable) {
      _error = 'Облачные функции недоступны';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _magentoService.updateAvatar(
        _currentProfile!.customerId,
        imageUrl,
      );

      if (success) {
        _currentProfile = _currentProfile!.copyWith(avatarUrl: imageUrl);
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = 'Не удалось обновить аватар';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Ошибка обновления аватара: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Очистка ошибки
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
