// ignore_for_file: avoid_print

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:to_do_list_app/pages/calendar.dart';
import 'package:to_do_list_app/pages/login.dart';
import 'package:to_do_list_app/pages/profile.dart';
import 'package:to_do_list_app/pages/reset_password.dart';
import 'package:to_do_list_app/pages/sign_up.dart';
import 'package:to_do_list_app/pages/dashboard.dart';
import 'package:to_do_list_app/provider/auth.provider.dart';
import 'package:to_do_list_app/screens/introduce.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list_app/screens/spash.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidSettings);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  final token = await FirebaseMessaging.instance.getToken();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MyApp(fcmToken: token),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String? fcmToken;

  const MyApp({super.key, this.fcmToken});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Gửi FCM token sau khi load user
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await authProvider.loadUser();
      await authProvider.sendTokenToBackend(fcmToken);
    });

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const TaskManagement(),
        '/login': (context) => const Login(),
        '/signUp': (context) => const SignUp(),
        '/resetPassword': (context) => const ResetPassword(),
        '/calendar': (context) => const Calendar(),
        '/profile': (context) => const Profile(),
        '/introduce': (context) => const Introduce(),
      },
    );
  }
}
