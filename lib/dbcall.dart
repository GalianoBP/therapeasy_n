import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:therapeasy/access.dart';

class Dbcall{
  static void userPage() async{
    final data = await DbComms.supabase.rpc('user_type');
  }
}