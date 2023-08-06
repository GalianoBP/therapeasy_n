import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:therapeasy/app_user.dart';
import 'package:therapeasy/access.dart';
import 'package:therapeasy/icons.dart';

class TherPage extends StatefulWidget {
  const TherPage({super.key});

  State<TherPage> createState() => _TherPage();
}

class _TherPage extends State<TherPage> {
  late List<Map<String, dynamic>> therapies = [];
  final myChannel = DbComms.supabase.channel('therapies_page_channel');

  void initState() {
    myChannel.on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
          event: 'UPDATE',
          schema: 'public',
          table: 'therapies',
          filter: 'pat_id_fk=eq.${Appuser.userID.toString()}'),
      (payload, [ref]) async {
        await Refresh();
      },
    ).on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
          event: 'INSERT',
          schema: 'public',
          table: 'therapies',
          filter: 'pat_id_fk=eq.${Appuser.userID.toString()}'),
      (payload, [ref]) async {
        await Refresh();
      },
    ).on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
          event: 'DELETE',
          schema: 'public',
          table: 'therapies',
          filter: 'pat_id_fk=eq.${Appuser.userID.toString()}'),
      (payload, [ref]) async {
        await Refresh();
      },
    ).subscribe();
    Refresh();
    super.initState();
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
                  therapies.clear();
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
          itemCount: therapies.length,
          itemBuilder: (context, index) {
            return Card(
                child: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: (therapies[index]['state'] != true)
                                ? [
                              Colors.orangeAccent.shade100,
                              Colors.orange.shade200
                            ]
                                : [
                                    Colors.greenAccent.shade100,
                                    Colors.greenAccent.shade200
                                  ],
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
                              _list_element_maker_therapies(therapies[index])),
                    )));
          },
        ));
  }

  Future<void> Refresh() async {
    therapies.clear();
    for (var elem in await DbComms.supabase
        .from('therapies')
        .select('*, doctors(name, surname, med_spec)')
        .eq('compiled', true)
        .eq('pat_id_fk', Appuser.userID) //Appuser.userID)
        .order('start_date, end_date')
        .order('state', ascending: false)) {
      therapies.add(elem as Map<String, dynamic>);
    }

    setState(() {
      print("--- Lista aggiornata delle terapie per Therapies page ---");
      print(therapies.length);
    });
  }

  List<Widget> _list_element_maker_therapies(Map<String, dynamic> elem) {
    DateTime st_date = DateTime.parse(elem['start_date']);
    DateTime end_date = DateTime.parse(elem['end_date']);
    String ther_name = elem['name'];

    return [
      SizedBox(
          width: MediaQuery.of(context).orientation == Orientation.landscape
              ? null
              : 179,
          child: Column(children: [
            RichText(
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
              strutStyle: StrutStyle(fontSize: 40),
              textAlign: TextAlign.left,
              text: TextSpan(
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade800,
                      fontSize: 25,
                      fontFamily: 'Gotham'),
                  text: ther_name),
            ),
            Row(
              children: <Widget>[
                const Text(
                  'Data d\'inizio: ',
                  style: TextStyle(
                      color: Colors.indigo,
                      fontSize: 28,
                      fontFamily: 'Gotham',
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
                Text(
                  '${st_date.day}-${st_date.month}-${st_date.year}',
                  style:
                  const TextStyle(fontSize: 28, fontFamily: 'Gotham'),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
            Row(children: <Widget>[
              const Text(
                'Data di fine: ',
                // ${end_date.hour + 2}:${end_date.minute}',
                style: TextStyle(
                    color: Colors.indigo,
                    fontSize: 28,
                    fontFamily: 'Gotham',
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
              Text(
                '${end_date.day}-${end_date.month}-${end_date.year}',
                style: const TextStyle(fontSize: 28, fontFamily: 'Gotham'),
                textAlign: TextAlign.left,
              ),
            ]),
          ])),
      Flexible(
          fit: FlexFit.tight,
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Spacer(),
            IconButton(
                icon: Icon(Medicons.stethoscope),
                iconSize: 75,
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
                                        text:
                                            ' ${elem['doctors']['name']} ${elem['doctors']['surname']}',
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
                                        text: '${elem['doctors']['med_spec']}',
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
