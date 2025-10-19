# Интеграция истории сессий с Magento профилем

## Обзор

Реализована интеграция истории сессий джапа медитации с профилем Flutter Magento, где каждая завершенная сессия сохраняется как "покупка" в системе Magento.

## Что было реализовано

### 1. Модель JapaSessionPurchase
- **Файл**: `lib/models/japa_session_purchase.dart`
- **Назначение**: Представляет сессию джапы как покупку в Magento
- **Функции**:
  - Преобразование в формат Magento Order
  - Создание из JapaSession
  - JSON сериализация/десериализация

### 2. Расширенный MagentoService
- **Файл**: `lib/services/magento_service.dart`
- **Новые методы**:
  - `saveJapaSessionAsPurchase()` - сохранение сессии как покупки
  - `getJapaSessionHistory()` - получение истории из Magento
  - `getJapaSessionStatistics()` - статистика сессий
  - `syncLocalSessionsWithMagento()` - синхронизация локальных сессий
  - `getCustomerAchievements()` - достижения пользователя
  - `createOrUpdateCustomerProfile()` - создание/обновление профиля

### 3. Обновленный JapaProvider
- **Файл**: `lib/providers/japa_provider.dart`
- **Новые возможности**:
  - Автоматическая синхронизация завершенных сессий с Magento
  - Методы загрузки истории из Magento профиля
  - Объединенная история (локальная + Magento)

### 4. Обновленный UI
- **Файл**: `lib/screens/japa_screen.dart`
- **Улучшения**:
  - Отображение сессий из облака и локальных
  - Визуальные индикаторы источника сессии
  - Кнопка синхронизации с Magento
  - Отображение дополнительной информации (мантра, тип сессии)

## Как это работает

### Автоматическая синхронизация
1. При завершении сессии джапы вызывается `_syncSessionWithMagento()`
2. Создается объект `JapaSessionPurchase` из `JapaSession`
3. Сессия сохраняется в Magento как заказ с нулевой стоимостью
4. Данные включают: количество кругов, длительность, мантру, метаданные

### Загрузка истории
1. `getCombinedSessionHistory()` объединяет локальные и облачные сессии
2. Сессии сортируются по дате (новые сверху)
3. UI показывает источник каждой сессии (локальная/облачная)

### Структура данных в Magento
```json
{
  "entity_id": null,
  "state": "complete",
  "status": "complete",
  "customer_id": "user_id",
  "items": [{
    "sku": "japa_session_123",
    "name": "Japa Meditation Session - Hare Krishna",
    "description": "Completed 16/16 rounds in 240 minutes",
    "price": 0.0,
    "custom_attributes": [
      {"attribute_code": "session_id", "value": "123"},
      {"attribute_code": "completed_rounds", "value": 16},
      {"attribute_code": "duration_minutes", "value": 240},
      {"attribute_code": "mantra", "value": "Hare Krishna"}
    ]
  }]
}
```

## Преимущества

1. **Централизованное хранение**: Все сессии сохраняются в профиле пользователя
2. **Синхронизация между устройствами**: Доступ к истории с любого устройства
3. **Аналитика**: Возможность анализа практики через Magento
4. **Интеграция с e-commerce**: Сессии как "духовные покупки"
5. **Резервное копирование**: Автоматическое сохранение в облаке

## Настройка

Для работы интеграции необходимо:
1. Настроить Magento сервер с REST API
2. Включить облачные функции в настройках приложения
3. Настроить аутентификацию пользователей

## API Endpoints

Интеграция использует следующие Magento API endpoints:
- `POST /rest/V1/orders` - создание заказа для сессии
- `GET /rest/V1/customers/{id}/japa-sessions` - получение истории сессий
- `GET /rest/V1/customers/{id}/japa-statistics` - статистика сессий
- `GET /rest/V1/customers/{id}/achievements` - достижения пользователя
- `POST /rest/V1/customers` - создание/обновление профиля

## Заключение

Интеграция позволяет пользователям сохранять свою духовную практику в профиле Magento, обеспечивая синхронизацию между устройствами и централизованное хранение истории сессий джапа медитации.


