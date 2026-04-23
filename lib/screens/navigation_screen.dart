import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'prestations_screen.dart';
import 'vehicule_screen.dart';
import 'compte_screen.dart';
import 'contact_screen.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _currentIndex = 0;

  static const _pages = [
    HomeScreen(),
    PrestationsScreen(),
    VehiculeScreen(),
    CompteScreen(),
    ContactScreen(),
  ];

  static const _items = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'Accueil',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.build_outlined),
      activeIcon: Icon(Icons.build),
      label: 'Services',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.directions_car_outlined),
      activeIcon: Icon(Icons.directions_car),
      label: 'Véhicule',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'Compte',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.headset_mic_outlined),
      activeIcon: Icon(Icons.headset_mic),
      label: 'Support',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF1E3A8A),
            unselectedItemColor: const Color(0xFF94A3B8),
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            elevation: 0,
            items: _items,
          ),
        ),
      ),
    );
  }
}
