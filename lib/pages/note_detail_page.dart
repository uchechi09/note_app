import 'package:flutter/material.dart';
import 'package:note_app/models/note.dart';
import 'package:note_app/pages/create_edit_note_page.dart';
import 'package:note_app/provider/note_provider.dart';
import 'package:provider/provider.dart';

class NoteDetailPage extends StatelessWidget {
  final String noteId;

  const NoteDetailPage({super.key, required this.noteId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Note>>(
      stream: context.read<NoteProvider>().notesStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final note = snapshot.data!
            .firstWhere((n) => n.id == noteId);

        return CreateEditNotePage(note: note);
      },
    );
  }
}
