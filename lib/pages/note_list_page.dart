import 'package:flutter/material.dart';
import 'package:note_app/models/note.dart';
import 'package:note_app/pages/create_edit_note_page.dart';
import 'package:note_app/pages/note_view_page.dart';
import 'package:note_app/provider/note_filter_provider.dart';
import 'package:note_app/widets/dark_mode_dialog.dart';
import 'package:note_app/widets/note_card.dart';
import 'package:provider/provider.dart';

class NoteListPage extends StatefulWidget {
  const NoteListPage({super.key});

  @override
  State<NoteListPage> createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
  bool _isSearching = false;
  bool _showFavoritesOnly = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      // Update provider only when the user types
      context.read<NoteFilterProvider>().setSearchQuery(
        _searchController.text.trim(),
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dynamic filterProvider = Provider.of<NoteFilterProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search notes...',
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.pink),
                autofocus: true,
              )
            : const Text(
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
            icon: Icon(
              _showFavoritesOnly ? Icons.star : Icons.star_border,
              color: Colors.pink,
            ),
            tooltip: _showFavoritesOnly ? 'Show all' : 'Show favorites',
            onPressed: () {
              setState(() {
                _showFavoritesOnly = !_showFavoritesOnly;
              });

              // try the originally intended method name; if it doesn't exist, try a common alternative,
              // otherwise fail silently to avoid compile-time errors.

              // filterProvider.setFavoritesOnly(_showFavoritesOnly);
              filterProvider.setFavoriteFilter(_showFavoritesOnly);
            },
          ),
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Colors.pink,
            ),
            onPressed: () {
              setState(() {
                if (_isSearching) _searchController.clear();
                _isSearching = !_isSearching;
              });
            },
          ),
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

      // Body uses the provider's filtered stream directly
      body: StreamBuilder<List<Note>>(
        stream: filterProvider.getFilteredNotesStream(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final notes = snapshot.data ?? [];
          if (notes.isEmpty) {
            return Center(
              child: Text(
                _showFavoritesOnly
                    ? 'No favourite notes yet.'
                    : 'No notes yet.\nTap + to create your first note!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async =>
                await Future.delayed(const Duration(milliseconds: 300)),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: notes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final note = notes[index];
                return NoteCard(
                  note: note,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NoteViewPage(note: note),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),

      floatingActionButton: _buildFloatingButton(context),
    );
  }


















  Container _buildFloatingButton(BuildContext context) {
    return Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF9115D4), Color(0xFFFECFEF), Color(0xFFE2525C)],
          begin: Alignment.topCenter,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateEditNotePage()),
          );
        },
        child: const Icon(Icons.add, size: 34, color: Colors.white),
      ),
    );
  }
}
