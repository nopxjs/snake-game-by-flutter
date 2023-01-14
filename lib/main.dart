import 'package:flutter/material.dart';
import 'package:snake_game/home_page.dart';
import 'package:firebase_core/firebase_core.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized;
  await Firebase.initializeApp(
      options: const FirebaseOptions(
    apiKey: "AIzaSyD0H9eujiuzTJlaB467nTaPuTa1ew_pKNc",
    authDomain: "snakegame-49ce8.firebaseapp.com",
    projectId: "snakegame-49ce8",
    storageBucket: "snakegame-49ce8.appspot.com",
    messagingSenderId: "928380485259",
    appId: "1:928380485259:web:6dd1ef669c12d67d71de8e",
    measurementId: "G-GLFBYQXJCB",
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      title: 'Flutter Demo',
    );
  }
}
