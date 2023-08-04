import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:therapeasy/app_user.dart';
import 'package:therapeasy/access.dart';
import 'package:therapeasy/icons.dart';

class MedPage extends StatefulWidget {
  const MedPage({super.key});

  State<MedPage> createState() => _MedPage();
}

class _MedPage extends State<MedPage> {
  late Set<Map<String, dynamic>> medicines = {};
  final myChannel = DbComms.supabase.channel('medicines_page_channel');

  void initState() {
    myChannel.on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
        event: 'UPDATE',
        schema: 'public',
        table: 'Derivare_NN',
      ), //filter: 'therapies(pat_id_fk)=eq.${Appuser.userID.toString()}'),
      (payload, [ref]) async {
        await Refresh();
      },
    ).on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
        event: 'INSERT',
        schema: 'public',
        table: 'Derivare_NN',
      ), // filter: 'therapies(pat_id_fk)=eq.${Appuser.userID.toString()}'),
      (payload, [ref]) async {
        await Refresh();
      },
    ).on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
          event: 'DELETE',
          schema: 'public',
          table: 'Derivare_NN',
      ),// filter: 'therapies(pat_id_fk)=eq.${Appuser.userID.toString()}'),
      (payload, [ref]) async {
        await Refresh();
      },
    ).subscribe();
    Refresh();
    super.initState();
  }

  Future<void> Refresh() async {
    medicines.clear();
    for (var elem in await DbComms.supabase
        .from('medicine_view')
        .select(
            '*')
        .eq('pat_id_fk', Appuser.userID)
        .order('medicine', ascending: true)) {
      medicines.add(elem as Map<String, dynamic>);
    }
    setState(() {
      print("--- Lista aggiornata delle medicine Medicines page ---");
      print(medicines.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () async {
              await DbComms.supabase.removeChannel(myChannel);
              Navigator.of(context).pop();
            },
          ),
          centerTitle: true,
          toolbarHeight: 75,
          title: RichText(
              text: const TextSpan(
                  text: "Therapeasy",
                  style: TextStyle(
                      color: Colors.teal,
                      fontSize: 35,
                      fontFamily: 'VeganStyle'))),
          actions: [
            IconButton(
                onPressed: () async {
                  medicines.clear();
                  Refresh();
                },
                icon: const Icon(Icons.replay)),
            IconButton(
                onPressed: () async {
                  DbComms.logout();
                  Future.delayed(Duration.zero, () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/loginPage', (route) => false);
                  });
                },
                icon: const Icon(Icons.logout))
          ],
        ),
        body: ListView.builder(
          itemCount: medicines.length,
          itemBuilder: (context, index) {
            return Card(
                child: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Colors.blue.shade200, Colors.blue.shade300],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                        borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(15),
                            left: Radius.circular(15))),
                    child: Padding(
                      padding:
                      const EdgeInsets.only(top: 15, bottom: 15, left: 15),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children:
                          _list_element_maker_therapies(medicines.elementAt(index))),
                    )));
          },
        ));
  }

  List<Widget> _list_element_maker_therapies(Map<String, dynamic> elem) {
    String name = elem['medicine'];
    String type = elem['type'];
    String ac_princ = elem['active_principle'];
    String doc ='${elem['doc_name']} ${elem['doc_surname']}';
    String spec = '${elem['spec']}';
    return [
      SizedBox(
          width: MediaQuery.of(context).orientation == Orientation.landscape
              ? null
              : 300,
          child: Column(children: [
            RichText(
              overflow: TextOverflow.ellipsis,
              strutStyle: StrutStyle(fontSize: 40),
              text: TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 25),
                  text: name),
            ),
            Text(
              'Tipologia: $type',
              style: const TextStyle(
                fontSize: 28,
              ),
            ),
            Text(
              'Principio attivo: $ac_princ',
              // ${end_date.hour + 2}:${end_date.minute}',
              style: const TextStyle(
                fontSize: 28,
              ),
            )
          ])),
      Flexible(
          fit: FlexFit.tight,
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Spacer(),
            IconButton(
                icon: Icon(Medicons.stethoscope),
                iconSize: 50,
                onPressed: () {
                  AwesomeDialog(
                    context: context,
                    btnOkColor: Colors.teal,
                    animType: AnimType.scale,
                    dialogType: DialogType.info,
                    body: Flexible(
                        child: Column(children: <Widget>[
                      RichText(
                          text: const TextSpan(
                              text: "Therapeasy",
                              style: TextStyle(
                                  color: Colors.teal,
                                  fontSize: 40,
                                  fontFamily: 'VeganStyle'))),
                      Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Row(
                            children: <Widget>[
                              RichText(
                                  text: const TextSpan(
                                      text: "Medico: ",
                                      style: TextStyle(
                                          color: Colors.teal,
                                          fontSize: 20,
                                          fontFamily: 'Gotham'))),
                              Flexible(
                                child: RichText(
                                    maxLines: 3,
                                    softWrap: true,
                                    text: TextSpan(
                                        text: '$doc',
                                        style: const TextStyle(
                                            overflow: TextOverflow.ellipsis,
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontFamily: 'Gotham'))),
                              )
                            ],
                          )),
                      Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Row(
                            children: <Widget>[
                              RichText(
                                  text: const TextSpan(
                                      text: "Specializzazione: ",
                                      style: TextStyle(
                                          color: Colors.teal,
                                          fontSize: 20,
                                          fontFamily: 'Gotham'))),
                              Flexible(
                                child: RichText(
                                    maxLines: 3,
                                    softWrap: true,
                                    text: TextSpan(
                                        text: '$spec',
                                        style: const TextStyle(
                                            overflow: TextOverflow.ellipsis,
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontFamily: 'Gotham'))),
                              )
                            ],
                          )),
                    ])),
                    btnOkOnPress: () {},
                  ).show();
                })
          ]))
    ];
  }
}
