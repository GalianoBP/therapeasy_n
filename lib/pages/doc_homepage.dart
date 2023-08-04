import 'package:flutter/material.dart';
import 'package:therapeasy/app_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:therapeasy/app_user.dart';
import 'package:therapeasy/access.dart';

class DocHomePage extends StatefulWidget {
  const DocHomePage({super.key});

  State<DocHomePage> createState() => _DocHPState();
}

class _DocHPState extends State<DocHomePage> {
  late String go;
  int nc_ther = 0;
  late bool pushpage = false;
  final myChannel = DbComms.supabase.channel('doc_home_ther_channel');

  @override
  void initState() {
    myChannel.on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
          event: 'UPDATE',
          schema: 'public',
          table: 'therapies',
          filter: 'doc_id_fk=eq.${Appuser.userID.toString()}'),
      (payload, [ref]) async {
        await Refresh();
        print(
            'rilevato update sulle terapie non compilate dalla DocHp, terapie in sospeso: $nc_ther');
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
        await Refresh();
        print(
            'rilevato insert sulle terapie non compilate dalla DocHp, terapie in sospeso: $nc_ther');
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
        await Refresh();
        print(
            'rilevato delete sulle terapie non compilate dalla DocHp, terapie in sospeso: $nc_ther');
        setState(() {});
      },
    ).subscribe();

    Refresh();
    super.initState();
  }

  Future<void> Refresh() async {
    nc_ther = 0;
    nc_ther = (await DbComms.supabase
            .from('therapies')
            .select('*, doctors(name, surname, med_spec)')
            .eq('compiled', false)
            .eq('doc_id_fk', Appuser.userID) as List<dynamic>)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Refresh(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            // Future hasn't finished yet, return a placeholder
            return AppRouter.waitingAnim(context);
          }
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    // Add an image widget to display an image
                                    Image.asset(
                                      'assets/images/doc_logo.png',
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
                                              text: TextSpan(
                                                  text:
                                                      "Ciao, dott. ${Appuser.surname}",
                                                  style: const TextStyle(
                                                      color: Colors.red,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 25,
                                                      fontFamily: 'Gotham'))),
                                          // Add some spacing between the title and the subtitle
                                          Container(height: 5),
                                          // Add a subtitle widget
                                          RichText(
                                              text: TextSpan(
                                                  text:
                                                      "Al momento hai $nc_ther terapie non compilate",
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.amber,
                                                      fontSize: 18,
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
                                Navigator.pushNamed(context, '/medlistpage');
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
                                                      text: "Lista dei farmaci",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color.fromARGB(
                                                              1000, 1, 82, 90),
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
                                Navigator.pushNamed(context, '/ther_man_page');
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
                                                      text: "Lista delle terapie",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color.fromARGB(
                                                              1000, 1, 82, 90),
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
                    ]))
              ]));
        });
  }
}
