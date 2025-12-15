import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:note_app/models/note.dart';

class FirebaseService {
  final CollectionReference _notesCollection =
      FirebaseFirestore.instance.collection('notes');

  // Stream all notes ordered by update time
  Stream<List<Note>> getNotesStream() {
    return _notesCollection
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Note.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Fetch a note by ID
  Future<Note?> getNoteById(String id) async {
    final doc = await _notesCollection.doc(id).get();
    if (!doc.exists) return null;
    return Note.fromJson(doc.data() as Map<String, dynamic>);
  }

  // Add new note
  Future<void> addNote(Note note) async {
    await _notesCollection.doc(note.id).set(note.toJson());
  }

  // Update note
  Future<void> updateNote(Note note) async {
    await _notesCollection.doc(note.id).update(note.toJson());
  }

  // Delete note
  Future<void> deleteNote(String noteId) async {
    await _notesCollection.doc(noteId).delete();
  }
}
