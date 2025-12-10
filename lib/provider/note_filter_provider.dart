import 'package:flutter/material.dart';
import 'package:note_app/models/note.dart';
import 'package:note_app/provider/note_provider.dart';
import 'package:provider/provider.dart';

class NoteFilterProvider extends ChangeNotifier {
  String _searchQuery = '';
  bool _isFilteringFavorites = false;

  String get searchQuery => _searchQuery;
  bool get isFilteringFavorites => _isFilteringFavorites;

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase().trim();
    notifyListeners();
  }

  void setFavoriteFilter(bool value) {
    _isFilteringFavorites = value;
    notifyListeners();
  }

  Stream<List<Note>> getFilteredNotesStream(BuildContext context) {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);

    return noteProvider.notesStream.map((allNotes) {
      Iterable<Note> notes = allNotes;

      // ⭐ Filter favourites
      if (_isFilteringFavorites) {
        notes = notes.where((note) => note.isFavourite);
      }

      // 🔍 Apply search filter
      if (_searchQuery.isNotEmpty) {
        notes = notes.where((note) {
          return note.title.toLowerCase().contains(_searchQuery) ||
              note.content.toLowerCase().contains(_searchQuery);
        });
      }

      return notes.toList();
    });
  }
}
