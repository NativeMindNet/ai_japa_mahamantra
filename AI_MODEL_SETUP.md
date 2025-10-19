# Установка AI модели mozgach108 для локального запуска на мобильном устройстве

Это руководство поможет вам подготовить и интегрировать модель mozgach108 для работы непосредственно на мобильном телефоне.

## 📋 Требования

### Минимальные требования к устройству:
- **Android**: версия 8.0+ (API 26+), 6+ ГБ RAM
- **iOS**: iPhone 12+ или iPad Pro, iOS 14+, 6+ ГБ RAM
- **Свободное место**: минимум 4-8 ГБ для модели

### Рекомендуемые устройства:
- **Android**: Snapdragon 8 Gen 2+, 8+ ГБ RAM (например, Samsung S23, Xiaomi 13 Pro)
- **iOS**: iPhone 14 Pro/15 Pro с 8 ГБ RAM

## 🔄 Шаг 1: Конвертация mozgach108 в формат GGUF

Модель mozgach108 нужно сконвертировать в квантованный GGUF формат для работы на мобильных устройствах.

### 1.1 Установите llama.cpp на компьютере

```bash
# Клонируем llama.cpp
git clone https://github.com/ggerganov/llama.cpp
cd llama.cpp

# Собираем на macOS/Linux
make

# Или на Windows (с CMake)
cmake -B build
cmake --build build --config Release
```

### 1.2 Найдите вашу модель mozgach108

Проверьте путь к модели Ollama:
```bash
ls -la ~/.ollama/models/manifests/registry.ollama.ai/library/mozgach108-minimal
```

Модель Ollama хранится в виде блобов. Найдите файл модели:
```bash
# Найдите SHA256 хэш из манифеста
cat ~/.ollama/models/manifests/registry.ollama.ai/library/mozgach108-minimal/latest

# Модель будет в одном из блобов
ls -lh ~/.ollama/models/blobs/
```

### 1.3 Конвертируйте модель в GGUF

Если модель в формате PyTorch/Safetensors:
```bash
cd llama.cpp

# Конвертация в FP16 GGUF
python3 convert.py /path/to/mozgach108-minimal --outfile mozgach108-minimal-f16.gguf --outtype f16

# Квантование для мобильных устройств (Q4_K_M - оптимальный баланс)
./quantize mozgach108-minimal-f16.gguf mozgach108-minimal-q4.gguf Q4_K_M
```

Если модель уже в GGUF формате Ollama:
```bash
# Найдите blob с моделью и скопируйте
cp ~/.ollama/models/blobs/sha256-XXXX mozgach108-minimal.gguf

# Квантуйте для оптимизации
./quantize mozgach108-minimal.gguf mozgach108-minimal-q4.gguf Q4_K_M
```

### Варианты квантования:

| Формат | Размер | Качество | RAM | Скорость | Рекомендация |
|--------|--------|----------|-----|----------|--------------|
| Q4_K_M | ~2-3 ГБ | Хорошее | 4-5 ГБ | Быстро | ✅ **Рекомендуется для мобильных** |
| Q5_K_M | ~3-4 ГБ | Отличное | 5-6 ГБ | Средне | Для топовых устройств |
| Q6_K | ~4-5 ГБ | Максимальное | 6-8 ГБ | Медленно | Только для iPad Pro/флагманов |
| Q8_0 | ~6-7 ГБ | Почти FP16 | 8+ ГБ | Очень медленно | Не рекомендуется |

**Рекомендация**: Используйте **Q4_K_M** - оптимальный баланс качества и производительности.

## 📱 Шаг 2: Интеграция модели в приложение

### 2.1 Добавьте модель в assets (для небольших моделей < 100 МБ)

```bash
# Создайте директорию assets/models
mkdir -p assets/models

# Скопируйте модель
cp mozgach108-minimal-q4.gguf assets/models/
```

Обновите `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/models/mozgach108-minimal-q4.gguf
```

⚠️ **Важно**: Если модель > 100 МБ, GitHub и Google Play могут отклонить приложение. В этом случае используйте загрузку при первом запуске (см. Шаг 2.2).

### 2.2 Загрузка модели при первом запуске (для больших моделей)

Разместите модель на облачном хранилище (Google Drive, Dropbox, собственный сервер):

```dart
// Добавьте в LocalAIService метод загрузки
Future<String?> downloadModel({
  required String url,
  required Function(double progress) onProgress,
}) async {
  try {
    final documentsDir = await getApplicationDocumentsDirectory();
    final modelFile = File('${documentsDir.path}/models/mozgach108-minimal-q4.gguf');
    
    if (await modelFile.exists()) {
      return modelFile.path; // Уже загружена
    }
    
    final dio = Dio();
    await dio.download(
      url,
      modelFile.path,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          onProgress(received / total);
        }
      },
    );
    
    return modelFile.path;
  } catch (e) {
    debugPrint('Ошибка загрузки модели: $e');
    return null;
  }
}
```

## 🔧 Шаг 3: Настройка нативных библиотек

### 3.1 Для Android

Добавьте llama.cpp как подмодуль или скачайте готовые бинарники:

```bash
cd android/app/src/main/jniLibs

# Скачайте или скомпилируйте llama.cpp для Android
# Нужны библиотеки для: arm64-v8a, armeabi-v7a, x86_64

# Структура:
# jniLibs/
#   arm64-v8a/
#     libllama.so
#     libllama_android.so
#   armeabi-v7a/
#     libllama.so
#     libllama_android.so
```

Обновите `android/app/build.gradle.kts`:
```kotlin
android {
    ndkVersion = "25.1.8937393"
    
    defaultConfig {
        ndk {
            abiFilters.addAll(listOf("arm64-v8a", "armeabi-v7a"))
        }
    }
}
```

### 3.2 Для iOS

Добавьте llama.cpp в проект:

```bash
cd ios
pod init # если еще нет Podfile

# Добавьте в Podfile:
# pod 'llama.cpp', :git => 'https://github.com/ggerganov/llama.cpp', :tag => 'b1600'

pod install
```

## ⚙️ Шаг 4: Настройки для максимальной производительности

### 4.1 Параметры модели в LocalAIService

Уже настроено в коде для **максимальной нагрузки GPU и качества**:

```dart
static const int _nThreads = 8;        // Все доступные ядра CPU
static const int _nGpuLayers = 99;     // Максимум слоев на GPU
static const int _contextSize = 4096;  // Большой контекст
static const double _temperature = 0.8; // Креативность ответов
static const double _topP = 0.95;      // Разнообразие
static const int _topK = 60;           // Качество выбора токенов
static const int _maxTokens = 512;     // Длина ответа
```

### 4.2 GPU ускорение

**Android (Vulkan)**:
- Автоматически используется если доступно
- Snapdragon 8+ Gen 1 и новее - отличная производительность
- Mali GPU - хорошая производительность

**iOS (Metal)**:
- Автоматически используется на всех iPhone
- A15+ (iPhone 13+) - оптимальная производительность
- A17 Pro (iPhone 15 Pro) - максимальная производительность

### 4.3 Оптимизация памяти

Добавьте в `AndroidManifest.xml`:
```xml
<application
    android:largeHeap="true"
    android:hardwareAccelerated="true">
</application>
```

Добавьте в `ios/Runner/Info.plist`:
```xml
<key>UIBackgroundModes</key>
<array>
    <string>processing</string>
</array>
```

## 🧪 Шаг 5: Тестирование

### 5.1 Проверка установки

Запустите приложение и проверьте логи:

```bash
# Android
adb logcat | grep LocalAI

# iOS  
# В Xcode смотрите Console

# Ожидаемые сообщения:
# ✅ Модель найдена: /path/to/model.gguf
# ✅ Локальный AI сервис готов к работе
# ✅ Мантра #1 отправлена к AI (круг 1)
```

### 5.2 Мониторинг производительности

Проверьте статистику AI:

```dart
final stats = await Provider.of<JapaProvider>(context, listen: false)
    .getLocalAIStatistics();

print('Мантр отправлено: ${stats['mantrasSent']}');
print('Мантр обработано: ${stats['mantrasProcessed']}');
print('Модель: ${stats['modelPath']}');
```

## 📊 Ожидаемая производительность

### Скорость генерации (токенов/сек):

| Устройство | Q4_K_M | Q5_K_M | Q6_K |
|------------|--------|--------|------|
| iPhone 15 Pro (A17) | 15-20 | 10-15 | 8-12 |
| iPhone 14 Pro (A16) | 12-18 | 8-12 | 6-10 |
| Samsung S23 (SD 8 Gen 2) | 10-15 | 7-10 | 5-8 |
| Xiaomi 13 Pro (SD 8 Gen 2) | 10-15 | 7-10 | 5-8 |
| Бюджетные устройства | 3-7 | 2-5 | - |

### Задержка на бусину:
- **Быстрая обработка**: 50-200 мс (не блокирует UI)
- **Полная генерация**: 2-10 секунд в фоне
- **Параллельная обработка**: до 108 мантр за круг

## 🔧 Альтернативные модели

Если mozgach108 слишком большая или не подходит:

### Рекомендуемые легковесные модели:

1. **TinyLlama-1.1B-Chat** (~600 МБ Q4_K_M)
   - Очень быстрая
   - Работает на любых устройствах
   - Качество среднее

2. **Phi-3-mini** (~2.3 ГБ Q4_K_M)
   - Отличное качество
   - Microsoft модель
   - Хорошо понимает русский

3. **Gemma-2B** (~1.5 ГБ Q4_K_M)
   - Google модель
   - Хорошее качество
   - Быстрая

4. **Llama-3.2-1B** (~700 МБ Q4_K_M)
   - Meta модель
   - Отличное качество/скорость
   - **Рекомендуется как альтернатива**

### Конвертация альтернативной модели:

```bash
# Скачать с Hugging Face
git lfs install
git clone https://huggingface.co/meta-llama/Llama-3.2-1B-Instruct

# Конвертировать
python3 llama.cpp/convert.py Llama-3.2-1B-Instruct --outtype f16
./llama.cpp/quantize Llama-3.2-1B-Instruct/ggml-model-f16.gguf llama-3.2-1b-q4.gguf Q4_K_M

# Переименовать для использования в приложении
mv llama-3.2-1b-q4.gguf assets/models/mozgach108-minimal-q4.gguf
```

## 🐛 Решение проблем

### Проблема: "Модель не найдена"
**Решение**: 
- Проверьте что модель в `assets/models/`
- Проверьте `pubspec.yaml` 
- Выполните `flutter clean && flutter pub get`

### Проблема: "MODEL_NOT_LOADED"
**Решение**:
- Проверьте размер модели (должна быть < 8 ГБ)
- Проверьте доступную RAM на устройстве
- Попробуйте более легкую квантизацию (Q4_K_M)

### Проблема: Медленная генерация
**Решение**:
- Уменьшите `_nGpuLayers` если GPU слабое
- Используйте более агрессивную квантизацию
- Уменьшите `_maxTokens`

### Проблема: Приложение крашится
**Решение**:
- Увеличьте heap size в AndroidManifest.xml
- Уменьшите `_contextSize` до 2048
- Используйте меньшую модель

## 📚 Полезные ссылки

- [llama.cpp GitHub](https://github.com/ggerganov/llama.cpp)
- [GGUF модели на Hugging Face](https://huggingface.co/models?library=gguf)
- [Квантизация моделей](https://github.com/ggerganov/llama.cpp/blob/master/examples/quantize/README.md)
- [llama.cpp для Android](https://github.com/ggerganov/llama.cpp/tree/master/examples/llama.android)

## ✅ Проверочный список

- [ ] Модель сконвертирована в GGUF формат
- [ ] Модель квантована (Q4_K_M рекомендуется)
- [ ] Модель добавлена в `assets/models/` или настроена загрузка
- [ ] Нативные библиотеки llama.cpp скомпилированы/добавлены
- [ ] `pubspec.yaml` обновлен с путями к assets
- [ ] Плагин зарегистрирован в MainActivity/AppDelegate
- [ ] Приложение собрано и протестировано на реальном устройстве
- [ ] Проверена отправка мантр в логах
- [ ] Проверена статистика LocalAI

## 🎯 Итоговая интеграция

После выполнения всех шагов ваше приложение будет:

✅ Отправлять каждую прочитанную мантру к AI модели на устройстве
✅ Максимально использовать GPU для обработки
✅ Работать полностью офлайн
✅ Обрабатывать до 108 мантр за круг в фоновом режиме
✅ Не блокировать интерфейс приложения

**Харе Кришна! 🕉️**

