import 'dart:ui';

import 'package:flutter/material.dart';

class Modifichedatiprofilo extends StatefulWidget {
  final String name;
  final String surname;
  final String email;
  final double height;
  final double weight;

  const Modifichedatiprofilo({
    Key? key,
    required this.name,
    required this.surname,
    required this.email,
    required this.height,
    required this.weight,
  }) : super(key: key);

  @override
  _ModifichedatiprofiloState createState() => _ModifichedatiprofiloState();
}

class _ModifichedatiprofiloState extends State<Modifichedatiprofilo> {
  late TextEditingController nameController;
  late TextEditingController surnameController;
  late TextEditingController emailController;
  late TextEditingController heightController;
  late TextEditingController weightController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name);
    surnameController = TextEditingController(text: widget.surname);
    emailController = TextEditingController(text: widget.email);
    heightController = TextEditingController(text: widget.height.toString());
    weightController = TextEditingController(text: widget.weight.toString());
  }

  @override
  void dispose() {
    nameController.dispose();
    surnameController.dispose();
    emailController.dispose();
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/fitness.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Filtro di sfocatura sopra l'immagine
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), // Applica la sfocatura
              child: Container(
                color: Colors.black.withOpacity(0), // Imposta trasparente sopra lo sfondo
              ),
            ),
          ),

          // Contenuto principale
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Card semi-trasparente
                Card(
                  color: Colors.amber.withOpacity(0.8), // Colore bianco semi-trasparente
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          style: TextStyle(fontStyle: FontStyle.italic,fontSize: 20),
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Nome',
                            hintText: 'Inserisci il tuo nome',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          style: TextStyle(fontStyle: FontStyle.italic,fontSize: 20),
                          controller: surnameController,
                          decoration: InputDecoration(
                            labelText: 'Cognome',
                            hintText: 'Inserisci il tuo cognome',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          style: TextStyle(fontStyle: FontStyle.italic,fontSize: 20),
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'Inserisci la tua email',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          style: TextStyle(fontStyle: FontStyle.italic,fontSize: 20),
                          controller: heightController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Altezza (cm)',
                            hintText: 'Inserisci la tua altezza',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          style: TextStyle(fontStyle: FontStyle.italic,fontSize: 20),
                          controller: weightController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Peso (kg)',
                            hintText: 'Inserisci il tuo peso',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20), // Spazio tra Card e bottone

                // Bottone Salva
                ElevatedButton(
                  onPressed: () {
                    final updatedData = {
                      'name': nameController.text,
                      'surname': surnameController.text,
                      'email': emailController.text,
                      'height': double.parse(heightController.text),
                      'weight': double.parse(weightController.text),
                    };
                    Navigator.pop(context, updatedData);
                  },
                  child: Text('Salva'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.amber,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
