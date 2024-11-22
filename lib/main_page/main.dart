import 'package:flutter/material.dart';
import '../pages/homepage.dart';
import '../pages/events_page.dart';
import '../pages/journal_page.dart';
import '../pages/profile_page.dart';

void main() {
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
      home: const MyHomePage(title: 'Socialize MUC'),
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

  final List<Widget> _pages = const <Widget>[
    HomePage(),
    EventsPage(
      title: 'Events',
    ),
    JournalPage(
      title: 'Journaling',
    ),
    ProfilePage(
      title: 'Profile',
    )
  ];

  void _onPageSelected(int index) {
    setState(() {
      _pageindex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_pageindex],
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
}
