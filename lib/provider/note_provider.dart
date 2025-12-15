import 'package:flutter/material.dart';
import 'package:note_app/models/note.dart';
import 'package:note_app/services/firebase_services.dart';
import 'package:note_app/main.dart';
import 'dart:math';

class NoteProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  Stream<List<Note>>? _notesStream;

  Stream<List<Note>> get notesStream {
    _notesStream ??= _firebaseService.getNotesStream();
    return _notesStream!;
  }

  // Generate unique notification ID
  int _generateNotificationId() {
    return Random().nextInt(999999999);
  }

  // Format note content for notification preview
  String _formatContent(String content) {
    final text = content
        .trim()
        .replaceAll('\n', ' ')
        .replaceAll(RegExp(r'\s+'), ' ');

    if (text.isEmpty) return '';
    if (text.length <= 60) return text;

    return '${text.substring(0, 60)}…';
  }

  // Handle reminder scheduling and cancellation on update
  Future<void> _handleReminder(Note oldNote, Note newNote) async {
    final oldReminder = oldNote.reminder;
    final newReminder = newNote.reminder;
    final oldId = oldNote.notificationId;
    final newId = newNote.notificationId;

    // No reminder before or after
    if (oldReminder == null && newReminder == null) return;

    // New reminder added
    if (oldReminder == null && newReminder != null) {
      final id = newId ?? _generateNotificationId();
      await scheduleReminder(
        id,
        newReminder,
        newNote.title,
        _formatContent(newNote.content),
      );
      await _firebaseService.updateNote(newNote.copyWith(notificationId: id));
      return;
    }

    // Reminder removed
    if (oldReminder != null && newReminder == null) {
      if (oldId != null) await cancelReminder(oldId);
      await _firebaseService.updateNote(newNote.copyWith(notificationId: null));
      return;
    }

    // Reminder changed
    if (oldReminder != null && newReminder != null) {
      if (oldId != null) await cancelReminder(oldId);
      final id = newId ?? _generateNotificationId();
      await scheduleReminder(
        id,
        newReminder,
        newNote.title,
        _formatContent(newNote.content),
      );
      await _firebaseService.updateNote(newNote.copyWith(notificationId: id));
    }
  }

  // Add new note and schedule reminder if needed
  Future<void> addNote(Note note) async {
    Note updated = note;

    if (note.reminder != null) {
      final id = note.notificationId ?? _generateNotificationId();
      await scheduleReminder(
        id,
        note.reminder!,
        note.title,
        _formatContent(note.content),
      );
      updated = note.copyWith(notificationId: id);
    }

    await _firebaseService.addNote(updated);
    notifyListeners();
  }

  // Update note and adjust reminder accordingly
  Future<void> updateNote(Note note) async {
    final oldNote = await _firebaseService.getNoteById(note.id);
    if (oldNote != null) {
      await _handleReminder(oldNote, note);
    }

    await _firebaseService.updateNote(note);
    notifyListeners();
  }

  // Delete note and cancel reminder if exists
  Future<void> deleteNote(String noteId) async {
    final oldNote = await _firebaseService.getNoteById(noteId);
    if (oldNote != null && oldNote.notificationId != null) {
      await cancelReminder(oldNote.notificationId!);
    }

    await _firebaseService.deleteNote(noteId);
    notifyListeners();
  }
}
