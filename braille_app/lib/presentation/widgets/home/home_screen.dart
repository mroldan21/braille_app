// lib/presentation/widgets/home/home_screen.dart
import 'package:flutter/material.dart';
import '../../../presentation/widgets/common/connection_indicator.dart';
import '../phrase/phrase_screen.dart';
import '../random/random_screen.dart';
import '../settings/settings_screen.dart';
import '../single_char/single_char_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const SingleCharScreen(),
    const RandomScreen(),
    const PhraseScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Braille App'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: const [
          ConnectionIndicator(),
          SizedBox(width: 16),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.text_fields),
            label: 'Carácter',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.casino),
            label: 'Aleatorio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.format_quote),
            label: 'Frase',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}