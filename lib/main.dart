import 'package:do_an_lt/coach_main.dart';
import 'package:do_an_lt/Customer/Home/customer_main.dart';
import 'package:do_an_lt/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:do_an_lt/login.dart';
import 'package:do_an_lt/register.dart';
import 'package:do_an_lt/guess_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Stripe.publishableKey = 'pk_test_51QHQ0IGVyUQsdJTUKqBdjNH4ZW79wTWV4LUD5oYz36anI4gCTYgceBS0Pthhyh7RO1uCWTJESYrzFH6ilmvUs8LM004IBc0Ump';
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
        '/customer_main': (context) => CustomerMainPage(),
        '/coach_main': (context) => CoachMainPage(),
      },
    );
  }
}
