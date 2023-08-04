import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:therapeasy/access.dart';

late Map<String, String> med_list = Map();

class CompTherPage extends StatefulWidget {
  const CompTherPage({super.key});

  State<CompTherPage> createState() => _CompTherPage();
}

class _CompTherPage extends State<CompTherPage> {
  //final List<TextEditingController> trattamento = [];
  final myChannel = DbComms.supabase.channel('mod_ther_page_channel');

  late List<Map<String, dynamic>> sub_med = [];
  late Map<String, Map<String, dynamic>> der_med = Map();
  late final med;

  //late String pat;
  late var arguments;

  @override
  void initState() {
    myChannel.on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(event: 'UPDATE', schema: 'public', table: 'medicines'),
      (payload, [ref]) async {
        await Refresh();
        print(
            'rilevato update sulle medicine dalla mod_ther_page, medicine rilevate: ${med_list.length} ');
        setState(() {});
      },
    ).on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(event: 'INSERT', schema: 'public', table: 'patients'),
      (payload, [ref]) async {
        await Refresh();
        print(
            'rilevato insert  sulle medicine dalla mod_ther_page, medicine rilevate: ${med_list.length}');
        setState(() {});
      },
    ).on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(event: 'DELETE', schema: 'public', table: 'patients'),
      (payload, [ref]) async {
        await Refresh();
        print(
            'rilevato delete  sulle medicine dalla mod_ther_page, medicine rilevate: ${med_list.length}');
        setState(() {});
      },
    ).subscribe();
    med_list.clear();
    super.initState();
  }

  void ref(){
    setState(() {

    });
  }

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
                  padding: const EdgeInsets.all(20),
                  child: ListView(children: [
                    DropdownSearch<String>(
                      selectedItem: null,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Per favore inserisci un medicinale!';
                        }
                        return null;
                      },
                      popupProps: const PopupProps.menu(
                        showSearchBox: true,
                        showSelectedItems: false,
                      ),
                      items: med_list.keys.toList(),
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: "medicinale",
                          hintText:
                              "Seleziona un medicinale, puoi cercarlo nella barra sottostante",
                        ),
                      ),
                      onChanged: (String? src) {
                        AddSub(med_list[src].toString());
                        med_list.remove(src);
                      },
                    ),
                    Column(
                      children: <Widget>[
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: sub_med.length,
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
                                      sub_med[index], context)),
                            ));
                          },
                        ),
                      ],
                    )
                  ])));
        });

  }

  Future<void> Refresh() async {
    med_list.clear();
    String present;
    for (var elem in (await DbComms.supabase.from('medicines').select('*')
        as List<dynamic>)) {
      elem as Map<String, dynamic>;
      med_list['${elem['name']} ${elem['type']} ${elem['active_principle']}'] =
          '${elem['med_code']}';
    }

    for (var elem in (await DbComms.supabase
        .from('Derivare_NN')
        .select('*')
        .eq('ther_id_fk', (arguments)['clin_id']) as List<dynamic>)) {
      elem as Map<String, dynamic>;
      //der_med[elem['med_cod_fk'].toString()]=elem;
      //print(sub_med);
      if (med_list.containsValue(elem['med_cod_fk'].toString())) {
        present = med_list.keys
            .firstWhere((k) => med_list[k] == elem['med_cod_fk'].toString());
        print('Medicinale ${med_list[present]} già presente in terapia');
        //sub_med[elem['med_cod_fk'].toString()] = present;
        med_list.remove(present);
        //print(sub_med);
      }
    }
  }

  void AddSub(String medcode) {
    bool ins = true;
    Map<String, dynamic> tempap = Map();

    //der_med[elem[medcode].toString()]=elem;
    List<bool> tod = [false, false, false, false];
    int therId = (arguments)['clin_id'];
    String posology = '';
    String todh = '';
    tempap[medcode] = [therId, medcode, tod, posology, todh].toList();
    for (Map<String, dynamic> elem in sub_med) {
      if (elem.keys.first == medcode) {
        ins = false;
        break;
      }
    }

    if (ins) sub_med.add(tempap);
    print('$sub_med\n');
    setState(() {});
  }


  List<Widget> _list_element_maker_ther_man(
      Map<String, dynamic> elem, context) {

    final _formKey = GlobalKey<FormState>();
    String key = elem.keys.first;
    final TextEditingController posologia = TextEditingController(text: (elem[key])[3].toString());
    bool br = ((elem.values.toSet().elementAt(0)[2][0]));
    bool lu = ((elem.values.toSet().elementAt(0)[2][1]));
    bool di = ((elem.values.toSet().elementAt(0)[2][2]));
    bool tod = ((elem.values.toSet().elementAt(0)[2][3]));
    String name = med_list.keys.firstWhere(
            (k) => med_list[k] == elem.keys.first.toString(),
        orElse: () => 'Caricamento...');

    late TimeOfDay? todT; // TimeOfDay.now();

    return [
      Padding(
          padding: EdgeInsets.only(top: 8, right: 8),
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            IconButton(
              color: Colors.white,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                  sub_med.remove(elem); ref();
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
                    textAlign: TextAlign.justify,
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
                                          (elem[key])[2][3] = tod;
                                          (elem[key])[2][0] = br;
                                          print(sub_med);
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
                                          (elem[key])[2][3] = tod;
                                          (elem[key])[2][1] = lu;
                                          print(sub_med);
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
                                          (elem[key])[2][3] = tod;
                                          (elem[key])[2][2] = di;
                                          print(sub_med);
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
                                            (elem[key])[4] =
                                            '${todT?.hour}:${(todT!.minute < 10) ? '0${todT!.minute}' : todT!.minute}:00';
                                          }
                                          setState(() {
                                            (elem[key])[2][0] = br;
                                            (elem[key])[2][1] = lu;
                                            (elem[key])[2][2] = di;
                                            (elem[key])[2][3] = tod;
                                            print(sub_med);
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
                          onTapOutside: (str) { (elem[key])[3]=posologia.text; print((elem[key]));},
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
                                  if (!(elem[key])[2][0] &&
                                      !(elem[key])[2][1] &&
                                      !(elem[key])[2][2] &&
                                      !(elem[key])[2][3]) {
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
                                        .insert({
                                      'ther_id_fk': (elem[key])[0],
                                      'med_cod_fk': (elem[key])[1],
                                      'tod': (elem[key])[2],
                                      'Posology': posologia.text,
                                      'todh': (!tod)
                                          ? null
                                          : '${todT!.hour}:${(todT!.minute < 10) ? '0${todT!.minute}' : todT!.minute}:00',
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          backgroundColor: Colors.blueAccent,
                                          duration: Duration(seconds: 1),
                                          content: Text(
                                              'Operazione completata con successo...')),
                                    );
                                    sub_med.remove(elem);
                                    ref();
                                  }
                                },
                                child: const Text(
                                  'Inserisci',
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
