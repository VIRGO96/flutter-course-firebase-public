import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_course_app/Features/FirebaseNotifications/firebase_notification_service.dart';
import 'package:flutter_course_app/Features/OnBoarding/splash_screen.dart';
import 'package:flutter_course_app/Features/Provider/auth_provider.dart';
import 'package:flutter_course_app/Features/Provider/poll_provider.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

FirebaseNotificationService firebaseNotificationService =
    FirebaseNotificationService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  log('Handling a background message ${message.messageId}');
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    firebaseNotificationService.requestNotificationPermissions();
    firebaseNotificationService.foregroundMessage();
    firebaseNotificationService.setupInteractMessage(context);
    firebaseNotificationService.getDeviceToken().then((value) => log(value));
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProviderData()),
        ChangeNotifierProvider(create: (_) => PollProvider())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme:
              ColorScheme.fromSeed(seedColor: Colors.orange.withOpacity(0.5)),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
