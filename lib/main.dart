  // ignore_for_file: unused_import

  import 'package:flutter/material.dart';
  import 'package:firebase_core/firebase_core.dart';
  import 'package:flutter_dotenv/flutter_dotenv.dart';
  import 'package:quest/presentation/chardescpage/pages/chardescpage.dart';
  import 'package:quest/presentation/info/pages/infopage.dart';
  import 'package:quest/presentation/login/pages/loginpage.dart';
  import 'package:quest/presentation/splash/pages/splash.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import 'firebase_options.dart';

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await dotenv.load(fileName: "assets/StoryGenerator.env");
    runApp(const MyApp());
  }

  class MyApp extends StatefulWidget {
    const MyApp({super.key});

    @override
    State<MyApp> createState() => _MyAppState();
  }

  class _MyAppState extends State<MyApp> {
    

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        title: 'Questora',
        debugShowCheckedModeBanner: false,
        home: const SplashPage(), 
      );
    }  
  }
