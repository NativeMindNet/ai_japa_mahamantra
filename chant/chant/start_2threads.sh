#!/bin/bash

# Скрипт для запуска Chant Mantra в 2 потока
# russianscsm и harkonnen языки

echo "🕉️ Запуск Chant Mantra в 2 потока..."
echo "🌍 Языки: russianscsm, harkonnen"
echo "⏱️ Интервал: 100ms"
echo "🤖 Модель: mozgach:latest"

# Активируем виртуальное окружение
source venv/bin/activate

# Запускаем многопоточный chant
python chant_multithread.py --model mozgach:latest --interval 0.1
