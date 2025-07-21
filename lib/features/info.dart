import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  final String name;

  const InfoPage({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Your Info")),
      body: Center(
        child: Text(
          'Hello, $name!',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
