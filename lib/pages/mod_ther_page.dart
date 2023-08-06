import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:therapeasy/access.dart';

late Map<String, String> med_list = Map();

class ModTherPage extends StatefulWidget {
  const ModTherPage({super.key});

  State<ModTherPage> createState() => _ModTherPage();
}

class _ModTherPage extends State<ModTherPage> {
  late var arguments;
  late List<Map<String, dynamic>> der_med = [];
  bool mod = true;
  late DateTime stDate;
  late DateTime endDate;

  Widget build(BuildContext context) {
    arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    print(arguments['start_date']);
    if (mod) {
      stDate = DateFormat("yyyy-MM-dd").parse(arguments['start_date']);
      print(stDate);
      endDate = DateFormat("yyyy-MM-dd").parse(arguments['end_date']);
    }
    mod = true;

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
              body: Padding(
                padding: EdgeInsets.all(20),
                child: ListView(children: <Widget>[
                  Row(children: [
                    Column(children: [
                      Text(
                        'Inizio: ${(stDate.day < 10) ? '0${stDate.day}' : '${stDate.day}'}-${(stDate.month < 10) ? '0${stDate.month}' : '${stDate.month}'}-${endDate.year}',
                        style: const TextStyle(
                            color: Colors.indigo,
                            fontSize: 28,
                            fontFamily: 'Gotham',
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        'Fine: ${(endDate.day < 10) ? '0${endDate.day}' : '${endDate.day}'}-${(endDate.month < 10) ? '0${endDate.month}' : '${endDate.month}'}-${stDate.year}',
                        style: const TextStyle(
                            color: Colors.indigo,
                            fontSize: 28,
                            fontFamily: 'Gotham',
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                      ),
                    ]),
                    //SizedBox(width: 20),
                    Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: Container(
                            width: 75,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: Colors.white.withOpacity(0.5),
                            ),
                            child: Center(
                                child: IconButton(
                              iconSize: 55,
                              style: IconButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).secondaryHeaderColor,
                              ),
                              color: Colors.deepPurple,
                              onPressed: () => _selectDate(context),
                              icon: Icon(Icons.calendar_month),
                            )))),
                  ]),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: der_med.length,
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
                        child: Column(
                            children: _list_element_maker_ther_man(
                                der_med[index], context)),
                      ));
                    },
                  )
                ]),
              ));
        });
  }

  Future<void> Refresh() async {
    der_med.clear();
    for (var elem in (await DbComms.supabase
        .from('Derivare_NN')
        .select('*, medicines(name, type, active_principle)')
        .eq('ther_id_fk', (arguments)['clin_id']) as List<dynamic>)) {
      elem as Map<String, dynamic>;
      der_med.add(elem);
    }
    print(der_med);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
        helpText: 'Seleziona intervallo di date per la terapia',
        saveText: 'Salva',
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        context: context,
        firstDate: DateTime.now(),
        lastDate: DateTime(2101));
    if (picked != null) {
      stDate = picked
          .start; //'${picked.start.day}-${picked.start.month}-${picked.start.year}';
      endDate = picked
          .end; //'${picked.end.day}-${picked.end.month}-${picked.end.year}';
      await DbComms.supabase.from('therapies').update({
        'start_date': '${stDate.year}-${stDate.month}-${stDate.day}',
        'end_date': '${endDate.year}-${endDate.month}-${endDate.day}'
      }).match({'clin_id': arguments['clin_id']});
      await DbComms.supabase
          .from('Derivare_NN')
          .update({'ther_id_fk': arguments['clin_id']}).match(
              {'ther_id_fk': arguments['clin_id']});

      setState(() {});
    }
    mod = false;
  }

  void ref() {
    setState(() {});
  }

  List<Widget> _list_element_maker_ther_man(
      Map<String, dynamic> elem, context) {
    final TextEditingController posologia =
        TextEditingController(text: elem['Posology'].toString());
    final _formKey = GlobalKey<FormState>();
    bool br = elem['tod'][0];
    bool lu = elem['tod'][1];
    bool di = elem['tod'][2];
    bool tod = elem['tod'][3];
    String name = elem['medicines']['name'];

    late TimeOfDay? todT;
    if (elem['todh'] != null) {
      todT = TimeOfDay(
          hour: int.parse(elem['todh'].split(":")[0]),
          minute: int.parse(elem['todh'].split(":")[1])); // TimeOfDay.now();
    }

    return [
      Padding(
          padding: EdgeInsets.only(top: 8, right: 8),
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            IconButton(
              color: Colors.white,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await DbComms.supabase
                    .from('Derivare_NN')
                    .delete()
                    .match({'id': elem['id']});
                der_med.remove(elem);
                ref();
              },
              icon: Icon(Icons.close),
            ),
          ])),
      StatefulBuilder(builder: (context, setState) {
        return SizedBox(
            width: MediaQuery.sizeOf(context).width - 60,
            child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(children: [
                  RichText(
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    strutStyle: const StrutStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade800,
                            fontSize: 25,
                            fontFamily: 'Gotham'),
                        text: name),
                  ),
                  Form(
                      key: _formKey,
                      child: Column(children: [
                        Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Wrap(
                                  direction: Axis.vertical,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Checkbox(
                                      checkColor: Colors.white,
                                      value: br,
                                      onChanged: (bool? value) {
                                        br = value!;
                                        setState(() {
                                          tod = false;
                                          elem['tod'][3] = tod;
                                          elem['tod'][0] = br;
                                          print(der_med);
                                        });
                                      },
                                    ),
                                    const Text(
                                      "Colaz  ",
                                      style: TextStyle(
                                          color: Colors.indigo,
                                          fontSize: 15,
                                          fontFamily: 'Gotham',
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.left,
                                    ),
                                  ],
                                ),
                                Wrap(
                                  direction: Axis.vertical,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Checkbox(
                                      checkColor: Colors.white,
                                      value: lu,
                                      onChanged: (bool? value) {
                                        lu = value!;
                                        setState(() {
                                          tod = false;
                                          elem['tod'][3] = tod;
                                          elem['tod'][1] = lu;
                                          print(der_med);
                                        });
                                      },
                                    ),
                                    const Text(
                                      "Pranzo   ",
                                      style: TextStyle(
                                          color: Colors.indigo,
                                          fontSize: 15,
                                          fontFamily: 'Gotham',
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.left,
                                    ),
                                  ],
                                ),
                                Wrap(
                                  direction: Axis.vertical,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Checkbox(
                                      checkColor: Colors.white,
                                      value: di,
                                      onChanged: (bool? value) {
                                        di = value!;
                                        setState(() {
                                          tod = false;
                                          elem['tod'][3] = tod;
                                          elem['tod'][2] = di;
                                          print(der_med);
                                        });
                                      },
                                    ),
                                    const Text(
                                      "Cena  ",
                                      style: TextStyle(
                                          color: Colors.indigo,
                                          fontSize: 15,
                                          fontFamily: 'Gotham',
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.left,
                                    ),
                                  ],
                                ),
                                Wrap(
                                  direction: Axis.vertical,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Row(children: [
                                      Checkbox(
                                        checkColor: Colors.white,
                                        value: tod,
                                        onChanged: (bool? value) async {
                                          tod = value!;
                                          br = false;
                                          lu = false;
                                          di = false;
                                          if (tod) {
                                            todT = await showTimePicker(
                                                initialTime: TimeOfDay.now(),
                                                context: context,
                                                initialEntryMode:
                                                    TimePickerEntryMode
                                                        .inputOnly);
                                          }
                                          if (todT == null) {
                                            tod = false;
                                          } else {
                                            elem['todh'] =
                                                '${todT?.hour}:${(todT!.minute < 10) ? '0${todT!.minute}' : todT!.minute}:00';
                                          }
                                          setState(() {
                                            elem['tod'][0] = br;
                                            elem['tod'][1] = lu;
                                            elem['tod'][2] = di;
                                            elem['tod'][3] = tod;
                                            print(der_med);
                                          });
                                        },
                                      ),
                                    ]),
                                    const Text(
                                      'Orario',
                                      style: TextStyle(
                                          color: Colors.indigo,
                                          fontSize: 15,
                                          fontFamily: 'Gotham',
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.left,
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 20),
                                if (tod && todT != null)
                                  Text(
                                    '${todT?.hour}:${(todT!.minute < 10) ? '0${todT!.minute}' : todT!.minute}',
                                    style: const TextStyle(
                                        color: Colors.indigo,
                                        fontSize: 20,
                                        fontFamily: 'Gotham',
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.left,
                                  )
                              ],
                            )),
                        TextFormField(
                          controller: posologia,
                          decoration: const InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: 'Inserisci posologia',
                            labelStyle: TextStyle(
                                fontSize: 25,
                                color: Colors.indigo,
                                fontFamily: 'Gotham',
                                fontWeight: FontWeight.bold),
                          ),
                          style: const TextStyle(
                              color: Colors.purple,
                              fontSize: 20,
                              fontFamily: 'Gotham',
                              fontWeight: FontWeight.bold),
                          cursorColor: Colors.purple,
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Per favore inserisci una posologia!';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal),
                                onPressed: () async {
                                  if (!elem['tod'][0] &&
                                      !elem['tod'][1] &&
                                      !elem['tod'][2] &&
                                      !elem['tod'][3]) {
                                    AwesomeDialog(
                                      context: context,
                                      btnOkColor: Colors.teal,
                                      animType: AnimType.scale,
                                      dialogType: DialogType.error,
                                      body: const Text(
                                        'Inserisci almeno una fascia oraria!',
                                        // ${end_date.hour + 2}:${end_date.minute}',
                                        style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 28,
                                            fontFamily: 'Gotham',
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.left,
                                      ),
                                      btnOkOnPress: () {},
                                    ).show();
                                    return;
                                  }
                                  if (_formKey.currentState!.validate()) {
                                    // If the form is valid, display a snackbar. In the real world,
                                    // you'd often call a server or save the information in a database.
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          duration: Duration(seconds: 1),
                                          content: Text(
                                              'Sto contattando il server...')),
                                    );
                                    await DbComms.supabase
                                        .from('Derivare_NN')
                                        .update({
                                      'ther_id_fk': elem['ther_id_fk'],
                                      'med_cod_fk': elem['med_cod_fk'],
                                      'tod': elem['tod'],
                                      'Posology': posologia.text,
                                      'todh': (!tod)
                                          ? null
                                          : '${todT!.hour}:${(todT!.minute < 10) ? '0${todT!.minute}' : todT!.minute}:00',
                                    }).match({'id': elem['id']});
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          backgroundColor: Colors.blueAccent,
                                          duration: Duration(seconds: 1),
                                          content: Text(
                                              'Operazione completata con successo...')),
                                    );
                                  }
                                },
                                child: const Text(
                                  'Modifica',
                                  // ${end_date.hour + 2}:${end_date.minute}',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontFamily: 'Gotham',
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              //SizedBox(width:10),
                            ])
                      ]))
                ])));
      }),
    ];
  }
}
