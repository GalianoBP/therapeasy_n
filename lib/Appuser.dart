import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:therapeasy/access.dart';

class Appuser {
  static late int userID;
  static late String name;
  static late String surname;
  static late int role;
  static late List<dynamic> ther;
  static List<Map<String, dynamic>> pending_med = [];
  static late final medrole;
  static late List<dynamic> terapie;

  Appuser(Map<String, dynamic> data, int usrole) {
    userID = data.values.first as int;
    name = data['name']! as String;
    surname = data['surname']! as String;
    role = usrole;
    if (usrole == 2) {
      print('---------- Paziente caricato con successo ----------');
      print('Id: $userID, nome: $name, cognome: $surname ');
      _medupdate();
    } else {
      print('---------- Medico caricato con successo ----------');
      print('Id: $userID, nome: $name, cognome: $surname ');
    }
  }

  static therupdate() async {
    if (role != 2) {
      //pat = await DbComms.supabase.from('therapies').select('doc_id_fk').eq('doc_id_fk', Appuser.userID);
    } else {
      ther = await DbComms.supabase
          .from('therapies')
          .select('pat_id_fk')
          .eq('pat_id_fk', Appuser.userID);
    }
  }

  _medupdate() {
    DbComms.supabase
        .from('ther_plan')
        .stream(primaryKey: ['plan_id'])
        .eq('pat_id_fk', userID.toString())
        //.inFilter('state', ['wait', 'ncom', 'comp'])
        .listen((List<Map<String, dynamic>> data) {
          pending_med.clear();
          for (var elem in data) {
            (elem['state'] == 'wait') ? pending_med.add(elem) : null;
          }
        });
  }
}
