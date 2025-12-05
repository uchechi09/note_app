import 'package:flutter/material.dart';

class AppConstants {
  // Collection name in Firestore
  static const String notesCollection = 'notes';
  
  // Note colors matching your UI
  static const List<Color> noteColors = [
    Color(0xFFB3E5FC), // Light Blue
    Color(0xFFF8BBD0), // Light Pink
    Color(0xFFFFF9C4), // Light Yellow
    Color(0xFFC8E6C9), // Light Green
    Color(0xFFE1BEE7), // Light Purple
    Color(0xFFFFE0B2), // Light Orange
    Color(0xFFB2DFDB), // Light Teal
    Color(0xFFFFCCBC), // Light Peach
  ];
  
  // Get color from hex string
  static Color getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }
  
  // Convert color to hex string
  static String getHexFromColor(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }
}