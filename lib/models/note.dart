import 'package:json_annotation/json_annotation.dart';

part 'note.g.dart';
@JsonSerializable()
class Note{
  final String id;
  final String title;
  final String content;
  final String color;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavourite;
  final DateTime? reminder;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
    this.isFavourite = false,
    this.reminder,
  });

factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
Map<String, dynamic> toJson() => _$NoteToJson(this);

 // CopyWith method for updating notes
  Note copyWith({
    String? id,
    String? title,
    String? content,
    String? color,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavourite,
    DateTime? reminder,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavourite: isFavourite ?? this.isFavourite,
      reminder: reminder ?? this.reminder,
    );
  }


}

