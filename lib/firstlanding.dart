import 'package:flutter/material.dart';

class Firstlanding extends StatefulWidget {
  TextField styledTextField(
      context, String hint, bool obscure, controllerText) {
    return TextField(
      controller: controllerText,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.onPrimary,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.onSecondary,
            width: 2.0,
          ),
        ),
      ),
    );
  }

  @override
  State<Firstlanding> createState() => _LoginState();
}

class _LoginState extends State<Firstlanding> {
  final TextEditingController name = TextEditingController();
  final TextEditingController psw = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Form(
            key:_formKey,
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
                      )))),
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ElevatedButton(
                    onPressed: () {
                      // Validate returns true if the form is valid, or false otherwise.
                      if (_formKey.currentState!.validate()) {
                        // If the form is valid, display a snackbar. In the real world,
                        // you'd often call a server or save the information in a database.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sto contattando il server...')),
                        );

                      }
                    },
                    child: const Text('Submit'),))
        ]))));
  }

  void Getaccess(){

  }
}
