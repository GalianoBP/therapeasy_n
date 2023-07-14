import 'package:flutter/material.dart';
import 'package:therapeasy/access.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    await Future.delayed(Duration.zero);
    if (!mounted) {
      return;
    }

    final session = DbComms.supabase.auth.currentSession;
    if (session != null) {
      Navigator.of(context).pushReplacementNamed('/medHomePage');
    } else {
      Navigator.of(context).pushReplacementNamed('/loginPage');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}