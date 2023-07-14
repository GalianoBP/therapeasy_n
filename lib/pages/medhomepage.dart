import 'package:flutter/material.dart';
import 'package:therapeasy/access.dart';

class MedHomePage extends StatefulWidget {
  State<MedHomePage> createState() => _MedHPState();
}

class _MedHPState extends State<MedHomePage> {
  late String go;
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
                  text: "Medhomepage",
                  style: TextStyle(
                      color: Colors.teal,
                      fontSize: 40,
                      fontFamily: 'VeganStyle'))),
          ElevatedButton(
            onPressed: () {
              DbComms.logout();
              Future.delayed(Duration.zero, () {Navigator.pushNamedAndRemoveUntil(context, '/loginPage', (route) =>route.isFirst);});
            },
            child: const Text('sloggati'),
          )
        ])));
  }
}
