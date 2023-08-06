import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:therapeasy/access.dart';

class FirstBlankPage extends StatefulWidget {
  const FirstBlankPage({super.key});

  @override
  State<FirstBlankPage> createState() => _BlankPageState();
}

class _BlankPageState extends State<FirstBlankPage> {
  @override
  void initState() {
    super.initState();
    _firstBlankPage();
  }

  _firstBlankPage() async {
    if (!mounted) {
      return;
    }
    (DbComms.retrieveSession())
        ? Future.delayed(Duration.zero, () async { Navigator.pushNamedAndRemoveUntil(context, await DbComms.routeToGo(), (route) =>false);})
        : Future.delayed(Duration.zero, () {Navigator.pushNamedAndRemoveUntil(context, '/loginPage', (route) =>false);});
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
                  text: "Therapeasy",
                  style: TextStyle(
                      color: Colors.teal,
                      fontSize: 40,
                      fontFamily: 'VeganStyle'))),
          Padding(
              padding: const EdgeInsets.only(top: 32.0),
              child:
                  LoadingAnimationWidget.inkDrop(color: Colors.teal, size: 50))
        ])));
  }
}
