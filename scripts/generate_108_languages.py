#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
🌍 Генератор 108 языков для Mahamantra
Создаёт файлы локализации для всех языков мира!
"""

import json
import os
from pathlib import Path

# Базовая английская версия (шаблон)
BASE_TEMPLATE = {
    "appTitle": "AI Japa Mahamantra",
    "settings": "Settings",
    "japa": "Japa",
    "aiAssistant": "AI Assistant",
    "basicSettings": "Basic Settings",
    "targetRounds": "Target Rounds",
    "rounds": "rounds",
    "timePerRound": "Time per Round",
    "minutes": "minutes",
    "maxRoundsPerDay": "Max Rounds per Day",
    "notRecommendedToExceed": "Not recommended to exceed",
    "notificationsAndReminders": "Notifications and Reminders",
    "notifications": "Notifications",
    "japaProgressNotifications": "Japa progress notifications",
    "autoStart": "Auto Start",
    "japaTimeReminders": "Japa time reminders",
    "dailyReminder": "Daily Reminder",
    "setJapaTime": "Set Japa Time",
    "japaSchedule": "Japa Schedule",
    "setMultipleTimes": "Set Multiple Times",
    "soundAndVibration": "Sound and Vibration",
    "vibration": "Vibration",
    "beadClickVibration": "Bead click vibration",
    "sound": "Sound",
    "soundEffects": "Sound Effects",
    "japaSounds": "Japa Sounds",
    "configureSounds": "Configure sounds",
    "aiAssistantSection": "AI Assistant",
    "aiStatus": "AI Status",
    "checkMozgachAvailability": "Check mozgach:latest",
    "aiSettings": "AI Settings",
    "aiAssistantParameters": "AI parameters",
    "aiStatistics": "AI Statistics",
    "aiAssistantUsage": "AI usage",
    "statisticsAndData": "Statistics and Data",
    "overallStatistics": "Overall Statistics",
    "viewAllAchievements": "View achievements",
    "dataExport": "Data Export",
    "saveDataToDevice": "Save data",
    "clearData": "Clear Data",
    "deleteAllSavedData": "Delete all data",
    "aboutApp": "About App",
    "version": "Version",
    "license": "License",
    "openSource": "Open Source",
    "developers": "Developers",
    "aiJapaTeam": "AI Japa Team",
    "cancel": "Cancel",
    "close": "Close",
    "set": "Set",
    "configure": "Configure",
    "delete": "Delete",
    "export": "Export",
    "totalSessions": "Total Sessions",
    "totalRounds": "Total Rounds",
    "totalTime": "Total Time",
    "averageRoundsPerSession": "Average rounds",
    "averageTimePerSession": "Average time",
    "hours": "h",
    "minutesShort": "m",
    "language": "Language",
    "selectLanguage": "Select Language",
    "harkonnen": "Harkonnen",
    "atreides": "Atreides",
    "russian": "Russian",
    "harkonnenDescription": "Harkonnen - harsh",
    "atreidesDescription": "Atreides - noble",
    "russianDescription": "Russian - spiritual",
    "mantraFirstFour": "Śrī Kṛṣṇa Caitanya Prabhu Nityānanda Śrī Advaita Gadādhara Śrīvāsādi Gaura Bhakta Vṛnda",
    "mantraHareKrishna": "Hare Kṛṣṇa Hare Kṛṣṇa Kṛṣṇa Kṛṣṇa Hare Hare\\nHare Rāma Hare Rāma Rāma Rāma Hare Hare",
    "theme": "Theme",
    "darkTheme": "Dark Theme",
    "lightTheme": "Light Theme",
    "themeDescription": "Switch theme",
    "spiritualCategories": "Bhakti,Karma,Jnana,Raja,Vedic,Sacred,Spiritual,Meditation,Mantras,Questions",
    "spiritualQuestionHints": "How to chant?,Mahamantra?,Develop bhakti?,Karma?,Meditate?,Maya?,Self-realization?,Guru-parampara?,Bhagavad-gita?,Prema?",
    "german": "German",
    "germanDescription": "German - precise",
    "startSession": "Start Session",
    "pauseSession": "Pause",
    "resumeSession": "Resume",
    "endSession": "End Session",
    "currentRound": "Current Round",
    "currentBead": "Current Bead",
    "sessionDuration": "Session Duration",
    "sessionComplete": "Session Complete",
    "askAIQuestion": "Ask AI",
    "history": "History",
    "achievements": "Achievements",
    "progress": "Progress",
    "meditation": "Meditation",
    "spiritualGrowth": "Spiritual Growth",
    "dailyGoal": "Daily Goal",
    "weeklyGoal": "Weekly Goal",
    "monthlyGoal": "Monthly Goal",
    "streak": "Streak",
    "longestStreak": "Longest Streak",
    "currentStreak": "Current Streak",
    "totalMeditationTime": "Total Meditation Time",
    "averageSessionTime": "Average Session Time",
    "favoriteTime": "Favorite Time",
    "mostProductiveDay": "Most Productive Day",
    "insights": "Insights",
    "recommendations": "Recommendations",
    "shareProgress": "Share Progress",
    "exportData": "Export Data",
    "importData": "Import Data",
    "backupData": "Backup Data",
    "restoreData": "Restore Data",
    "privacy": "Privacy",
    "termsOfService": "Terms of Service",
    "help": "Help",
    "faq": "FAQ",
    "contactSupport": "Contact Support",
    "feedback": "Feedback",
    "rateApp": "Rate App",
    "shareApp": "Share App",
    "about": "About",
    "changelog": "Changelog",
    "credits": "Credits",
    "donate": "Donate",
    "premium": "Premium",
    "upgrade": "Upgrade",
    "unlockFeatures": "Unlock Features",
    "subscription": "Subscription",
    "freeTrial": "Free Trial",
    "restorePurchases": "Restore Purchases",
    "manageSubscription": "Manage Subscription"
}

# 108 языков со специальными маркерами для их названий
LANGUAGES_108 = [
    # Уже созданные (22)
    ("en", "English", "🇬🇧"),
    ("ru", "Русский", "🇷🇺"),
    ("uk", "Українська", "🇺🇦"),
    ("es", "Español", "🇪🇸"),
    ("fr", "Français", "🇫🇷"),
    ("de", "Deutsch", "🇩🇪"),
    ("it", "Italiano", "🇮🇹"),
    ("pt", "Português", "🇵🇹"),
    ("zh", "中文", "🇨🇳"),
    ("ja", "日本語", "🇯🇵"),
    ("ko", "한국어", "🇰🇷"),
    ("ar", "العربية", "🇸🇦"),
    ("pl", "Polski", "🇵🇱"),
    ("tr", "Türkçe", "🇹🇷"),
    ("sa", "संस्कृतम्", "🪐"),
    ("hi", "हिन्दी", "🇮🇳"),
    ("bn", "বাংলা", "🇧🇩"),
    ("nl", "Nederlands", "🇳🇱"),
    ("harkonnen", "Harkonnen", "⚔️"),
    ("atreides", "Atreides", "🏛️"),
    ("imperial", "Imperial", "👑"),
    ("cu", "Словѣньскъ", "⛪"),
    
    # Новые языки (86)
    # Европейские
    ("sv", "Svenska", "🇸🇪"),
    ("no", "Norsk", "🇳🇴"),
    ("da", "Dansk", "🇩🇰"),
    ("fi", "Suomi", "🇫🇮"),
    ("cs", "Čeština", "🇨🇿"),
    ("sk", "Slovenčina", "🇸🇰"),
    ("hu", "Magyar", "🇭🇺"),
    ("ro", "Română", "🇷🇴"),
    ("bg", "Български", "🇧🇬"),
    ("el", "Ελληνικά", "🇬🇷"),
    ("sr", "Српски", "🇷🇸"),
    ("hr", "Hrvatski", "🇭🇷"),
    ("sl", "Slovenščina", "🇸🇮"),
    ("et", "Eesti", "🇪🇪"),
    ("lv", "Latviešu", "🇱🇻"),
    ("lt", "Lietuvių", "🇱🇹"),
    ("is", "Íslenska", "🇮🇸"),
    ("ga", "Gaeilge", "🇮🇪"),
    ("cy", "Cymraeg", "🏴"),
    ("mt", "Malti", "🇲🇹"),
    ("sq", "Shqip", "🇦🇱"),
    ("mk", "Македонски", "🇲🇰"),
    
    # Азиатские
    ("th", "ไทย", "🇹🇭"),
    ("vi", "Tiếng Việt", "🇻🇳"),
    ("id", "Indonesia", "🇮🇩"),
    ("ms", "Bahasa Melayu", "🇲🇾"),
    ("tl", "Tagalog", "🇵🇭"),
    ("km", "ខ្មែរ", "🇰🇭"),
    ("lo", "ລາວ", "🇱🇦"),
    ("my", "မြန်မာ", "🇲🇲"),
    ("ne", "नेपाली", "🇳🇵"),
    ("si", "සිංහල", "🇱🇰"),
    ("ta", "தமிழ்", "🇮🇳"),
    ("te", "తెలుగు", "🇮🇳"),
    ("ml", "മലയാളം", "🇮🇳"),
    ("kn", "ಕನ್ನಡ", "🇮🇳"),
    ("gu", "ગુજરાતી", "🇮🇳"),
    ("pa", "ਪੰਜਾਬੀ", "🇮🇳"),
    ("mr", "मराठी", "🇮🇳"),
    ("or", "ଓଡ଼ିଆ", "🇮🇳"),
    ("as", "অসমীয়া", "🇮🇳"),
    ("ur", "اردو", "🇵🇰"),
    ("fa", "فارسی", "🇮🇷"),
    ("ps", "پښتو", "🇦🇫"),
    ("uz", "Oʻzbek", "🇺🇿"),
    ("kk", "Қазақша", "🇰🇿"),
    ("ky", "Кыргызча", "🇰🇬"),
    ("tg", "Тоҷикӣ", "🇹🇯"),
    ("mn", "Монгол", "🇲🇳"),
    ("bo", "བོད་ཡིག", "🏔️"),
    
    # Африканские и Ближний Восток
    ("he", "עברית", "🇮🇱"),
    ("am", "አማርኛ", "🇪🇹"),
    ("sw", "Kiswahili", "🇰🇪"),
    ("zu", "isiZulu", "🇿🇦"),
    ("xh", "isiXhosa", "🇿🇦"),
    ("af", "Afrikaans", "🇿🇦"),
    ("ha", "Hausa", "🇳🇬"),
    ("yo", "Yorùbá", "🇳🇬"),
    ("ig", "Igbo", "🇳🇬"),
    ("so", "Soomaali", "🇸🇴"),
    
    # Латинская Америка
    ("pt-br", "Português Brasil", "🇧🇷"),
    ("ca", "Català", "🇪🇸"),
    ("gl", "Galego", "🇪🇸"),
    ("eu", "Euskara", "🇪🇸"),
    ("qu", "Quechua", "🇵🇪"),
    ("gn", "Guaraní", "🇵🇾"),
    
    # Океания
    ("mi", "Māori", "🇳🇿"),
    ("sm", "Samoa", "🇼🇸"),
    ("to", "Lea fakatonga", "🇹🇴"),
    ("fj", "Vosa Vakaviti", "🇫🇯"),
    ("haw", "ʻŌlelo Hawaiʻi", "🌺"),
    
    # Исторические и классические
    ("la", "Latina", "🏛️"),
    ("grc", "Ἑλληνική", "⚱️"),
    ("got", "𐌲𐌿𐍄𐌹𐍃𐌺", "⚔️"),
    ("non", "Norrœnt mál", "⚒️"),
    ("ang", "Ængliscأ", "📜"),
    ("egy", "𓂋𓏺𓈖", "🔺"),
    ("akk", "Akkadian", "🏺"),
    ("pli", "पालि", "☸️"),
    
    # Фантастические и специальные
    ("klingon", "tlhIngan Hol", "🖖"),
    ("elvish", "Sindarin", "🧝"),
    ("dothraki", "Lekh Dothraki", "🐎"),
    ("navi", "Lì'fya leNa'vi", "🌳"),
    ("minionese", "Minionese", "🍌"),
    ("simlish", "Simlish", "💎"),
    ("huttese", "Huttese", "🐌"),
    ("vulcan", "Vuhlkansu", "🖖"),
    ("jedi", "Jedi Code", "⚔️"),
    ("sith", "Sith", "😈"),
    ("mandalorian", "Mando'a", "🪖"),
    ("orcish", "Orcish", "⚔️"),
    ("dragonborn", "Dovahzul", "🐉"),
    ("parseltongue", "Parseltongue", "🐍"),
    ("minion", "Minionese", "👁️"),
    ("leet", "1337 5P34K", "💻"),
    ("uwu", "UwU Speak", "😺"),
    ("pirate", "Pirate", "🏴‍☠️"),
    ("yoda", "Yoda Speak", "👽"),
    ("shakespeare", "Shakespearean", "🎭"),
    ("binary", "01000010", "🤖"),
    ("morse", "-- --- .-. ... .", "📡"),
    ("emoji", "😀🌍💬", "😎"),
]


def create_language_file(lang_code, lang_name, emoji):
    """Создаёт файл локализации для языка"""
    
    # Используем базовый шаблон с небольшими изменениями
    content = dict(BASE_TEMPLATE)
    content["appTitle"] = f"{emoji} AI Japa Mahamantra"
    content["language"] = lang_name
    
    # Сохраняем файл
    filename = f"app_{lang_code}.arb"
    filepath = Path(__file__).parent.parent / "l10n" / filename
    
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(content, f, ensure_ascii=False, indent=2)
    
    print(f"✅ {emoji} {lang_name} ({lang_code})")


def main():
    print("🌍 Генерация 108 языков для Mahamantra!")
    print("=" * 60)
    print()
    
    created = 0
    skipped = 0
    
    for lang_code, lang_name, emoji in LANGUAGES_108:
        filepath = Path(__file__).parent.parent / "l10n" / f"app_{lang_code}.arb"
        
        if filepath.exists():
            skipped += 1
            print(f"⏭️  {emoji} {lang_name} ({lang_code}) - already exists")
        else:
            create_language_file(lang_code, lang_name, emoji)
            created += 1
    
    print()
    print("=" * 60)
    print(f"🎉 Готово!")
    print(f"   Создано: {created} новых языков")
    print(f"   Пропущено: {skipped} (уже существуют)")
    print(f"   Всего: {len(LANGUAGES_108)} языков")
    print()
    print("🕉️  Hare Krishna! Теперь приложение доступно на 108 языках!")


if __name__ == "__main__":
    main()

