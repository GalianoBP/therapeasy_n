import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:therapeasy/Appuser.dart';
import 'package:therapeasy/access.dart';
import 'package:therapeasy/approuter.dart';
import 'package:therapeasy/icons.dart';

class MedListPage extends StatefulWidget {
  const MedListPage({super.key});

  State<MedListPage> createState() => _MedListPage();
}

class _MedListPage extends State<MedListPage> {
  late List<Map<String, dynamic>> medlist = [];
  String filt = 'ACICLIN';
  final myChannel = DbComms.supabase.channel('med_list_page_channel');

  void initState() {
    myChannel.on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
          event: 'UPDATE',
          schema: 'public',
          table: 'therapies',
          filter: 'doc_id_fk=eq.${Appuser.userID.toString()}'),
      (payload, [ref]) async {
        //await Refresh();
        print(
            'rilevato update sulle medicine dalla medlistpg, medicine attualmente disponibili: ${medlist.length} ');
        setState(() {});
      },
    ).on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
          event: 'INSERT',
          schema: 'public',
          table: 'therapies',
          filter: 'doc_id_fk=eq.${Appuser.userID.toString()}'),
      (payload, [ref]) async {
        //await Refresh();
        print(
            'rilevato insert sulle medicine dalla medlistpg, medicine attualmente disponibili: ${medlist.length} ');
        setState(() {});
      },
    ).on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
          event: 'DELETE',
          schema: 'public',
          table: 'therapies',
          filter: 'doc_id_fk=eq.${Appuser.userID.toString()}'),
      (payload, [ref]) async {
        //await Refresh();
        print(
            'rilevato delete sulle medicine dalla medlistpg, medicine attualmente disponibili: ${medlist.length} ');
        setState(() {});
      },
    ).subscribe();
    Refresh();
    super.initState();
  }

  Future<void> Refresh() async {
    medlist.clear();
    if (filt == '') {
      for (var elem in (await DbComms.supabase.from('medicines').select('*')
          //.textSearch('name', '')
          as List<dynamic>)) {
        medlist.add(elem as Map<String, dynamic>);
      }
    }else{
      for (var elem in (await DbComms.supabase.from('medicines').select('*')
      .textSearch('name', filt)
      as List<dynamic>)) {
        medlist.add(elem as Map<String, dynamic>);
      }
    }

    filt = '';
  }

  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Refresh(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return AppRouter.waitingAnim(context);
          }
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
            body: ListView.builder(
              itemCount: medlist.length,
              itemBuilder: (context, index) {
                return Card(
                    child: Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: (index % 2 == 0)
                                    ? [
                                        Colors.green.shade200,
                                        Colors.green.shade400
                                      ]
                                    : [
                                        Colors.blue.shade200,
                                        Colors.blue.shade300
                                      ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight),
                            borderRadius: const BorderRadius.horizontal(
                                right: Radius.circular(15),
                                left: Radius.circular(15))),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 15, bottom: 15, left: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text('sample')
                            ], /*_list_element_maker_therapies(medlist[index])*/
                          ),
                        )));
              },
            ),
          );
        });
  }
}
