import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:shared_preferences/shared_preferences.dart';

/// Сервис для работы с шифрованными логами
/// Реализует хранение логов для Правила № 1 и № 3
class EncryptedLogService {
  static EncryptedLogService? _instance;
  
  late encrypt.Encrypter _encrypter;
  late encrypt.IV _iv;
  bool _isInitialized = false;
  
  // Типы логов
  static const String logTypeHighPower = 'high_power_108';
  static const String logTypeLowPower = 'low_power_108';
  static const String logTypeGeneral = 'general';
  
  EncryptedLogService._();
  
  /// Получить singleton экземпляр
  static EncryptedLogService get instance {
    _instance ??= EncryptedLogService._();
    return _instance!;
  }
  
  /// Инициализация сервиса шифрования
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Получаем или создаем ключ шифрования
      final key = await _getOrCreateEncryptionKey();
      final keyBytes = encrypt.Key.fromUtf8(key);
      
      // Создаем IV (initialization vector)
      _iv = encrypt.IV.fromLength(16);
      
      // Инициализируем шифровальщик с AES
      _encrypter = encrypt.Encrypter(encrypt.AES(keyBytes));
      
      _isInitialized = true;
      debugPrint('EncryptedLogService инициализирован');
    } catch (e) {
      debugPrint('Ошибка инициализации EncryptedLogService: $e');
    }
  }
  
  /// Получает или создает ключ шифрования
  Future<String> _getOrCreateEncryptionKey() async {
    final prefs = await SharedPreferences.getInstance();
    String? key = prefs.getString('encryption_key');
    
    if (key == null) {
      // Генерируем новый ключ на основе уникального ID устройства
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final randomData = '$timestamp-mahamantra-108-secret';
      
      // Хэшируем для получения 32-байтового ключа
      final bytes = utf8.encode(randomData);
      final digest = sha256.convert(bytes);
      key = digest.toString().substring(0, 32);
      
      // Сохраняем ключ
      await prefs.setString('encryption_key', key);
      debugPrint('Создан новый ключ шифрования');
    }
    
    return key;
  }
  
  /// Шифрует текст
  String _encrypt(String plainText) {
    if (!_isInitialized) {
      throw Exception('EncryptedLogService не инициализирован');
    }
    
    final encrypted = _encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }
  
  /// Расшифровывает текст
  String _decrypt(String encryptedText) {
    if (!_isInitialized) {
      throw Exception('EncryptedLogService не инициализирован');
    }
    
    final encrypted = encrypt.Encrypted.fromBase64(encryptedText);
    return _encrypter.decrypt(encrypted, iv: _iv);
  }
  
  /// Добавляет запись в лог
  Future<void> addLogEntry({
    required String logType,
    required String message,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final timestamp = DateTime.now().toIso8601String();
      
      final entry = {
        'timestamp': timestamp,
        'type': logType,
        'message': message,
        'metadata': metadata ?? {},
      };
      
      final jsonEntry = jsonEncode(entry);
      final encryptedEntry = _encrypt(jsonEntry);
      
      // Сохраняем в файл
      final file = await _getLogFile(logType);
      await file.writeAsString(
        '$encryptedEntry\n',
        mode: FileMode.append,
      );
      
      debugPrint('Лог запись добавлена: $logType');
    } catch (e) {
      debugPrint('Ошибка добавления лог записи: $e');
    }
  }
  
  /// Добавляет лог для обработки мантры через AI модель
  Future<void> addMantraProcessingLog({
    required int modelNumber,
    required String modelName,
    required String mantra,
    required String response,
    required int processingTimeMs,
    required int beadNumber,
    required int roundNumber,
  }) async {
    await addLogEntry(
      logType: logTypeHighPower,
      message: 'Мантра обработана моделью #$modelNumber',
      metadata: {
        'model_number': modelNumber,
        'model_name': modelName,
        'mantra': mantra,
        'response': response,
        'processing_time_ms': processingTimeMs,
        'bead_number': beadNumber,
        'round_number': roundNumber,
      },
    );
  }
  
  /// Добавляет лог для Low Power режима
  Future<void> addLowPowerCycleLog({
    required int cycleNumber,
    required int mantrasCount,
    required String accumulatedText,
    required int textLength,
  }) async {
    await addLogEntry(
      logType: logTypeLowPower,
      message: 'Цикл Low Power завершен',
      metadata: {
        'cycle_number': cycleNumber,
        'mantras_count': mantrasCount,
        'accumulated_text': accumulatedText,
        'text_length': textLength,
      },
    );
  }
  
  /// Получает файл лога для типа
  Future<File> _getLogFile(String logType) async {
    final dir = await getApplicationDocumentsDirectory();
    final logsDir = Directory('${dir.path}/encrypted_logs');
    
    if (!await logsDir.exists()) {
      await logsDir.create(recursive: true);
    }
    
    return File('${logsDir.path}/$logType.log');
  }
  
  /// Читает все логи определенного типа
  Future<List<Map<String, dynamic>>> readLogs(String logType) async {
    try {
      final file = await _getLogFile(logType);
      
      if (!await file.exists()) {
        return [];
      }
      
      final encryptedLines = await file.readAsLines();
      final logs = <Map<String, dynamic>>[];
      
      for (final encryptedLine in encryptedLines) {
        if (encryptedLine.trim().isEmpty) continue;
        
        try {
          final decrypted = _decrypt(encryptedLine);
          final entry = jsonDecode(decrypted) as Map<String, dynamic>;
          logs.add(entry);
        } catch (e) {
          debugPrint('Ошибка расшифровки записи: $e');
        }
      }
      
      return logs;
    } catch (e) {
      debugPrint('Ошибка чтения логов: $e');
      return [];
    }
  }
  
  /// Получает все логи High Power (108 моделей)
  Future<List<Map<String, dynamic>>> getHighPowerLogs() async {
    return await readLogs(logTypeHighPower);
  }
  
  /// Получает все логи Low Power
  Future<List<Map<String, dynamic>>> getLowPowerLogs() async {
    return await readLogs(logTypeLowPower);
  }
  
  /// Получает общие логи
  Future<List<Map<String, dynamic>>> getGeneralLogs() async {
    return await readLogs(logTypeGeneral);
  }
  
  /// Получает все типы логов
  Future<Map<String, List<Map<String, dynamic>>>> getAllLogs() async {
    return {
      'high_power': await getHighPowerLogs(),
      'low_power': await getLowPowerLogs(),
      'general': await getGeneralLogs(),
    };
  }
  
  /// Получает статистику логов
  Future<Map<String, int>> getLogsStatistics() async {
    final highPower = await getHighPowerLogs();
    final lowPower = await getLowPowerLogs();
    final general = await getGeneralLogs();
    
    return {
      'high_power_count': highPower.length,
      'low_power_count': lowPower.length,
      'general_count': general.length,
      'total_count': highPower.length + lowPower.length + general.length,
    };
  }
  
  /// Экспортирует логи в читаемом формате (для Easter Egg)
  Future<String> exportLogsAsText(String logType) async {
    final logs = await readLogs(logType);
    final buffer = StringBuffer();
    
    buffer.writeln('=' * 60);
    buffer.writeln('MAHAMANTRA - ENCRYPTED LOGS');
    buffer.writeln('Log Type: $logType');
    buffer.writeln('Exported: ${DateTime.now().toIso8601String()}');
    buffer.writeln('Total Entries: ${logs.length}');
    buffer.writeln('=' * 60);
    buffer.writeln();
    
    for (int i = 0; i < logs.length; i++) {
      final entry = logs[i];
      buffer.writeln('Entry #${i + 1}');
      buffer.writeln('Timestamp: ${entry['timestamp']}');
      buffer.writeln('Message: ${entry['message']}');
      
      final metadata = entry['metadata'] as Map<String, dynamic>?;
      if (metadata != null && metadata.isNotEmpty) {
        buffer.writeln('Metadata:');
        metadata.forEach((key, value) {
          buffer.writeln('  $key: $value');
        });
      }
      
      buffer.writeln('-' * 60);
      buffer.writeln();
    }
    
    return buffer.toString();
  }
  
  /// Очищает логи определенного типа
  Future<void> clearLogs(String logType) async {
    try {
      final file = await _getLogFile(logType);
      
      if (await file.exists()) {
        await file.delete();
        debugPrint('Логи типа $logType очищены');
      }
    } catch (e) {
      debugPrint('Ошибка очистки логов: $e');
    }
  }
  
  /// Очищает все логи
  Future<void> clearAllLogs() async {
    await clearLogs(logTypeHighPower);
    await clearLogs(logTypeLowPower);
    await clearLogs(logTypeGeneral);
    debugPrint('Все логи очищены');
  }
  
  /// Получает размер логов в байтах
  Future<Map<String, int>> getLogsSizeInBytes() async {
    final sizes = <String, int>{};
    
    for (final type in [logTypeHighPower, logTypeLowPower, logTypeGeneral]) {
      final file = await _getLogFile(type);
      if (await file.exists()) {
        sizes[type] = await file.length();
      } else {
        sizes[type] = 0;
      }
    }
    
    sizes['total'] = sizes.values.reduce((a, b) => a + b);
    
    return sizes;
  }
}


