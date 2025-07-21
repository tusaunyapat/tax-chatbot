import 'package:flutter/material.dart';

class MenuPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade900,
        foregroundColor: Colors.white38,
      ),
      body: Container(
        color: Colors.blueGrey.shade900,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/meal');
                },
                icon: Icon(Icons.fastfood_rounded),

                label: Text("Find Meal"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey.shade300,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 36),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/find');
                },
                icon: Icon(Icons.document_scanner),

                label: Text("Search Manual"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey.shade300,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
