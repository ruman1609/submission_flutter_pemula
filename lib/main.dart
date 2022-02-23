import 'package:flutter/material.dart';

import 'fe/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Map<int, Color> colorSwatches = {
      50: const Color.fromRGBO(0, 0, 0, .1),
      100: const Color.fromRGBO(0, 0, 0, .2),
      200: const Color.fromRGBO(0, 0, 0, .3),
      300: const Color.fromRGBO(0, 0, 0, .4),
      400: const Color.fromRGBO(0, 0, 0, .5),
      500: const Color.fromRGBO(0, 0, 0, .6),
      600: const Color.fromRGBO(0, 0, 0, .7),
      700: const Color.fromRGBO(0, 0, 0, .8),
      800: const Color.fromRGBO(0, 0, 0, .9),
      900: const Color.fromRGBO(0, 0, 0, 1),
    };
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: MaterialColor(0xFF000000, colorSwatches),
        ),
        home: const HomeScreen());
    // This is the theme of your application.
  }
}
