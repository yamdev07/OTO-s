import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/prestations_screen.dart';
import 'screens/vehicule_screen.dart';
import 'screens/compte_screen.dart';
import 'screens/contact_screen.dart';

void main() {
  runApp(const OtoApp());
}

class OtoApp extends StatelessWidget {
  const OtoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'O\'TO Service',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const NavigationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const PrestationsScreen(),
    const VehiculeScreen(),
    const CompteScreen(),
    const ContactScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Prestations'),
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Mon véhicule'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Compte'),
          BottomNavigationBarItem(icon: Icon(Icons.contact_mail), label: 'Contact'),
        ],
      ),
    );
  }
}
