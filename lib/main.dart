import 'package:taxdul/pages/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:taxdul/pages/memolist_page.dart';
import 'pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/dify_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'provider/memo_manager.dart';
import 'pages/chatlist_page.dart';
import 'pages/mainscaffold.dart';
import 'pages/welcome_page.dart';
import 'package:taxdul/provider/chat_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  final prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('user_id');

  if (userId == null) {
    userId = DifyService().generateUserId();
    await prefs.setString('user_id', userId);
  }

  DifyService().initialize(userId);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MemoManager()),
        ChangeNotifierProvider(create: (_) => ChatManager()),
      ],
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
                ChatPage(conversationId: conversationId, title: title),
          );
        }

        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => HomePage());
          case '/home':
            return MaterialPageRoute(builder: (_) => MainScaffold());
          case '/chatlist':
            return MaterialPageRoute(builder: (_) => ChatListPage());
          case '/newchat':
            return MaterialPageRoute(
              builder: (_) => ChatPage(conversationId: "", title: "New Chat"),
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
