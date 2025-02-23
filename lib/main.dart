import 'package:do_an_lt/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:do_an_lt/login.dart';
import 'package:do_an_lt/register.dart';
import 'package:do_an_lt/guess_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/splash_screen': (context) => GuessPage(), // Trang chính
        '/login': (context) => LoginPage(), // Route đến trang login
        '/register': (context) => RegisterPage(), // Route đến trang register
      },
    );
  }
}
