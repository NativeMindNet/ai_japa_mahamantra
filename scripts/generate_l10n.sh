#!/bin/bash

# 🌍 Script to generate Flutter localization files
# Скрипт для генерации файлов локализации Flutter

echo "🌍 Generating Flutter localization files..."
echo "Генерация файлов локализации Flutter..."

cd "$(dirname "$0")/.." || exit

# Count .arb files
arb_count=$(find l10n -name "*.arb" | wc -l)
echo "📝 Found $arb_count language files"
echo "Найдено $arb_count файлов языков"

# List all languages
echo ""
echo "📋 Available languages:"
for arb_file in l10n/*.arb; do
    lang=$(basename "$arb_file" .arb | sed 's/app_//')
    echo "  - $lang"
done

echo ""
echo "🔧 Running flutter pub get..."
flutter pub get

echo ""
echo "🎨 Generating localization code..."
flutter gen-l10n

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Localization files generated successfully!"
    echo "Файлы локализации успешно сгенерированы!"
    echo ""
    echo "📦 Generated files location:"
    echo "   .dart_tool/flutter_gen/gen_l10n/"
else
    echo ""
    echo "❌ Error generating localization files"
    echo "Ошибка при генерации файлов локализации"
    exit 1
fi

echo ""
echo "🎉 Done! You can now use AppLocalizations in your Flutter app"
echo "Готово! Теперь вы можете использовать AppLocalizations в вашем приложении Flutter"

