import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxdul/services/dify.dart';

class ChatManager extends ChangeNotifier {
  List<Map<String, dynamic>> _chatHistory = [];

  List<Map<String, dynamic>> get chatHistory => _chatHistory;
  String userId = "";
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  final DifyService _difyService = DifyService();

  ChatManager() {
    _init();
  }

  Future<void> _init() async {
    print("call init of ChatManager");
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString("user_id") ?? "defaultUser";
    print(userId);
    await _loadAllChats();
    _isLoading = false;

    notifyListeners();
  }

  Future<void> _loadAllChats() async {
    print("call loadAllChats of ChatManager");

    final allConversations = await _difyService.getConversations(
      // userId: userId,
    );
    print("finish fetch allConversation");
    // print(allConversations);
    List<Map<String, dynamic>> conversations = [];

    for (var conversation in allConversations) {
      final id = conversation['id'];
      final history = await _difyService.getConversationHistory(
        conversationId: id,
        // userId: userId,
      );
      conversations.add({
        'conversationId': conversation['id'],
        'title': conversation['name'],
        'history': history,
      });
      print("add into conversations");
    }

    _chatHistory = List<Map<String, dynamic>>.from(conversations);
    notifyListeners();
  }

  Future<void> deleteChat(String conversationId) async {
    // await _difyService.deleteConversation(conversationId: conversationId);
    // notifyListeners();
    final success = await _difyService.deleteConversation(
      conversationId: conversationId,
    );

    if (success) {
      // Remove the chat from local list
      _chatHistory.removeWhere(
        (chat) => chat['conversationId'] == conversationId,
      );

      // Notify UI to rebuild
      notifyListeners();
    }
  }
}
