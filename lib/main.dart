import 'package:flutter/material.dart';
import 'package:shop/widgets/grocery_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData.dark(
        useMaterial3: true,
      ).copyWith(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 2, 72, 54),
          surface:const Color.fromARGB(255, 11, 110, 85),
          scrim: const Color.fromARGB(255, 3, 172, 130), 
        ),
      ),
      home: const GroceryList(),
    );
  }
}
