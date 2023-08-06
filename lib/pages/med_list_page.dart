import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:therapeasy/app_user.dart';
import 'package:therapeasy/access.dart';

class MedListPage extends StatefulWidget {
  const MedListPage({super.key});

  State<MedListPage> createState() => _MedListPage();
}

class _MedListPage extends State<MedListPage> {
  late List<Map<String, dynamic>> medlist = [];
  final TextEditingController src = TextEditingController();
  String filt = '';
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
    } else {
      for (var elem in (await DbComms.supabase
          .from('medicines')
          .select('*')
          .textSearch('name', filt) as List<dynamic>)) {
        medlist.add(elem as Map<String, dynamic>);
      }
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
                                    labelText: "Cerca",
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
                Expanded(
                  child: ListView.builder(
                    itemCount: medlist.length,
                    itemBuilder: (context, index) {
                      return Card(
                          child: Container(
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      colors: [
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
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: _list_element_maker_medicines(
                                        medlist[index])),
                              )));
                    },
                  ),
                )
              ])));
        });
  }

  List<Widget> _list_element_maker_medicines(Map<String, dynamic> elem) {
    String name = (elem['name']);
    String type = (elem['type']);
    String ac_pri = elem['active_principle'];

    return [
      SizedBox(
          width: MediaQuery.of(context).orientation == Orientation.landscape
              ? null
              : MediaQuery.sizeOf(context).width - 30,
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
                  text: name),
            ),
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Principio attivo:',
                    style: TextStyle(
                        color: Colors.indigo,
                        fontSize: 28,
                        fontFamily: 'Gotham',
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$ac_pri',
                    style: const TextStyle(fontSize: 28, fontFamily: 'Gotham'),
                  ),
                  const Text(
                    'Tipologia:',
                    // ${end_date.hour + 2}:${end_date.minute}',
                    style: TextStyle(
                        color: Colors.indigo,
                        fontSize: 28,
                        fontFamily: 'Gotham',
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$type',
                    style: const TextStyle(fontSize: 28, fontFamily: 'Gotham'),
                  ),
                ]),
          ]))
    ];
  }
}
