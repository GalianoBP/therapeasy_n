import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:therapeasy/access.dart';

class loginPage extends StatefulWidget {
  @override
  State<loginPage> createState() => _LoginState();
}

class _LoginState extends State<loginPage> {
  final TextEditingController name = TextEditingController();
  final TextEditingController psw = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late String go;

  @override
  void initState() {
    super.initState();
    //, (route) => false);});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Form(
            key: _formKey,
            child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      RichText(
                          text: const TextSpan(
                              text: "Therapeasy",
                              style: TextStyle(
                                  color: Colors.teal,
                                  fontSize: 40,
                                  fontFamily: 'VeganStyle'))),
                      Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: SizedBox(
                              width: 320,
                              child: TextFormField(
                                  controller: name,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Per favore inserisci la tua email';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'email',
                                    hintStyle:
                                    const TextStyle(fontFamily: 'VeganStyle'),
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
                                  )))),
                      Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: SizedBox(
                              width: 320,
                              child: TextFormField(
                                  controller: psw,
                                  obscureText: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Per favore inserisci la tua password';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'password',
                                    hintStyle:
                                    const TextStyle(fontFamily: 'VeganStyle'),
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
                                  )))),
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: ElevatedButton(
                            onPressed: () async {
                              // Validate returns true if the form is valid, or false otherwise.
                              if (_formKey.currentState!.validate()) {
                                // If the form is valid, display a snackbar. In the real world,
                                // you'd often call a server or save the information in a database.
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    duration: Duration(seconds: 1),
                                      content:
                                      Text('Sto contattando il server...')),
                                );

                                Future<bool> logged = DbComms.userAccess(name, psw);
                                if (await logged) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        duration: Duration(seconds: 1),
                                        backgroundColor: Colors.greenAccent,
                                        content:
                                        Text('Benvenuto')
                                  ));
                                  go = await DbComms.routeToGo();
                                  Future.delayed(Duration.zero, () { Navigator.pushNamedAndRemoveUntil(context, go, (route) =>false);});
                                }
                                else{
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        duration: Duration(seconds: 1),
                                        backgroundColor: Colors.redAccent,
                                        content:
                                        Text('Credenziali errate o sessione già attiva')),
                                  );
                                }
                              }
                            },
                            child: const Text('Submit'),
                          ))
                    ]))));
  }
}
