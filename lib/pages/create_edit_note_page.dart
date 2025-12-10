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
  bool _isFavourite = false;
  DateTime? _reminder;

  @override
  void initState() {
    super.initState();

    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _selectedColor = widget.note!.color;
      _isFavourite = widget.note!.isFavourite;
      _reminder = widget.note!.reminder;
    } else {
      _selectedColor =
          AppConstants.getHexFromColor(AppConstants.noteColors[0]);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickReminder() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(minutes: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    setState(() {
      _reminder = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _saveNote() async {
    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Content is required')),
      );
      return;
    }

    final provider = Provider.of<NoteProvider>(context, listen: false);
    final navigator = Navigator.of(context);

    final Note newNote;

    if (widget.note != null) {
      newNote = widget.note!.copyWith(
        title: _titleController.text,
        content: _contentController.text,
        color: _selectedColor,
        updatedAt: DateTime.now(),
        isFavourite: _isFavourite,
        reminder: _isFavourite ? _reminder : null,
      );

      await provider.updateNote(newNote);
    } else {
      newNote = Note(
        id: const Uuid().v4(),
        title: _titleController.text,
        content: _contentController.text,
        color: _selectedColor,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isFavourite: _isFavourite,
        reminder: _isFavourite ? _reminder : null,
      );

      await provider.addNote(newNote);
    }

    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.getColorFromHex(_selectedColor),
      appBar: AppBar(
        backgroundColor: Colors.white70,
        actions: [
          // ⭐ Favorite toggle
          IconButton(
            icon: Icon(
              _isFavourite ? Icons.star : Icons.star_border,
              color: Colors.pink,
              size: 28,
            ),
            onPressed: () {
              setState(() {
                _isFavourite = !_isFavourite;
                if (!_isFavourite) _reminder = null;
              });
            },
          ),

          // ⏰ Reminder button (only if favourite)
          if (_isFavourite)
            IconButton(
              icon: const Icon(Icons.alarm, color: Colors.pink, size: 26),
              onPressed: _pickReminder,
            ),

          // ✔ Save button
          IconButton(
            onPressed: _saveNote,
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

          if (_reminder != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(top: 10, bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.alarm, color: Colors.black87),
                  const SizedBox(width: 8),
                  Text(
                    "Reminder: $_reminder",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _reminder = null),
                  ),
                ],
              ),
            ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'Title',
                      border: InputBorder.none,
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
                    maxLines: null,
                    style:
                        const TextStyle(fontSize: 18, color: Colors.black87),
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
