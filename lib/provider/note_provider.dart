import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:note_app/models/note.dart';
import 'package:note_app/services/firebase_services.dart';
import 'package:note_app/main.dart';

class NoteProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  Stream<List<Note>>? _notesStream;

  Stream<List<Note>> get notesStream {
    _notesStream ??= _firebaseService.getNotesStream();
    return _notesStream!;
  }

  String _formatContent(String content) {
    final text = content
        .trim()
        .replaceAll('\n', ' ')
        .replaceAll(RegExp(r'\s+'), ' ');

    if (text.isEmpty) return '';
    if (text.length <= 60) return text;

    return '${text.substring(0, 60)}…';
  }

  Future<void> addNote(Note note) async {
    await _firebaseService.addNote(note);

    if (note.reminder != null) {
      final notifId = note.id.hashCode;

      await scheduleReminder(
        payload: note.id,
        repeatType: DateTimeComponents.dayOfWeekAndTime,
        notifId,
        note.reminder!,
        note.title,
        _formatContent(note.content),
      );
    }

    notifyListeners();
  }

  Future<void> updateNote(Note note) async {
    final oldNote = await _firebaseService.getNoteById(note.id);

    if (oldNote != null) {
      final notifId = note.id.hashCode;

      // Cancel old reminder if it existed
      if (oldNote.reminder != null) {
        await cancelReminder(notifId);
      }

      // Schedule new reminder if it exists
      if (note.reminder != null) {
        await scheduleReminder(
          repeatType: DateTimeComponents.dayOfWeekAndTime,
          payload: note.id,
          notifId,
          note.reminder!,
          note.title,
          _formatContent(note.content),
        );
      }
    }

    await _firebaseService.updateNote(note);
    notifyListeners();
  }

  Future<void> deleteNote(String noteId) async {
    final oldNote = await _firebaseService.getNoteById(noteId);

    if (oldNote?.reminder != null) {
      await cancelReminder(noteId.hashCode);
    }

    await _firebaseService.deleteNote(noteId);
    notifyListeners();
  }
}
