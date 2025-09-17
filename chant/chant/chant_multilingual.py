#!/usr/bin/env python3
"""
Chant Multilingual - демонстрация смены языка махамантры во время работы
"""

import time
import threading
from chant_mantra import ChantMantra

def language_switcher(chanter, languages, switch_interval=300):
    """
    Автоматически переключает языки махамантры
    
    Args:
        chanter: Экземпляр ChantMantra
        languages: Список языков для переключения
        switch_interval: Интервал смены языка в секундах
    """
    current_index = 0
    
    # Используем все доступные языки если список не передан
    if not languages:
        languages = ["russian", "thai", "harkonnen", "atreides", "freemen"]
    
    while True:
        time.sleep(switch_interval)
        
        # Переключаем на следующий язык
        current_index = (current_index + 1) % len(languages)
        new_language = languages[current_index]
        
        print(f"\n🔄 Автоматическое переключение языка на: {new_language}")
        chanter.change_language(new_language)

def main():
    """Основная функция для демонстрации многоязычности"""
    print("🌍 Chant Multilingual - Демонстрация смены языка")
    print("=" * 50)
    
    # Создаем экземпляр с русским языком по умолчанию
    chanter = ChantMantra(language="russian")
    
    # Проверяем доступность модели
    if not chanter.check_model_availability():
        print("❌ Модель недоступна. Проверьте настройки Ollama.")
        return
    
    # Показываем доступные языки
    available_languages = chanter.get_available_languages()
    print(f"🌍 Доступные языки: {', '.join(available_languages)}")
    print(f"🌍 Текущий язык: {chanter.language}")
    print(f"🕉️ Текущая махамантра: {chanter.mantra}")
    print()
    
    # Запускаем автоматическое переключение языков в отдельном потоке
    # Каждые 5 минут (300 секунд) язык будет меняться
    language_thread = threading.Thread(
        target=language_switcher,
        args=(chanter, available_languages, 300),
        daemon=True
    )
    language_thread.start()
    
    print("🔄 Автоматическое переключение языков запущено (каждые 5 минут)")
    print("💡 Для остановки нажмите Ctrl+C")
    print()
    
    try:
        # Запускаем основную отправку махамантры
        chanter.continuous_chant(interval=60)
    except KeyboardInterrupt:
        print("\n🛑 Получен сигнал остановки. Завершаю работу...")
    finally:
        print("🏁 Демонстрация завершена")

if __name__ == "__main__":
    main()
