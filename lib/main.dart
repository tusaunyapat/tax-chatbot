import 'package:taxdul/features/Chatpage.dart';
import 'package:flutter/material.dart';
import 'package:taxdul/features/pages/MemoList.dart';
import 'features/pages/landingpage.dart';
import 'features/pages/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/dify.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'provider/MemoManager.dart';
import 'features/chat/Chatlist.dart';
import 'features/pages/MainScaffold.dart';
import 'features/pages/welcome.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  final prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('user_id');

  if (userId == null) {
    userId = DifyService().generateUserId();
    await prefs.setString('user_id', userId);
  }

  DifyService().initialize();

  runApp(
    ChangeNotifierProvider(
      create: (_) => MemoManager(),
      child: MyApp(userId: userId),
    ),
  );
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
      debugShowCheckedModeBanner: false,
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
          case '/home':
            return MaterialPageRoute(builder: (_) => MainScaffold());
          case '/chatlist':
            return MaterialPageRoute(builder: (_) => ChatListPage());
          case '/newchat':
            return MaterialPageRoute(
              builder: (_) =>
                  ChatFindPage(conversationId: "", title: "New Chat"),
            );
          case '/memo':
            return MaterialPageRoute(builder: (_) => MemoListPage());
          case '/welcome':
            return MaterialPageRoute(builder: (_) => WelcomePage());
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
