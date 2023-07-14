import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DbComms {
  static final supabase = Supabase.instance.client;
  static late Session? session;
  static late User? user;

  static Future<void> dbAccess() async {
    await Supabase.initialize(
      url: 'https://hrpnbmvshkvpopoqprhd.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhycG5ibXZzaGt2cG9wb3FwcmhkIiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODg2NjkyNzcsImV4cCI6MjAwNDI0NTI3N30.bHDd-lPzAnQkTNAdK_yedmlPfD3W53G-0V-Eymor3w8',
    );
  }

  static Future<bool> userAccess(name, psw) async {
    try {
      final AuthResponse res = await DbComms.supabase.auth.signInWithPassword(
        email: name.text,
        password: psw.text,
      );
      session = res.session;
      user = res.user;
      return true;
    } on Exception {
      return false;
    }
  }

  static bool retrieveSession() {
    session = supabase.auth.currentSession;
    user = DbComms.supabase.auth.currentUser;
    if (!(DbComms.session == null)) {
      return true;
    } else {
      return false;
    }
  }

  static void logout() async {
    await supabase.auth.signOut();
  }

  static Future<String> routeToGo() async {
    final doc = await supabase.from('doctors').select('user, doc_id').eq('user', user?.id);
    final num= await supabase.rpc('user_type', params: {'idparameter' : user?.id});
    var paz = await supabase.from('patients').select('user, pat_id').eq('user', user?.id);
    print(doc);
    print(paz);
    print(num);
    switch (num) {
      case 1:
        return '/medHomePage';
        break;
      case 2:
        return '/patHomePage';
        break;
      default:
        return '/errorpage';
        break;
    }
  }
}
