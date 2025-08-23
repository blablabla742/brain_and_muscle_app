import 'package:brain_and_muscle_app/data/notifiers.dart';
import 'package:brain_and_muscle_app/views/pages/calendar_page.dart';
import 'package:brain_and_muscle_app/views/pages/category_overview_page.dart';
import 'package:brain_and_muscle_app/views/pages/further_lists_page.dart';
import 'package:flutter/material.dart';
import 'widgets/navbar_widget.dart';

List<Widget> pages = [
  CategoryOverviewPage(),
  TodosOverview(),
  FurtherListsOverview(),
];

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Brain & Muscle Apps'),
        centerTitle: true,
        actions: [
          /*Lottie.asset(
            'assets/lotties/Home 3d illustration.json',
            height: 100.0,
          ),*/
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(child: Text('Einstellungen')),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ValueListenableBuilder(
                  valueListenable: isDarkModeNotifier,
                  builder: (context, value, child) {
                    return value ? Text('Light-Mode') : Text('Dark-Mode');
                  },
                ),
                IconButton(
                  icon: ValueListenableBuilder(
                    valueListenable: isDarkModeNotifier,
                    builder: (context, value, child) {
                      return value
                          ? Icon(Icons.light_mode)
                          : Icon(Icons.dark_mode);
                    },
                  ),
                  onPressed: () {
                    isDarkModeNotifier.value = !isDarkModeNotifier.value;
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: selectedPageNotifier,
        builder: (context, value, child) {
          return pages.elementAt(value);
        },
      ),

      bottomNavigationBar: NavbarWidget(),
    );
  }
}
