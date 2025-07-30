import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxdul/services/dify_service.dart';

class ChatManager extends ChangeNotifier {
  List<Map<String, dynamic>> _chatHistory = [];
  String _selectedChat = "";

  List<Map<String, dynamic>> get chatHistory => _chatHistory;
  String get selectedChat => _selectedChat;
  String userId = "";
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  double _loadingPercentage = 0.0;
  double get loadingPercentage => _loadingPercentage;
  final DifyService _difyService = DifyService();

  ChatManager() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString("user_id") ?? "defaultUser";

    await _loadAllChats();
    _isLoading = false;

    notifyListeners();
  }

  Future<void> _loadAllChats() async {
    final allConversations = await _difyService.getConversations();
    List<Map<String, dynamic>> conversations = [];

    int i = 0;
    for (var conversation in allConversations) {
      final id = conversation['id'];
      final history = await _difyService.getConversationHistory(
        conversationId: id,
      );
      conversations.add({
        'conversationId': conversation['id'],
        'title': conversation['name'],
        'history': history,
      });
      i += 1;
      _loadingPercentage = i / allConversations.length * 100;
      notifyListeners();
    }

    _chatHistory = List<Map<String, dynamic>>.from(conversations);
    notifyListeners();
  }

  Future<void> deleteChat(String conversationId) async {
    final success = await _difyService.deleteConversation(
      conversationId: conversationId,
    );

    if (success) {
      _chatHistory.removeWhere(
        (chat) => chat['conversationId'] == conversationId,
      );

      notifyListeners();
    }
  }

  Future<void> selectChat(String conversationId) async {
    _selectedChat = conversationId;
    notifyListeners();
  }

  Future<void> updateChat(String conversationId) async {
    final index = _chatHistory.indexWhere(
      (chat) => chat['conversationId'] == conversationId,
    );

    if (index != -1) {
      final history = await _difyService.getConversationHistory(
        conversationId: conversationId,
      );
      _chatHistory[index]['history'] = history;
      notifyListeners();
    } else {
      final latestConversations = await _difyService.getConversations(limit: 1);
      final history = await _difyService.getConversationHistory(
        conversationId: latestConversations[0]['id'],
      );

      _chatHistory.insert(0, {
        'conversationId': latestConversations[0]['id'],
        'title': latestConversations[0]['name'],
        'history': history,
      });
      notifyListeners();
    }
  }
}
