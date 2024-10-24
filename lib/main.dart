import 'dart:developer';

import 'package:astech_demo/firebase_options.dart';
import 'package:astech_demo/home_screen.dart';
import 'package:astech_demo/local_notification_manager.dart';
import 'package:astech_demo/push_notification_manager.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotificationManager().init();
  await PushNotificationManager().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}
