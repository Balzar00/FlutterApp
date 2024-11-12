import 'dart:collection';
import 'dart:io';
import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'LoginPage.dart';
import 'Modifichedatiprofilo.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Menu());
  }
}

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<Menu> {
  int _selectedIndex = 0;

  // Liste delle schermate per ogni sezione del menu
  final List<Widget> _screens = [
    HomeScreen(),
    CardScreen(),
    ProfiloScreen(),
    LogoutScreen(),
  ];

  // Funzione per aggiornare l'indice selezionato
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _screens[_selectedIndex], // Mostra la schermata selezionata
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.amber,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Scheda',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profilo'),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
        ],
      ),
    );
  }
}

class LogoutScreen extends StatelessWidget {
  const LogoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Immagine di sfondo con sfocatura
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/fitness.jpg"),
                  fit: BoxFit.cover, // L'immagine copre l'intera schermata
                ),
              ),
            ),
          ),
          // Applichiamo il filtro di sfocatura
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              // Impostiamo la sfocatura
              child: Container(
                color: Colors.black.withOpacity(
                    0), // Per evitare che il filtro copra completamente il contenuto
              ),
            ),
          ),
          // Il contenuto sopra il filtro sfocato (il bottone)
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                // Mostra il dialog di conferma
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Conferma Uscita'),
                      content: Text('Sei sicuro di voler uscire?'),
                      actions: <Widget>[
                        // Bottone "No"
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Chiude il dialog
                          },
                          child: Text('No'),
                        ),
                        // Bottone "Sì"
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Chiude il dialog
                            // Esegui il logout effettivo
                            _logout(context);
                          },
                          child: Text('Sì'),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: Icon(
                Icons.exit_to_app,
                color: Colors.amber,
              ), // Icona per il logout
              label: Text(
                'Logout',
                style: TextStyle(color: Colors.amber),
              ), // Etichetta
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.amber,
                backgroundColor: Colors.black, // Colore di sfondo del bottone
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Bordo arrotondato
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    // Step 1: Esegui il logout da Supabase
    await Supabase.instance.client.auth.signOut();

    // Step 2: Cancella eventuali dati di autenticazione locali (non obbligatorio, ma consigliato)
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(
        'isFirstTime'); // Facoltativo: dipende se vuoi mostrare di nuovo la schermata Welcome

    // Step 3: Reindirizza l'utente alla schermata di Login
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false, // Rimuovi tutte le schermate precedenti
    );
  }
}

class ProfiloScreen extends StatefulWidget {
  const ProfiloScreen({super.key});

  @override
  _ProfiloScreenState createState() => _ProfiloScreenState();
}

class _ProfiloScreenState extends State<ProfiloScreen> {
  String name = '';
  String surname = '';
  String email = '';
  double height = 0.0;
  double weight = 0.0;
  String? profileImagePath; // Percorso dell'immagine del profilo
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Carica i dati memorizzati e l'immagine
  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? '';
      surname = prefs.getString('surname') ?? '';
      email = prefs.getString('email') ?? '';
      height = prefs.getDouble('height') ?? 0.0;
      weight = prefs.getDouble('weight') ?? 0.0;
      profileImagePath = prefs.getString(
        'profileImagePath',
      ); // Carica il percorso dell'immagine
    });
  }

  // Salva i dati e l'immagine
  _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('name', name);
    prefs.setString('surname', surname);
    prefs.setString('email', email);
    prefs.setDouble('height', height);
    prefs.setDouble('weight', weight);
    if (profileImagePath != null) {
      prefs.setString(
        'profileImagePath',
        profileImagePath!,
      ); // Salva il percorso dell'immagine
    }
  }

  // Funzione per scegliere un'immagine dalla galleria
  _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        profileImagePath =
            pickedFile.path; // Imposta il percorso dell'immagine selezionata
      });
      _saveData(); // Salva l'immagine selezionata
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Immagine di sfondo
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
          // Contenuto sopra la sfocatura
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Immagine del profilo cliccabile
                  GestureDetector(
                    onTap: _pickImage, // Cliccando sull'immagine, apri la galleria
                    child: CircleAvatar(
                      radius: 100, // Aumenta il raggio per ingrandire l'immagine
                      backgroundImage: profileImagePath != null
                          ? FileImage(File(profileImagePath!)) // Usa il percorso dell'immagine
                          : AssetImage("images/immagine_di_default.jpg")
                      as ImageProvider, // Immagine di default se non c'è una selezione
                    ),
                  ),
                  SizedBox(height: 20),
                  // La Card con i dati
                  Card(
                    color: Colors.amber.withOpacity(0.8),
                    elevation: 10,
                    margin: EdgeInsets.all(20),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Nome: $name', style: TextStyle(fontSize: 18)),
                          SizedBox(height: 10),
                          Text('Cognome: $surname', style: TextStyle(fontSize: 18)),
                          SizedBox(height: 10),
                          Text('Email: $email', style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic)),
                          SizedBox(height: 10),
                          Text('Altezza: ${height.toString()} cm', style: TextStyle(fontSize: 18)),
                          SizedBox(height: 10),
                          Text('Peso: ${weight.toString()} kg', style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final updatedData = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Modifichedatiprofilo(
                            name: name,
                            surname: surname,
                            email: email,
                            height: height,
                            weight: weight,
                          ),
                        ),
                      );

                      if (updatedData != null) {
                        setState(() {
                          name = updatedData['name'];
                          surname = updatedData['surname'];
                          email = updatedData['email'];
                          height = updatedData['height'];
                          weight = updatedData['weight'];
                        });
                        _saveData();
                      }
                    },
                    child: Text('Modifica Dati'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.amber,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CardScreen extends StatefulWidget {
  const CardScreen({Key? key}) : super(key: key);

  @override
  _CardScreenState createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  // Variabili per tenere traccia del livello e giorno selezionato
  String? selectedLevel;
  int? selectedDay;

  // Dati degli esercizi con serie
  final Map<String, Map<int, List<Map<String, String>>>> exerciseData = {
    'Principiante': {
      1: [
        {
          'Esercizio': 'Riscaldamento',
          'Serie': '-',
          'Recupero': '-',
          'Descrizione': 'ti riscaldi',
          'YouTube': '',
        },
        {
          'Esercizio': 'Leg press',
          'Serie': '3x10',
          'Recupero': '1min',
          'Descrizione':
          'Appoggiare i piedi sulla pedana alla larghezza delle anche, assicurandoti che i talloni siano piatti.Il sedere dovrebbe essere piatto contro il sedile piuttosto che sollevato. Le gambe dovrebbero formare un angolo di circa 90 gradi alle ginocchia.Le ginocchia dovrebbero essere in linea con i piedi e non essere né piegate né verso l’interno né verso l’esterno."Mentre spingete, assicuratevi di mantenere tale allineamento.',
          'YouTube': 'https://www.youtube.com/watch?v=uEsZWWiYNAQ',
        },
        {
          'Esercizio': 'Leg extension',
          'Serie': '3x10',
          'Recupero': '1min',
          'Descrizione':
          'Posiziona il cuscinetto anteriore sulle tibie vicino alla caviglia e non a contatto coi piedi.Le ginocchia devono posizionarsi al limite della seduta, in modo che il ginocchio non sporga eccessivamente dalla stessa ma non sia nemmeno troppo indietro.I gradi del movimento vanno decisi in base anche ad eventuali problematiche che possiedi. Generalmente se le tue ginocchia stanno bene, potresti partire in un range compreso tra 100-120° di flessione di ginocchia.Il movimento finisce quando le ginocchia sono in completa estensione.I movimenti devono essere sempre controllati in ogni singola fase dell’esercizio.',
          'YouTube': 'https://www.youtube.com/watch?v=4ZDm5EbiFI8',
        },
        {
          'Esercizio': 'Affondi',
          'Serie': '3x10',
          'Recupero': '1min',
          'Descrizione':
          'Gli affondi si eseguono in una posizione di partenza eretta,con i piedi ben saldi a terra e le mani sui fianchi oppure lungo i fianchi.Dopo aver assunto la posizione corretta, si esegue un lungo passo o avanti, o indietro o laterale e si flette un ginocchio, mantenendo la parte superiore del corpo ben dritta.',
          'YouTube': 'https://www.youtube.com/watch?v=Cbqjuj3N7Zo',
        },
        {
          'Esercizio': 'Panca piana',
          'Serie': '4x10',
          'Recupero': '1min',
          'Descrizione':
          'Ci si stende su una panca, si afferra il bilanciere dagli appoggi, si stendono le braccia,si porta il bilanciere al petto per spingerlo via fino a tornare nella posizione iniziale',
          'YouTube': 'https://www.youtube.com/watch?v=abkLsC0HEjg',
        },
        {
          'Esercizio': 'Panca 30° croci',
          'Serie': '3x10',
          'Recupero': '1min',
          'Descrizione':
          "L'esecutore si posiziona su panca piana inclinata a 30# impugnando i manubri solitamente con una presa neutra con i piedi fissati al suolo.Durante il movimento, i gomiti sono leggermente flessi e bloccati, ciò significa che non devono variare la loro lunghezza ed essere mobilizzati durante l'esecuzione.Si alzano i manubri in vericale e facciamo un movimento ad aprire e poi chiudere, cercado di controllarli entrambi.",
          'YouTube': 'https://www.youtube.com/watch?v=AY9pI9ANxs8',
        },
        {
          'Esercizio': 'Chest  press',
          'Serie': '3x10',
          'Recupero': '1min',
          'Descrizione':
          'Per eseguirla bene ecco delle linee guida: non devi muoverti con l’intero corpo, ma solo distendere le braccia,devi mantenere la schiena poggiata sullo schienale,devi tenere addotte e depresse le scapole,non devi spingere in avanti le scapole,devi completare il movimento di distensione delle braccia,utilizza pieno controllo motorio per l’intera esecuzione,la testa non deve venire in avanti, ma rimanere appoggiata allo schienale,i gomiti NON vanno tenuti ALTI, come si sente spesso dire.',
          'YouTube': 'https://www.youtube.com/watch?v=sqNwDkUU_Ps',
        },
        {
          'Esercizio': 'Bicipiti bilanciere',
          'Serie': '3x10',
          'Recupero': '1min',
          'Descrizione':
          "Se eseguita sulla panca scott bisogna prestare attenzione alla posizione delle braccia che devono essere parallele tra loro e al movimento del braccio che non deve un angolo piatto (180°) ma uno acuto (circa 100/120°).Mentre se eseguiti da in piedi bisogna prestare attenzione a bloccare il motito al busto e non muoverlo durante l'esecuzione.",
          'YouTube': 'https://www.youtube.com/watch?v=7ECvCFpsOik',
        },
        {
          'Esercizio': 'Bicipiti curl manubri',
          'Serie': '3x10',
          'Recupero': '1min',
          'Descrizione':
          "Stessa esecuzione dei curl col bilanciere unica differenza è che non limiteremo il movimento quindi partiamo con il braccio a riposo e porteremo i manubri fino all'altezza delle spalle, possiamo aggiungere una rotazione alla partenza per attivare anche gli avambracci.",
          'YouTube': 'https://www.youtube.com/watch?v=ykJmrZ5v0Oo',
        },
        {
          'Esercizio': 'Crunch',
          'Serie': '3x10',
          'Recupero': '1min',
          'Descrizione':
          'Il crunch viene eseguito stendendosi in posizione supina e sollevando il busto in direzione del bacino che invece deve restare in saldo appoggio.',
          'YouTube': 'https://www.youtube.com/watch?v=MKmrqcoCZ-M',
        },
      ],
      2: [
        {
          'Esercizio': 'Riscaldamento',
          'Serie': '-',
          'Recupero': '-',
          'Descrizione': 'ti riscaldi',
          'YouTube': '',
        },
        {
          'Esercizio': 'Stacco sumo',
          'Serie': '4x10',
          'Recupero': '1min',
          'Descrizione':
          "Posizione: piedi più larghi delle spalle, punte dei piedi verso l'esterno.Afferra il bilanciere con le mani tra le gambe.Mantieni la schiena dritta e solleva il bilanciere estendendo le gambe e spingendo i fianchi in avanti.Ritorna alla posizione iniziale piegando ginocchia e anche.",
          'YouTube': 'https://www.youtube.com/watch?v=L2P_PqpbwSQ',
        },
        {
          'Esercizio': 'Stacco Gambe tese manubri',
          'Serie': '3x15',
          'Recupero': '30s',
          'Descrizione':
          'In piedi, con i manubri davanti alle cosce e piedi a larghezza spalle.Tieni le gambe quasi dritte, flettendo leggermente le ginocchia.Scendi con i manubri lungo le gambe, mantenendo la schiena dritta, fino a sentire lo stretching nei femorali.Risali contraendo i glutei e i femorali.',
          'YouTube': 'https://www.youtube.com/watch?v=89heg4k6Vps',
        },
        {
          'Esercizio': 'Leg curl',
          'Serie': '3x15',
          'Recupero': '1min',
          'Descrizione':
          'Sdraiato o in piedi sulla macchina apposita, aggancia i piedi ai cuscinetti.Fletti le ginocchia, portando i talloni verso i glutei.Rilascia lentamente alla posizione di partenza, controllando il movimento.',
          'YouTube': 'https://www.youtube.com/watch?v=89heg4k6Vps',
        },
        {
          'Esercizio': 'Lat machine avanti',
          'Serie': '3x12',
          'Recupero': '1min',
          'Descrizione':
          "Siediti sulla lat machine con le gambe bloccate sotto i cuscinetti.Afferra la barra con presa larga.Tira la barra verso il petto, contraendo i dorsali, mantenendo il busto leggermente inclinato all'indietro.Rilascia la barra lentamente fino a tornare in alto.",
          'YouTube': 'https://www.youtube.com/watch?v=89heg4k6Vps',
        },
        {
          'Esercizio': 'Pulley',
          'Serie': '3x12',
          'Recupero': '1min',
          'Descrizione':
          'Siediti di fronte alla macchina con i piedi sulle pedane.Afferra la barra o maniglia e tira verso di te, mantenendo il busto dritto.Tira i gomiti indietro, avvicinando le scapole.Rilascia lentamente alla posizione di partenza.',
          'YouTube': 'https://www.youtube.com/watch?v=89heg4k6Vps',
        },
        {
          'Esercizio': 'Low rowing machine',
          'Serie': '3x10',
          'Recupero': '1min',
          'Descrizione':
          'Simile al pulley, ma utilizzando una macchina con resistenza.Afferra le maniglie e tira verso il busto, concentrandoti sulla contrazione dei dorsali e avvicinando le scapole.Rilascia lentamente fino a tornare alla posizione iniziale.',
          'YouTube': 'https://www.youtube.com/watch?v=89heg4k6Vps',
        },
        {
          'Esercizio': 'French press bilanciere',
          'Serie': '3x10',
          'Recupero': '1min',
          'Descrizione':
          'Sdraiati su una panca piana con il bilanciere tenuto sopra il petto.Fletti i gomiti portando il bilanciere verso la fronte, mantenendo i gomiti fermi.Estendi le braccia tornando alla posizione iniziale, concentrandoti sui tricipiti.',
          'YouTube': 'https://www.youtube.com/watch?v=89heg4k6Vps',
        },
        {
          'Esercizio': 'Tricipiti ai cavi',
          'Serie': '3x12',
          'Recupero': '1min',
          'Descrizione':
          'In piedi di fronte alla macchina con cavi.Afferra la barra con presa stretta e spingi verso il basso, estendendo completamente i gomiti.Rilascia lentamente fino a tornare alla posizione iniziale, tenendo i gomiti fermi.',
          'YouTube': 'https://www.youtube.com/watch?v=89heg4k6Vps',
        },
        {
          'Esercizio': 'Russian twist',
          'Serie': '3x20',
          'Recupero': '1min',
          'Descrizione':
          "Siediti a terra con le ginocchia piegate e i piedi sollevati.Afferra un peso (palla medica o manubrio) e ruota il busto da un lato all'altro.Mantieni il core contratto e la schiena dritta mentre esegui la rotazione.",
          'YouTube': 'https://www.youtube.com/watch?v=89heg4k6Vps',
        },
      ],
      3: [
        {
          'Esercizio': 'Riscaldamento',
          'Serie': '-',
          'Recupero': '-',
          'Descrizione': 'ti riscaldi',
          'YouTube': '',
        },
        {
          'Esercizio': 'Leg press',
          'Serie': '3x10',
          'Recupero': '1min',
          'Descrizione':
          'Appoggiare i piedi sulla pedana alla larghezza delle anche, assicurandoti che i talloni siano piatti.Il sedere dovrebbe essere piatto contro il sedile piuttosto che sollevato. Le gambe dovrebbero formare un angolo di circa 90 gradi alle ginocchia.Le ginocchia dovrebbero essere in linea con i piedi e non essere né piegate né verso l’interno né verso l’esterno."Mentre spingete, assicuratevi di mantenere tale allineamento.',
          'YouTube': 'https://www.youtube.com/watch?v=uEsZWWiYNAQ',
        },
        {
          'Esercizio': 'Squat',
          'Serie': '3x10',
          'Recupero': '1min',
          'Descrizione':
          "Posizione: piedi a larghezza delle spalle, punte leggermente verso l'esterno.Fletti le ginocchia e scendi con i fianchi indietro, mantenendo la schiena dritta e il petto sollevato.Scendi fino a quando le cosce sono parallele al pavimento o oltre, senza sollevare i talloni.Risali spingendo sui talloni e contrai i glutei alla fine del movimento.",
          'YouTube': 'https://www.youtube.com/watch?v=N2nKCnguWFo',
        },
        {
          'Esercizio': 'Leg extension ',
          'Serie': '3x15',
          'Recupero': '1min',
          'Descrizione':
          'Posiziona il cuscinetto anteriore sulle tibie vicino alla caviglia e non a contatto coi piedi.Le ginocchia devono posizionarsi al limite della seduta, in modo che il ginocchio non sporga eccessivamente dalla stessa ma non sia nemmeno troppo indietro.I gradi del movimento vanno decisi in base anche ad eventuali problematiche che possiedi. Generalmente se le tue ginocchia stanno bene, potresti partire in un range compreso tra 100-120° di flessione di ginocchia.Il movimento finisce quando le ginocchia sono in completa estensione.I movimenti devono essere sempre controllati in ogni singola fase dell’esercizio.',
          'YouTube': 'https://www.youtube.com/watch?v=4ZDm5EbiFI8',
        },
        {
          'Esercizio': 'Affondi',
          'Serie': '3x20',
          'Recupero': '1min',
          'Descrizione':
          'Gli affondi si eseguono in una posizione di partenza eretta,con i piedi ben saldi a terra e le mani sui fianchi oppure lungo i fianchi.Dopo aver assunto la posizione corretta, si esegue un lungo passo o avanti, o indietro o laterale e si flette un ginocchio, mantenendo la parte superiore del corpo ben dritta.',
          'YouTube': 'https://www.youtube.com/watch?v=Cbqjuj3N7Zo',
        },
        {
          'Esercizio': 'Shoulder press',
          'Serie': '3x12',
          'Recupero': '1min',
          'Descrizione':
          "In piedi o seduto, tieni i manubri o il bilanciere all'altezza delle spalle.Spingi verso l'alto estendendo le braccia sopra la testa, mantenendo i gomiti leggermente in avanti.Abbassa lentamente il peso fino alla posizione iniziale senza lasciare cadere le braccia troppo indietro.",
          'YouTube': 'https://www.youtube.com/watch?v=UtQiS_rNg7M',
        },
        {
          'Esercizio': 'Alzate laterali',
          'Serie': '3x10',
          'Recupero': '1min',
          'Descrizione':
          "In piedi, con un manubrio in ciascuna mano e le braccia lungo i fianchi.Solleva le braccia lateralmente fino a portarle all'altezza delle spalle, mantenendo un leggero piegamento dei gomiti.Rilascia lentamente fino a tornare alla posizione iniziale, mantenendo il controllo.",
          'YouTube': 'https://www.youtube.com/watch?v=5Dyh1z6E6rM',
        },
        {
          'Esercizio': 'Alzate singole inclinate',
          'Serie': '3x10',
          'Recupero': '1min',
          'Descrizione':
          "Posizione: inclinati in avanti con il busto quasi parallelo al pavimento, un braccio appoggiato su una panca per supporto.Con l'altro braccio, solleva un manubrio lateralmente, concentrandoti sul deltoide posteriore.Mantieni il gomito leggermente flesso e controlla il movimento sia in salita che in discesa.",
          'YouTube': 'https://www.youtube.com/watch?v=nwBSKOpMOdo',
        },
        {
          'Esercizio': 'Crunch inverso',
          'Serie': '3x20',
          'Recupero': '1min',
          'Descrizione':
          "Sdraiato sulla schiena, con le gambe piegate e i piedi sollevati da terra.Porta le ginocchia verso il petto, sollevando il bacino dal pavimento e contrai gli addominali.Rilascia lentamente abbassando le gambe senza far toccare i piedi a terra, mantenendo il controllo del movimento.",
          'YouTube': 'https://www.youtube.com/watch?v=2UMZfWtY4mY',
        },
        {
          'Esercizio': 'Sit ups',
          'Serie': '3x20',
          'Recupero': '1min',
          'Descrizione':
          "Sdraiato sulla schiena con le ginocchia piegate e i piedi piatti a terra.Metti le mani dietro la testa o incrocia le braccia sul petto.Solleva il busto fino a sederti, contrarre gli addominali, poi torna lentamente alla posizione di partenza.",
          'YouTube': "https://www.youtube.com/watch?v=jDwoBqPH0jk",
        },
      ],
    },
    'Medio': {
      1: [
        {
          'Esercizio': 'Riscaldamento',
          'Serie': '-',
          'Recupero': '-',
          'Descrizione': 'ti riscaldi',
          'YouTube': '',
        },
        {
          'Esercizio': 'Squat',
          'Serie': '4x10',
          'Recupero': '1min',
          'Descrizione':
          "Posizione: piedi a larghezza delle spalle, punte leggermente verso l'esterno.Fletti le ginocchia e scendi con i fianchi indietro, mantenendo la schiena dritta e il petto sollevato.Scendi fino a quando le cosce sono parallele al pavimento o oltre, senza sollevare i talloni.Risali spingendo sui talloni e contrai i glutei alla fine del movimento.",
          'YouTube': 'https://www.youtube.com/watch?v=N2nKCnguWFo',
        },
        {
          'Esercizio': 'Leg extension ',
          'Serie': '4x10',
          'Recupero': '1min',
          'Descrizione':
          'Posiziona il cuscinetto anteriore sulle tibie vicino alla caviglia e non a contatto coi piedi.Le ginocchia devono posizionarsi al limite della seduta, in modo che il ginocchio non sporga eccessivamente dalla stessa ma non sia nemmeno troppo indietro.I gradi del movimento vanno decisi in base anche ad eventuali problematiche che possiedi. Generalmente se le tue ginocchia stanno bene, potresti partire in un range compreso tra 100-120° di flessione di ginocchia.Il movimento finisce quando le ginocchia sono in completa estensione.I movimenti devono essere sempre controllati in ogni singola fase dell’esercizio.',
          'YouTube': 'https://www.youtube.com/watch?v=4ZDm5EbiFI8',
        },
        {
          'Esercizio': 'Leg curl',
          'Serie': '4x10',
          'Recupero': '1min',
          'Descrizione':
          'Sdraiato o in piedi sulla macchina apposita, aggancia i piedi ai cuscinetti.Fletti le ginocchia, portando i talloni verso i glutei.Rilascia lentamente alla posizione di partenza, controllando il movimento.',
          'YouTube': 'https://www.youtube.com/watch?v=89heg4k6Vps',
        },
        {
          'Esercizio': 'Panca piana',
          'Serie': '4x10',
          'Recupero': '1min',
          'Descrizione':
          'Ci si stende su una panca, si afferra il bilanciere dagli appoggi, si stendono le braccia,si porta il bilanciere al petto per spingerlo via fino a tornare nella posizione iniziale',
          'YouTube': 'https://www.youtube.com/watch?v=abkLsC0HEjg',
        },
        {
          'Esercizio': 'Panca 30° croci',
          'Serie': '4x10',
          'Recupero': '1min',
          'Descrizione':
          "L'esecutore si posiziona su panca piana inclinata a 30# impugnando i manubri solitamente con una presa neutra con i piedi fissati al suolo.Durante il movimento, i gomiti sono leggermente flessi e bloccati, ciò significa che non devono variare la loro lunghezza ed essere mobilizzati durante l'esecuzione.Si alzano i manubri in vericale e facciamo un movimento ad aprire e poi chiudere, cercado di controllarli entrambi.",
          'YouTube': 'https://www.youtube.com/watch?v=AY9pI9ANxs8',
        },
        {
          'Esercizio': 'Chest  press',
          'Serie': '4x10',
          'Recupero': '1min',
          'Descrizione':
          'Per eseguirla bene ecco delle linee guida: non devi muoverti con l’intero corpo, ma solo distendere le braccia,devi mantenere la schiena poggiata sullo schienale,devi tenere addotte e depresse le scapole,non devi spingere in avanti le scapole,devi completare il movimento di distensione delle braccia,utilizza pieno controllo motorio per l’intera esecuzione,la testa non deve venire in avanti, ma rimanere appoggiata allo schienale,i gomiti NON vanno tenuti ALTI, come si sente spesso dire.',
          'YouTube': 'https://www.youtube.com/watch?v=sqNwDkUU_Ps',
        },
        {
          'Esercizio': 'Bicipiti bilanciere',
          'Serie': '3x10',
          'Recupero': '1min',
          'Descrizione':
          "Se eseguita sulla panca scott bisogna prestare attenzione alla posizione delle braccia che devono essere parallele tra loro e al movimento del braccio che non deve un angolo piatto (180°) ma uno acuto (circa 100/120°).Mentre se eseguiti da in piedi bisogna prestare attenzione a bloccare il motito al busto e non muoverlo durante l'esecuzione.",
          'YouTube': 'https://www.youtube.com/watch?v=7ECvCFpsOik',
        },
        {
          'Esercizio': 'Bicipiti curl manubri',
          'Serie': '3x10',
          'Recupero': '1min',
          'Descrizione':
          "Stessa esecuzione dei curl col bilanciere unica differenza è che non limiteremo il movimento quindi partiamo con il braccio a riposo e porteremo i manubri fino all'altezza delle spalle, possiamo aggiungere una rotazione alla partenza per attivare anche gli avambracci.",
          'YouTube': 'https://www.youtube.com/watch?v=ykJmrZ5v0Oo',
        },
        {
          'Esercizio': 'Crunch',
          'Serie': '3x20',
          'Recupero': '1min',
          'Descrizione':
          'Il crunch viene eseguito stendendosi in posizione supina e sollevando il busto in direzione del bacino che invece deve restare in saldo appoggio.',
          'YouTube': 'https://www.youtube.com/watch?v=MKmrqcoCZ-M',
        },
      ],
      2: [
        {'Esercizio': 'Riscaldamento', 'Serie': '-', 'Recupero': '-'},
        {
          'Esercizio': 'Lat machine avanti',
          'Serie': '4x10',
          'Recupero': '1min',
          'Descrizione': 'ti riscaldi',
          'YouTube': '',
        },
        {
          'Esercizio': 'Sit-up',
          'Serie': '4x15',
          'Recupero': '40s',
          'Descrizione':
          "Posizione: piedi a larghezza delle spalle, punte leggermente verso l'esterno.Fletti le ginocchia e scendi con i fianchi indietro, mantenendo la schiena dritta e il petto sollevato.Scendi fino a quando le cosce sono parallele al pavimento o oltre, senza sollevare i talloni.Risali spingendo sui talloni e contrai i glutei alla fine del movimento.",
          'YouTube': 'https://www.youtube.com/watch?v=N2nKCnguWFo',
        },
        {
          'Esercizio': 'Pulley',
          'Serie': '3x12',
          'Recupero': '1min',
          'Descrizione':
          'Siediti di fronte alla macchina con i piedi sulle pedane.Afferra la barra o maniglia e tira verso di te, mantenendo il busto dritto.Tira i gomiti indietro, avvicinando le scapole.Rilascia lentamente alla posizione di partenza.',
          'YouTube': 'https://www.youtube.com/watch?v=89heg4k6Vps',
        },
        {
          'Esercizio': 'Tricipiti ai cavi',
          'Serie': '4x10',
          'Recupero': '1min',
          'Descrizione':
          'In piedi di fronte alla macchina con cavi.Afferra la barra con presa stretta e spingi verso il basso, estendendo completamente i gomiti.Rilascia lentamente fino a tornare alla posizione iniziale, tenendo i gomiti fermi.',
          'YouTube': 'https://www.youtube.com/watch?v=89heg4k6Vps',
        },
        {
          'Esercizio': 'French press bilanciere',
          'Serie': '3x10',
          'Recupero': '1min',
          'Descrizione':
          'Sdraiati su una panca piana con il bilanciere tenuto sopra il petto.Fletti i gomiti portando il bilanciere verso la fronte, mantenendo i gomiti fermi.Estendi le braccia tornando alla posizione iniziale, concentrandoti sui tricipiti.',
          'YouTube': 'https://www.youtube.com/watch?v=89heg4k6Vps',
        },
        {
          'Esercizio': 'Alzate laterali',
          'Serie': '4x10',
          'Recupero': '1min',
          'Descrizione':
          "In piedi, con un manubrio in ciascuna mano e le braccia lungo i fianchi.Solleva le braccia lateralmente fino a portarle all'altezza delle spalle, mantenendo un leggero piegamento dei gomiti.Rilascia lentamente fino a tornare alla posizione iniziale, mantenendo il controllo.",
          'YouTube': 'https://www.youtube.com/watch?v=5Dyh1z6E6rM',
        },
        {
          'Esercizio': 'Alzate singole inclinate',
          'Serie': '3x10',
          'Recupero': '1min',
          'Descrizione':
          "Posizione: inclinati in avanti con il busto quasi parallelo al pavimento, un braccio appoggiato su una panca per supporto.Con l'altro braccio, solleva un manubrio lateralmente, concentrandoti sul deltoide posteriore.Mantieni il gomito leggermente flesso e controlla il movimento sia in salita che in discesa.",
          'YouTube': 'https://www.youtube.com/watch?v=nwBSKOpMOdo',
        },
        {
          'Esercizio': 'Sit ups',
          'Serie': '3x20',
          'Recupero': '1min',
          'Descrizione':
          "Sdraiato sulla schiena con le ginocchia piegate e i piedi piatti a terra.Metti le mani dietro la testa o incrocia le braccia sul petto.Solleva il busto fino a sederti, contrarre gli addominali, poi torna lentamente alla posizione di partenza.",
          'YouTube': "https://www.youtube.com/watch?v=jDwoBqPH0jk",
        },
        {
          'Esercizio': 'Russian twist',
          'Serie': '3x20',
          'Recupero': '1min',
          'Descrizione':
          "Siediti a terra con le ginocchia piegate e i piedi sollevati.Afferra un peso (palla medica o manubrio) e ruota il busto da un lato all'altro.Mantieni il core contratto e la schiena dritta mentre esegui la rotazione.",
          'YouTube': 'https://www.youtube.com/watch?v=89heg4k6Vps',
        },
      ],
      3: [
        {
          'Esercizio': 'Riscaldamento',
          'Serie': '-',
          'Recupero': '-',
          'Descrizione': 'ti riscaldi',
          'YouTube': '',
        },
        {
          'Esercizio': 'Chest  press',
          'Serie': '4x10',
          'Recupero': '1min',
          'Descrizione':
          'Per eseguirla bene ecco delle linee guida: non devi muoverti con l’intero corpo, ma solo distendere le braccia,devi mantenere la schiena poggiata sullo schienale,devi tenere addotte e depresse le scapole,non devi spingere in avanti le scapole,devi completare il movimento di distensione delle braccia,utilizza pieno controllo motorio per l’intera esecuzione,la testa non deve venire in avanti, ma rimanere appoggiata allo schienale,i gomiti NON vanno tenuti ALTI, come si sente spesso dire.',
          'YouTube': 'https://www.youtube.com/watch?v=sqNwDkUU_Ps',
        },
        {
          'Esercizio': 'Panca piana',
          'Serie': '4x10',
          'Recupero': '1min',
          'Descrizione':
          'Ci si stende su una panca, si afferra il bilanciere dagli appoggi, si stendono le braccia,si porta il bilanciere al petto per spingerlo via fino a tornare nella posizione iniziale',
          'YouTube': 'https://www.youtube.com/watch?v=abkLsC0HEjg',
        },
        {
          'Esercizio': 'Spinte 30°',
          'Serie': '4x10',
          'Recupero': '1min',
          'Descrizione':
          "Posizionati su una panca inclinata a 30 gradi, con manubri o bilanciere in mano.Afferra i manubri (o il bilanciere) con le mani all'altezza del petto, i gomiti piegati e leggermente verso il basso.Spingi i pesi verso l'alto estendendo le braccia, mantenendo i gomiti leggermente piegati alla fine del movimento.Torna alla posizione iniziale lentamente, controllando la discesa e mantenendo una buona attivazione dei pettorali superiori.",
          'YouTube': 'https://www.youtube.com/watch?v=2mvWe_8jhMk',
        },
        {
          'Esercizio': 'Alzate laterali',
          'Serie': '4x10',
          'Recupero': '1min',
          'Descrizione':
          "In piedi, con un manubrio in ciascuna mano e le braccia lungo i fianchi.Solleva le braccia lateralmente fino a portarle all'altezza delle spalle, mantenendo un leggero piegamento dei gomiti.Rilascia lentamente fino a tornare alla posizione iniziale, mantenendo il controllo.",
          'YouTube': 'https://www.youtube.com/watch?v=5Dyh1z6E6rM',
        },
        {
          'Esercizio': 'Shoulder press',
          'Serie': '3x15',
          'Recupero': '1min',
          'Descrizione':
          "In piedi o seduto, tieni i manubri o il bilanciere all'altezza delle spalle.Spingi verso l'alto estendendo le braccia sopra la testa, mantenendo i gomiti leggermente in avanti.Abbassa lentamente il peso fino alla posizione iniziale senza lasciare cadere le braccia troppo indietro.",
          'YouTube': 'https://www.youtube.com/watch?v=UtQiS_rNg7M',
        },
        {
          'Esercizio': 'Bicipiti curl manubri',
          'Serie': '4x10',
          'Recupero': '1min',
          'Descrizione':
          "Stessa esecuzione dei curl col bilanciere unica differenza è che non limiteremo il movimento quindi partiamo con il braccio a riposo e porteremo i manubri fino all'altezza delle spalle, possiamo aggiungere una rotazione alla partenza per attivare anche gli avambracci.",
          'YouTube': 'https://www.youtube.com/watch?v=ykJmrZ5v0Oo',
        },
        {
          'Esercizio': 'Bicipiti bilanciere',
          'Serie': '3x15',
          'Recupero': '1min',
          'Descrizione':
          "Se eseguita sulla panca scott bisogna prestare attenzione alla posizione delle braccia che devono essere parallele tra loro e al movimento del braccio che non deve un angolo piatto (180°) ma uno acuto (circa 100/120°).Mentre se eseguiti da in piedi bisogna prestare attenzione a bloccare il motito al busto e non muoverlo durante l'esecuzione.",
          'YouTube': 'https://www.youtube.com/watch?v=7ECvCFpsOik',
        },
        {
          'Esercizio': 'Tricipiti ai cavi',
          'Serie': '4x10',
          'Recupero': '1min',
          'Descrizione':
          'In piedi di fronte alla macchina con cavi.Afferra la barra con presa stretta e spingi verso il basso, estendendo completamente i gomiti.Rilascia lentamente fino a tornare alla posizione iniziale, tenendo i gomiti fermi.',
          'YouTube': 'https://www.youtube.com/watch?v=89heg4k6Vps',
        },
        {
          'Esercizio': 'Dip',
          'Serie': '4x10',
          'Recupero': '1min',
          'Descrizione':
          "Posizionati su parallele o su una stazione per dip, con le braccia estese e il corpo sospeso.Fletti i gomiti abbassando lentamente il corpo fino a che le braccia non formano un angolo di 90 gradi o meno.Spingi verso l'alto estendendo i gomiti fino a tornare alla posizione di partenzaMantieni il busto leggermente inclinato in avanti per coinvolgere maggiormente i pettorali, o dritto per concentrarti sui tricipiti.",
          'YouTube': 'https://www.youtube.com/watch?v=TrJVszDm7ik',
        },
      ],
    },
    'Avanzato': {
      1: [
        {
          'Esercizio': 'Riscaldamento',
          'Serie': '-',
          'Recupero': '-',
          'Descrizione': 'ti riscaldi',
          'YouTube': '',
        },
        {
          'Esercizio': 'Squat',
          'Serie': '4x10',
          'Recupero': '2min',
          'Descrizione':
          "Posizione: piedi a larghezza delle spalle, punte leggermente verso l'esterno.Fletti le ginocchia e scendi con i fianchi indietro, mantenendo la schiena dritta e il petto sollevato.Scendi fino a quando le cosce sono parallele al pavimento o oltre, senza sollevare i talloni.Risali spingendo sui talloni e contrai i glutei alla fine del movimento.",
          'YouTube': 'https://www.youtube.com/watch?v=N2nKCnguWFo',
        },
        {
          'Esercizio': 'Leg press',
          'Serie': '4x10',
          'Recupero': '2min',
          'Descrizione':
          'Appoggiare i piedi sulla pedana alla larghezza delle anche, assicurandoti che i talloni siano piatti.Il sedere dovrebbe essere piatto contro il sedile piuttosto che sollevato. Le gambe dovrebbero formare un angolo di circa 90 gradi alle ginocchia.Le ginocchia dovrebbero essere in linea con i piedi e non essere né piegate né verso l’interno né verso l’esterno."Mentre spingete, assicuratevi di mantenere tale allineamento.',
          'YouTube': 'https://www.youtube.com/watch?v=uEsZWWiYNAQ',
        },
        {
          'Esercizio': 'Leg extension',
          'Serie': '4x10',
          'Recupero': '1min',
          'Descrizione':
          'Posiziona il cuscinetto anteriore sulle tibie vicino alla caviglia e non a contatto coi piedi.Le ginocchia devono posizionarsi al limite della seduta, in modo che il ginocchio non sporga eccessivamente dalla stessa ma non sia nemmeno troppo indietro.I gradi del movimento vanno decisi in base anche ad eventuali problematiche che possiedi. Generalmente se le tue ginocchia stanno bene, potresti partire in un range compreso tra 100-120° di flessione di ginocchia.Il movimento finisce quando le ginocchia sono in completa estensione.I movimenti devono essere sempre controllati in ogni singola fase dell’esercizio.',
          'YouTube': 'https://www.youtube.com/watch?v=4ZDm5EbiFI8',
        },
        {
          'Esercizio': 'Leg curl',
          'Serie': '4x10',
          'Recupero': '1min',
          'Descrizione':
          'Sdraiato o in piedi sulla macchina apposita, aggancia i piedi ai cuscinetti.Fletti le ginocchia, portando i talloni verso i glutei.Rilascia lentamente alla posizione di partenza, controllando il movimento.',
          'YouTube': 'https://www.youtube.com/watch?v=89heg4k6Vps',
        },
        {
          'Esercizio': 'Calf',
          'Serie': '4x10',
          'Recupero': '1min',
          'Descrizione':
          "In piedi, con i piedi a larghezza spalle e le punte dei piedi leggermente rivolte in avanti.Sollevati lentamente sulle punte dei piedi, concentrandoti sulla contrazione dei polpacci.Mantieni la posizione per un secondo nella parte alta del movimento.Abbassati lentamente fino a tornare alla posizione di partenza, senza far toccare i talloni a terra se vuoi maggiore intensità.",
          'YouTube': 'https://www.youtube.com/watch?v=TSWcyXFxdvo',
        },
        {
          'Esercizio': 'Shoulder press',
          'Serie': '4x10',
          'Recupero': '1min',
          'Descrizione':
          "In piedi o seduto, tieni i manubri o il bilanciere all'altezza delle spalle.Spingi verso l'alto estendendo le braccia sopra la testa, mantenendo i gomiti leggermente in avanti.Abbassa lentamente il peso fino alla posizione iniziale senza lasciare cadere le braccia troppo indietro.",
          'YouTube': 'https://www.youtube.com/watch?v=UtQiS_rNg7M',
        },
        {
          'Esercizio': 'Alzate laterali',
          'Serie': '4x10',
          'Recupero': '1min',
          'Descrizione':
          "In piedi, con un manubrio in ciascuna mano e le braccia lungo i fianchi.Solleva le braccia lateralmente fino a portarle all'altezza delle spalle, mantenendo un leggero piegamento dei gomiti.Rilascia lentamente fino a tornare alla posizione iniziale, mantenendo il controllo.",
          'YouTube': 'https://www.youtube.com/watch?v=5Dyh1z6E6rM',
        },
        {
          'Esercizio': 'French press bilanciere',
          'Serie': '3x10',
          'Recupero': '1min',
          'Descrizione':
          'Sdraiati su una panca piana con il bilanciere tenuto sopra il petto.Fletti i gomiti portando il bilanciere verso la fronte, mantenendo i gomiti fermi.Estendi le braccia tornando alla posizione iniziale, concentrandoti sui tricipiti.',
          'YouTube': 'https://www.youtube.com/watch?v=89heg4k6Vps',
        },
        {
          'Esercizio': 'Tricipi ai cavi',
          'Serie': '4x10',
          'Recupero': '1min',
          'Descrizione':
          'In piedi di fronte alla macchina con cavi.Afferra la barra con presa stretta e spingi verso il basso, estendendo completamente i gomiti.Rilascia lentamente fino a tornare alla posizione iniziale, tenendo i gomiti fermi.',
          'YouTube': 'https://www.youtube.com/watch?v=89heg4k6Vps',
        },
        {
          'Esercizio': 'Crunch',
          'Serie': '3x20',
          'Recupero': '1min',
          'Descrizione':
          'Il crunch viene eseguito stendendosi in posizione supina e sollevando il busto in direzione del bacino che invece deve restare in saldo appoggio.',
          'YouTube': 'https://www.youtube.com/watch?v=MKmrqcoCZ-M',
        },
      ],
      2: [
        {
          'Esercizio': 'Riscaldamento',
          'Serie': '-',
          'Recupero': '-',
          'Descrizione': 'ti riscaldi',
          'YouTube': '',
        },
        {
          'Esercizio': 'Chest  press',
          'Serie': '4x10',
          'Recupero': '1min',
          'Descrizione':
          'Per eseguirla bene ecco delle linee guida: non devi muoverti con l’intero corpo, ma solo distendere le braccia,devi mantenere la schiena poggiata sullo schienale,devi tenere addotte e depresse le scapole,non devi spingere in avanti le scapole,devi completare il movimento di distensione delle braccia,utilizza pieno controllo motorio per l’intera esecuzione,la testa non deve venire in avanti, ma rimanere appoggiata allo schienale,i gomiti NON vanno tenuti ALTI, come si sente spesso dire.',
          'YouTube': 'https://www.youtube.com/watch?v=sqNwDkUU_Ps',
        },
        {
          'Esercizio': 'Panca piana',
          'Serie': '4x10',
          'Recupero': '1min',
          'Descrizione':
          'Ci si stende su una panca, si afferra il bilanciere dagli appoggi, si stendono le braccia,si porta il bilanciere al petto per spingerlo via fino a tornare nella posizione iniziale',
          'YouTube': 'https://www.youtube.com/watch?v=abkLsC0HEjg',
        },
        {
          'Esercizio': 'Spinte 30°',
          'Serie': '3x15',
          'Recupero': '1min',
          'Descrizione':
          "Posizionati su una panca inclinata a 30 gradi, con manubri o bilanciere in mano.Afferra i manubri (o il bilanciere) con le mani all'altezza del petto, i gomiti piegati e leggermente verso il basso.Spingi i pesi verso l'alto estendendo le braccia, mantenendo i gomiti leggermente piegati alla fine del movimento.Torna alla posizione iniziale lentamente, controllando la discesa e mantenendo una buona attivazione dei pettorali superiori.",
          'YouTube': 'https://www.youtube.com/watch?v=2mvWe_8jhMk',
        },
        {
          'Esercizio': 'Panca 30° croci',
          'Serie': '4x10',
          'Recupero': '1min',
          'Descrizione':
          "L'esecutore si posiziona su panca piana inclinata a 30# impugnando i manubri solitamente con una presa neutra con i piedi fissati al suolo.Durante il movimento, i gomiti sono leggermente flessi e bloccati, ciò significa che non devono variare la loro lunghezza ed essere mobilizzati durante l'esecuzione.Si alzano i manubri in vericale e facciamo un movimento ad aprire e poi chiudere, cercado di controllarli entrambi.",
          'YouTube': 'https://www.youtube.com/watch?v=AY9pI9ANxs8',
        },
        {
          'Esercizio': 'Alzate laterali',
          'Serie': '4x10',
          'Recupero': '1min',
          'Descrizione':
          "In piedi, con un manubrio in ciascuna mano e le braccia lungo i fianchi.Solleva le braccia lateralmente fino a portarle all'altezza delle spalle, mantenendo un leggero piegamento dei gomiti.Rilascia lentamente fino a tornare alla posizione iniziale, mantenendo il controllo.",
          'YouTube': 'https://www.youtube.com/watch?v=5Dyh1z6E6rM',
        },
        {
          'Esercizio': 'Alzate laterali ai cavi',
          'Serie': '4x10',
          'Recupero': '1min',
          'Descrizione':
          "Posizionati di lato rispetto alla macchina con cavi.Afferra la maniglia del cavo con la mano opposta rispetto al lato della macchina (se sei di fronte alla macchina con il lato destro, usa la mano sinistra e viceversa).Mantieni una leggera inclinazione laterale verso la macchina e tieni l’altra mano sull’anca o su un supporto per maggiore stabilità.Esecuzione:Tira il cavo sollevando il braccio lateralmente fino a portarlo all'altezza della spalla, mantenendo il gomito leggermente piegato e la mano in linea con il gomito.Evita di ruotare il polso durante il movimento, mantenendo la mano in posizione neutra (come se stessi versando acqua da una brocca).Fai una pausa in alto, sentendo la contrazione nel deltoide laterale (spalla).Abbassa lentamente il braccio fino alla posizione di partenza, controllando il movimento per tutta la discesa.",
          'YouTube': 'https://www.youtube.com/shorts/6Z-wuEf04ZQ',
        },
        {
          'Esercizio': 'Bicipiti bilanciere',
          'Serie': '3x15',
          'Recupero': '1min',
          'Descrizione':
          "Se eseguita sulla panca scott bisogna prestare attenzione alla posizione delle braccia che devono essere parallele tra loro e al movimento del braccio che non deve un angolo piatto (180°) ma uno acuto (circa 100/120°).Mentre se eseguiti da in piedi bisogna prestare attenzione a bloccare il motito al busto e non muoverlo durante l'esecuzione.",
          'YouTube': 'https://www.youtube.com/watch?v=7ECvCFpsOik',
        },
        {
          'Esercizio': 'Bicipiti curl manubri',
          'Serie': '3x10',
          'Recupero': '1min',
          'Descrizione':
          "Stessa esecuzione dei curl col bilanciere unica differenza è che non limiteremo il movimento quindi partiamo con il braccio a riposo e porteremo i manubri fino all'altezza delle spalle, possiamo aggiungere una rotazione alla partenza per attivare anche gli avambracci.",
          'YouTube': 'https://www.youtube.com/watch?v=ykJmrZ5v0Oo',
        },
        {
          'Esercizio': 'Crunch inverso',
          'Serie': '3x20',
          'Recupero': '1min',
          'Descrizione':
          "Sdraiato sulla schiena, con le gambe piegate e i piedi sollevati da terra.Porta le ginocchia verso il petto, sollevando il bacino dal pavimento e contrai gli addominali.Rilascia lentamente abbassando le gambe senza far toccare i piedi a terra, mantenendo il controllo del movimento.",
          'YouTube': 'https://www.youtube.com/watch?v=2UMZfWtY4mY',
        },
      ],
      3: [
        {
          'Esercizio': 'Riscaldamento',
          'Serie': '-',
          'Recupero': '-',
          'Descrizione': 'ti riscaldi',
          'YouTube': '',
        },
        {
          'Esercizio': 'Lat Machine avanti',
          'Serie': '4x10',
          'Recupero': '2min',
          'Descrizione':
          "Siediti sulla lat machine con le gambe bloccate sotto i cuscinetti.Afferra la barra con presa larga.Tira la barra verso il petto, contraendo i dorsali, mantenendo il busto leggermente inclinato all'indietro.Rilascia la barra lentamente fino a tornare in alto.",
          'YouTube': 'https://www.youtube.com/watch?v=89heg4k6Vps',
        },
        {
          'Esercizio': 'Low rowing machine',
          'Serie': '4x10',
          'Recupero': '1min',
          'Descrizione':
          'Simile al pulley, ma utilizzando una macchina con resistenza.Afferra le maniglie e tira verso il busto, concentrandoti sulla contrazione dei dorsali e avvicinando le scapole.Rilascia lentamente fino a tornare alla posizione iniziale.',
          'YouTube': 'https://www.youtube.com/watch?v=89heg4k6Vps',
        },
        {
          'Esercizio': 'Pulley',
          'Serie': '3x12',
          'Recupero': '1min',
          'Descrizione':
          'Siediti di fronte alla macchina con i piedi sulle pedane.Afferra la barra o maniglia e tira verso di te, mantenendo il busto dritto.Tira i gomiti indietro, avvicinando le scapole.Rilascia lentamente alla posizione di partenza.',
          'YouTube': 'https://www.youtube.com/watch?v=89heg4k6Vps',
        },
        {
          'Esercizio': 'Rematore t bar',
          'Serie': '4x10',
          'Recupero': '2min',
          'Descrizione':
          "Posizionati sulla T-bar, con i piedi alla larghezza delle spalle e le ginocchia leggermente piegate.Afferra le maniglie della T-bar con entrambe le mani, tenendo le braccia distese.Mantieni il busto inclinato in avanti, con la schiena dritta e il petto in fuori, creando un angolo di circa 45 gradi rispetto al pavimento.Esecuzione:Tira la maniglia della T-bar verso il busto, portando i gomiti indietro e vicino al corpo.Durante il movimento, concentra la contrazione nei muscoli dorsali, cercando di avvicinare le scapole tra loro.Mantieni una breve contrazione nella parte alta del movimento, con la barra vicino alla parte inferiore del petto o all'addome.Rilascia lentamente il peso tornando alla posizione di partenza, estendendo le braccia senza perdere la tensione sui dorsali.",
          'YouTube': 'https://www.youtube.com/watch?v=e1YdZdLVsmw',
        },
        {
          'Esercizio': 'Bicipiti bilanciere',
          'Serie': '4x10',
          'Recupero': '1min',
          'Descrizione':
          "Se eseguita sulla panca scott bisogna prestare attenzione alla posizione delle braccia che devono essere parallele tra loro e al movimento del braccio che non deve un angolo piatto (180°) ma uno acuto (circa 100/120°).Mentre se eseguiti da in piedi bisogna prestare attenzione a bloccare il motito al busto e non muoverlo durante l'esecuzione.",
          'YouTube': 'https://www.youtube.com/watch?v=7ECvCFpsOik',
        },
        {
          'Esercizio': 'Bicipiti curl manubri',
          'Serie': '4x10',
          'Recupero': '1min',
          'Descrizione':
          "Stessa esecuzione dei curl col bilanciere unica differenza è che non limiteremo il movimento quindi partiamo con il braccio a riposo e porteremo i manubri fino all'altezza delle spalle, possiamo aggiungere una rotazione alla partenza per attivare anche gli avambracci.",
          'YouTube': 'https://www.youtube.com/watch?v=ykJmrZ5v0Oo',
        },
        {
          'Esercizio': 'Dip',
          'Serie': '3x20',
          'Recupero': '1min',
          'Descrizione':
          "Posizionati su parallele o su una stazione per dip, con le braccia estese e il corpo sospeso.Fletti i gomiti abbassando lentamente il corpo fino a che le braccia non formano un angolo di 90 gradi o meno.Spingi verso l'alto estendendo i gomiti fino a tornare alla posizione di partenzaMantieni il busto leggermente inclinato in avanti per coinvolgere maggiormente i pettorali, o dritto per concentrarti sui tricipiti.",
          'YouTube': 'https://www.youtube.com/watch?v=TrJVszDm7ik',
        },
        {
          'Esercizio': 'Tricipiti ai cavi',
          'Serie': '4x10',
          'Recupero': '1min',
          'Descrizione':
          'In piedi di fronte alla macchina con cavi.Afferra la barra con presa stretta e spingi verso il basso, estendendo completamente i gomiti.Rilascia lentamente fino a tornare alla posizione iniziale, tenendo i gomiti fermi.',
          'YouTube': 'https://www.youtube.com/watch?v=89heg4k6Vps',
        },
        {
          'Esercizio': 'Russian twist',
          'Serie': '3x20',
          'Recupero': '1min',
          'Descrizione':
          "Siediti a terra con le ginocchia piegate e i piedi sollevati.Afferra un peso (palla medica o manubrio) e ruota il busto da un lato all'altro.Mantieni il core contratto e la schiena dritta mentre esegui la rotazione.",
          'YouTube': 'https://www.youtube.com/watch?v=89heg4k6Vps',
        },
      ],
    },
  };

  void _showExerciseDetails(
      String exerciseName,
      String description,
      String youtubeUrl,
      ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(exerciseName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(description),
              SizedBox(height: 10),
              Text('Guarda il video su YouTube:'),
              SizedBox(height: 10),
              InkWell(
                onTap: () {
                  launchURL(youtubeUrl); // Funzione per aprire il link YouTube
                },
                child: Text(
                  'Link al video',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Chiudi'),
              onPressed: () {
                Navigator.of(context).pop(); // Chiudi il dialogo
              },
            ),
          ],
        );
      },
    );
  }

  void launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  // Funzione per navigare al giorno successivo
  void goToNextDay() {
    setState(() {
      if (selectedDay != null && selectedDay! < 3) {
        selectedDay = selectedDay! + 1;
      }
    });
  }

  // Funzione per tornare al giorno precedente o alla selezione del livello
  void goToPreviousDayOrLevel() {
    setState(() {
      if (selectedDay != null && selectedDay! > 1) {
        selectedDay = selectedDay! - 1;
      } else {
        selectedDay = null; // Torna alla selezione del livello
      }
    });
  }

  // Funzione per generare il testo da condividere
  String generateShareText() {
    if (selectedLevel != null && selectedDay != null) {
      final exercises = exerciseData[selectedLevel]![selectedDay]!;
      String shareText = "Scheda di Allenamento: \n\n";
      shareText += "Livello: $selectedLevel - Giorno: $selectedDay\n\n";
      for (var exercise in exercises) {
        shareText +=
        "${exercise['Esercizio']} - Serie: ${exercise['Serie']} - Recupero: ${exercise['Recupero']}\n";
      }
      return shareText;
    }
    return "Seleziona un livello e un giorno per visualizzare la scheda.";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scheda di Allenamento'),
        actions: [
          if (selectedLevel != null && selectedDay != null)
            IconButton(
              icon: Icon(Icons.share, size: 30),
              onPressed: () {
                Share.share(generateShareText());
              },
              tooltip: 'Condividi la scheda',
            ),
        ],
        backgroundColor: Colors.amber,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Stack(
              children: [
                // Sfondo dell'immagine
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        'images/palestra.png',
                      ), // Immagine di sfondo
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Overlay trasparente con sfocatura
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 10.0,
                      sigmaY: 10.0,
                    ), // Effetto di sfocatura
                    child: Container(
                      color: Colors.black.withOpacity(
                        0.3,
                      ), // Semi-trasparente per l'effetto di oscuramento
                    ),
                  ),
                ),
                // Contenuto sopra lo sfondo sfocato
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment
                        .start, // Allinea tutto il contenuto in alto
                    crossAxisAlignment:
                    CrossAxisAlignment.stretch, // Centra orizzontalmente
                    children: [
                      // Testo in alto
                      Column(
                        children: [
                          Text(
                            selectedLevel == null
                                ? 'Seleziona il tuo livello'
                                : (selectedDay == null
                                ? 'Seleziona il giorno del tuo allenamento'
                                : 'Giorno $selectedDay - Allenamento'),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                          SizedBox(height: 20), // Spazio sotto il testo
                        ],
                      ),
                      // Bottoni centrati sotto al testo
                      if (selectedLevel == null) ...[
                        buildLevelButton("Principiante"),
                        SizedBox(height: 20),
                        buildLevelButton('Intermedio'),
                        SizedBox(height: 20),
                        buildLevelButton('Avanzato'),
                      ] else if (selectedDay == null) ...[
                        buildDayButton(1),
                        SizedBox(height: 20),
                        buildDayButton(2),
                        SizedBox(height: 20),
                        buildDayButton(3),
                      ] else ...[
                        buildExerciseTable(),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.arrow_back,
                                size: 50,
                                color: Colors.amber,
                              ),
                              onPressed: () {
                                goToPreviousDayOrLevel();
                              },
                            ),
                            if (selectedDay != 3)
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_forward_sharp,
                                  size: 50,
                                  color: Colors.amber,
                                ),
                                onPressed: () {
                                  goToNextDay();
                                },
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLevelButton(String level) {
    return ElevatedButton(
      onPressed: () => setState(() => selectedLevel = level),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.amber,
        backgroundColor: Colors.black,
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(level, style: TextStyle(fontSize: 18)),
    );
  }

  Widget buildDayButton(int day) {
    return ElevatedButton(
      onPressed: () => setState(() => selectedDay = day),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.amber,
        backgroundColor: Colors.black,
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text('Giorno $day', style: TextStyle(fontSize: 18)),
    );
  }

  Widget buildExerciseTable() {
    return Table(
      border: TableBorder.all(),
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(2),
      },
      children: [
        TableRow(
          children: [
            buildTableHeader('Esercizio'),
            buildTableHeader('Serie'),
            buildTableHeader('Recupero'),
          ],
        ),
        ...exerciseData[selectedLevel]![selectedDay]!.map((exercise) {
          return TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap:
                      () => _showExerciseDetails(
                    exercise['Esercizio']!,
                    exercise['Descrizione']!,
                    exercise['YouTube']!,
                  ),
                  child: Text(
                    exercise['Esercizio']!,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              buildTableCell(exercise['Serie']!),
              buildTableCell(exercise['Recupero']!),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
      ),
    );
  }

  Widget buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(text, style: TextStyle(color: Colors.white)),
    );
  }

  Widget buildNavigationButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.amber,
        backgroundColor: Colors.black,
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(text, style: TextStyle(fontSize: 18)),
    );
  }
}

class MenuScreen {}

// Schermata Home
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Grafico
  late LineChartData chartData;
  // Coda per gestire i dati (FIFO)
  Queue<double> dataQueue = Queue();
  // SharedPreferences per salvare i dati
  late SharedPreferences sharedPreferences;
  String userName = "Utente"; // Default name

  // Inizializzazione del widget e caricamento dei dati
  @override
  void initState() {
    super.initState();
    _loadDataFromSharedPreferences();
  }

  // Carica i dati salvati e il nome dell'utente
  Future<void> _loadDataFromSharedPreferences() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      dataQueue.clear();
      for (int i = 0; i < 30; i++) {
        dataQueue.add(sharedPreferences.getDouble('entry$i') ?? 0.0);
      }
      userName = sharedPreferences.getString('name') ?? "Utente";
      _initializeChart();
    });
  }

  // Salva i dati aggiornati
  Future<void> _saveDataToSharedPreferences() async {
    for (int i = 0; i < dataQueue.length; i++) {
      sharedPreferences.setDouble('entry$i', dataQueue.elementAt(i));
    }
  }

  // Funzione per generare il messaggio di benvenuto
  String getWelcomeMessage() {
    int currentHour = DateTime.now().hour;
    if (currentHour < 12) {
      return "Buongiorno, $userName";
    } else if (currentHour < 18) {
      return "Buon pomeriggio, $userName";
    } else {
      return "Buonasera, $userName";
    }
  }

  // Inizializzazione del grafico
  void _initializeChart() {
    List<FlSpot> spots = [];
    double x = 1;
    for (double value in dataQueue) {
      spots.add(FlSpot(x, value));
      x += 1;
    }

    chartData = LineChartData(
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toStringAsFixed(0),
                style: TextStyle(
                  color: Colors.amber, // Colore giallo per i titoli sull'asse Y
                  fontSize: 10,
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toStringAsFixed(0),
                style: TextStyle(
                  color: Colors.amber, // Colore giallo per i titoli sull'asse X
                  fontSize: 10,
                ),
              );
            },
          ),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          color: Colors.amber, // Colore giallo per la linea
          isCurved: true,
          barWidth: 2,
          belowBarData: BarAreaData(
            show: true,
            color: Colors.amber.withOpacity(0.2), // Colore giallo chiaro sotto la linea
          ),
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, barData, chartContext, size) {
              return FlDotCirclePainter(
                  color: Colors.amber, // Colore giallo per i punti
                  radius: 4, // Dimensione del punto
                  strokeWidth: 2,
                  strokeColor: Colors.amber); // Colore del bordo del punto
            },
          ),
        ),
      ],
      gridData: FlGridData(
        show: true,
        getDrawingHorizontalLine: (value) => FlLine(
          color: Colors.amber.withOpacity(0.5), // Colore griglia giallo
          strokeWidth: 1,
        ),
        getDrawingVerticalLine: (value) => FlLine(
          color: Colors.amber.withOpacity(0.5), // Colore griglia giallo
          strokeWidth: 1,
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.amber, width: 1), // Bordo giallo del grafico
      ),
    );
  }

  // Aggiorna il grafico con un nuovo valore
  void _aggiornaGrafico(double newValue) {
    setState(() {
      if (dataQueue.length >= 30) {
        dataQueue.removeFirst();
      }
      dataQueue.add(newValue);
      _initializeChart();
    });
    _saveDataToSharedPreferences();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController pesoController = TextEditingController();


    return Scaffold(
      appBar: AppBar(
        title: Text('Andamento Peso'),
        backgroundColor: Colors.amber,
      ),
      body: Stack(
        children: [
          // Sfondo con immagine
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
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), // Aggiunge la sfocatura
              child: Container(
                color: Colors.black.withOpacity(0), // Sfondo trasparente sopra
              ),
            ),
          ),
          // Contenuto sopra il filtro
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getWelcomeMessage(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
                SizedBox(height: 20),
                Expanded(child: LineChart(chartData)),
                SizedBox(height: 20),
                TextField(
                  cursorColor: Colors.amber,
                  controller: pesoController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Inserisci il peso',
                    border: OutlineInputBorder(),
                    labelStyle: TextStyle(color: Colors.amber),
                    // Etichetta gialla
                  ),
                  style: TextStyle(
                    color: Colors.amber,
                  ),
                ),
                SizedBox(height: 10),
                // Button centrato
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      String pesoString = pesoController.text;
                      if (pesoString.isNotEmpty) {
                        try {
                          double peso = double.parse(pesoString);
                          if (peso > 0) {
                            _aggiornaGrafico(peso);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Inserisci un peso valido")),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Inserisci un peso valido")),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Inserisci un peso")),
                        );
                      }
                    },
                    child: Text("Aggiungi Peso"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.amber,
                    ),
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