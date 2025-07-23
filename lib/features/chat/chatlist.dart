import 'package:flutter/material.dart';
import 'package:taxdul/services/dify.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatListPage extends StatefulWidget {
  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  List<dynamic> _conversationIds = [];
  final DifyService _difyService = DifyService();

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    final prefs = await SharedPreferences.getInstance();

    String? _userId = prefs.getString('user_id');
    final conversations = await _difyService.getConversations(userId: _userId);

    setState(() {
      _conversationIds = conversations;
    });
  }

  // Future<void> _deleteConversation(String id) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     _conversationIds.remove(id);
  //   });
  //   // await prefs.setStringList('conversation_ids', _conversationIds);
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
    return Container(
      color: Colors.transparent,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Text(
            'Latest Chats',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          // No SizedBox or padding here to keep no space
          _conversationIds.isEmpty
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
                    itemCount: _conversationIds.length,
                    itemBuilder: (context, index) {
                      final id = _conversationIds[index]['id'];
                      if (index < 4) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Material(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                            child: ListTile(
                              title: Text(
                                '${_conversationIds[index]['name']}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => debugPrint("delete"),
                              ),
                              onTap: () => _openChat(
                                id,
                                _conversationIds[index]['name'],
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
