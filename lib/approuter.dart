import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:therapeasy/access.dart';
import 'package:therapeasy/pages/Comp_ther_page.dart';
import 'package:therapeasy/pages/loginPage.dart';
import 'package:therapeasy/pages/firstBlankPage.dart';
import 'package:therapeasy/pages/dochomepage.dart';
import 'package:therapeasy/pages/medlistpage.dart';
import 'package:therapeasy/pages/new_ther_page.dart';
import 'package:therapeasy/pages/pathomepage.dart';
import 'package:therapeasy/pages/ther_managament_page.dart';
import 'package:therapeasy/pages/therpage.dart';
import 'package:therapeasy/pages/therplanpage.dart';
import 'package:therapeasy/pages/medpage.dart';

class AppRouter {
  static Map<String, WidgetBuilder> threeRouting() {
    return {
      '/': (context) => loginPage(),
      '/loginPage': (context) => loginPage(),
      '/firstBlankPage': (context) => FirstBlankPage(),
      '/docHomePage': (context) => DocHomePage(),
      '/patHomePage': (context) => PatHomePage(),
      '/therplanpage': (context) => TherPlanPage(),
      '/therpage': (context) => TherPage(),
      '/medpage': (context) => MedPage(),
      '/medlistpage': (context) => MedListPage(),
      '/ther_man_page': (context) => TherManPage(),
      '/newtherpage': (context) => NewTherPage(),
      '/Comptherpage': (context) => CompTherPage(),
    };
  }
  static Scaffold waitingAnim(BuildContext context){
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          toolbarHeight: 75,
          title: RichText(
              text: const TextSpan(
                  text: "Therapeasy",
                  style: TextStyle(
                      color: Colors.teal,
                      fontSize: 40,
                      fontFamily: 'VeganStyle'))),
          actions: [
            IconButton(
                onPressed: () async {
                  DbComms.logout();
                  //await DbComms.supabase.removeChannel(myChannel);
                  Future.delayed(Duration.zero, () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/loginPage', (route) => false);
                  });
                },
                icon: const Icon(Icons.logout))
          ],
        ),
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
                      child: LoadingAnimationWidget.inkDrop(
                          color: Colors.teal, size: 50))
                ])));
  }
}
