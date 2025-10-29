import 'package:json_annotation/json_annotation.dart';

part 'mahabharata_comic.g.dart';

/// Модель комикса Махабхараты в формате .comics / .boranko
/// Поддерживает старый формат с полной обратной совместимостью
@JsonSerializable()
class MahabharataComic {
  /// Уникальный идентификатор комикса
  final String id;
  
  /// Название эпизода
  final String title;
  
  /// Описание эпизода
  final String description;
  
  /// Порядковый номер эпизода в Махабхарате
  final int episodeNumber;
  
  /// Список панелей комикса
  final List<ComicPanel> panels;
  
  /// Теги для поиска
  final List<String> tags;
  
  /// Персонажи, участвующие в эпизоде
  final List<String> characters;
  
  /// Связь с джапой (опционально)
  /// Указывает на какой бусине/круге показывать этот комикс
  final JapaConnection? japaConnection;
  
  /// Дата создания
  final DateTime createdAt;
  
  /// Дата последнего обновления
  final DateTime updatedAt;
  
  /// Является ли комикс избранным
  final bool isFavorite;
  
  /// Прогресс чтения (0.0 - 1.0)
  final double readProgress;
  
  /// Метаданные для аналитики
  final Map<String, dynamic>? metadata;

  MahabharataComic({
    required this.id,
    required this.title,
    required this.description,
    required this.episodeNumber,
    required this.panels,
    this.tags = const [],
    this.characters = const [],
    this.japaConnection,
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
    this.readProgress = 0.0,
    this.metadata,
  });

  factory MahabharataComic.fromJson(Map<String, dynamic> json) =>
      _$MahabharataComicFromJson(json);

  Map<String, dynamic> toJson() => _$MahabharataComicToJson(this);

  /// Создает копию с обновленными полями
  MahabharataComic copyWith({
    String? id,
    String? title,
    String? description,
    int? episodeNumber,
    List<ComicPanel>? panels,
    List<String>? tags,
    List<String>? characters,
    JapaConnection? japaConnection,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
    double? readProgress,
    Map<String, dynamic>? metadata,
  }) {
    return MahabharataComic(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      episodeNumber: episodeNumber ?? this.episodeNumber,
      panels: panels ?? this.panels,
      tags: tags ?? this.tags,
      characters: characters ?? this.characters,
      japaConnection: japaConnection ?? this.japaConnection,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      readProgress: readProgress ?? this.readProgress,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Панель комикса (один кадр)
@JsonSerializable()
class ComicPanel {
  /// Идентификатор панели
  final String id;
  
  /// Порядковый номер панели
  final int order;
  
  /// Путь к изображению панели
  final String imagePath;
  
  /// Текст панели (речь, мысли)
  final List<PanelText> texts;
  
  /// Звуковые эффекты (опционально)
  final String? soundEffect;
  
  /// Длительность отображения (в секундах)
  final double displayDuration;
  
  /// Тип перехода к следующей панели
  final TransitionType transitionType;

  ComicPanel({
    required this.id,
    required this.order,
    required this.imagePath,
    this.texts = const [],
    this.soundEffect,
    this.displayDuration = 3.0,
    this.transitionType = TransitionType.fade,
  });

  factory ComicPanel.fromJson(Map<String, dynamic> json) =>
      _$ComicPanelFromJson(json);

  Map<String, dynamic> toJson() => _$ComicPanelToJson(this);
}

/// Текст на панели комикса
@JsonSerializable()
class PanelText {
  /// Текст
  final String text;
  
  /// Тип текста (речь, мысли, повествование)
  final TextType type;
  
  /// Персонаж, говорящий этот текст
  final String? character;
  
  /// Позиция текста на панели (0.0 - 1.0)
  final TextPosition position;

  PanelText({
    required this.text,
    required this.type,
    this.character,
    required this.position,
  });

  factory PanelText.fromJson(Map<String, dynamic> json) =>
      _$PanelTextFromJson(json);

  Map<String, dynamic> toJson() => _$PanelTextToJson(this);
}

/// Позиция текста на панели
@JsonSerializable()
class TextPosition {
  final double x; // 0.0 - 1.0 (слева направо)
  final double y; // 0.0 - 1.0 (сверху вниз)

  TextPosition({
    required this.x,
    required this.y,
  });

  factory TextPosition.fromJson(Map<String, dynamic> json) =>
      _$TextPositionFromJson(json);

  Map<String, dynamic> toJson() => _$TextPositionToJson(this);
}

/// Связь комикса с джапа-практикой
@JsonSerializable()
class JapaConnection {
  /// Номер бусины (1-108)
  final int? beadNumber;
  
  /// Номер круга
  final int? roundNumber;
  
  /// Показывать комикс после завершения круга
  final bool showAfterRound;
  
  /// Показывать комикс как награду за достижение
  final bool showAsReward;
  
  /// Минимальное количество кругов для разблокировки
  final int minRoundsToUnlock;

  JapaConnection({
    this.beadNumber,
    this.roundNumber,
    this.showAfterRound = false,
    this.showAsReward = false,
    this.minRoundsToUnlock = 0,
  });

  factory JapaConnection.fromJson(Map<String, dynamic> json) =>
      _$JapaConnectionFromJson(json);

  Map<String, dynamic> toJson() => _$JapaConnectionToJson(this);
}

/// Тип перехода между панелями
enum TransitionType {
  @JsonValue('none')
  none,
  
  @JsonValue('fade')
  fade,
  
  @JsonValue('slide')
  slide,
  
  @JsonValue('zoom')
  zoom,
  
  @JsonValue('dissolve')
  dissolve,
}

/// Тип текста на панели
enum TextType {
  @JsonValue('speech')
  speech, // Речь персонажа
  
  @JsonValue('thought')
  thought, // Мысли персонажа
  
  @JsonValue('narration')
  narration, // Повествование автора
  
  @JsonValue('sound')
  sound, // Звуковой эффект
}

/// Коллекция комиксов Махабхараты
@JsonSerializable()
class MahabharataComicCollection {
  /// Название коллекции
  final String name;
  
  /// Описание коллекции
  final String description;
  
  /// Версия формата
  final String formatVersion;
  
  /// Список комиксов
  final List<MahabharataComic> comics;
  
  /// Метаданные коллекции
  final CollectionMetadata metadata;

  MahabharataComicCollection({
    required this.name,
    required this.description,
    this.formatVersion = '1.0.0',
    required this.comics,
    required this.metadata,
  });

  factory MahabharataComicCollection.fromJson(Map<String, dynamic> json) =>
      _$MahabharataComicCollectionFromJson(json);

  Map<String, dynamic> toJson() => _$MahabharataComicCollectionToJson(this);
}

/// Метаданные коллекции
@JsonSerializable()
class CollectionMetadata {
  /// Автор коллекции
  final String author;
  
  /// Дата создания коллекции
  final DateTime createdAt;
  
  /// Язык комиксов
  final String language;
  
  /// Общее количество эпизодов
  final int totalEpisodes;
  
  /// Дополнительная информация
  final Map<String, dynamic>? extra;

  CollectionMetadata({
    required this.author,
    required this.createdAt,
    this.language = 'ru',
    required this.totalEpisodes,
    this.extra,
  });

  factory CollectionMetadata.fromJson(Map<String, dynamic> json) =>
      _$CollectionMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$CollectionMetadataToJson(this);
}

