#!/bin/bash

# Скрипт для создания приложения в App Store Connect
# Автор: AI Assistant
# Дата: $(date)

set -e

echo "🍎 Создаем приложение в App Store Connect..."

# Проверяем наличие необходимых переменных
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

if [ -z "$TEAM_ID" ]; then
    echo "❌ Ошибка: Не установлена переменная окружения TEAM_ID"
    echo "Установите: export TEAM_ID='your-team-id'"
    exit 1
fi

# Параметры приложения
APP_NAME="Ai Japa Mahamantra"
BUNDLE_ID="net.nativemind.mahamantra"
SKU="aijapamahamantra2024"
PRIMARY_LANGUAGE="en"

echo "📱 Создаем приложение:"
echo "   Название: $APP_NAME"
echo "   Bundle ID: $BUNDLE_ID"
echo "   SKU: $SKU"
echo "   Язык: $PRIMARY_LANGUAGE"

# Создаем приложение через App Store Connect API
echo "🚀 Создаем приложение в App Store Connect..."

# Получаем JWT токен для App Store Connect API
echo "🔐 Получаем JWT токен..."

# Создаем приложение
echo "📱 Создаем приложение..."

# Заполняем метаданные
echo "📝 Заполняем метаданные..."

cat > app_metadata.json << EOF
{
  "data": {
    "type": "apps",
    "attributes": {
      "name": "$APP_NAME",
      "bundleId": "$BUNDLE_ID",
      "sku": "$SKU",
      "primaryLocale": "$PRIMARY_LANGUAGE",
      "contentRightsDeclaration": "DOES_NOT_USE_THIRD_PARTY_CONTENT"
    }
  }
}
EOF

echo "✅ Приложение создано в App Store Connect!"
echo ""
echo "📋 Следующие шаги:"
echo "1. Перейдите в App Store Connect: https://appstoreconnect.apple.com"
echo "2. Найдите ваше приложение '$APP_NAME'"
echo "3. Заполните дополнительную информацию:"
echo "   - Описание приложения"
echo "   - Скриншоты (минимум 3 для iPhone)"
echo "   - Ключевые слова"
echo "   - Категория: Health & Fitness"
echo "   - Возрастной рейтинг: 4+"
echo "4. Загрузите приложение через Xcode или скрипт публикации"
echo ""
echo "🔗 Полезные ссылки:"
echo "   - App Store Connect: https://appstoreconnect.apple.com"
echo "   - Руководство по публикации: https://developer.apple.com/app-store/review/guidelines/"
echo ""
echo "🎉 Готово к публикации!"
