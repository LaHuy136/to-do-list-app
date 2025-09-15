// ignore_for_file: avoid_print

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:to_do_list_app/pages/calendar.dart';
import 'package:to_do_list_app/viewmodels/task_viewmodel.dart';
import 'package:to_do_list_app/viewmodels/todoitem_viewmodel.dart';
import 'package:to_do_list_app/views/auth/login_screen.dart';
import 'package:to_do_list_app/pages/profile.dart';
import 'package:to_do_list_app/pages/reset_password.dart';
import 'package:to_do_list_app/views/auth/register_screen.dart';
import 'package:to_do_list_app/pages/dashboard.dart';
import 'package:to_do_list_app/screens/introduce.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list_app/views/spash_screen.dart';
import 'package:to_do_list_app/viewmodels/auth_viewmodel.dart';

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
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>(create: (_) => AuthViewModel()),
        ChangeNotifierProvider<TodoItemViewModel>(create: (_) => TodoItemViewModel()),
        ChangeNotifierProvider<TaskViewModel>(create: (_) => TaskViewModel()),
      ],
      child: MyApp(fcmToken: token),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String? fcmToken;

  const MyApp({super.key, this.fcmToken});

  @override
  Widget build(BuildContext context) {
    // Đợi sau khi widget tree đã build thì mới gọi provider
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authViewModel = context.read<AuthViewModel>();
      await authViewModel.loadUser();
      await authViewModel.sendTokenToBackend(fcmToken);
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
