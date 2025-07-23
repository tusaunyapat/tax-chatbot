import 'package:taxdul/features/find_page.dart';
import 'package:taxdul/features/menu_page.dart';
import 'package:flutter/material.dart';
import 'features/pages/landingpage.dart';
import 'features/pages/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'features/meal_page.dart';
import 'services/dify.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'provider/MemoManager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  print('✅ ENV Loaded: ${dotenv.env['DIFY_API_KEY']}');

  final prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('user_id');

  if (userId == null) {
    userId = DifyService().generateUserId();
    await prefs.setString('user_id', userId);
    print('🆕 Generated and stored userId: $userId');
  } else {
    print('📦 Loaded userId from SharedPreferences: $userId');
  }

  List<String> conversationIds = prefs.getStringList('conversation_ids') ?? [];
  print('📃📃📃converation stored in share preference : ${conversationIds}');

  DifyService().initialize();
  print('✅ Dify Service Initialized');

  runApp(
    ChangeNotifierProvider(
      create: (_) => MemoManager(),
      child: MyApp(userId: userId),
    ),
  ); // ✅ pass userId to MyApp
}

class MyApp extends StatelessWidget {
  final String userId;
  MyApp({required this.userId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dify Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final Uri uri = Uri.parse(settings.name ?? '');
        if (uri.pathSegments.length == 2 && uri.pathSegments.first == 'chat') {
          final conversationId = uri.pathSegments[1];
          final title = uri.queryParameters['title'] ?? 'New Chat';

          return MaterialPageRoute(
            builder: (context) =>
                ChatFindPage(conversationId: conversationId, title: title),
          );
        }

        // fallback
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => HomePage());
          case '/menu':
            return MaterialPageRoute(builder: (_) => MenuPage());
          case '/home':
            return MaterialPageRoute(builder: (_) => LandingPage());
          case '/newchat':
            return MaterialPageRoute(
              builder: (_) =>
                  ChatFindPage(conversationId: "", title: "New Chat"),
            );
          default:
            return MaterialPageRoute(
              builder: (_) =>
                  Scaffold(body: Center(child: Text('404 Not Found'))),
            );
        }
      },
    );
  }
}
