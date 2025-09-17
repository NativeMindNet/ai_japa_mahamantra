#!/usr/bin/env python3
"""
Chant Mantra - отправляет махамантру "Харе Кришна" к локальной AI Mozgach через Ollama
"""

import requests
import json
import time
import logging
from typing import Dict, Any
import sys
import os

# Настройка логирования
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('chant.log'),
        logging.StreamHandler(sys.stdout)
    ]
)

class ChantMantra:
    def __init__(self, ollama_url: str = "http://localhost:11434", model_name: str = "mozgach", language: str = "russian"):
        """
        Инициализация класса для отправки махамантры
        
        Args:
            ollama_url: URL Ollama сервера
            model_name: Название модели для использования
            language: Язык махамантры ("russian" или "thai")
        """
        self.ollama_url = ollama_url
        self.model_name = model_name
        self.language = language
        
        # Махамантры на разных языках
        self.mantras = {
            "russian": "Харе Кришна Харе Кришна Кришна Кришна Харе Харе Харе Рама Харе Рама Рама Рама Харе Харе",
            "russianscsm": "Харей Кришна Харей Кришна Кришна Кришна Харей Харе Харей Рама Харей Рама Рама Рама Харей Харе",
            "thai": "ฮาเร กฤษณะ ฮาเร กฤษณะ กฤษณะ กฤษณะ ฮาเร ฮาเร ฮาเร ราม ฮาเร ราม ราม ราม ฮาเร ฮาเร",
            "harkonnen": "Ḥāre Kṛṣṇa Ḥāre Kṛṣṇa Kṛṣṇa Kṛṣṇa Ḥāre Ḥāre Ḥāre Rāma Ḥāre Rāma Rāma Rāma Ḥāre Ḥāre",
            "atreides": "Hāre Kṛṣṇa Hāre Kṛṣṇa Kṛṣṇa Kṛṣṇa Hāre Hāre Hāre Rāma Hāre Rāma Rāma Rāma Hāre Hāre",
            "freemen": "Ḥāre Kṛṣṇa Ḥāre Kṛṣṇa Kṛṣṇa Kṛṣṇa Ḥāre Ḥāre Ḥāre Rāma Ḥāre Rāma Rāma Rāma Ḥāre Ḥāre"
        }
        
        self.mantra = self.mantras.get(language, self.mantras["russian"])
        
        # Проверяем доступность Ollama
        self.check_ollama_connection()
    
    def check_ollama_connection(self) -> bool:
        """Проверяет соединение с Ollama сервером"""
        try:
            response = requests.get(f"{self.ollama_url}/api/tags", timeout=5)
            if response.status_code == 200:
                logging.info(f"✅ Соединение с Ollama установлено: {self.ollama_url}")
                return True
            else:
                logging.error(f"❌ Ollama недоступен. Статус: {response.status_code}")
                return False
        except requests.exceptions.RequestException as e:
            logging.error(f"❌ Не удается подключиться к Ollama: {e}")
            return False
    
    def check_model_availability(self) -> bool:
        """Проверяет доступность модели"""
        try:
            response = requests.get(f"{self.ollama_url}/api/tags", timeout=5)
            if response.status_code == 200:
                models = response.json().get('models', [])
                model_names = [model['name'] for model in models]
                
                if self.model_name in model_names:
                    logging.info(f"✅ Модель '{self.model_name}' доступна")
                    return True
                else:
                    logging.warning(f"⚠️ Модель '{self.model_name}' не найдена. Доступные модели: {model_names}")
                    return False
            return False
        except Exception as e:
            logging.error(f"❌ Ошибка при проверке модели: {e}")
            return False
    
    def send_mantra(self) -> Dict[str, Any]:
        """
        Отправляет махамантру к AI модели
        
        Returns:
            Dict с ответом от модели
        """
        payload = {
            "model": self.model_name,
            "prompt": f"Повтори махамантру: {self.mantra}",
            "stream": False,
            "options": {
                "temperature": 0.7,
                "top_p": 0.9,
                "num_predict": 100
            }
        }
        
        try:
            logging.info(f"🕉️ Отправляю махамантру: {self.mantra}")
            
            response = requests.post(
                f"{self.ollama_url}/api/generate",
                json=payload,
                timeout=30
            )
            
            if response.status_code == 200:
                result = response.json()
                logging.info(f"✅ Ответ получен: {result.get('response', '')[:100]}...")
                return result
            else:
                logging.error(f"❌ Ошибка API: {response.status_code} - {response.text}")
                return {"error": f"HTTP {response.status_code}", "details": response.text}
                
        except requests.exceptions.RequestException as e:
            logging.error(f"❌ Ошибка запроса: {e}")
            return {"error": "Request failed", "details": str(e)}
        except json.JSONDecodeError as e:
            logging.error(f"❌ Ошибка парсинга JSON: {e}")
            return {"error": "JSON parse error", "details": str(e)}
    
    def continuous_chant(self, interval: int = 60, max_requests: int = None):
        """
        Постоянно отправляет махамантру с заданным интервалом
        
        Args:
            interval: Интервал между запросами в секундах
            max_requests: Максимальное количество запросов (None = бесконечно)
        """
        logging.info(f"🚀 Начинаю непрерывную отправку махамантры каждые {interval} секунд")
        logging.info(f"🕉️ Махамантра: {self.mantra}")
        
        request_count = 0
        
        try:
            while True:
                if max_requests and request_count >= max_requests:
                    logging.info(f"✅ Достигнуто максимальное количество запросов: {max_requests}")
                    break
                
                request_count += 1
                logging.info(f"📝 Запрос #{request_count}")
                
                # Отправляем махамантру
                result = self.send_mantra()
                
                # Логируем результат
                if "error" not in result:
                    logging.info(f"✅ Запрос #{request_count} успешен")
                else:
                    logging.error(f"❌ Запрос #{request_count} неудачен: {result.get('error')}")
                
                # Ждем перед следующим запросом
                if max_requests and request_count >= max_requests:
                    break
                    
                logging.info(f"⏳ Ожидание {interval} секунд до следующего запроса...")
                time.sleep(interval)
                
        except KeyboardInterrupt:
            logging.info("🛑 Получен сигнал остановки. Завершаю работу...")
        except Exception as e:
            logging.error(f"❌ Неожиданная ошибка: {e}")
        finally:
            logging.info(f"🏁 Завершено. Всего отправлено запросов: {request_count}")
    
    def change_language(self, new_language: str):
        """
        Меняет язык махамантры
        
        Args:
            new_language: Новый язык ("russian" или "thai")
        """
        if new_language in self.mantras:
            self.language = new_language
            self.mantra = self.mantras[new_language]
            logging.info(f"🌍 Язык изменен на: {new_language}")
            logging.info(f"🕉️ Новая махамантра: {self.mantra}")
        else:
            logging.warning(f"⚠️ Неподдерживаемый язык: {new_language}. Доступные: {list(self.mantras.keys())}")
    
    def get_available_languages(self):
        """Возвращает список доступных языков"""
        return list(self.mantras.keys())

def main():
    """Основная функция"""
    import argparse
    
    parser = argparse.ArgumentParser(description="Отправка махамантры к AI Mozgach через Ollama")
    parser.add_argument("--url", default="http://localhost:11434", help="URL Ollama сервера")
    parser.add_argument("--model", default="mozgach", help="Название модели")
    parser.add_argument("--interval", type=int, default=60, help="Интервал между запросами в секундах")
    parser.add_argument("--max-requests", type=int, help="Максимальное количество запросов")
    parser.add_argument("--language", choices=["russian", "thai", "harkonnen", "atreides", "freemen"], default="russian", help="Язык махамантры")
    
    args = parser.parse_args()
    
    # Создаем экземпляр класса
    chanter = ChantMantra(args.url, args.model, args.language)
    
    # Проверяем доступность модели
    if not chanter.check_model_availability():
        logging.error("❌ Модель недоступна. Проверьте настройки Ollama.")
        sys.exit(1)
    
    # Показываем информацию о доступных языках
    logging.info(f"🌍 Доступные языки: {', '.join(chanter.get_available_languages())}")
    logging.info(f"🌍 Выбранный язык: {args.language}")
    
    # Запускаем непрерывную отправку
    chanter.continuous_chant(args.interval, args.max_requests)

if __name__ == "__main__":
    main()
