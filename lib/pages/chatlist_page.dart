import 'package:flutter/material.dart';
import 'package:taxdul/provider/chat_manager.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});
  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
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

        return Scaffold(
          appBar: AppBar(
            centerTitle: false,
            title: Text(
              'My Chats',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                foreground: Paint()
                  ..shader = LinearGradient(
                    colors: <Color>[Colors.purpleAccent, Colors.deepPurple],
                  ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
              ),
            ),
          ),

          body: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: conversations.isEmpty
                      ? Center(child: Text('No conversations'))
                      : ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: conversations.length,
                          itemBuilder: (context, index) {
                            final id = conversations[index]['conversationId'];
                            final name = conversations[index]['title'];

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Slidable(
                                key: ValueKey(id),
                                endActionPane: ActionPane(
                                  motion: const DrawerMotion(),
                                  extentRatio: 0.25,
                                  children: [
                                    SlidableAction(
                                      onPressed: (context) =>
                                          chatManager.deleteChat(id),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      icon: Icons.delete,
                                      label: 'Delete',
                                    ),
                                  ],
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white,
                                        Colors.grey.shade100,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withAlpha(
                                          (0.2 * 255).round(),
                                        ),
                                        blurRadius: 6,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 2,
                                    ),
                                    title: Text(
                                      name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    trailing: SizedBox(
                                      width: 20,
                                      child: Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    onTap: () => {
                                      chatManager.selectChat(id),
                                      _openChat(id, name),
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
