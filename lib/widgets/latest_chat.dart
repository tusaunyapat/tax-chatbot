import 'package:flutter/material.dart';
import 'package:taxdul/provider/chat_manager.dart';
import 'package:provider/provider.dart';

class LatestChat extends StatefulWidget {
  const LatestChat({super.key});
  @override
  _LatestChatState createState() => _LatestChatState();
}

class _LatestChatState extends State<LatestChat> {
  @override
  void initState() {
    super.initState();
  }

  void _openChat(String conversationId, String title) {
    Navigator.pushNamed(
      context,
      '/chat/$conversationId?title=$title',
      arguments: {'conversationId': conversationId},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatManager>(
      builder: (context, chatManager, child) {
        final conversations = chatManager.chatHistory;

        return Container(
          color: Colors.transparent,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Latest Chats',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..shader = LinearGradient(
                          colors: <Color>[
                            Colors.purpleAccent,
                            Colors.deepPurple,
                          ],
                        ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/chatlist'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.pinkAccent,
                      padding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Text('All Chats >', style: TextStyle(fontSize: 14)),
                  ),
                ],
              ),

              conversations.isEmpty
                  ? Expanded(
                      child: Center(
                        child: Text(
                          'No conversations',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        physics: NeverScrollableScrollPhysics(),

                        itemCount: conversations.length > 3
                            ? 3
                            : conversations.length,
                        itemBuilder: (context, index) {
                          final id = conversations[index]['conversationId'];
                          final title = conversations[index]['title'];

                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Material(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                              child: ListTile(
                                title: Text(
                                  '$title',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),

                                onTap: () => {
                                  chatManager.selectChat(id),
                                  _openChat(id, title),
                                },
                                trailing: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }
}
