import 'package:flutter/material.dart';
import 'package:taxdul/features/chat/latestChat.dart';
import 'package:taxdul/features/chat/memo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String? fullname = "";

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    _controller.forward();

    _loadFullname();
  }

  void _loadFullname() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      fullname = prefs.getString("fullname");
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight =
        MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        kToolbarHeight // typical appbar height, if you have one
        -
        kBottomNavigationBarHeight; // if you have bottomNavigationBar

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.indigoAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 72, left: 24, bottom: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/avatar.png'),
                    backgroundColor: Colors.grey.shade400,
                  ),
                  SizedBox(width: 16), // spacing between avatar and text
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back,',
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                      Text(
                        '${fullname}', // Replace with dynamic username if needed
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              children: [
                // First button
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.black45.withOpacity(0.3),
                        elevation: 6,
                        shadowColor: Colors.black45.withOpacity(0.5),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/');
                      },
                      child: const Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.account_circle,
                            size: 48,
                            color: Colors.white,
                          ),
                          Expanded(
                            child: Text(
                              'Info',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.black45.withOpacity(0.3),
                        elevation: 6,
                        shadowColor: Colors.black45.withOpacity(0.5),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/newchat');
                      },
                      child: const Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.forum_rounded,
                            size: 36,
                            color: Colors.white,
                          ),
                          Expanded(
                            child: Text(
                              'New Chat',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const Spacer(),
            Container(
              height: screenHeight * 0.75,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
              child: Column(
                children: [
                  Expanded(child: LatestChat()),
                  Expanded(child: MemoList()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
