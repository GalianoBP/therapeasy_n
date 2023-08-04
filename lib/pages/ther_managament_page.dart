import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:therapeasy/app_user.dart';
import 'package:therapeasy/access.dart';
import 'package:therapeasy/app_router.dart';

class TherManPage extends StatefulWidget {
  const TherManPage({super.key});

  State<TherManPage> createState() => _TherManPage();
}

class _TherManPage extends State<TherManPage> {
  late List<Map<String, dynamic>> ther_list_pending = [];
  late List<Map<String, dynamic>> ther_list_compiled = [];
  final TextEditingController src = TextEditingController();
  bool onlync = false;
  String filt = '';
  final myChannel = DbComms.supabase.channel('ther_man_page_channel');

  void initState() {
    myChannel.on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
          event: 'UPDATE',
          schema: 'public',
          table: 'therapies',
          filter: 'doc_id_fk=eq.${Appuser.userID.toString()}'),
      (payload, [ref]) async {
        await Refresh();
        print(
            'rilevato update sulle terapie dalla ther_man_page, terapie rilevate: ${ther_list_compiled.length + ther_list_pending.length} ');
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
        await Refresh();
        print(
            'rilevato insert sulle terapie dalla ther_man_page, terapie rilevate: ${ther_list_compiled.length + ther_list_pending.length}');
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
        await Refresh();
        print(
            'rilevato delete sulle terapie dalla ther_man_page, terapie rilevate: ${ther_list_compiled.length + ther_list_pending.length} ');
        setState(() {});
      },
    ).subscribe();
    ther_list_compiled.clear();
    ther_list_pending.clear();
    super.initState();
  }

  Future<void> Refresh() async {
    ther_list_compiled.clear();
    ther_list_pending.clear();
    if (filt == '') {
      for (var elem in (await DbComms.supabase
          .from('therapies')
          .select('*, patients(name,surname)')
          .eq('doc_id_fk', Appuser.userID))) {
        ((elem as Map<String, dynamic>)['compiled'])
            ? ther_list_compiled.add(elem)
            : ther_list_pending.add(elem);
      }
      print(
          "Ci sono ${ther_list_pending.length} terapie in attesa di compilazione rilevate da ther_man_pg");
      print(
          "Ci sono ${ther_list_compiled.length} terapie compilate rilevate da ther_man_pg");
    } else {
      for (var elem in (await DbComms.supabase
          .from('therapies')
          .select('*, patients(name,surname)')
          .eq('doc_id_fk', Appuser.userID))) {
        ((elem as Map<String, dynamic>)['compiled'])
            ? ((elem['patients']['surname'] as String).matchAsPrefix(filt)) !=
                    null
                ? ther_list_compiled.add(elem)
                : null
            : ((elem['patients']['surname'] as String).matchAsPrefix(filt)) !=
                    null
                ? ther_list_pending.add(elem)
                : null;
      }
      print(
          "SEARCH: $filt Ci sono ${ther_list_pending.length} terapie in attesa di compilazione rilevate da ther_man_pg");
      print(
          "SEARCH: $filt  Ci sono ${ther_list_compiled.length} terapie compilate rilevate da ther_man_pg");
    }

    filt = '';
  }

  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Refresh(),
        builder: (context, snapshot) {
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
                      icon: const Icon(Icons.logout)),
                ],
              ),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () async {
                  Navigator.pushNamed(context, '/newtherpage');
                },
                backgroundColor: Colors.teal,
                label: const Row(children: <Widget>[
                  Icon(Icons.add),
                ]),
              ),
              body: Container(
                  child: Column(children: <Widget>[
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                              width: MediaQuery.of(context).size.width - 75,
                              child: TextField(
                                onTap: () {},
                                onSubmitted: (String) {
                                  setState(() {
                                    filt = src.text;
                                  });
                                },
                                controller: src,
                                decoration: const InputDecoration(
                                    labelText: "Cerca paziente per cognome",
                                    hintText: "Cerca medicinale",
                                    prefixIcon: Icon(Icons.search),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25.0)))),
                              )),
                          IconButton(
                              onPressed: () {
                                src.clear();
                                setState(() {});
                              },
                              icon: const Icon(Icons.search_off))
                        ])),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Checkbox(
                            value: onlync,
                            onChanged: (bool) {
                              setState(() {
                                onlync = !onlync;
                              });
                            }),
                        const Text(
                          'Solo ncomp',
                          // ${end_date.hour + 2}:${end_date.minute}',
                          style: TextStyle(
                              color: Colors.indigo,
                              fontSize: 28,
                              fontFamily: 'Gotham',
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ),
                      ]),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: !(onlync)
                        ? (ther_list_pending.length + ther_list_compiled.length)
                        : ther_list_pending.length,
                    itemBuilder: (context, index) {
                      return Card(
                          child: Container(
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      colors: (index < ther_list_pending.length)
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
                                padding: const EdgeInsets.only(
                                    top: 15, bottom: 15, left: 15),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: _list_element_maker_ther_man(
                                        (index < ther_list_pending.length)
                                            ? ther_list_pending[index]
                                            : ther_list_compiled[index -
                                                ther_list_pending.length],
                                        context)),
                              )));
                    },
                  ),

                ),
              ])));
        });
  }
}

List<Widget> _list_element_maker_ther_man(Map<String, dynamic> elem, context) {
  String name = elem['name'];
  DateTime st_date = DateTime.parse(elem['start_date']);
  DateTime end_date = DateTime.parse(elem['end_date']);
  String pat = '${elem['patients']['name']} ${elem['patients']['surname']}';

  return [
    /*Row(mainAxisAlignment: MainAxisAlignment.end, children:[
      Padding(padding:EdgeInsets.only(right:15), child:

      )]),*/
    SizedBox(
        width: MediaQuery.of(context).orientation == Orientation.landscape
            ? null
            : MediaQuery.sizeOf(context).width - 30,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            RichText(
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
              strutStyle: StrutStyle(fontSize: 40),
              textAlign: TextAlign.center,
              text: TextSpan(
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade800,
                      fontSize: 25,
                      fontFamily: 'Gotham'),
                  text: name),
            ),
            Spacer(),
              Padding(padding:EdgeInsets.only(right:15), child:
            IconButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await DbComms.supabase
                    .from('therapies')
                    .delete()
                    .match({'clin_id': elem['clin_id']});
              },
              icon:Icon(Icons.close),
              color: Colors.white,
            ),)
          ]),
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
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
                const Text(
                  'Paziente: ',
                  // ${end_date.hour + 2}:${end_date.minute}',
                  style: TextStyle(
                      color: Colors.indigo,
                      fontSize: 28,
                      fontFamily: 'Gotham',
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
                Text(
                  pat,
                  style: const TextStyle(fontSize: 28, fontFamily: 'Gotham'),
                  textAlign: TextAlign.left,
                ),
              ]),
          Row(children: <Widget>[
            const Text(
              'Compilato: ',
              // ${end_date.hour + 2}:${end_date.minute}',
              style: TextStyle(
                  color: Colors.indigo,
                  fontSize: 28,
                  fontFamily: 'Gotham',
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
            (elem['compiled'])
                ? const Icon(
                    Icons.check_circle_outline,
                    color: Colors.blue,
                    size: 50,
                  )
                : const Icon(
                    Icons.close,
                    color: Colors.red,
                    size: 50,
                  )
          ]),
          SizedBox(height:15),
          Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {
                Navigator.pushNamed(context, '/Comptherpage', arguments: elem);
              },
              child: const Text(
                'Compila',
                // ${end_date.hour + 2}:${end_date.minute}',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: 'Gotham',
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              onPressed: () async {
                Navigator.pushNamed(context, '/modtherpage', arguments: elem);
              },
              child: const Text(
                'Modifica',
                // ${end_date.hour + 2}:${end_date.minute}',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: 'Gotham',
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ),
          ]),
        ]))
  ];
}
