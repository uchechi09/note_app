import 'package:flutter/material.dart';
import 'package:note_app/models/note.dart';
import 'package:note_app/services/firebase_services.dart';

class NoteProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  Stream<List<Note>>? _notesStream;

  Stream<List<Note>> get notesStream {
    _notesStream ??= _firebaseService.getNotesStream();
    return _notesStream!;
  }

  Future<void> addNote(Note note) async {
    try {
      await _firebaseService.addNote(note);
      notifyListeners();
    } catch (e) {
      print('Error adding note: $e');
      rethrow;
    }
  }

  Future<void> updateNote(Note note) async {
    try {
      await _firebaseService.updateNote(note);
      notifyListeners();
    } catch (e) {
      print('Error updating note: $e');
      rethrow;
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      await _firebaseService.deleteNote(noteId);
      notifyListeners();
    } catch (e) {
      print('Error deleting note: $e');
      rethrow;
    }
  }
}
