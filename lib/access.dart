import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DbComms{
  static final supabase = Supabase.instance.client;
  static late final Session? session;
  static late final User? user;

  static void DBaccess() async{
    await Supabase.initialize(
      url: 'https://hrpnbmvshkvpopoqprhd.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhycG5ibXZzaGt2cG9wb3FwcmhkIiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODg2NjkyNzcsImV4cCI6MjAwNDI0NTI3N30.bHDd-lPzAnQkTNAdK_yedmlPfD3W53G-0V-Eymor3w8',
    );
  }

  static Future<bool> userAccess(name, psw) async{
    try{
    final AuthResponse res = await DbComms.supabase.auth.signInWithPassword(
      email: name.text,
      password: psw.text,
    );
    session = res.session;
    user = res.user;
    return true;
    } on AuthException
    {
      return false;
    }

  }
}

class _CustomException implements Exception {
  String cause;
  _CustomException(this.cause);
}