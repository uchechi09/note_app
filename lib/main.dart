import 'package:flutter/material.dart';
import 'package:note_app/pages/note_list_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:note_app/provider/note_filter_provider.dart';
import 'package:note_app/provider/theme_provider.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:note_app/provider/note_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => NoteProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => NoteFilterProvider()),
      ],
      // Use a Consumer to access the ThemeProvider state
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'My Notes',
            debugShowCheckedModeBanner: false,
            
            // Connect the themeMode from the provider
            themeMode: themeProvider.themeMode, 
            
            // Define the Light Theme
            theme: ThemeData(
              brightness: Brightness.light,
              primarySwatch: Colors.pink, 
              fontFamily: 'Roboto',
            ),
            
            // Define the Dark Theme (Crucial for dark mode to look right)
            darkTheme: ThemeData( 
              brightness: Brightness.dark,
              primarySwatch: Colors.blueGrey, // Use a different color for dark mode contrast
              fontFamily: 'Roboto',
              // Example of a dark background color
              scaffoldBackgroundColor: const Color(0xFF121212),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.black,
              ),
            ),
            
            home: const NoteListPage(),
          );
        },
      ),
    );
  }
}