# 📋 Следующие шаги для запуска AI интеграции

## ✅ Что уже готово

- ✅ **Код полностью интегрирован**
  - LocalAIService для работы с моделью
  - JapaProvider отправляет каждую мантру к AI
  - Нативные плагины для Android и iOS
  - Настройки для максимальной нагрузки GPU

- ✅ **Документация создана**
  - `QUICKSTART.md` - быстрый старт
  - `AI_MODEL_SETUP.md` - подробная настройка модели
  - `INTEGRATION_SUMMARY.md` - технический отчет
  - `AI_INTEGRATION_README.md` - краткий обзор

- ✅ **Зависимости установлены**
  - Flutter пакеты обновлены
  - pubspec.yaml настроен
  - assets/models/ директория создана

## ⚠️ Что нужно сделать для работы AI

### Вариант A: Использовать готовую легковесную модель (РЕКОМЕНДУЕТСЯ)

Это самый простой способ быстро протестировать AI функционал:

```bash
# 1. Скачайте Llama-3.2-1B (~700 МБ)
cd /Users/anton/proj/APPLICATIONS/mahamantra
curl -L "https://huggingface.co/bartowski/Llama-3.2-1B-Instruct-GGUF/resolve/main/Llama-3.2-1B-Instruct-Q4_K_M.gguf" \
  -o assets/models/mozgach108-minimal-q4.gguf

# 2. Скомпилируйте нативные библиотеки (см. ниже)

# 3. Запустите
flutter run --release
```

**Преимущества:**
- ✅ Быстро скачивается
- ✅ Работает на большинстве устройств
- ✅ Хорошее качество
- ✅ Можно сразу тестировать

### Вариант B: Конвертировать mozgach108 из Ollama

Если вы хотите использовать именно вашу модель:

```bash
# 1. Установите llama.cpp
git clone https://github.com/ggerganov/llama.cpp
cd llama.cpp
make  # или cmake -B build && cmake --build build

# 2. Найдите модель Ollama
cat ~/.ollama/models/manifests/registry.ollama.ai/library/mozgach108-minimal/latest

# 3. Скопируйте blob (замените HASH на актуальный)
cp ~/.ollama/models/blobs/sha256-HASH mozgach108-original.gguf

# 4. Квантуйте для мобильных
./quantize mozgach108-original.gguf mozgach108-minimal-q4.gguf Q4_K_M

# 5. Скопируйте в проект
cp mozgach108-minimal-q4.gguf /Users/anton/proj/APPLICATIONS/mahamantra/assets/models/
```

Подробная инструкция: см. `AI_MODEL_SETUP.md`

## 🔧 Компиляция нативных библиотек

### Для Android:

**Вариант 1: Использовать предсобранные библиотеки (проще)**

```bash
# Скачайте готовые .so файлы llama.cpp для Android
# Их можно найти в релизах llama.cpp на GitHub

mkdir -p android/app/src/main/jniLibs/arm64-v8a
mkdir -p android/app/src/main/jniLibs/armeabi-v7a

# Скопируйте libllama.so и libllama_android.so в каждую архитектуру
```

**Вариант 2: Собрать самостоятельно**

```bash
cd llama.cpp
mkdir -p build-android
cd build-android

# Настройте Android NDK
export ANDROID_NDK=/path/to/android-ndk

cmake .. \
  -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake \
  -DANDROID_ABI=arm64-v8a \
  -DANDROID_PLATFORM=android-26 \
  -DLLAMA_VULKAN=ON

make
```

### Для iOS:

```bash
cd /Users/anton/proj/APPLICATIONS/mahamantra/ios

# Добавьте llama.cpp через CocoaPods или вручную
# Создайте или обновите Podfile:

echo "
platform :ios, '14.0'
use_frameworks!

target 'Runner' do
  # Добавьте llama.cpp
  pod 'llama.cpp', :git => 'https://github.com/ggerganov/llama.cpp.git', :branch => 'master'
end
" > Podfile

pod install
```

**Или соберите вручную:**

```bash
git clone https://github.com/ggerganov/llama.cpp
cd llama.cpp

# Соберите для iOS
cmake -B build-ios -G Xcode \
  -DCMAKE_SYSTEM_NAME=iOS \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=14.0 \
  -DLLAMA_METAL=ON

cmake --build build-ios --config Release
```

## 🧪 Тестирование

### Шаг 1: Запустите без модели (проверка базового функционала)

```bash
flutter run
```

В логах должно быть:
```
LocalAI: Модель не найдена. Требуется загрузка модели GGUF.
```

Приложение должно работать, но AI будет недоступен.

### Шаг 2: Добавьте модель и перезапустите

```bash
# После добавления модели в assets/models/
flutter clean
flutter run --release
```

В логах должно быть:
```
LocalAI: Модель найдена: /data/.../models/mozgach108-minimal-q4.gguf
LocalAI: Локальный AI сервис готов к работе
✅ Мантра #1 отправлена к AI (круг 1)
```

### Шаг 3: Проверьте статистику

В приложении проверьте настройки или добавьте отладочный код:

```dart
final stats = await Provider.of<JapaProvider>(context, listen: false)
    .getLocalAIStatistics();

print('AI инициализирован: ${stats['isInitialized']}');
print('Модель загружена: ${stats['isModelLoaded']}');
print('Мантр отправлено: ${stats['mantrasSent']}');
print('Мантр обработано: ${stats['mantrasProcessed']}');
```

## 📊 Проверка производительности

### Мониторинг GPU (Android):

```bash
# Во время работы приложения
adb shell dumpsys gfxinfo net.nativemind.mahamantra

# Мониторинг температуры
adb shell cat /sys/class/thermal/thermal_zone0/temp
```

### Мониторинг памяти:

```bash
adb shell dumpsys meminfo net.nativemind.mahamantra
```

## ⚡ Оптимизация для слабых устройств

Если приложение тормозит или падает:

### 1. Используйте меньшую модель

```bash
# TinyLlama (~600 МБ)
curl -L "https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf" \
  -o assets/models/mozgach108-minimal-q4.gguf
```

### 2. Уменьшите параметры в LocalAIService:

```dart
// lib/services/local_ai_service.dart

static const int _nThreads = 4;        // Вместо 8
static const int _nGpuLayers = 32;     // Вместо 99
static const int _contextSize = 2048;  // Вместо 4096
static const int _maxTokens = 256;     // Вместо 512
```

### 3. Включите опциональную отправку

Добавьте настройку в UI чтобы пользователь мог отключить AI:

```dart
// В настройках приложения
Switch(
  value: sendMantrasToAI,
  onChanged: (value) {
    Provider.of<JapaProvider>(context, listen: false)
        .setSendMantrasToAI(value);
  },
)
```

## 📱 Варианты развертывания

### A. Модель в APK/IPA (для моделей < 100 МБ)

Просто поместите модель в `assets/models/` и соберите.

**Ограничения:**
- Google Play: APK должен быть < 150 МБ (иначе expansion files)
- App Store: IPA может быть до 4 ГБ

### B. Загрузка при первом запуске (для больших моделей)

Разместите модель на вашем сервере и загружайте:

```dart
// Добавьте в LocalAIService
Future<void> downloadModel() async {
  final url = 'https://your-server.com/mozgach108-minimal-q4.gguf';
  // ... код загрузки (уже есть в LocalAIService)
}
```

### C. Гибридный подход

- Включите TinyLlama (~600 МБ) в APK
- Предложите загрузить mozgach108 для лучшего качества

## 🎯 Чек-лист готовности

- [ ] Модель скачана/сконвертирована
- [ ] Модель помещена в `assets/models/mozgach108-minimal-q4.gguf`
- [ ] Нативные библиотеки llama.cpp скомпилированы для Android/iOS
- [ ] Библиотеки помещены в `android/app/src/main/jniLibs/` (Android)
- [ ] Библиотеки добавлены в Xcode проект (iOS)
- [ ] `flutter pub get` выполнен успешно
- [ ] Приложение собирается без ошибок
- [ ] В логах видно "Модель найдена"
- [ ] В логах видно "Мантра отправлена к AI"
- [ ] Статистика показывает обработанные мантры

## 🚀 Запуск в продакшн

```bash
# Android
flutter build apk --release
# или
flutter build appbundle --release

# iOS
flutter build ipa --release
```

## 📚 Дополнительная помощь

- **Не работает модель**: см. "Решение проблем" в `AI_MODEL_SETUP.md`
- **Падает приложение**: уменьшите размер модели или параметры
- **Медленно работает**: используйте Q4_K_M квантизацию и меньшую модель
- **Компиляция llama.cpp**: см. документацию llama.cpp на GitHub

## 💡 Альтернативный путь (без llama.cpp)

Если компиляция llama.cpp слишком сложная, можно:

1. Временно отключить LocalAI
2. Использовать только облачный AI (Ollama на сервере)
3. Добавить llama.cpp позже

Приложение будет работать в любом случае!

---

**Харе Кришна! 🕉️**

*Готов помочь с конкретными шагами, если возникнут вопросы!*

