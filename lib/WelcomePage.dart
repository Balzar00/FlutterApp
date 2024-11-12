import 'package:authentication/RegistrationPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'LoginPage.dart';
import 'menu.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://kflfrnzqvvjiqwfketyb.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtmbGZybnpxdnZqaXF3ZmtldHliIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzEzMzU4OTcsImV4cCI6MjA0NjkxMTg5N30.Nu3P5hqR6LQxvQgfWJfRY_9JjRr5sxnr6M-8NXJ29bk',
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
    );
  }
}
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateBasedOnState();
  }

  Future<void> _navigateBasedOnState() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
    final bool isAuthenticated = Supabase.instance.client.auth.currentUser != null;

    if (isFirstTime) {
      // Salva che la schermata di benvenuto è stata vista
      await prefs.setBool('isFirstTime', false);

      // Vai alla schermata Welcome
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Welcome()),
      );
    } else if (isAuthenticated) {
      // Vai direttamente al Menu se l'utente è già autenticato
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Menu()),
      );
    } else {
      // Vai alla schermata di Login se non autenticato
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()), // Indicatore di caricamento
    );
  }
}
class Welcome extends StatelessWidget {
  const Welcome({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'images/muro.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 20,
            left: 10,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                fixedSize: Size(180, 60),
                backgroundColor: Colors.black,
                textStyle: TextStyle(
                  color: Colors.amber,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Accedi'),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 10,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistrationPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                fixedSize: Size(180, 60),
                backgroundColor: Colors.black,
                textStyle: TextStyle(
                  color: Colors.amber,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Registrati'),
            ),
          ),
        ],
      ),
    );
  }
}