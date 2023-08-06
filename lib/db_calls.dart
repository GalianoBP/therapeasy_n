import 'package:therapeasy/access.dart';

class Dbcall{
  static void userPage() async{
    await DbComms.supabase.rpc('user_type');
  }


}