import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyBphVyozIZ_4b_zwwIW6HCnnGjk12Nl0kM",
          authDomain: "kfupmeval.firebaseapp.com",
          databaseURL: "https://kfupmeval-default-rtdb.firebaseio.com",
          projectId: "kfupmeval",
          storageBucket: "kfupmeval.firebasestorage.app",
          messagingSenderId: "799318154278",
          appId: "1:799318154278:web:14610e05fda75f9bac1ae7",
          measurementId: "G-JYF87DBJ9V"),
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KFUPMEval',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(), // Update to your login page widget
    );
  }
}
