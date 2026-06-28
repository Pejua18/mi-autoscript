import 'package:flutter/material.dart';
import 'connect_screen.dart';
import 'logs_screen.dart';
import 'extras_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1;
  final List<Widget> _screens = const [LogsScreen(), ConnectScreen(), ExtrasScreen()];
  @override Widget build(BuildContext context) {
    return Scaffold(backgroundColor: const Color(0xFF0A1628), body: _screens[_currentIndex], bottomNavigationBar: _buildBottomNav());
  }
  Widget _buildBottomNav() {
    return Container(decoration: BoxDecoration(color: const Color(0xFF0D1F3C), border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08), width: 1))),
      child: SafeArea(child: Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _navItem(0, Icons.description_outlined, 'Registros'),
        _navItem(1, Icons.home_rounded, 'Inicio'),
        _navItem(2, Icons.grid_view_rounded, 'Extras'),
      ]))));
  }
  Widget _navItem(int index, IconData icon, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(onTap: () => setState(() => _currentIndex = index), behavior: HitTestBehavior.opaque,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: isActive ? const Color(0xFF00C8FF) : Colors.white38, size: 24),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: isActive ? const Color(0xFF00C8FF) : Colors.white38, fontWeight: isActive ? FontWeight.w600 : FontWeight.normal)),
      ]));
  }
}
