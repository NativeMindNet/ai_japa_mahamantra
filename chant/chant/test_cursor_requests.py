#!/usr/bin/env python3
"""
Тестовый скрипт для отправки запросов от курсора к системе чантинга
Демонстрирует приоритетную обработку запросов курсора
"""

import requests
import time
import json
import threading
from typing import Optional

class CursorRequestTester:
    """Тестер для отправки запросов от курсора"""
    
    def __init__(self, base_url: str = "http://localhost:11434"):
        self.base_url = base_url
        
        # Запросы на разных языках из списка системы чантинга
        self.test_requests = {
            "russianscsm": [
                "Привет, как дела?",
                "Расскажи о квантовой физике",
                "Напиши стихотворение о любви",
                "Объясни принцип работы нейронных сетей",
                "Что такое искусственный интеллект?"
            ],
            "thai": [
                "สวัสดี เป็นอย่างไรบ้าง?",
                "อธิบายเกี่ยวกับฟิสิกส์ควอนตัม",
                "เขียนบทกวีเกี่ยวกับความรัก",
                "อธิบายหลักการทำงานของเครือข่ายประสาท",
                "ปัญญาประดิษฐ์คืออะไร?"
            ],
            "harkonnen": [
                "Ḥāre, kāma vartate?",
                "Vivṛṇu kvaṇṭa-bhautikam",
                "Likhātu kāvyaṃ prema-viṣayam",
                "Vivṛṇu tāntrika-jāla-kriyā-pratipatti",
                "Kṛtrima-prajñā kim?"
            ]
        }
        
        # Текущий язык для ротации
        self.current_language_index = 0
        self.languages = list(self.test_requests.keys())
        
    def send_test_request(self, request: str, thread_id: Optional[int] = None) -> bool:
        """Отправка тестового запроса"""
        try:
            # Здесь мы бы отправляли запрос к системе чантинга
            # В реальной системе это будет API endpoint
            print(f"📤 Отправка запроса: {request[:50]}...")
            
            # Имитируем отправку к модели
            payload = {
                "model": "mozgach:latest",
                "prompt": request,
                "stream": False,
                "options": {
                    "temperature": 0.7,
                    "top_p": 0.9,
                    "max_tokens": 200
                }
            }
            
            response = requests.post(f"{self.base_url}/api/generate", json=payload, timeout=30)
            response.raise_for_status()
            
            result = response.json()
            answer = result.get('response', '')
            
            print(f"✅ Получен ответ: {answer[:100]}...")
            return True
            
        except Exception as e:
            print(f"❌ Ошибка отправки запроса: {e}")
            return False
            
    def run_continuous_test(self, interval: float = 5.0):
        """Запуск непрерывного тестирования с ротацией языков"""
        print(f"🚀 Запуск непрерывного тестирования с интервалом {interval} секунд")
        print("🌍 Ротация языков: russianscsm → thai → harkonnen")
        print("💡 Нажмите Ctrl+C для остановки")
        print("-" * 60)
        
        request_index = 0
        
        try:
            while True:
                # Выбираем язык для текущего запроса
                current_language = self.languages[self.current_language_index % len(self.languages)]
                language_requests = self.test_requests[current_language]
                
                # Выбираем запрос для текущего языка
                request = language_requests[request_index % len(language_requests)]
                
                print(f"🌍 Язык: {current_language}")
                print(f"📝 Запрос: {request}")
                
                # Отправляем запрос
                success = self.send_test_request(request)
                
                if success:
                    print(f"✅ Запрос #{request_index + 1} на языке {current_language} успешен")
                else:
                    print(f"❌ Запрос #{request_index + 1} на языке {current_language} неудачен")
                
                request_index += 1
                self.current_language_index += 1  # Переходим к следующему языку
                
                # Ждем перед следующим запросом
                print(f"⏳ Ожидание {interval} секунд...")
                time.sleep(interval)
                print("-" * 60)
                
        except KeyboardInterrupt:
            print("\n🛑 Тестирование остановлено пользователем")
            
    def run_burst_test(self, burst_size: int = 3, delay: float = 0.5):
        """Запуск тестирования пакетом запросов с ротацией языков"""
        print(f"💥 Запуск пакетного тестирования: {burst_size} запросов с задержкой {delay}s")
        print("🌍 Ротация языков: russianscsm → thai → harkonnen")
        print("-" * 60)
        
        for i in range(burst_size):
            # Выбираем язык для текущего запроса
            current_language = self.languages[self.current_language_index % len(self.languages)]
            language_requests = self.test_requests[current_language]
            
            # Выбираем запрос для текущего языка
            request = language_requests[i % len(language_requests)]
            
            print(f"🌍 Язык: {current_language}")
            print(f"📤 Пакетный запрос #{i + 1}: {request[:50]}...")
            
            success = self.send_test_request(request)
            
            if success:
                print(f"✅ Пакетный запрос #{i + 1} на языке {current_language} успешен")
            else:
                print(f"❌ Пакетный запрос #{i + 1} на языке {current_language} неудачен")
            
            self.current_language_index += 1  # Переходим к следующему языку
                
            if i < burst_size - 1:
                print(f"⏳ Задержка {delay} секунд...")
                time.sleep(delay)
                
        print("🏁 Пакетное тестирование завершено")
        
    def run_interactive_test(self):
        """Интерактивное тестирование"""
        print("🎮 Интерактивное тестирование")
        print("💡 Введите запрос или команду:")
        print("   - 'quit' или 'exit' для выхода")
        print("   - 'status' для получения статуса")
        print("   - 'help' для справки")
        print("-" * 60)
        
        while True:
            try:
                user_input = input("📝 Введите запрос: ").strip()
                
                if not user_input:
                    continue
                    
                if user_input.lower() in ['quit', 'exit', 'q']:
                    print("👋 До свидания!")
                    break
                    
                if user_input.lower() == 'status':
                    print("📊 Статус системы: активна")
                    continue
                    
                if user_input.lower() == 'help':
                    print("📚 Доступные команды:")
                    print("   - Введите любой текст для отправки запроса")
                    print("   - 'quit' или 'exit' для выхода")
                    print("   - 'status' для получения статуса")
                    print("   - 'help' для справки")
                    continue
                    
                # Отправляем пользовательский запрос
                print(f"📤 Отправка пользовательского запроса...")
                
                # Определяем язык запроса (по умолчанию русский)
                detected_language = "russianscsm"
                if any(char in user_input for char in "ฮาเรกฤษณะราม"):
                    detected_language = "thai"
                elif any(char in user_input for char in "ḤāreKṛṣṇaRāma"):
                    detected_language = "harkonnen"
                
                print(f"🌍 Определен язык: {detected_language}")
                success = self.send_test_request(user_input)
                
                if success:
                    print("✅ Запрос успешно обработан")
                else:
                    print("❌ Ошибка обработки запроса")
                    
            except KeyboardInterrupt:
                print("\n👋 До свидания!")
                break
            except EOFError:
                print("\n👋 До свидания!")
                break

def main():
    """Основная функция"""
    import argparse
    
    parser = argparse.ArgumentParser(description="Тестирование запросов от курсора")
    parser.add_argument("--url", default="http://localhost:11434", help="URL Ollama сервера")
    parser.add_argument("--mode", choices=["continuous", "burst", "interactive"], 
                       default="interactive", help="Режим тестирования")
    parser.add_argument("--interval", type=float, default=5.0, 
                       help="Интервал между запросами (для continuous режима)")
    parser.add_argument("--burst-size", type=int, default=3, 
                       help="Размер пакета (для burst режима)")
    parser.add_argument("--delay", type=float, default=0.5, 
                       help="Задержка между запросами в пакете (для burst режима)")
    
    args = parser.parse_args()
    
    # Создаем тестер
    tester = CursorRequestTester(args.url)
    
    # Запускаем выбранный режим
    if args.mode == "continuous":
        tester.run_continuous_test(args.interval)
    elif args.mode == "burst":
        tester.run_burst_test(args.burst_size, args.delay)
    else:  # interactive
        tester.run_interactive_test()

if __name__ == "__main__":
    main()
