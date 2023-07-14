import 'package:flutter/material.dart';
import 'package:therapeasy/pages/loginPage.dart';
import 'package:therapeasy/pages/firstBlankPage.dart';
import 'package:therapeasy/pages/medhomepage.dart';
import 'package:therapeasy/pages/pathomepage.dart';
import 'package:therapeasy/pages/Splashpage.dart';

class AppRouter {
  static Map<String, WidgetBuilder> threeRouting() {
    return {
      '/': (context) => loginPage(),
      '/loginPage': (context) => loginPage(),
      '/firstBlankPage': (context) => FirstBlankPage(),
      '/medHomePage': (context) => MedHomePage(),
      '/patHomePage': (context) => PatHomePage(),
      '/splashPage': (context) => SplashPage()
    };
  }
}
