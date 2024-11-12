import 'dart:ui';

import 'package:authentication/menu.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'RegistrationPage.dart';
import 'WelcomePage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final supabase = Supabase.instance.client;

  Future<void> _signIn() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Menu()),
        );
      } else {
        _showError('Invalid login credentials');
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Immagine di sfondo
          Positioned.fill(
            child: Image.asset('images/gym.jpg', fit: BoxFit.cover),
          ),
          // Sfocatura dell'immagine di sfondo
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withOpacity(
                  0,
                ), // Usato per rendere la sfocatura visibile
              ),
            ),
          ),
          // Posizioniamo l'icona in alto a sinistra
          Positioned(
            top: 40, // Distanza dal top
            left: 10, // Distanza dal lato sinistro
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.amber,
              ), // Icona per tornare
              onPressed: () {
                // Naviga alla schermata di Benvenuto
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Welcome(),
                  ), // Reindirizza alla schermata Welcome
                  (route) => false, // Rimuove tutte le schermate precedenti
                );
              },
            ),
          ),
          // Card per il login
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Colors.black45,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Titolo "LOGIN"
                      Text(
                        'LOGIN',
                        style: TextStyle(
                          color: Colors.amber,
                          fontStyle: FontStyle.italic,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),

                      // Campo Email
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.amber),
                          hintText:
                          "Inserisci l'email", // Se vuoi un testo di esempio
                          hintStyle: TextStyle(
                            color: Colors.amber, // Colore del testo di esempio
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.amber,
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              30,
                            ), // Cerchio, arrotondamento del bordo
                            borderSide: BorderSide(
                              color: Colors.amber,
                              width: 2,
                            ), // Colore e spessore del bordo quando il campo è attivo
                          ),
                        ),
                        style: TextStyle(
                          color: Colors.amber,
                        ), // Colore del testo inserito
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 12),

                      // Campo Password
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Colors.amber),
                          hintText:
                              'Inserisci la password', // Se vuoi un testo di esempio
                          hintStyle: TextStyle(
                            color: Colors.amber, // Colore del testo di esempio
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.amber, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30), // Cerchio, arrotondamento del bordo
                          borderSide: BorderSide(color: Colors.amber, width: 2), // Colore e spessore del bordo quando il campo è attivo
                        ),
                        ),
                        style: TextStyle(
                          color: Colors.amber,
                        ), // Colore del testo inserito
                        obscureText: true,
                      ),
                      SizedBox(height: 20),

                      // Bottone di conferma
                      ElevatedButton(
                        onPressed: _signIn,
                        child: Text('ACCEDI'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black45,
                          foregroundColor: Colors.amber,
                          minimumSize: Size(double.infinity, 50),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Testo di registrazione
                      GestureDetector(
                        onTap: () {
                          // Naviga alla schermata di registrazione
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegistrationPage(),
                            ),
                          );
                        },
                        child: Text(
                          "Non sei registrato? Registrati.",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.amber,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
