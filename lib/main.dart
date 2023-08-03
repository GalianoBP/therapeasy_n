import 'package:flutter/material.dart';
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
        builder: (context, child) =>
            MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), child: child as Widget),
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
