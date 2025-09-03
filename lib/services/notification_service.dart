import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  
  static bool _isInitialized = false;
  
  /// Инициализация сервиса уведомлений
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    _isInitialized = true;
  }
  
  /// Показывает уведомление о напоминании джапы
  static Future<void> showJapaReminder({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) return;
    
    const androidDetails = AndroidNotificationDetails(
      'japa_reminder_channel',
      'Напоминания о джапе',
      channelDescription: 'Уведомления о времени для практики джапы',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('mantra_bell'),
      icon: '@mipmap/ic_launcher',
      color: Color(AppConstants.primaryColor),
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'mantra_bell.wav',
    );
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }
  
  /// Показывает уведомление о завершении круга
  static Future<void> showRoundComplete({
    required int roundNumber,
    required int totalRounds,
  }) async {
    if (!_isInitialized) return;
    
    const androidDetails = AndroidNotificationDetails(
      'japa_progress_channel',
      'Прогресс джапы',
      channelDescription: 'Уведомления о прогрессе в джапе',
      importance: Importance.medium,
      priority: Priority.medium,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
      color: Color(AppConstants.successColor),
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: true,
      sound: 'mantra_bell.wav',
    );
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.show(
      2, // ID уведомления
      'Круг завершен!',
      'Вы завершили круг $roundNumber из $totalRounds',
      details,
      payload: 'round_complete',
    );
  }
  
  /// Показывает уведомление о завершении сессии
  static Future<void> showSessionComplete({
    required int totalRounds,
    required Duration duration,
  }) async {
    if (!_isInitialized) return;
    
    const androidDetails = AndroidNotificationDetails(
      'japa_session_channel',
      'Завершение сессии',
      channelDescription: 'Уведомления о завершении сессии джапы',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
      color: Color(AppConstants.successColor),
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'mantra_bell.wav',
    );
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    
    await _notifications.show(
      3, // ID уведомления
      'Сессия завершена!',
      'Вы завершили $totalRounds кругов за ${minutes}м ${seconds}с',
      details,
      payload: 'japa_time',
    );
  }
  
  /// Планирует ежедневное напоминание
  static Future<void> scheduleDailyReminder({
    required TimeOfDay time,
    required String title,
    required String body,
  }) async {
    if (!_isInitialized) return;
    
    const androidDetails = AndroidNotificationDetails(
      'japa_daily_channel',
      'Ежедневные напоминания',
      channelDescription: 'Ежедневные напоминания о джапе',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
      color: Colors.blue,
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.show(
      1, // ID уведомления
      title,
      body,
      details,
    );
  }
  
  /// Отменяет все уведомления
  static Future<void> cancelAll() async {
    if (!_isInitialized) return;
    await _notifications.cancelAll();
  }
  
  /// Отменяет конкретное уведомление
  static Future<void> cancel(int id) async {
    if (!_isInitialized) return;
    await _notifications.cancel(id);
  }
  
  /// Обработчик нажатия на уведомление
  static void _onNotificationTapped(NotificationResponse response) {
    // Здесь можно добавить логику для обработки нажатий на уведомления
    print('Уведомление нажато: ${response.payload}');
  }
  
  /// Вычисляет следующее время для уведомления
  static DateTime _nextInstanceOfTime(TimeOfDay time) {
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }
  
  /// Проверяет разрешения на уведомления
  static Future<bool> areNotificationsEnabled() async {
    if (!_isInitialized) return false;
    
    final androidEnabled = await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled();
    
    final iosEnabled = await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    
    return (androidEnabled ?? false) || (iosEnabled ?? false);
  }
}
