#!/bin/bash

# Скрипт для автоматической публикации в Apple App Store
# Автор: AI Assistant
# Дата: $(date)

set -e

echo "🚀 Начинаем автоматическую публикацию в Apple App Store..."

# Проверяем, что мы в корневой директории проекта
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Ошибка: Запустите скрипт из корневой директории проекта"
    exit 1
fi

# Проверяем наличие необходимых инструментов
if ! command -v flutter &> /dev/null; then
    echo "❌ Ошибка: Flutter не установлен или не добавлен в PATH"
    exit 1
fi

if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Ошибка: Xcode не установлен или не добавлен в PATH"
    exit 1
fi

# Проверяем наличие Apple Developer Account
if [ -z "$APPLE_ID" ]; then
    echo "❌ Ошибка: Не установлена переменная окружения APPLE_ID"
    echo "Установите: export APPLE_ID='your-apple-id@example.com'"
    exit 1
fi

if [ -z "$APPLE_PASSWORD" ]; then
    echo "❌ Ошибка: Не установлена переменная окружения APPLE_PASSWORD"
    echo "Установите: export APPLE_PASSWORD='your-app-specific-password'"
    exit 1
fi

# Проверяем наличие Team ID
if [ -z "$TEAM_ID" ]; then
    echo "❌ Ошибка: Не установлена переменная окружения TEAM_ID"
    echo "Установите: export TEAM_ID='your-team-id'"
    exit 1
fi

echo "📱 Версия Flutter: $(flutter --version | head -n 1)"
echo "🍎 Apple ID: $APPLE_ID"
echo "👥 Team ID: $TEAM_ID"

# Очищаем предыдущие сборки
echo "🧹 Очищаем предыдущие сборки..."
flutter clean

# Получаем зависимости
echo "📦 Получаем зависимости..."
flutter pub get

# Проверяем код
echo "🔍 Проверяем код..."
flutter analyze

# Собираем приложение для iOS
echo "🏗️ Собираем приложение для iOS..."
flutter build ios --release

# Создаем архив
echo "📦 Создаем архив..."
cd ios
xcodebuild -workspace Runner.xcworkspace \
           -scheme Runner \
           -configuration Release \
           -destination generic/platform=iOS \
           -archivePath build/Runner.xcarchive \
           archive

# Экспортируем для App Store
echo "📤 Экспортируем для App Store..."
xcodebuild -exportArchive \
           -archivePath build/Runner.xcarchive \
           -exportPath build/AppStore \
           -exportOptionsPlist exportOptions.plist

cd ..

# Создаем exportOptions.plist если его нет
if [ ! -f "ios/exportOptions.plist" ]; then
    echo "📝 Создаем exportOptions.plist..."
    cat > ios/exportOptions.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>$TEAM_ID</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
    <key>manageAppVersionAndBuildNumber</key>
    <true/>
</dict>
</plist>
EOF
fi

# Загружаем в App Store Connect
echo "🚀 Загружаем в App Store Connect..."
xcrun altool --upload-app \
             --type ios \
             --file ios/build/AppStore/Runner.ipa \
             --username "$APPLE_ID" \
             --password "$APPLE_PASSWORD"

echo "✅ Приложение успешно загружено в App Store Connect!"
echo ""
echo "📋 Следующие шаги:"
echo "1. Перейдите в App Store Connect: https://appstoreconnect.apple.com"
echo "2. Найдите ваше приложение 'Ai Japa Mahamantra'"
echo "3. Заполните метаданные (описание, скриншоты, ключевые слова)"
echo "4. Отправьте на проверку Apple"
echo ""
echo "🔗 Полезные ссылки:"
echo "   - App Store Connect: https://appstoreconnect.apple.com"
echo "   - Руководство по публикации: https://developer.apple.com/app-store/review/guidelines/"
echo ""
echo "🎉 Публикация завершена!"
