import 'package:brain_and_muscle_app/data/notifiers.dart';
import 'package:flutter/material.dart';

class NavbarWidget extends StatelessWidget {
  const NavbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectedPageNotifier,
      builder: (context, selectedPage, child) {
        return NavigationBar(
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.category),
              label: 'Meine Kategorien',
              tooltip: '',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month),
              label: 'To-Dos',
              tooltip: '',
            ),
            NavigationDestination(
              icon: Icon(Icons.list),
              label: 'Weitere Listen',
              tooltip: '',
            ),
          ],
          onDestinationSelected: (int value) {
            selectedPageNotifier.value = value;
          },
          selectedIndex: selectedPage,
        );
      },
    );
  }
}
