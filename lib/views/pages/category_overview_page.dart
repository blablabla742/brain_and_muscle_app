import 'package:flutter/material.dart';

class CategoryOverview extends StatelessWidget {
  const CategoryOverview({super.key});

  // Testdaten
  final List<Map<String, dynamic>> testData = const [
    {"name": "Max Mustermann", "age": 25},
    {"name": "Anna Müller", "age": 30},
    {"name": "Peter Schmidt", "age": 28},
    {"name": "Julia Becker", "age": 22},
    {"name": "Tom Meier", "age": 35},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: testData.length,
      itemBuilder: (context, index) {
        final item = testData[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text(item["name"][0]), // Erster Buchstabe des Namens
          ),
          title: Text(item["name"]),
          subtitle: Text('Alter: ${item["age"]}'),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${item["name"]} ausgewählt')),
            );
          },
        );
      },
    );
  }
}
