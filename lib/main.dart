import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nhis_chat_admin/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await Firebase.initializeApp(
    options: FirebaseOptions(
      appId: '1:607237988868:android:6f5955b43e04f7bc8a4b51',
      apiKey: 'AIzaSyCPWljpiuzxNu5VLQ54B72p41BhA_ugjHI',
      projectId: 'flutter-firebase-plugins',
      messagingSenderId: '607237988868',
      databaseURL: 'https://messagingapp-c52c2.firebaseio.com',
    ),
  );
  print(app.name);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NHIS super ADMIN',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginScreen(),
    );
  }
}
