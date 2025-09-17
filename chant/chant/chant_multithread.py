#!/usr/bin/env python3
"""
Chant Multithread - Система с 3 экземплярами моделей mozgach:latest
Работает в 3 потоках с автоматическим чантингом на разных языках
"""

import threading
import time
import requests
import json
import logging
from typing import Dict, List, Optional
from queue import Queue, Empty
import signal
import sys

# Настройка логирования
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(threadName)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('chant_multithread.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class ChantWorker:
    """Рабочий поток для одной модели с автоматическим чантингом"""
    
    def __init__(self, thread_id: int, language: str, ollama_url: str = "http://localhost:11434", 
                 chant_ratio: float = 0.8, cursor_ratio: float = 0.2):
        self.thread_id = thread_id
        self.language = language
        self.ollama_url = ollama_url
        self.model_name = "mozgach:latest"
        self.running = False
        self.request_queue = Queue()
        self.last_request_time = time.time()
        self.chanting_active = True
        
        # Коэффициенты разбавки: чантинг vs запросы курсора
        self.chant_ratio = chant_ratio      # 80% времени на чантинг
        self.cursor_ratio = cursor_ratio    # 20% времени на запросы курсора
        self.chant_interval = 0.1          # Интервал между чантингом (100ms)
        self.cursor_interval = 0.5         # Интервал после обработки запроса курсора
        
        # Махамантры на разных языках
        self.mantras = {
            "russianscsm": "Харей Кришна Харей Кришна Кришна Кришна Харей Харе Харей Рама Харей Рама Рама Рама Харей Харе",
            "thai": "ฮาเร กฤษณะ ฮาเร กฤษณะ กฤษณะ กฤษณะ ฮาเร ฮาเร ฮาเร ราม ฮาเร ราม ราม ราม ฮาเร ฮาเร",
            "harkonnen": "Ḥāre Kṛṣṇa Ḥāre Kṛṣṇa Kṛṣṇa Kṛṣṇa Ḥāre Ḥāre Ḥāre Rāma Ḥāre Rāma Rāma Rāma Ḥāre Ḥāre"
        }
        
        self.current_mantra = self.mantras.get(language, self.mantras["russianscsm"])
        
    def start(self):
        """Запуск рабочего потока"""
        self.running = True
        self.thread = threading.Thread(target=self._work_loop, name=f"Worker-{self.thread_id}")
        self.thread.daemon = True
        self.thread.start()
        logger.info(f"Запущен рабочий поток {self.thread_id} с языком {self.language}")
        
    def stop(self):
        """Остановка рабочего потока"""
        self.running = False
        self.chanting_active = False
        logger.info(f"Остановка рабочего потока {self.thread_id}")
        
    def add_request(self, request: str):
        """Добавление запроса от курсора"""
        self.request_queue.put(request)
        self.last_request_time = time.time()
        self.chanting_active = False  # Временно отключаем чантинг
        logger.info(f"Получен запрос в потоке {self.thread_id}: {request[:50]}...")
        
    def _work_loop(self):
        """Основной цикл работы с коэффициентом разбавки"""
        chant_counter = 0
        cursor_counter = 0
        
        while self.running:
            try:
                # Проверяем запросы от курсора (с коэффициентом разбавки)
                try:
                    request = self.request_queue.get_nowait()
                    self._process_cursor_request(request)
                    self.last_request_time = time.time()
                    cursor_counter += 1
                    
                    # Логируем статистику разбавки
                    if cursor_counter % 5 == 0:  # Каждые 5 запросов
                        total = chant_counter + cursor_counter
                        chant_percent = (chant_counter / total) * 100 if total > 0 else 0
                        cursor_percent = (cursor_counter / total) * 100 if total > 0 else 0
                        logger.info(f"Поток {self.thread_id} - Статистика: Чантинг {chant_percent:.1f}%, Курсор {cursor_percent:.1f}%")
                    
                    # Возвращаемся к чантинг с задержкой
                    time.sleep(self.cursor_interval)
                    continue
                except Empty:
                    pass
                
                # Основной режим - чантинг махамантры (приоритет)
                if self.chanting_active and (time.time() - self.last_request_time) > self.cursor_interval:
                    self._chant_mantra()
                    chant_counter += 1
                    time.sleep(self.chant_interval)  # Пауза между чантингом
                else:
                    time.sleep(self.chant_interval)  # Небольшая пауза
                    
            except Exception as e:
                logger.error(f"Ошибка в потоке {self.thread_id}: {e}")
                time.sleep(1)
                
    def _process_cursor_request(self, request: str):
        """Обработка запроса от курсора"""
        try:
            logger.info(f"Обрабатываю запрос курсора в потоке {self.thread_id}")
            
            # Отправляем запрос к модели
            response = self._send_to_model(request)
            
            if response:
                logger.info(f"Получен ответ от модели в потоке {self.thread_id}: {response[:100]}...")
            else:
                logger.warning(f"Пустой ответ от модели в потоке {self.thread_id}")
                
        except Exception as e:
            logger.error(f"Ошибка обработки запроса курсора в потоке {self.thread_id}: {e}")
            
    def _chant_mantra(self):
        """Отправка махамантры к модели"""
        try:
            mantra = f"Чантинг на языке {self.language}: {self.current_mantra}"
            logger.info(f"Поток {self.thread_id}: {mantra}")
            
            # Отправляем махамантру к модели
            response = self._send_to_model(self.current_mantra)
            
            if response:
                logger.debug(f"Модель в потоке {self.thread_id} ответила на мантру")
            else:
                logger.debug(f"Модель в потоке {self.thread_id} не ответила на мантру")
                
        except Exception as e:
            logger.error(f"Ошибка чантинга в потоке {self.thread_id}: {e}")
            
    def _send_to_model(self, prompt: str) -> Optional[str]:
        """Отправка запроса к модели через Ollama API"""
        try:
            url = f"{self.ollama_url}/api/generate"
            payload = {
                "model": self.model_name,
                "prompt": prompt,
                "stream": False,
                "options": {
                    "temperature": 0.7,
                    "top_p": 0.9,
                    "max_tokens": 100
                }
            }
            
            response = requests.post(url, json=payload, timeout=30)
            response.raise_for_status()
            
            result = response.json()
            return result.get('response', '')
            
        except requests.exceptions.RequestException as e:
            logger.error(f"Ошибка API в потоке {self.thread_id}: {e}")
            return None
        except Exception as e:
            logger.error(f"Неожиданная ошибка в потоке {self.thread_id}: {e}")
            return None

class ChantManager:
    """Менеджер для управления всеми рабочими потоками"""
    
    def __init__(self, ollama_url: str = "http://localhost:11434", 
                 chant_ratio: float = 0.8, cursor_ratio: float = 0.2):
        self.ollama_url = ollama_url
        self.workers: Dict[int, ChantWorker] = {}
        self.running = False
        
        # Коэффициенты разбавки
        self.chant_ratio = chant_ratio      # 80% времени на чантинг
        self.cursor_ratio = cursor_ratio    # 20% времени на запросы курсора
        
        # Языки для каждого потока
        self.languages = ["russianscsm", "thai", "harkonnen"]
        
    def start(self):
        """Запуск всех рабочих потоков"""
        logger.info("Запуск системы чантинга с 3 потоками...")
        
        # Проверяем доступность Ollama
        if not self._check_ollama():
            logger.error("Ollama недоступен. Убедитесь, что сервер запущен.")
            return False
            
        # Проверяем наличие модели
        if not self._check_model():
            logger.error("Модель mozgach:latest не найдена. Загрузите её командой: ollama pull mozgach:latest")
            return False
            
        # Создаем и запускаем рабочие потоки
        for i, language in enumerate(self.languages):
            worker = ChantWorker(i + 1, language, self.ollama_url, 
                               self.chant_ratio, self.cursor_ratio)
            worker.start()
            self.workers[i + 1] = worker
            
        self.running = True
        logger.info("Все рабочие потоки запущены успешно!")
        return True
        
    def stop(self):
        """Остановка всех рабочих потоков"""
        logger.info("Остановка системы чантинга...")
        
        for worker in self.workers.values():
            worker.stop()
            
        # Ждем завершения потоков
        for worker in self.workers.values():
            if hasattr(worker, 'thread'):
                worker.thread.join(timeout=5)
                
        self.running = False
        logger.info("Система чантинга остановлена.")
        
    def send_request(self, request: str, thread_id: Optional[int] = None):
        """Отправка запроса от курсора"""
        if not self.running:
            logger.warning("Система не запущена")
            return
            
        if thread_id and thread_id in self.workers:
            # Отправляем в конкретный поток
            self.workers[thread_id].add_request(request)
            logger.info(f"Запрос отправлен в поток {thread_id}")
        else:
            # Отправляем в случайный поток для балансировки нагрузки
            import random
            random_thread = random.choice(list(self.workers.keys()))
            self.workers[random_thread].add_request(request)
            logger.info(f"Запрос отправлен в случайный поток {random_thread}")
            
    def _check_ollama(self) -> bool:
        """Проверка доступности Ollama сервера"""
        try:
            response = requests.get(f"{self.ollama_url}/api/tags", timeout=5)
            return response.status_code == 200
        except:
            return False
            
    def _check_model(self) -> bool:
        """Проверка наличия модели mozgach:latest"""
        try:
            response = requests.get(f"{self.ollama_url}/api/tags", timeout=5)
            if response.status_code == 200:
                models = response.json().get('models', [])
                return any('mozgach:latest' in model.get('name', '') for model in models)
            return False
        except:
            return False
            
    def get_status(self) -> Dict:
        """Получение статуса всех потоков"""
        status = {
            "running": self.running,
            "workers": {}
        }
        
        for thread_id, worker in self.workers.items():
            status["workers"][thread_id] = {
                "language": worker.language,
                "chanting_active": worker.chanting_active,
                "last_request_time": worker.last_request_time,
                "queue_size": worker.request_queue.qsize()
            }
            
        return status

def signal_handler(signum, frame):
    """Обработчик сигналов для корректного завершения"""
    logger.info("Получен сигнал завершения...")
    if hasattr(signal_handler, 'manager'):
        signal_handler.manager.stop()
    sys.exit(0)

def main():
    """Основная функция"""
    import argparse
    
    parser = argparse.ArgumentParser(description="Система чантинга с 3 потоками и коэффициентом разбавки")
    parser.add_argument("--url", default="http://localhost:11434", help="URL Ollama сервера")
    parser.add_argument("--chant-ratio", type=float, default=0.8, help="Коэффициент времени на чантинг (0.0-1.0)")
    parser.add_argument("--cursor-ratio", type=float, default=0.2, help="Коэффициент времени на запросы курсора (0.0-1.0)")
    
    args = parser.parse_args()
    
    # Проверяем корректность коэффициентов
    if args.chant_ratio + args.cursor_ratio > 1.0:
        print("⚠️  Внимание: сумма коэффициентов больше 1.0, это может привести к неожиданному поведению")
    
    # Настройка обработчика сигналов
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    
    # Создание менеджера с настройками коэффициентов
    manager = ChantManager(args.url, args.chant_ratio, args.cursor_ratio)
    signal_handler.manager = manager  # Сохраняем ссылку для обработчика сигналов
    
    try:
        # Запуск системы
        if manager.start():
            logger.info("Система чантинга запущена и работает...")
            logger.info("Используйте Ctrl+C для остановки")
            
            # Основной цикл
            while manager.running:
                time.sleep(1)
                
                # Периодически выводим статус
                if int(time.time()) % 30 == 0:  # Каждые 30 секунд
                    status = manager.get_status()
                    logger.info(f"Статус системы: {status}")
                    
        else:
            logger.error("Не удалось запустить систему")
            
    except KeyboardInterrupt:
        logger.info("Получен сигнал прерывания...")
    except Exception as e:
        logger.error(f"Критическая ошибка: {e}")
    finally:
        manager.stop()

if __name__ == "__main__":
    main()
