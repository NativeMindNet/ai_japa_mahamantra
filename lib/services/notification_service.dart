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
    );
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.show(
      roundNumber,
      'Круг $roundNumber завершен! 🎉',
      'Продолжайте практику. Осталось ${totalRounds - roundNumber} кругов.',
      details,
      payload: 'round_complete',
    );
  }
  
  /// Показывает уведомление о завершении сессии
  static Future<void> showSessionComplete({
    required int completedRounds,
    required Duration sessionDuration,
  }) async {
    if (!_isInitialized) return;
    
    const androidDetails = AndroidNotificationDetails(
      'japa_session_channel',
      'Сессии джапы',
      channelDescription: 'Уведомления о завершении сессий джапы',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('session_complete'),
      icon: '@mipmap/ic_launcher',
      color: Color(AppConstants.successColor),
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'session_complete.wav',
    );
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    final minutes = sessionDuration.inMinutes;
    final seconds = sessionDuration.inSeconds % 60;
    
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'Сессия завершена! 🕉️',
      'Вы завершили $completedRounds кругов за ${minutes}м ${seconds}с. Харе Кришна!',
      details,
      payload: 'session_complete',
    );
  }
  
  /// Показывает уведомление о времени для джапы
  static Future<void> showJapaTimeReminder() async {
    if (!_isInitialized) return;
    
    const androidDetails = AndroidNotificationDetails(
      'japa_time_channel',
      'Время джапы',
      channelDescription: 'Напоминания о времени для практики джапы',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('mantra_bell'),
      icon: '@mipmap/ic_launcher',
      color: Color(AppConstants.primaryColor),
      ongoing: false,
      autoCancel: true,
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
      'Время для джапы! 🕉️',
      'Пришло время для духовной практики. Откройте приложение и начните сессию.',
      details,
      payload: 'japa_time',
    );
  }
  
  /// Планирует ежедневное напоминание
  static Future<void> scheduleDailyReminder({
    required Time time,
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
      color: Color(AppConstants.primaryColor),
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
    
    await _notifications.zonedSchedule(
      1, // ID уведомления
      title,
      body,
      _nextInstanceOfTime(time),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: 
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
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
  static DateTime _nextInstanceOfTime(Time time) {
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
      time.second,
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
    
    return (androidEnabled ?? false) || (iosEnabled?.alert ?? false);
  }
}
