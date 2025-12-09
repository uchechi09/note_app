import 'package:flutter/material.dart';
import 'package:note_app/widets/delete_dialog.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../provider/note_provider.dart';
import '../utils/constant.dart';
import 'create_edit_note_page.dart';

class NoteDetailPage extends StatelessWidget {
  final Note note;

  const NoteDetailPage({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Note>>(
      stream: Provider.of<NoteProvider>(context).notesStream,
      initialData: [note],
      builder: (context, snapshot) {
        final notes = snapshot.data ?? [];
        // Find the updated note or return null if it was deleted
        final updatedNote = notes.firstWhere(
          (n) => n.id == note.id,
          orElse: () => Note(
            id: '',
            title: '',
            content: '',
            color: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ), // Return explicitly empty note to signal deletion
        );

        // If the ID is empty, it means the note was not found (deleted)
        if (updatedNote.id.isEmpty) {
          // Schedule the pop after the frame to avoid build collision
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) Navigator.pop(context);
          });
          return const Scaffold(body: SizedBox.shrink());
        }

        return Scaffold(
          backgroundColor: AppConstants.getColorFromHex(updatedNote.color),
          appBar: AppBar(
            backgroundColor: Colors.white70,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              // Edit button
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.black),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CreateEditNotePage(note: updatedNote),
                    ),
                  );
                },
              ),

              // Delete button
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => DeleteDialog(
                      onDelete: () async {
                        try {
                          await Provider.of<NoteProvider>(
                            context,
                            listen: false,
                          ).deleteNote(updatedNote.id);
                          // No manual pop needed here, the stream listener above will handle it
                          if (context.mounted) {
                            Navigator.pop(context); // Pop the dialog
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error deleting note: $e'),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  updatedNote.title.isEmpty ? 'Untitled' : updatedNote.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),

                // Date
                Text(
                  DateFormat(
                    'MMMM d, y \'at\' hh:mm a',
                  ).format(updatedNote.updatedAt),
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 24),

                // Content
                Text(
                  updatedNote.content,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}