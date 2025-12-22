import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:note_app/pages/note_detail_page.dart';
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

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final FlutterLocalNotificationsPlugin notifications =
    FlutterLocalNotificationsPlugin();

Future<void> _safeInitializeTimezones() async {
  try {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.local);
  } catch (_) {}
}

Future<void> initNotifications() async {
  await _safeInitializeTimezones();

  const android = AndroidInitializationSettings('ic_notification');
  const ios = DarwinInitializationSettings();

  final settings = InitializationSettings(android: android, iOS: ios);

  await notifications.initialize(
    settings,
    // onDidReceiveNotificationResponse: (response) {
    //   final noteId = response.payload;
    //   if (noteId != null) {
    //     _openNoteFromNotification(noteId);
    //   }
    // },
  );

  final launchDetails = await notifications.getNotificationAppLaunchDetails();

  if (launchDetails?.didNotificationLaunchApp ?? false) {
    final noteId = launchDetails!.notificationResponse?.payload;
    if (noteId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openNoteFromNotification(noteId);
      });
    }
  }

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

void _openNoteFromNotification(String noteId) {
  navigatorKey.currentState?.push(
    MaterialPageRoute(builder: (_) => NoteDetailPage(noteId: noteId)),
  );
}

Future<void> scheduleReminder(
  int notifId,
  DateTime dateTime,
  String title,
  String body, {
  required String payload,
  required DateTimeComponents repeatType,
}) async {
  final tz.TZDateTime tzTime = tz.TZDateTime.from(dateTime, tz.local);
  if (dateTime.isBefore(DateTime.now())) return;

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
        icon: 'ic_notification',
        playSound: true,
        enableVibration: true,
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    matchDateTimeComponents: repeatType,
    payload: payload,
  );
}

Future<void> cancelReminder(int id) async {
  await notifications.cancel(id);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await initNotifications();
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
            navigatorKey: navigatorKey,
            title: 'My Notes',
            debugShowCheckedModeBanner: false,
            themeMode: theme.themeMode,
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
