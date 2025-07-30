import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DifyService {
  static final DifyService _instance = DifyService._internal();

  factory DifyService() {
    return _instance;
  }

  DifyService._internal();

  String? _apiKey;
  late String userId;

  String? _baseUrl;
  final _uuid = Uuid();

  void initialize(String userId) {
    _apiKey = dotenv.env['DIFY_API_KEY'];
    _baseUrl = dotenv.env['DIFY_BASE_URL'] ?? 'https://udify.app/v1';
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('DIFY_API_KEY not found in environment variables');
    }
    this.userId = userId;
  }

  Future<void> getUserId() async {
    final prefs = await SharedPreferences.getInstance();

    String? storedUserId = prefs.getString('user_id');

    if (storedUserId == null || storedUserId.isEmpty) {
      storedUserId = _uuid.v4();
      await prefs.setString('user_id', storedUserId);
    }

    userId = storedUserId;
  }

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $_apiKey',
    'Content-Type': 'application/json',
  };

  Future<Map<String, dynamic>> sendChatMessage({
    required String message,
    required String userId,
    String? conversationId,
    String responseMode = 'blocking',
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/chat-messages');
      final body = {
        'inputs': {},

        'query': message,
        'user': userId,
        'response_mode': responseMode,
        'auto_generate_name': true,
      };

      if (conversationId != null) {
        body['conversation_id'] = conversationId;
      }

      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getConversationHistory({
    required String conversationId,

    int limit = 20,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/messages').replace(
        queryParameters: {
          'conversation_id': conversationId,
          'user': userId,
          'limit': limit.toString(),
        },
      );

      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to get conversation history: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getConversations({int limit = 20}) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/conversations',
      ).replace(queryParameters: {'user': userId, 'limit': limit.toString()});

      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to get conversations: $e');
    }
  }

  Future<Map<String, dynamic>> getParameters() async {
    try {
      final url = Uri.parse('${_baseUrl}/parameters');

      final response = await http.get(url, headers: _headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to get parameters: $e');
    }
  }

  Future<bool> deleteConversation({required String conversationId}) async {
    try {
      final url = Uri.parse('$_baseUrl/conversations/$conversationId');

      final response = await http.delete(
        url,
        headers: _headers,
        body: jsonEncode({'user': userId}),
      );
      return response.statusCode == 204;
    } catch (e) {
      throw Exception(e);
    }
  }

  String generateUserId() {
    return 'flutter_${_uuid.v4()}';
  }
}
