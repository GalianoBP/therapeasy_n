import 'package:flutter/material.dart';
import 'package:therapeasy/access.dart';

class PatHomePage extends StatefulWidget {
  const PatHomePage({super.key});

  State<PatHomePage> createState() => _PatHPState();
}

class _PatHPState extends State<PatHomePage> {
  late bool pushpage=false;

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
          RichText(
              text: const TextSpan(
                  text: "Pathomepage",
                  style: TextStyle(
                      color: Colors.teal,
                      fontSize: 40,
                      fontFamily: 'VeganStyle'))),
          ElevatedButton(
            onPressed: () {
              DbComms.logout();
              Future.delayed(Duration.zero, () {Navigator.pushNamedAndRemoveUntil(context, '/loginPage', (route) =>route.isFirst);});
            },
            child: Text('sloggati'),
          )
        ])));
  }
}
