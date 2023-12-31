import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:therapeasy/app_router.dart';
import 'package:therapeasy/app_user.dart';
import 'package:therapeasy/access.dart';

class PatHomePage extends StatefulWidget {
  const PatHomePage({super.key});

  State<PatHomePage> createState() => _PatHPState();
}

class _PatHPState extends State<PatHomePage> {
  late int act_ther;
  bool fastref=false;
  late int pend_med;
  late bool pushpage = false;
  final myChannel = DbComms.supabase.channel('pat_home_channel');
  final therchannel = DbComms.supabase.channel('pat_home_ther_channel');

  @override
  void initState() {
    myChannel.on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
          event: 'UPDATE', // INSERT, DELETE',
          schema: 'public',
          table: 'ther_plan',
          filter: 'pat_id_fk=eq.${Appuser.userID.toString()}'),
      (payload, [ref]) {
        print('rilevata variazione sui farmaci da assumere dalla Pathp');
        setState(() {});
      },
    ).on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
          event: 'INSERT',
          schema: 'public',
          table: 'ther_plan',
          filter: 'pat_id_fk=eq.${Appuser.userID.toString()}'),
      (payload, [ref]) {
        print('rilevata variazione sui farmaci da assumere dalla Pathp');
        setState(() {});
      },
    ).on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
          event: 'DELETE',
          schema: 'public',
          table: 'ther_plan',
          filter: 'pat_id_fk=eq.${Appuser.userID.toString()}'),
      (payload, [ref]) {
        print('rilevata variazione sui farmaci da assumere dalla Pathp');
        setState(() {});
      },
    ).subscribe();

    therchannel.on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
          event: 'UPDATE', // INSERT, DELETE',
          schema: 'public',
          table: 'therapies',
          filter: 'pat_id_fk=eq.${Appuser.userID.toString()}'),
      (payload, [ref]) {
        print('rilevata variazione sulle terapie associate dalla Pathp');
        setState(() {});
      },
    ).on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
          event: 'INSERT', // INSERT, DELETE',
          schema: 'public',
          table: 'therapies',
          filter: 'pat_id_fk=eq.${Appuser.userID.toString()}'),
      (payload, [ref]) {
        print('rilevata variazione sulle terapie associate dalla Pathp');
        setState(() {});
      },
    ).on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
          event: 'DELETE', // INSERT, DELETE',
          schema: 'public',
          table: 'therapies',
          filter: 'pat_id_fk=eq.${Appuser.userID.toString()}'),
      (payload, [ref]) {
        print('rilevata variazione sulle terapie associate dalla Pathp');
        setState(() {});
      },
    ).subscribe();

    super.initState();
  }

  Future<void> Refresh() async {
    act_ther = (await DbComms.supabase
            .from('therapies')
            .select('clin_id')
            .eq('pat_id_fk', Appuser.userID)
            .eq('state', true))
        .length;

    pend_med = (await DbComms.supabase
            .from('ther_plan')
            .select('plan_id')
            .eq('pat_id_fk', Appuser.userID)
            .eq('state', 'wait'))
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Refresh(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !fastref) {
            fastref=true;
            return AppRouter.waitingAnim(context);
          } else {
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
                        icon: const Icon(Icons.logout))
                  ],
                ),
                body: ListView(children: <Widget>[
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            // Add some spacing between the top of the card and the title
                                            Container(height: 5),
                                            // Add a title widget
                                            RichText(
                                                text: TextSpan(
                                                    text:
                                                        "Ciao, ${Appuser.name}",
                                                    style: const TextStyle(
                                                        color: Colors.teal,
                                                        fontSize: 25,
                                                        fontFamily: 'Gotham'))),
                                            // Add some spacing between the title and the subtitle
                                            Container(height: 5),
                                            // Add a subtitle widget
                                            RichText(
                                                text: TextSpan(
                                                    text:
                                                        "Al momento hai $act_ther terapie attive e devi assumere $pend_med medicine",
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
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
                              child: InkWell(
                                onTap: () async {
                                  Navigator.pushNamed(context, '/medpage');
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    // Add padding around the row widget
                                    Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          // Add an image widget to display an image
                                          Image.asset(
                                            'assets/images/med_list.png',
                                            height: 75,
                                            width: 75,
                                            fit: BoxFit.cover,
                                          ),
                                          // Add some spacing between the image and the text
                                          Container(width: 20),
                                          // Add an expanded widget to take up the remaining horizontal space
                                          Flexible(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                // Add some spacing between the top of the card and the title
                                                Container(height: 5),
                                                // Add a title widget
                                                RichText(
                                                    text: const TextSpan(
                                                        text: "Le tue medicine",
                                                        style: TextStyle(
                                                            color:
                                                                Color.fromARGB(
                                                                    1000,
                                                                    104,
                                                                    120,
                                                                    222),
                                                            fontSize: 30,
                                                            fontFamily:
                                                                'Gotham'))),
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
                            )),
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
                              child: InkWell(
                                onTap: () async {
                                  Navigator.pushNamed(context, '/therpage');
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    // Add padding around the row widget
                                    Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          // Add an image widget to display an image
                                          Image.asset(
                                            'assets/images/ther_list.png',
                                            height: 75,
                                            width: 75,
                                            fit: BoxFit.cover,
                                          ),
                                          // Add some spacing between the image and the text
                                          Container(width: 20),
                                          // Add an expanded widget to take up the remaining horizontal space
                                          Flexible(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                // Add some spacing between the top of the card and the title
                                                Container(height: 5),
                                                // Add a title widget
                                                RichText(
                                                    text: const TextSpan(
                                                        text: "Le tue terapie",
                                                        style: TextStyle(
                                                            color:
                                                                Color.fromARGB(
                                                                    1000,
                                                                    104,
                                                                    120,
                                                                    222),
                                                            fontSize: 30,
                                                            fontFamily:
                                                                'Gotham'))),
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
                            )),
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
                            child: InkWell(
                              onTap: () async {
                                //await DbComms.supabase.removeChannel(myChannel);
                                Navigator.pushNamed(context, '/therplanpage');
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  // Add padding around the row widget
                                  Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        // Add an image widget to display an image
                                        Image.asset(
                                          'assets/images/ther_plans.png',
                                          height: 75,
                                          width: 75,
                                          fit: BoxFit.cover,
                                        ),
                                        // Add some spacing between the image and the text
                                        Container(width: 20),
                                        // Add an expanded widget to take up the remaining horizontal space
                                        Flexible(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              // Add some spacing between the top of the card and the title
                                              Container(height: 5),
                                              // Add a title widget
                                              RichText(
                                                  text: const TextSpan(
                                                      text: "I tuoi piani",
                                                      style: TextStyle(
                                                          color: Color.fromARGB(
                                                              1000,
                                                              104,
                                                              120,
                                                              222),
                                                          fontSize: 30,
                                                          fontFamily:
                                                              'Gotham'))),
                                              // Add some spacing between the title and the subtitle
                                              Container(height: 5),
                                              // Add a subtitle widget
                                            ],
                                          ),
                                        ),
                                        Container(width: 20),
                                        Padding(
                                            padding: EdgeInsets.only(right: 10),
                                            child: Icon(
                                                ((Appuser.pending_med.isEmpty)
                                                    ? Icons.emoji_emotions_sharp
                                                    : Icons
                                                        .access_time_rounded),
                                                color: (Appuser
                                                        .pending_med.isEmpty)
                                                    ? Colors.greenAccent
                                                    : Colors.redAccent,
                                                size: 40)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ]))
                ]));
          }
        });
  }
}
