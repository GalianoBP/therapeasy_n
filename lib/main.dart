import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:therapeasy/access.dart';
import 'package:therapeasy/approuter.dart';

void main() async {
  await DbComms.dbAccess();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {


  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Therapeasy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      initialRoute: '/firstBlankPage',
      routes: AppRouter.threeRouting()
    );
  }
}
