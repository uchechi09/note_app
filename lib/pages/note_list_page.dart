import 'package:flutter/material.dart';
import 'package:note_app/models/note.dart';
import 'package:note_app/pages/create_edit_note_page.dart';
import 'package:note_app/pages/note_view_page.dart';
import 'package:note_app/provider/note_provider.dart';
import 'package:note_app/widets/dark_mode_dialog.dart';
import 'package:note_app/widets/note_card.dart';
import 'package:provider/provider.dart';

class NoteListPage extends StatefulWidget {
  const NoteListPage({super.key});

  @override
  State<NoteListPage> createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Notes',
          style: TextStyle(
            color: Colors.pink,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
         actions: [
    IconButton(
      icon: const Icon(Icons.brightness_6, color: Colors.pink),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => const DarkModeDialog(),
        );
      },
    ),
  ],
      ),
      body: StreamBuilder<List<Note>>(
        stream: Provider.of<NoteProvider>(context).notesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No notes yet.\nTap + to create your first note!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }

          final notes = snapshot.data!;
          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return NoteCard(
                note: note,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NoteDetailPage(note: note),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: Container(
        height: 70,
        width: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [
              Color(0xFF9115D4), // Purple
              Color(0xFFFECFEF), // Lighter pink
              Color(0xFFE2525C), // Light pink
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateEditNotePage()),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.add,
            size: 34,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
