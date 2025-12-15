import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'firebase_options.dart';
import 'pages/note_list_page.dart';
import 'provider/note_provider.dart';
import 'provider/theme_provider.dart';
import 'provider/note_filter_provider.dart';

// Notification plugin instance
final FlutterLocalNotificationsPlugin notifications =
    FlutterLocalNotificationsPlugin();

// Load timezone data
Future<void> _safeInitializeTimezones() async {
  try {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.local);
  } catch (_) {}
}

// Initialize local notifications
Future<void> initNotifications() async {
  await _safeInitializeTimezones();

  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ios = DarwinInitializationSettings();

  final settings = InitializationSettings(android: android, iOS: ios);
  await notifications.initialize(settings);

  // Create Android notification channel
  await notifications
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(
        const AndroidNotificationChannel(
          'reminder_channel',
          'Reminders',
          description: 'Note reminders',
          importance: Importance.max,
        ),
      );
}

// Schedule reminder with timezone support
Future<void> scheduleReminder(
  int notifId,
  DateTime dateTime,
  String title,
  String body,
) async {
  final tz.TZDateTime tzTime =
      tz.TZDateTime.from(dateTime, tz.local);

  debugPrint('====================');
  debugPrint('NOW     : ${tz.TZDateTime.now(tz.local)}');
  debugPrint('REMINDER: $tzTime');
  debugPrint('OFFSET  : ${tzTime.timeZoneOffset}');
  debugPrint('====================');

  await notifications.zonedSchedule(
    notifId,
    title,
    body,
    tzTime,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'reminder_channel',
        'Reminders',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    matchDateTimeComponents: null,
  );
}

// Cancel reminder by ID
Future<void> cancelReminder(int id) async {
  await notifications.cancel(id);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase init
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Notification init
  await initNotifications();

  // Permission request
  await Permission.notification.request();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NoteProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NoteFilterProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) {
          return MaterialApp(
            title: 'My Notes',
            debugShowCheckedModeBanner: false,
            themeMode: theme.themeMode,

            // Your original colors restored
            theme: ThemeData(
              brightness: Brightness.light,
              primarySwatch: Colors.pink,
              fontFamily: 'Roboto',
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: Colors.blueGrey,
              fontFamily: 'Roboto',
              scaffoldBackgroundColor: const Color(0xFF121212),
              appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
            ),

            home: const NoteListPage(),
          );
        },
      ),
    );
  }
}
