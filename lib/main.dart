import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:desco/pages/home.dart';
import 'package:desco/pages/login.dart';
import 'package:desco/pages/total_expenses.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const NewApp());
}

class NewApp extends StatefulWidget {
  const NewApp({super.key});

  @override
  State<NewApp> createState() => _NewAppState();
}

class _NewAppState extends State<NewApp> {
  late StreamSubscription<User?> user;
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.authStateChanges().listen((user) {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: [
        const Locale('en'), // English
        const Locale('pt'), // Portuguese
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: ThemeData(
          scaffoldBackgroundColor: Color.fromARGB(255, 225, 230, 225)),
      debugShowCheckedModeBanner: false,
      initialRoute:
          FirebaseAuth.instance.currentUser == null ? '/login' : '/home',
      routes: {
        '/login': (context) => const Login(),
        '/home': (context) => Home(),
        '/totalExpenses': (context) => TotalExpenses(),
      },
    );
  }
}
