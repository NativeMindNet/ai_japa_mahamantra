# 🔒 Инструкции по безопасной настройке проекта

## ⚠️ ВАЖНО: Что НЕ должно попадать в Git

Следующие файлы содержат конфиденциальную информацию и **НИКОГДА** не должны коммититься в Git:

### 🔴 Критически важные файлы

1. **Android Keystore** (для подписи приложения)
   - `android/upload-keystore.jks`
   - `android/app/upload-keystore.jks`
   - `*.jks`, `*.keystore`
   - `android/key.properties`

2. **App Store Connect API Keys**
   - `app_store_config.env`
   - `*.p8` файлы (AuthKey)
   - `*.p12` сертификаты
   - `*.mobileprovision` профили

3. **Локальные конфигурации**
   - `android/local.properties`
   - `.env`, `.env.local`, `.env.production`

4. **Build артефакты**
   - `ios/*.ipa`
   - `ios/*.dSYM.zip`
   - `build/` директория

## 📋 Первичная настройка проекта

### 1. Настройка Android

#### Создание Keystore для подписи приложения

```bash
# Генерация нового keystore (только если у вас его ещё нет!)
keytool -genkey -v -keystore android/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload

# Запишите пароли в безопасное место (например, 1Password, LastPass)
```

#### Настройка key.properties

Создайте файл `android/key.properties`:

```properties
storePassword=ваш-пароль-keystore
keyPassword=ваш-пароль-ключа
keyAlias=upload
storeFile=upload-keystore.jks
```

#### Настройка local.properties

```bash
# Скопируйте template
cp android/local.properties.example android/local.properties

# Отредактируйте и укажите путь к вашему Android SDK
# Обычно: /Users/USERNAME/Library/Android/sdk (macOS)
```

### 2. Настройка iOS / App Store

#### Создание App Store Config

```bash
# Скопируйте template
cp app_store_config.env.example app_store_config.env

# Отредактируйте файл и заполните ваши данные
```

#### Получение App Store Connect API Key

1. Войдите в [App Store Connect](https://appstoreconnect.apple.com)
2. Перейдите в Users and Access → Keys
3. Нажмите "Generate API Key" или используйте существующий
4. Скачайте `.p8` файл и сохраните в безопасном месте
5. Запишите Issuer ID и Key ID

### 3. Fastlane для iOS

#### Установка зависимостей

```bash
cd ios
bundle install
```

#### Настройка Fastlane

Убедитесь, что `ios/fastlane/Fastfile` настроен корректно и все API keys указаны.

### 4. Проверка безопасности

```bash
# Проверьте, что критичные файлы не отслеживаются git
git status

# Убедитесь, что в выводе нет:
# - *.jks или *.keystore файлов
# - app_store_config.env
# - *.p8, *.p12 файлов
# - local.properties
```

## 🔐 Хранение секретов

### Рекомендуемые решения:

1. **1Password / LastPass** - для паролей и ключей
2. **Encrypted Git repo** - для certificates (через Fastlane Match)
3. **CI/CD Secrets** - для GitHub Actions, GitLab CI, etc.
4. **Environment Variables** - для локальной разработки

### Что хранить:

✅ **В менеджере паролей:**
- Keystore пароли
- App Store Connect credentials
- API keys и tokens

✅ **В зашифрованном Git репозитории (Match):**
- iOS certificates
- Provisioning profiles

✅ **В CI/CD secrets:**
- Все вышеперечисленное для автоматической сборки

❌ **НИКОГДА в Git:**
- Keystore файлы
- Пароли в открытом виде
- API ключи
- Сертификаты

## 🚀 Автоматизированная публикация

### GitHub Actions / GitLab CI

Если используете CI/CD, добавьте secrets:

```yaml
# Пример секретов для GitHub Actions
ANDROID_KEYSTORE_BASE64  # Base64 закодированный keystore
ANDROID_KEYSTORE_PASSWORD
ANDROID_KEY_PASSWORD
APP_STORE_CONNECT_KEY_ID
APP_STORE_CONNECT_ISSUER_ID
APP_STORE_CONNECT_KEY_CONTENT  # Содержимое .p8 файла
```

### Кодирование Keystore в Base64

```bash
# Для хранения в CI/CD
base64 -i android/upload-keystore.jks | pbcopy  # macOS
base64 android/upload-keystore.jks | xclip  # Linux
```

## 📝 Восстановление после утечки

Если keystore или секреты случайно попали в Git:

### 1. Немедленные действия

```bash
# Удалите из всей истории Git (ОПАСНО!)
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch android/upload-keystore.jks" \
  --prune-empty --tag-name-filter cat -- --all

# Или используйте BFG Repo-Cleaner (рекомендуется)
bfg --delete-files upload-keystore.jks
```

### 2. Ротация секретов

- **Android:** Создайте новый keystore (потребует новый release в Play Store)
- **iOS:** Отзовите и создайте новые certificates
- **API Keys:** Создайте новые ключи в App Store Connect
- **Пароли:** Измените все пароли

### 3. Уведомления

Если проект публичный:
- Уведомите команду
- Измените все credentials
- Проверьте логи доступа в App Store Connect / Play Console

## ✅ Checklist перед каждым коммитом

- [ ] `git status` не показывает файлы из списка "Что НЕ должно попадать в Git"
- [ ] Проверили, что не добавили новые секреты в код
- [ ] `.gitignore` актуален
- [ ] Template файлы (`.example`) обновлены при необходимости

## 📚 Дополнительные ресурсы

- [Flutter: Signing Android Apps](https://docs.flutter.dev/deployment/android#signing-the-app)
- [Flutter: iOS Deployment](https://docs.flutter.dev/deployment/ios)
- [Fastlane Match](https://docs.fastlane.tools/actions/match/)
- [BFG Repo-Cleaner](https://rtyley.github.io/bfg-repo-cleaner/)

---

**Помните: Лучше потратить время на правильную настройку сейчас, чем разбираться с последствиями утечки потом! 🔒**



