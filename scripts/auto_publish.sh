#!/bin/bash

# Главный скрипт для автоматической публикации в Apple App Store
# Автор: AI Assistant
# Дата: $(date)

set -e

echo "🚀 АВТОМАТИЧЕСКАЯ ПУБЛИКАЦИЯ В APPLE APP STORE"
echo "=============================================="

# Проверяем наличие конфигурационного файла
if [ ! -f "app_store_config.env" ]; then
    echo "❌ Ошибка: Файл app_store_config.env не найден"
    echo "Создайте файл app_store_config.env на основе app_store_config.env"
    exit 1
fi

# Загружаем переменные окружения
source app_store_config.env

# Проверяем обязательные переменные
if [ -z "$APPLE_ID" ] || [ "$APPLE_ID" = "your-apple-id@example.com" ]; then
    echo "❌ Ошибка: Не установлен APPLE_ID в app_store_config.env"
    exit 1
fi

if [ -z "$APPLE_PASSWORD" ] || [ "$APPLE_PASSWORD" = "your-app-specific-password" ]; then
    echo "❌ Ошибка: Не установлен APPLE_PASSWORD в app_store_config.env"
    exit 1
fi

if [ -z "$TEAM_ID" ] || [ "$TEAM_ID" = "your-team-id" ]; then
    echo "❌ Ошибка: Не установлен TEAM_ID в app_store_config.env"
    exit 1
fi

echo "📱 Настройки публикации:"
echo "   Apple ID: $APPLE_ID"
echo "   Team ID: $TEAM_ID"
echo "   Bundle ID: $BUNDLE_ID"
echo "   App Name: $APP_NAME"
echo ""

# Экспортируем переменные для дочерних скриптов
export APPLE_ID
export APPLE_PASSWORD
export TEAM_ID
export BUNDLE_ID
export APP_NAME
export SKU
export PRIMARY_LANGUAGE

# Шаг 1: Создаем приложение в App Store Connect
echo "🍎 Шаг 1: Создание приложения в App Store Connect..."
if [ -f "scripts/create_app_store_connect_app.sh" ]; then
    chmod +x scripts/create_app_store_connect_app.sh
    ./scripts/create_app_store_connect_app.sh
else
    echo "⚠️  Скрипт создания приложения не найден, пропускаем..."
fi

# Шаг 2: Публикуем приложение
echo "📤 Шаг 2: Публикация приложения..."
if [ -f "scripts/publish_to_app_store.sh" ]; then
    chmod +x scripts/publish_to_app_store.sh
    ./scripts/publish_to_app_store.sh
else
    echo "❌ Скрипт публикации не найден!"
    exit 1
fi

echo ""
echo "🎉 АВТОМАТИЧЕСКАЯ ПУБЛИКАЦИЯ ЗАВЕРШЕНА!"
echo "======================================"
echo ""
echo "📋 Что было сделано:"
echo "✅ Bundle ID изменен на: $BUNDLE_ID"
echo "✅ Приложение собрано для iOS"
echo "✅ Архив создан"
echo "✅ Приложение загружено в App Store Connect"
echo ""
echo "📱 Следующие шаги в App Store Connect:"
echo "1. Перейдите в https://appstoreconnect.apple.com"
echo "2. Найдите приложение '$APP_NAME'"
echo "3. Заполните метаданные:"
echo "   - Описание: $DESCRIPTION"
echo "   - Ключевые слова: $KEYWORDS"
echo "   - Категория: $CATEGORY"
echo "   - Возрастной рейтинг: $AGE_RATING"
echo "4. Загрузите скриншоты (минимум 3 для iPhone)"
echo "5. Отправьте на проверку Apple"
echo ""
echo "⏱️  Время проверки: 24-48 часов"
echo "📧 Уведомления придут на: $APPLE_ID"
echo ""
echo "🔗 Полезные ссылки:"
echo "   - App Store Connect: https://appstoreconnect.apple.com"
echo "   - Apple Developer: https://developer.apple.com"
echo "   - Руководство по публикации: https://developer.apple.com/app-store/review/guidelines/"
echo ""
echo "🎊 Удачи с публикацией!"
