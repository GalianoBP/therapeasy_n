import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:therapeasy/Appuser.dart';
import 'package:therapeasy/access.dart';
import 'package:therapeasy/icons.dart';

class TherPlanPage extends StatefulWidget {
  const TherPlanPage({super.key});

  State<TherPlanPage> createState() => _TherPlanPage();
}

class _TherPlanPage extends State<TherPlanPage> {
  late List<Map<String, dynamic>> ther_plan = [];
  final myChannel = DbComms.supabase.channel('ther_plan_channel');

  void initState() {
    myChannel.on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
          event: 'UPDATE',//, INSERT, DELETE',
          schema: 'public',
          table: 'ther_plan',
          filter: 'pat_id_fk=eq.${Appuser.userID.toString()}'),
      (payload, [ref]) async {
        await Refresh();
      },
    ).on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
          event: 'INSERT',
          schema: 'public',
          table: 'ther_plan',
          filter: 'pat_id_fk=eq.${Appuser.userID.toString()}'),
          (payload, [ref]) async {
        await Refresh();
      },
    ).on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
          event: 'DELETE',
          schema: 'public',
          table: 'ther_plan',
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
                  ther_plan.clear();
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
          itemCount: ther_plan.length,
          itemBuilder: (context, index) {
            return Card(
                child: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: (ther_plan[index]['state'] != 'wait')
                                ? [
                                    Colors.yellow.shade200,
                                    Colors.yellow.shade400
                                  ]
                                : [Colors.red.shade200, Colors.red.shade300],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                        borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(15),
                            left: Radius.circular(15))),
                    child: Padding(
                      padding: const EdgeInsets.only(top:15, bottom:15, left:15),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: list_element_maker(ther_plan[index])),
                    )));
          },
        ));
  }

  Future<void> Refresh() async {
    late List<Map<String, dynamic>> _int_pend_med = [];
    late List<Map<String, dynamic>> _int_npend_med = [];
    ther_plan.clear();
    for (var elem in await DbComms.supabase
        .from('ther_plan')
        .select(
            '*, therapies(name,doc_id_fk), medicines(name),Derivare_NN(Posology)')
        .eq('pat_id_fk', Appuser.userID)
        .eq('state', 'wait')
        .order('state, active, sub_date,hour')) {
      _int_pend_med.add(elem as Map<String, dynamic>);
    }

    for (var elem in await DbComms.supabase
        .from('ther_plan')
        .select(
            '*, therapies(name,doc_id_fk), medicines(name),Derivare_NN(Posology)')
        .eq('pat_id_fk', Appuser.userID)
        .neq('state', 'wait')
        .order('active', ascending: false)
        .order('sub_date,hour', ascending: true)) {
      _int_npend_med.add(elem as Map<String, dynamic>);
    }

    ther_plan = _int_pend_med + _int_npend_med;
    setState(() {
      print("--- Lista aggiornata ---");
      print(ther_plan.length);
    });
  }

  List<Widget> list_element_maker(Map<String, dynamic> elem) {
    String Farmaco = elem['medicines']['name'];
    String Terapia = elem['therapies']['name'];
    DateTime s = DateTime.parse('${elem['sub_date']} ${elem['hour']}');
    String doc_id = elem['therapies']['doc_id_fk'].toString();
    String doc_name = '', doc_surname = '', doc_spec = '';
    return [
      SizedBox(
        width: MediaQuery.of(context).orientation == Orientation.landscape ? null: 179,
          child: Column(children: [
        RichText(
          overflow: TextOverflow.ellipsis,
          strutStyle: StrutStyle(fontSize: 40),
          text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 25),
              text: Farmaco),
        ),
        Text(
          '${s.day}-${s.month}-${s.year} ${s.hour + 2}:${s.minute}',
          style: const TextStyle(
            fontSize: 28,
          ),
        )
      ])),
      Flexible(fit:FlexFit.tight, child:
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
          children: [Spacer(),
        IconButton(
          iconSize: 75,
          onPressed: (elem['state'] == 'wait') ? () async {
           print(await DbComms.supabase
                .from('ther_plan')
                .update({ 'state': 'comp'})
                .eq('plan_id', elem['plan_id']));
          } : null,
          icon: const Icon(Icons.check_circle_outline),
          padding: const EdgeInsets.only(left:10,right: 10),
        ),
        Padding(padding: EdgeInsets.only(right: 10), child:
        Column(crossAxisAlignment: CrossAxisAlignment.end,mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(
              icon: Icon(Icons.medication, size: 30),
              onPressed: () {
                AwesomeDialog(
                  context: context,
                  btnOkColor: Colors.teal,
                  animType: AnimType.scale,
                  dialogType: DialogType.info,
                  title: Farmaco,
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
                                    text: "Farmaco: ",
                                    style: TextStyle(
                                        color: Colors.teal,
                                        fontSize: 20,
                                        fontFamily: 'Gotham'))),
                            Flexible(
                              child: RichText(
                                  maxLines: 3,
                                  softWrap: true,
                                  text: TextSpan(
                                      text: Farmaco,
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
                                    text: "Posologia: ",
                                    style: TextStyle(
                                        color: Colors.teal,
                                        fontSize: 20,
                                        fontFamily: 'Gotham'))),
                            Flexible(
                              child: RichText(
                                  maxLines: 3,
                                  softWrap: true,
                                  text: TextSpan(
                                      text: elem['Derivare_NN']['Posology'],
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
                                    text: "Terapia: ",
                                    style: TextStyle(
                                        color: Colors.teal,
                                        fontSize: 20,
                                        fontFamily: 'Gotham'))),
                            Flexible(
                              child: RichText(
                                  maxLines: 3,
                                  softWrap: true,
                                  text: TextSpan(
                                      text: Terapia,
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
              }),
          IconButton(
              icon: const Icon(Medicons.stethoscope),
              onPressed: () async {
                for (var elem in await DbComms.supabase
                    .from('doctors')
                    .select('*')
                    .eq('doc_id', doc_id)) {
                  doc_name = elem['name'];
                  doc_surname = elem['surname'];
                  doc_spec = elem['med_spec'];
                }
                AwesomeDialog(
                  context: context,
                  btnOkColor: Colors.teal,
                  animType: AnimType.scale,
                  dialogType: DialogType.info,
                  title: Farmaco,
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
                                text: TextSpan(
                                    text: "Medico: ",
                                    style: TextStyle(
                                        color: Colors.teal,
                                        fontSize: 20,
                                        fontFamily: 'Gotham'))),
                            Expanded(
                              child: RichText(
                                  maxLines: 3,
                                  softWrap: true,
                                  text: TextSpan(
                                      text: '$doc_name $doc_surname',
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
                            Expanded(
                              child: RichText(
                                  maxLines: 3,
                                  softWrap: true,
                                  text: TextSpan(
                                      text: '$doc_spec',
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
                                    text: "Terapia: ",
                                    style: TextStyle(
                                        color: Colors.teal,
                                        fontSize: 20,
                                        fontFamily: 'Gotham'))),
                            Expanded(
                              child: RichText(
                                  maxLines: 3,
                                  softWrap: true,
                                  text: TextSpan(
                                      text: Terapia,
                                      style: const TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontFamily: 'Gotham'))),
                            )
                          ],
                        )),
                  ])),
                  desc:
                      'Questo farmaco fà parte della tua terapia per ${Terapia}, la sua posologia è: ${elem['Derivare_NN']['Posology']}',
                  btnOkOnPress: () {},
                ).show();
              }),
        ]))
      ])
    )];
  }
}
