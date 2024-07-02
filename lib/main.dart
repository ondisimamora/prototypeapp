import 'package:flutter/material.dart';
// import 'package:prototypeapp/screens/cameraPage1.dart';
import 'package:prototypeapp/screens/homePageNew.dart';
// import 'package:prototypeapp/screens/homePageNew.dart';


void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TenX Demo App',
      theme: ThemeData(
        
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeNew(),
    );
  }
}
