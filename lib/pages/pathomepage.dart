import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:therapeasy/Appuser.dart';
import 'package:therapeasy/access.dart';
import 'package:therapeasy/dbcall.dart';

class PatHomePage extends StatefulWidget {
  const PatHomePage({super.key});

  State<PatHomePage> createState() => _PatHPState();
}

class _PatHPState extends State<PatHomePage> {
  //late int med=0;

  late bool pushpage = false;
  final myChannel = DbComms.supabase.channel('my_channel');
  /*void medstate() async {
    med=((await DbComms.supabase
        .from('ther_plan')
        .select('plan_id, state')
        .eq('state', 'wait')) as List<dynamic>).length;
    setState(() {
    });
  }*/

  @override
  void initState() {
    //medstate();
    super.initState();
    myChannel.on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
          event: 'UPDATE',
          schema: 'public',
          table: 'ther_plan',
          filter: 'pat_id_fk=eq.${Appuser.userID.toString()}'),
      (payload, [ref]) {
        setState(() {
          /*payload as Map<String, dynamic>;
          if(payload['new']['state'].toString() == 'wait') {
            //med=payload.length;
          } else if(payload['new']['state'].toString() == 'ncom' || payload['new']['state'].toString() == 'comp'){
            //med=payload.length;
          }*/
        });
      },
    ).subscribe();
  }

  @override
  Widget build(BuildContext context) {
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
                  await DbComms.supabase.removeChannel(myChannel);
                  Future.delayed(Duration.zero, () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/loginPage', (route) => false);
                  });
                },
                icon: const Icon(Icons.logout))
          ],
        ),
        body:
        ListView(
            children: <Widget>[
        Center(
            child: Column(
                //mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Card(
                  elevation: 0,
                  // Define the shape of the card
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  // Define how the card's content should be clipped
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  // Define the child widget of the card
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      // Add padding around the row widget
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            // Add an image widget to display an image
                            Image.asset(
                              'assets/images/pat_logo.png',
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                            // Add some spacing between the image and the text
                            Container(width: 20),
                            // Add an expanded widget to take up the remaining horizontal space
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  // Add some spacing between the top of the card and the title
                                  Container(height: 5),
                                  // Add a title widget
                                  RichText(
                                      text: TextSpan(
                                          text: "Ciao, ${Appuser.name}",
                                          style: const TextStyle(
                                              color: Colors.teal,
                                              fontSize: 25,
                                              fontFamily: 'Gotham'))),
                                  // Add some spacing between the title and the subtitle
                                  Container(height: 5),
                                  // Add a subtitle widget
                                  RichText(
                                      text: TextSpan(
                                          text: "Al momento hai ${Appuser.ther.length} terapie attive e devi assumere ${Appuser.pending_med.length} medicine",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                              color: Colors.amber,
                                              fontSize: 15,
                                              fontFamily: 'Gotham'))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Card(
                  // Define the shape of the card
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  // Define how the card's content should be clipped
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  // Define the child widget of the card
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      // Add padding around the row widget
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            // Add an image widget to display an image
                            Image.asset(
                              'assets/images/medicine_logo.png',
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                            // Add some spacing between the image and the text
                            Container(width: 20),
                            // Add an expanded widget to take up the remaining horizontal space
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  // Add some spacing between the top of the card and the title
                                  Container(height: 5),
                                  // Add a title widget
                                  RichText(
                                      text: const TextSpan(
                                          text: "Le tue medicine",
                                          style: TextStyle(
                                              color: Color.fromARGB(1000,104, 120, 222),
                                              fontSize: 30,
                                              fontFamily: 'Gotham'))),
                                  // Add some spacing between the title and the subtitle
                                  Container(height: 5),
                                  // Add a subtitle widget
                                ],
                              ),
                            ),
                            Container(width: 20),
                            Icon(((Appuser.pending_med.isEmpty)?Icons.emoji_emotions_sharp:Icons.access_time_rounded)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Card(
                      // Define the shape of the card
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      // Define how the card's content should be clipped
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      // Define the child widget of the card
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          // Add padding around the row widget
                          Padding(
                            padding: const EdgeInsets.all(15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                // Add an image widget to display an image
                                Image.asset(
                                  'assets/images/ther_image.png',
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                                // Add some spacing between the image and the text
                                Container(width: 20),
                                // Add an expanded widget to take up the remaining horizontal space
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      // Add some spacing between the top of the card and the title
                                      Container(height: 5),
                                      // Add a title widget
                                      RichText(
                                          text: const TextSpan(
                                              text: "Le tue terapie",
                                              style: TextStyle(
                                                  color: Color.fromARGB(1000,104, 120, 222),
                                                  fontSize: 30,
                                                  fontFamily: 'Gotham'))),
                                      // Add some spacing between the title and the subtitle
                                      Container(height: 5),
                                      // Add a subtitle widget
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Card(
                      // Define the shape of the card
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      // Define how the card's content should be clipped
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      // Define the child widget of the card
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          // Add padding around the row widget
                          Padding(
                            padding: const EdgeInsets.all(15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                // Add an image widget to display an image
                                Image.asset(
                                  'assets/images/plan_image.png',
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                                // Add some spacing between the image and the text
                                Container(width: 20),
                                // Add an expanded widget to take up the remaining horizontal space
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      // Add some spacing between the top of the card and the title
                                      Container(height: 5),
                                      // Add a title widget
                                      RichText(
                                          text: const TextSpan(
                                              text: "I tuoi piani",
                                              style: TextStyle(
                                                  color: Color.fromARGB(1000,104, 120, 222),
                                                  fontSize: 30,
                                                  fontFamily: 'Gotham'))),
                                      // Add some spacing between the title and the subtitle
                                      Container(height: 5),
                                      // Add a subtitle widget
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ]))]));
  }
}
