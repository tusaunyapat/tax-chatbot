import 'package:dify_test/features/find_page.dart';
import 'package:dify_test/features/menu_page.dart';
import 'package:flutter/material.dart';
import 'features/landingpage.dart';
import 'features/meal_page.dart';
import 'services/dify.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
    print('✅ ENV Loaded: ${dotenv.env['DIFY_API_KEY']}');

    // Initialize Dify service
    DifyService().initialize();
    print('✅ Dify Service Initialized');
  } catch (e) {
    print('⚠️ Error during initialization: $e');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dify Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LandingPage(),
      routes: {
        '/chat': (context) => ChatMealPage(),
        '/menu': (context) => MenuPage(),
        '/find': (context) => ChatFindPage(),
      },
    );
  }
}
