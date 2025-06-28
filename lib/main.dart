import 'package:flutter/material.dart';
import 'package:to_do_list_app/pages/login.dart';
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

      initialRoute: '/introduce',
      routes: {
        '/login': (context) => const Login(),
        '/introduce': (context) => const Introduce(),
      },
    );
  }
}
