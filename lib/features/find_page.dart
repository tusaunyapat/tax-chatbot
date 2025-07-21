import 'package:flutter/material.dart';
import 'package:dify_test/services/dify.dart';

class ChatFindPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatFindPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final DifyService _difyService = DifyService();

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  final String _conversationId = "ddfbbb47-f32f-40ac-a085-d3419b870735";
  // final String _userId = DifyService().generateUserId();
  final String _userId = "flutter_cfe6695b-1a8e-4eae-97a9-426859ebddd5";

  @override
  void initState() {
    super.initState();
    _loadConversationHistory();
    print("start user id ${_userId} conversation id = ${_conversationId}");
    // _testConnection();
  }

  Future<void> _loadConversationHistory() async {
    print("get----------------------");
    print(_userId);
    try {
      final conversations = await _difyService.getConversations(
        userId: _userId,
      );
      print('conversationnnnnn------------------------ ${conversations}');

      if (conversations.isNotEmpty) {
        print("converation is not empty 👌🏻👌🏻👌🏻");
        // _conversationId = conversations.first['id'];
        final history = await _difyService.getConversationHistory(
          conversationId: _conversationId,
          userId: _userId,
        );

        print(history[0]);
        print(history[history.length - 1]);

        setState(() {
          _messages = history.expand((msg) {
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
        });
      }
    } catch (e) {
      print('Error loading conversation history thisone: $e');
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

      print(
        "responssssssssss-------------------------- ${response['metadata']}",
      );

      setState(() {
        // _conversationId = "ddfbbb47-f32f-40ac-a085-d3419b870735";
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
      print('Error sending message: $e');
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
    return Scaffold(
      resizeToAvoidBottomInset: true, // Important for keyboard
      appBar: AppBar(
        title: Text('Search in PDf'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
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
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.blueGrey[500] : Colors.grey[300],
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

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: 5,
              minLines: 1,
              textInputAction: TextInputAction.newline,
              onSubmitted: (_) => _sendMessageBlocking(),
              enabled: !_isLoading,
            ),
          ),
          SizedBox(width: 8),
          FloatingActionButton(
            onPressed: _isLoading ? null : _sendMessageBlocking,
            child: Icon(_isLoading ? Icons.hourglass_empty : Icons.send),
            mini: true,
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
