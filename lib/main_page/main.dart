import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:socialize/main_page/auth_gate.dart';
import '../firebase_options.dart';
import '../pages/homepage.dart';
import '../pages/events_page.dart';
import '../pages/journal_page.dart';
import '../pages/profile_page.dart';
import 'dart:math';
import 'package:socialize/models/event.dart';
import 'package:socialize/models/challenge.dart';
import 'package:socialize/main_page/db_fetching.dart';

List<String> funnyUsernames = [
  "BananaInPajamas",
  "ToiletPaperTycoon",
  "CaptainObvious123",
  "NachoAverageJoe",
  "PickleRickRoll",
  "SirLaughsALot",
  "PineapplePizzaPro",
  "CerealKillerXD",
  "SassyPants42",
  "GravyBoatCaptain",
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  var db = FirebaseFirestore.instance;

  FirebaseAuth.instance.authStateChanges().listen((User? user) async {
    if (user != null) {
      var userRef = db.collection("user").doc(user.uid);

      var userDoc = await userRef.get();

      if (userDoc.exists) {
        // TODO: use user data
      } else {
        if (user.displayName == null) {
          String displayName = funnyUsernames[Random().nextInt(10)];
          await user.updateDisplayName(displayName);
          try {
            // Set the display_name in the document
            await userRef.set(
                {
                  'display_name': displayName,
                },
                SetOptions(
                    merge:
                        true)); // merge: true ensures that only the display_name field is updated, not overwriting the entire document
          } catch (e) {
            print("Error updating display name: $e");
          }
        }
        await userRef.set({"display_name": user.displayName});
      }
    }
  });

  runApp(const SocializeMucApp());
}

class SocializeMucApp extends StatelessWidget {
  const SocializeMucApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Socialize MUC',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home:
          const AuthGate(nestedPage: const MyHomePage(title: 'Socialize MUC')),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _pageindex = 0;

  Future<List<Event>>? future_events;
  Future<List<Challenge>>? future_challenges;
  late Future<List<Widget>> _pages;

  @override
  void initState() {
    super.initState();
    future_events = getEvents();
    future_challenges = getChallenges();
    _pages = getPages();
  }

  void _onPageSelected(int index) {
    setState(() {
      _pageindex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: _pages,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No events found"));
            } else {
              return snapshot.data![_pageindex];
            }
          }),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            icon: const Icon(Icons.house_outlined),
            activeIcon: const Icon(Icons.house),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            icon: const Icon(Icons.calendar_month_outlined),
            activeIcon: const Icon(Icons.calendar_month),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            icon: const Icon(Icons.description_outlined),
            activeIcon: const Icon(Icons.description),
            label: 'Journal',
          ),
          BottomNavigationBarItem(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: 'Profile')
        ],
        currentIndex: _pageindex,
        onTap: _onPageSelected,
      ),
    );
  }

  Future<List<Widget>> getPages() async {
    // Fetch events asynchronously
    List<Event> events = await getEvents();
    List<Challenge> challenges = await getChallenges();

    // Create pages using the events
    return [
      HomePage(events: events, challenges: challenges),
      EventsPage(
        title: 'Events',
        initialEvents: events, // Pass the events as a Future
      ),
      JournalPage(
        title: 'Journaling',
      ),
      ProfilePage(
        title: 'Profile',
      ),
    ];
  }
}
