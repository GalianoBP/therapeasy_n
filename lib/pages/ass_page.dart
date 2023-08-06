import 'package:flutter/material.dart';
import 'package:therapeasy/access.dart';

class AssPage extends StatefulWidget {
  const AssPage({super.key});

  @override
  State<AssPage> createState() => _AssPage();
}

class _AssPage extends State<AssPage> {
  late Set<String> med_not_ass = Set();
  late Map<String, List<String>> ther_plan = Map();
  final myChannel = DbComms.supabase.channel('ass_page_channel');
  late var arguments;

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;

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
                      setState(() {});
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
                                colors: [
                                  Colors.orangeAccent.shade100,
                                  Colors.orange.shade200
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
                              children: _list_element_maker_assumption(
                                  ther_plan.keys.toList()[index], context)),
                        )));
              },
            ),
          );
        });
  }

  Future<void> Refresh() async {
    med_not_ass.clear();
    ther_plan.clear();
    for (var elem in await DbComms.supabase
        .from('ther_plan')
        .select('sub_date,hour,medicines(name),Derivare_NN(Posology)')
        .eq('clin_id_fk', arguments['clin_id'])
        .eq('state', 'ncomp')
        .order('sub_date,hour')) {
      DateTime day = DateTime.parse(elem['sub_date']);
      TimeOfDay time = TimeOfDay(
          hour: int.parse(elem['hour'].split(":")[0]),
          minute: int.parse(elem['hour'].split(":")[1]));

      if (!ther_plan.containsKey(elem['medicines']['name'])) {
        ther_plan[elem['medicines']['name']] = [
          '${day.day}-${day.month}-${day.year}',
          '${time.hour}:${time.minute}'
        ];
      } else {
        ther_plan[elem['medicines']['name']]
            ?.add('${day.day}-${day.month}-${day.year}');
        ther_plan[elem['medicines']['name']]
            ?.add('${time.hour}:${time.minute}');
      }
    }

    ther_plan = Map.fromEntries(
        ther_plan.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key)));
    print(ther_plan);
    print(
        "Il paziente ha ${ther_plan.length} medicinali non assunti per la terapia ${arguments['clin_id']}");
  }

  List<Widget> _list_element_maker_assumption(String name, context) {
    var hd = ther_plan[name];
    List<Widget> days = [];
    List<Widget> hours = [];

    for (int i = 0; i < (ther_plan[name]!.length); i++) {
      (i % 2 == 0)
          ? days.add(
              Text(
                hd![i],
                style: const TextStyle(fontSize: 28, fontFamily: 'Gotham'),
                textAlign: TextAlign.left,
              ),
            )
          : hours.add(
              Text(
                hd![i],
                style: const TextStyle(fontSize: 28, fontFamily: 'Gotham'),
                textAlign: TextAlign.left,
              ),
            );
    }

    return [
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
            )
          ]),
          const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Data',
                  style: TextStyle(
                      color: Colors.indigo,
                      fontSize: 28,
                      fontFamily: 'Gotham',
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
                SizedBox(
                  width: 90,
                ),
                Text(
                  'Ora',
                  // ${end_date.hour + 2}:${end_date.minute}',
                  style: TextStyle(
                      color: Colors.indigo,
                      fontSize: 28,
                      fontFamily: 'Gotham',
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
              ]),
          ListView.builder(
              shrinkWrap: true,
              itemCount: days.length,
              itemBuilder: (context, index) {
                return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      days[index],
                      SizedBox(
                        width: 20,
                      ),
                      hours[index],
                    ]);
              })
        ]),
      )
    ];
  }
}
