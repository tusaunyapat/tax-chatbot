import 'package:flutter/material.dart';
import 'package:taxdul/services/dify.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxdul/provider/ChatManager.dart';
import 'package:provider/provider.dart';

class LatestChat extends StatefulWidget {
  @override
  _LatestChatState createState() => _LatestChatState();
}

class _LatestChatState extends State<LatestChat> {
  // List<dynamic> _conversationIds = [];
  final DifyService _difyService = DifyService();

  @override
  void initState() {
    super.initState();
    // _loadConversations();
  }

  // Future<void> _loadConversations() async {
  //   final prefs = await SharedPreferences.getInstance();

  //   String? _userId = prefs.getString('user_id');
  //   final conversations = await _difyService.getConversations(userId: _userId);

  //   setState(() {
  //     _conversationIds = conversations;
  //   });
  // }

  void _openChat(String conversationId, String title) {
    Navigator.pushNamed(
      context,
      '/chat/${conversationId}?title=${title}',
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
                      decorationStyle: TextDecorationStyle.dashed,
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

              // No SizedBox or padding here to keep no space
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

                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Material(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                              child: ListTile(
                                title: Text(
                                  '${conversations[index]['title']}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),

                                onTap: () => _openChat(
                                  id,
                                  conversations[index]['title'],
                                ),
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
