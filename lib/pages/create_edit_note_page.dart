import 'package:flutter/material.dart';
import 'package:note_app/models/note.dart';
import 'package:note_app/provider/note_provider.dart';
import 'package:note_app/utils/constant.dart';
import 'package:note_app/widets/color_selector.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CreateEditNotePage extends StatefulWidget {
  final Note? note;
  const CreateEditNotePage({super.key, this.note});

  @override
  State<CreateEditNotePage> createState() => _CreateEditNotePageState();
}

class _CreateEditNotePageState extends State<CreateEditNotePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _selectedColor = '';

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _selectedColor = widget.note!.color;
    } else {
      _selectedColor = AppConstants.getHexFromColor(AppConstants.noteColors[0]);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.getColorFromHex(_selectedColor),
      appBar: AppBar(
        backgroundColor: Colors.white70,
        actions: [
          IconButton(
            onPressed: () async {
              if (_contentController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Content is required')),
                );
                return;
              }

              final provider = Provider.of<NoteProvider>(
                context,
                listen: false,
              );

              final Note updatedNote;
              if (widget.note != null) {
                // Update existing note
                updatedNote = widget.note!.copyWith(
                  title: _titleController.text,
                  content: _contentController.text,
                  color: _selectedColor,
                  updatedAt: DateTime.now(),
                );
                await provider.updateNote(updatedNote);
              } else {
                // Create new note
                updatedNote = Note(
                  id: const Uuid().v4(),
                  title: _titleController.text,
                  content: _contentController.text,
                  color: _selectedColor,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                await provider.addNote(updatedNote);
              }
              if (mounted) {
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.check, color: Colors.black87),
          ),
        ],
      ),
      body: Column(
        children: [
          ColorSelector(
            selectedColor: _selectedColor,
            onColorSelected: (color) {
              setState(() {
                _selectedColor = color;
              });
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'Title',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.black38),
                    ),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      hintText: 'Start writing your note...',
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 18, color: Colors.black87),
                    maxLines: null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}