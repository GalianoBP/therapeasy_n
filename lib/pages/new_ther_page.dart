import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:therapeasy/app_user.dart';
import 'package:therapeasy/access.dart';

class NewTherPage extends StatefulWidget {
  const NewTherPage({super.key});

  State<NewTherPage> createState() => _NewTherPage();
}

class _NewTherPage extends State<NewTherPage> {
  final TextEditingController trattamento = TextEditingController();
  final myChannel = DbComms.supabase.channel('new_ther_page_channel');
  late Map<String, String> pat_list = Map();
  late String pat;
  final _formKey = GlobalKey<FormState>();
  DateTime stDate = DateTime
      .now(); //DateTime(DateTime.now().day,DateTime.now().month,DateTime.now().year);
  DateTime endDate = DateTime.now().add(Duration(
      days:
          7)); //DateTime(DateTime.now().day,DateTime.now().month,DateTime.now().year).add(const Duration(days: 7));

  void initState() {
    myChannel.on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(event: 'UPDATE', schema: 'public', table: 'patients'),
      (payload, [ref]) async {
        await Refresh();
        print(
            'rilevato update sui pazienti dalla new_ther_page, pazienti rilevati: $pat_list ');
        setState(() {});
      },
    ).on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(event: 'INSERT', schema: 'public', table: 'patients'),
      (payload, [ref]) async {
        await Refresh();
        print(
            'rilevato insert sui pazienti dalla new_ther_page, pazienti rilevati: $pat_list ');
        setState(() {});
      },
    ).on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(event: 'DELETE', schema: 'public', table: 'patients'),
      (payload, [ref]) async {
        await Refresh();
        print(
            'rilevato delete sulle terapie dalla new_ther_page, pazienti rilevati: $pat_list ');
        setState(() {});
      },
    ).subscribe();
    pat_list.clear();
    super.initState();
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
              body: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: ListView(
                    children: [
                      DropdownSearch<String>(
                        selectedItem: null,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Per favore inserisci un paziente!';
                          }
                          return null;
                        },
                        popupProps: const PopupProps.menu(
                          showSearchBox: true,
                          showSelectedItems: true,
                        ),
                        items: pat_list.keys.toList(),
                        dropdownDecoratorProps: const DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: "Paziente",
                            hintText:
                                "Seleziona un paziente, puoi cercarlo nella barra sottostante",
                          ),
                        ),
                        onChanged: (String? src) => {pat = pat_list[src]!},
                      ),
                      SizedBox(height: 20),
                      Row(children: <Widget>[
                        Column(children: <Widget>[
                          Text(
                              'Inizio terapia: ${stDate.day}-${stDate.month}-${stDate.year}'),
                          Text(
                              'Fine terapia: ${endDate.day}-${endDate.month}-${endDate.year}'),
                        ]),
                        Padding(
                            padding: EdgeInsets.only(left: 20),
                            child: ElevatedButton(
                              onPressed: () => _selectDate(context),
                              child: const Text('Seleziona date'),
                            )),
                      ]),
                      //DatePickerDialog(initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: {DateTime.now()+365})
                      const SizedBox(
                        height: 20.0,
                      ),
                      TextFormField(
                        controller: trattamento,
                        decoration: InputDecoration(
                          hintText: 'nome della terapia',
                          hintStyle: const TextStyle(fontFamily: 'VeganStyle'),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              color: Colors.teal,
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: Colors.greenAccent,
                              width: 2.0,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Per favore inserisci un nome della terapia!';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // If the form is valid, display a snackbar. In the real world,
                            // you'd often call a server or save the information in a database.
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  duration: Duration(seconds: 1),
                                  content:
                                      Text('Sto contattando il server...')),
                            );
                            await DbComms.supabase.from('therapies').insert({
                              'name': trattamento.text,
                              'pat_id_fk': pat,
                              'doc_id_fk': Appuser.userID,
                              'start_date':
                                  '${stDate.year}-${stDate.month}-${stDate.day}',
                              'end_date':
                                  '${endDate.year}-${endDate.month}-${endDate.day}'
                            });
                            Navigator.of(context).pop();
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
                      )
                    ],
                  ),
                ),
              ));
        });
  }

  Future<void> Refresh() async {
    pat_list.clear();
    for (var elem in (await DbComms.supabase.from('patients').select('*')
        as List<dynamic>)) {
      elem as Map<String, dynamic>;
      pat_list['${elem['cf']} ${elem['name']} ${elem['surname']}'] =
          '${elem['pat_id']}';
    }
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
      setState(() {
        stDate = picked.start;
        endDate = picked.end;
      });
    }
  }
}
