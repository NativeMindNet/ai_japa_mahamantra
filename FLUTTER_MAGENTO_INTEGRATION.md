# Flutter Magento Integration

Ваше приложение AI Japa Mahamantra теперь интегрировано с пакетом `flutter_magento` для поддержки e-commerce функций.

## Что было добавлено

### 1. Пакет flutter_magento
- Добавлен в `pubspec.yaml` версия `^2.3.4`
- Включает 200+ функций для e-commerce
- Поддержка аутентификации, продуктов, корзины, заказов и многого другого

### 2. Обновленный MagentoService
Ваш существующий `MagentoService` был расширен для поддержки flutter_magento:

#### Новые возможности:
- **Прямой доступ к flutter_magento API** через `magento` геттер
- **Аутентификация пользователей** через Magento
- **Управление продуктами** (получение, поиск, фильтрация)
- **Корзина покупок** (создание, добавление товаров)
- **Совместимость** с существующими Japa-специфичными функциями

#### Основные методы:
```dart
// Аутентификация
await magentoService.authenticateCustomer(email, password);

// Получение продуктов
final products = await magentoService.getProducts(
  page: 1,
  pageSize: 20,
  searchQuery: 'meditation',
);

// Поиск продуктов
final results = await magentoService.searchProducts('spiritual books');

// Создание корзины
final cart = await magentoService.createCart();

// Прямой доступ к flutter_magento API
final magento = magentoService.magento;
```

## Как использовать

### 1. Настройка
Убедитесь, что у вас есть рабочий Magento сервер с REST API:

```dart
await magentoService.initialize(
  baseUrl: 'https://your-magento-store.com',
  accessToken: 'your-access-token',
);
```

### 2. Включение облачных функций
```dart
await magentoService.setCloudFeaturesEnabled(true);
```

### 3. Использование в коде
```dart
final magentoService = MagentoService();

// Проверка доступности
if (magentoService.isCloudAvailable) {
  // Используйте e-commerce функции
  final products = await magentoService.getProducts();
}
```

### 4. Пример использования
См. файл `lib/examples/magento_usage_example.dart` для полного примера интеграции.

## Функции flutter_magento

Пакет предоставляет следующие возможности:

### Аутентификация
- JWT токены с автоматическим обновлением
- Безопасное хранение с FlutterSecureStorage
- Поддержка "Запомнить меня"

### E-commerce
- Полная интеграция с Magento REST API
- GraphQL поддержка
- Корзина с поддержкой гостевых пользователей
- Wishlist с множественными списками
- Продвинутый поиск и фильтрация

### Локализация
- 45+ языков из коробки
- Автоматическое определение системной локали
- RTL поддержка

### Офлайн режим
- Автоматическое кэширование данных
- Очередь операций для офлайн режима
- Автоматическая синхронизация

## Совместимость

Интеграция полностью совместима с существующими функциями:
- ✅ Japa медитация продолжает работать как обычно
- ✅ Существующие облачные функции сохранены
- ✅ Все настройки и данные остаются нетронутыми
- ✅ Добавлены новые e-commerce возможности

## Зависимости

Пакет flutter_magento добавил следующие зависимости:
- `flutter_secure_storage` - безопасное хранение
- `hive` & `hive_flutter` - локальная база данных
- `logger` - логирование
- `retrofit` - REST API клиент
- `socket_io_client` - WebSocket поддержка
- И другие...

## Следующие шаги

1. **Настройте ваш Magento сервер** с REST API
2. **Получите API токены** для аутентификации
3. **Обновите URL и токены** в коде
4. **Протестируйте интеграцию** используя пример
5. **Добавьте e-commerce UI** в ваше приложение

## Поддержка

Для получения помощи по flutter_magento:
- 📚 [Документация](https://pub.dev/packages/flutter_magento)
- 🐛 [GitHub Issues](https://github.com/flutter_magento/issues)
- 📧 Email: support@nativemind.net

---

**Интеграция завершена успешно! 🎉**

