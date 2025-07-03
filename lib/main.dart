import 'package:flutter/material.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ChangeNotifierProvider(create: (_) => AuthProvider(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
