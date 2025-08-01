import 'dart:async';
import 'package:flutter/material.dart';
import 'package:taxdul/provider/chat_manager.dart';
import 'package:taxdul/services/dify_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:taxdul/provider/memo_manager.dart';

class ChatPage extends StatefulWidget {
  final String? conversationId;
  final String? title;

  const ChatPage({
    super.key,
    required this.conversationId,
    required this.title,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final DifyService _difyService = DifyService();
  dynamic parameters;
  bool isInit = true;

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String _conversationId = "";
  String _userId = "";
  String textSearch = "";

  @override
  void initState() {
    super.initState();
    _initializeUser();
    _scrollToBottom();
  }

  Future<void> _initializeUser() async {
    final prefs = await SharedPreferences.getInstance();

    String? storedUserId = prefs.getString('user_id');
    if (storedUserId == null) {
      storedUserId = _difyService.generateUserId();
      await prefs.setString('user_id', storedUserId);
    }

    setState(() {
      _userId = storedUserId!;
      _conversationId = widget.conversationId ?? "";
    });

    if (widget.conversationId != "") {
      _convertResponseToChatMessage();
      setState(() {
        isInit = false;
      });
    } else {
      _getParameters();
    }
  }

  Future<void> _getParameters() async {
    try {
      final Map<String, dynamic> parameters = await _difyService
          .getParameters();
      setState(() {
        _messages.add(
          ChatMessage(
            message: parameters['opening_statement'].toString().trim(),
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        this.parameters = parameters;
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> _convertResponseToChatMessage() async {
    try {
      final chatManager = Provider.of<ChatManager>(context, listen: false);
      final selectedChat = chatManager.chatHistory.firstWhere(
        (chat) => chat['conversationId'] == chatManager.selectedChat,
        orElse: () => {},
      );
      final history = selectedChat['history'];

      if (history == null || history.isEmpty) {
        setState(() {
          _messages = [
            ChatMessage(message: '', isUser: false, timestamp: DateTime.now()),
          ];
        });
        return;
      }

      final messages = history.expand<ChatMessage>((msg) {
        final timestamp = DateTime.fromMillisecondsSinceEpoch(
          (msg['created_at'] ?? 0) * 1000,
        );

        return [
          if (msg['query'] != null)
            ChatMessage(
              message: '${msg['query']}',
              isUser: true,
              timestamp: timestamp,
            ),
          if (msg['answer'] != null)
            ChatMessage(
              message: '${msg['answer']}',
              isUser: false,
              timestamp: timestamp,
            ),
        ];
      }).toList();

      setState(() {
        _messages = messages;
      });
    } catch (e) {
      setState(() {
        _messages = [
          ChatMessage(message: '', isUser: false, timestamp: DateTime.now()),
        ];
      });
    }
  }

  Future<void> _sendMessageBlocking() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _messages.add(
        ChatMessage(
          message: userMessage,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final response = await _difyService.sendChatMessage(
        message: userMessage,
        userId: _userId,
        conversationId: _conversationId,
        responseMode: 'blocking',
      );

      final prefs = await SharedPreferences.getInstance();
      String? storedMapJson = prefs.getString('conversations');
      Map<String, dynamic> conversations = storedMapJson != null
          ? jsonDecode(storedMapJson)
          : {};

      if (_conversationId == "") {
        final newConversationId = response['conversation_id'];
        conversations[newConversationId] = {"title": newConversationId};
        await prefs.setString('conversation_map', jsonEncode(conversations));
      }

      setState(() {
        _conversationId = response['conversation_id'];
        _messages.add(
          ChatMessage(
            message: response['answer'] ?? 'No response',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            message: 'Error: Unable to get response. Please try again.',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  Future<void> _scrollToBottom() async {
    await Future.delayed(Duration(milliseconds: 100));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (textSearch != "" || _messageController.text != textSearch) {
      _messageController.text = textSearch;
      textSearch = "";
    }

    return Consumer<ChatManager>(
      builder: (context, chatManager, child) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                chatManager.updateChat(chatManager.selectedChat);
                chatManager.selectChat("");
                Navigator.pop(context);
              },
            ),
            title: Text('${widget.title}'),
            backgroundColor: Colors.purpleAccent,
            foregroundColor: Colors.white,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple, Colors.indigoAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            actions: [
              IconButton(
                icon: Icon(Icons.add_box),
                tooltip: 'New Chat',
                onPressed: () {
                  chatManager.selectChat("");
                  Navigator.pushReplacementNamed(context, '/newchat');
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(16),
                  itemCount: _messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isLoading) {
                      return _buildLoadingIndicator();
                    }
                    return _buildMessageBubble(_messages[index]);
                  },
                ),
              ),
              _buildMessageInput(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? Colors.indigoAccent.withAlpha((0.7 * 255).round())
                    : Colors.grey[300]!.withAlpha((0.4 * 255).round()),
                borderRadius: BorderRadius.circular(16),
              ),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.message,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: message.isUser ? Colors.white70 : Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            if (!message.isUser)
              Positioned(
                bottom: 0,
                right: 0,
                child: Consumer<MemoManager>(
                  builder: (context, memoManager, child) {
                    final isMemo = memoManager.memos.contains(message.message);
                    return IconButton(
                      icon: Icon(
                        Icons.star_rounded,
                        color: isMemo ? Colors.amber : Colors.grey,
                      ),
                      onPressed: () {
                        if (isMemo) {
                          memoManager.removeMemo(message.message);
                        } else {
                          memoManager.addMemo(message.message);
                        }
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text('Typing...'),
          ],
        ),
      ),
    );
  }

  void _sendAndHideQuestions() {
    setState(() {
      isInit = false;
    });
    _sendMessageBlocking();
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(16),

      child: Column(
        children: [
          if (isInit)
            Column(
              children: [
                if (parameters != null)
                  ...parameters['suggested_questions'].map<Widget>((question) {
                    return Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            textSearch = question;
                          });
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.all(8),
                          alignment: Alignment.centerLeft,
                        ),
                        child: Text(
                          question,
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ),
                    );
                  }).toList(),
              ],
            ),
          Row(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(bottom: 16),
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.deepPurple, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withAlpha((0.2 * 255).round()),
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Ask any question...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 14,
                            ),
                          ),
                          maxLines: 5,
                          minLines: 1,
                          textInputAction: TextInputAction.newline,
                          onSubmitted: (_) => _sendAndHideQuestions(),
                          enabled: !_isLoading,
                        ),
                      ),

                      IconButton(
                        icon: Icon(
                          _isLoading ? Icons.hourglass_empty : Icons.send,
                          color: _isLoading ? Colors.grey : Colors.deepPurple,
                        ),
                        onPressed: _isLoading
                            ? null
                            : () {
                                isInit = false;
                                _sendMessageBlocking();
                              },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String message;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.message,
    required this.isUser,
    required this.timestamp,
  });
}
