import 'package:flutter/material.dart';
import 'package:therapeasy/access.dart';

class MedHomePage extends StatefulWidget {
  State<MedHomePage> createState() => _MedHPState();
}

class _MedHPState extends State<MedHomePage> {
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
                  text: "Medhomepage",
                  style: TextStyle(
                      color: Colors.teal,
                      fontSize: 40,
                      fontFamily: 'VeganStyle'))),
          ElevatedButton(
            onPressed: () async {
              DbComms.logout();
              await Navigator.of(context).popAndPushNamed('/loginPage');
            },
            child: const Text('sloggati'),
          )
        ])));
  }
}
