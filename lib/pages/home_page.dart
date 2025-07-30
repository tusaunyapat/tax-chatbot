import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxdul/provider/chat_manager.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _hasNavigated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final chatManager = Provider.of<ChatManager>(context);
    if (!chatManager.isLoading && !_hasNavigated) {
      _hasNavigated = true;
      _checkFullnameAndNavigate();
    }
  }

  Future<void> _checkFullnameAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString("fullname");

    if (!mounted) return;

    if (name != null && name.isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatManager>(
      builder: (context, chatManager, child) {
        if (chatManager.isLoading) {
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.smart_toy,
                        color: Colors.white.withAlpha((0.85 * 255).round()),
                        size: 160,
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'TaxAbdul',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 54,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black.withAlpha(
                                (0.3 * 255).round(),
                              ),
                              offset: Offset(2, 2),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Experience the future of interaction.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.white70),
                      ),
                      SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: chatManager.loadingPercentage / 100.0,
                        backgroundColor: Colors.white24,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 8,
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${chatManager.loadingPercentage.toStringAsFixed(1)} %',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.white70),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
