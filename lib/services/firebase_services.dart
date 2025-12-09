import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:note_app/models/note.dart';

class FirebaseService {
  final CollectionReference _notesCollection = FirebaseFirestore.instance
      .collection('notes');

  // Get notes stream
  Stream<List<Note>> getNotesStream() {
    return _notesCollection
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Note.fromJson(doc.data() as Map<String, dynamic>);
          }).toList();
        });
  }

  // Add a new note
  Future<void> addNote(Note note) async {
    await _notesCollection.doc(note.id).set(note.toJson());
  }

  // Update an existing note
  Future<void> updateNote(Note note) async {
    await _notesCollection.doc(note.id).update(note.toJson());
  }

  // Delete a note
  Future<void> deleteNote(String noteId) async {
    await _notesCollection.doc(noteId).delete();
  }
}