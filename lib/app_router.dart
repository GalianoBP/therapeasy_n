import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:therapeasy/access.dart';
import 'package:therapeasy/pages/comp_ther_page.dart';
import 'package:therapeasy/pages/login_page.dart';
import 'package:therapeasy/pages/first_blank_page.dart';
import 'package:therapeasy/pages/doc_homepage.dart';
import 'package:therapeasy/pages/med_list_page.dart';
import 'package:therapeasy/pages/mod_ther_page.dart';
import 'package:therapeasy/pages/new_ther_page.dart';
import 'package:therapeasy/pages/pat_homepage.dart';
import 'package:therapeasy/pages/ther_managament_page.dart';
import 'package:therapeasy/pages/ther_page.dart';
import 'package:therapeasy/pages/ther_plan_page.dart';
import 'package:therapeasy/pages/med_page.dart';

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
      '/modtherpage': (context) => ModTherPage(),
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
