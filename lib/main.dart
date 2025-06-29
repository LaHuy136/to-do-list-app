import 'package:flutter/material.dart';
import 'package:to_do_list_app/pages/login.dart';
import 'package:to_do_list_app/pages/sign_up.dart';
import 'package:to_do_list_app/screens/introduce.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      initialRoute: '/login',
      routes: {
        '/login': (context) => const Login(),
        '/signUp': (context) => const SignUp(),
        '/introduce': (context) => const Introduce(),
      },
    );
  }
}
