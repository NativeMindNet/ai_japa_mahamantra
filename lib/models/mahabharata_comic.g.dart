// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mahabharata_comic.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MahabharataComic _$MahabharataComicFromJson(Map<String, dynamic> json) =>
    MahabharataComic(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      episodeNumber: (json['episodeNumber'] as num).toInt(),
      panels: (json['panels'] as List<dynamic>)
          .map((e) => ComicPanel.fromJson(e as Map<String, dynamic>))
          .toList(),
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      characters:
          (json['characters'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      japaConnection: json['japaConnection'] == null
          ? null
          : JapaConnection.fromJson(
              json['japaConnection'] as Map<String, dynamic>,
            ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
      readProgress: (json['readProgress'] as num?)?.toDouble() ?? 0.0,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$MahabharataComicToJson(MahabharataComic instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'episodeNumber': instance.episodeNumber,
      'panels': instance.panels,
      'tags': instance.tags,
      'characters': instance.characters,
      'japaConnection': instance.japaConnection,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isFavorite': instance.isFavorite,
      'readProgress': instance.readProgress,
      'metadata': instance.metadata,
    };

ComicPanel _$ComicPanelFromJson(Map<String, dynamic> json) => ComicPanel(
  id: json['id'] as String,
  order: (json['order'] as num).toInt(),
  imagePath: json['imagePath'] as String,
  texts:
      (json['texts'] as List<dynamic>?)
          ?.map((e) => PanelText.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  soundEffect: json['soundEffect'] as String?,
  displayDuration: (json['displayDuration'] as num?)?.toDouble() ?? 3.0,
  transitionType:
      $enumDecodeNullable(_$TransitionTypeEnumMap, json['transitionType']) ??
      TransitionType.fade,
);

Map<String, dynamic> _$ComicPanelToJson(ComicPanel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order': instance.order,
      'imagePath': instance.imagePath,
      'texts': instance.texts,
      'soundEffect': instance.soundEffect,
      'displayDuration': instance.displayDuration,
      'transitionType': _$TransitionTypeEnumMap[instance.transitionType]!,
    };

const _$TransitionTypeEnumMap = {
  TransitionType.none: 'none',
  TransitionType.fade: 'fade',
  TransitionType.slide: 'slide',
  TransitionType.zoom: 'zoom',
  TransitionType.dissolve: 'dissolve',
};

PanelText _$PanelTextFromJson(Map<String, dynamic> json) => PanelText(
  text: json['text'] as String,
  type: $enumDecode(_$TextTypeEnumMap, json['type']),
  character: json['character'] as String?,
  position: TextPosition.fromJson(json['position'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PanelTextToJson(PanelText instance) => <String, dynamic>{
  'text': instance.text,
  'type': _$TextTypeEnumMap[instance.type]!,
  'character': instance.character,
  'position': instance.position,
};

const _$TextTypeEnumMap = {
  TextType.speech: 'speech',
  TextType.thought: 'thought',
  TextType.narration: 'narration',
  TextType.sound: 'sound',
};

TextPosition _$TextPositionFromJson(Map<String, dynamic> json) => TextPosition(
  x: (json['x'] as num).toDouble(),
  y: (json['y'] as num).toDouble(),
);

Map<String, dynamic> _$TextPositionToJson(TextPosition instance) =>
    <String, dynamic>{'x': instance.x, 'y': instance.y};

JapaConnection _$JapaConnectionFromJson(Map<String, dynamic> json) =>
    JapaConnection(
      beadNumber: (json['beadNumber'] as num?)?.toInt(),
      roundNumber: (json['roundNumber'] as num?)?.toInt(),
      showAfterRound: json['showAfterRound'] as bool? ?? false,
      showAsReward: json['showAsReward'] as bool? ?? false,
      minRoundsToUnlock: (json['minRoundsToUnlock'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$JapaConnectionToJson(JapaConnection instance) =>
    <String, dynamic>{
      'beadNumber': instance.beadNumber,
      'roundNumber': instance.roundNumber,
      'showAfterRound': instance.showAfterRound,
      'showAsReward': instance.showAsReward,
      'minRoundsToUnlock': instance.minRoundsToUnlock,
    };

MahabharataComicCollection _$MahabharataComicCollectionFromJson(
  Map<String, dynamic> json,
) => MahabharataComicCollection(
  name: json['name'] as String,
  description: json['description'] as String,
  formatVersion: json['formatVersion'] as String? ?? '1.0.0',
  comics: (json['comics'] as List<dynamic>)
      .map((e) => MahabharataComic.fromJson(e as Map<String, dynamic>))
      .toList(),
  metadata: CollectionMetadata.fromJson(
    json['metadata'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$MahabharataComicCollectionToJson(
  MahabharataComicCollection instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'formatVersion': instance.formatVersion,
  'comics': instance.comics,
  'metadata': instance.metadata,
};

CollectionMetadata _$CollectionMetadataFromJson(Map<String, dynamic> json) =>
    CollectionMetadata(
      author: json['author'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      language: json['language'] as String? ?? 'ru',
      totalEpisodes: (json['totalEpisodes'] as num).toInt(),
      extra: json['extra'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$CollectionMetadataToJson(CollectionMetadata instance) =>
    <String, dynamic>{
      'author': instance.author,
      'createdAt': instance.createdAt.toIso8601String(),
      'language': instance.language,
      'totalEpisodes': instance.totalEpisodes,
      'extra': instance.extra,
    };
