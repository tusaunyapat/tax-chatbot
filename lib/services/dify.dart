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
  String? _apiKeyStreaming;
  String? _apiKeyBlocking;
  late String userId;

  String? _baseUrl;
  final _uuid = Uuid();

  void initialize(String userId) {
    _apiKeyBlocking = dotenv.env['DIFY_API_KEY'];
    _apiKeyStreaming = dotenv.env['DIFY_API_KEY_STREAMING'];

    _apiKey = dotenv.env['DIFY_API_KEY'];
    _baseUrl = dotenv.env['DIFY_BASE_URL'] ?? 'https://udify.app/v1';

    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('DIFY_API_KEY not found in environment variables');
    }
    this.userId = userId;

    print('✅ Dify Service initialized with base URL: $_baseUrl');
  }

  Future<void> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedUserId = prefs.getString('user_id');

    if (storedUserId == null || storedUserId.isEmpty) {
      // Generate a new UUID
      storedUserId = _uuid.v4();
      await prefs.setString('user_id', storedUserId);
    }

    // Set the class variable
    userId = storedUserId;
    print('✅ User ID set: $userId');
  }

  Map<String, String> get _headersBlocking => {
    'Authorization': 'Bearer $_apiKeyBlocking',
    'Content-Type': 'application/json',
  };
  Map<String, String> get _headersStreaming => {
    'Authorization': 'Bearer $_apiKeyStreaming',
    'Content-Type': 'application/json',
  };

  // Send a chat message
  Future<Map<String, dynamic>> sendChatMessage({
    required String message,
    required String userId,
    String? conversationId,
    String responseMode = 'blocking',
  }) async {
    bool isBlockingMode = responseMode == 'blocking';

    _apiKey = isBlockingMode ? _apiKeyBlocking : _apiKeyStreaming;

    try {
      final url = Uri.parse('$_baseUrl/chat-messages');
      final body = {
        'inputs': isBlockingMode
            ? {} // ถ้าเป็น blocking ส่ง inputs ว่าง
            : {
                // 'text': base64File,
                // 'target_language': 'thai',
                'type': 'อาหารจานเดียว',
                'meal': 'มื้อเย็น',
                'n': 1,
                'location': 'seacon bangkae',
              },

        'query': message,
        'user': userId,
        'response_mode': responseMode,
        'auto_generate_name': true,
      };

      if (conversationId != null) {
        body['conversation_id'] = conversationId;
      }

      print('📤 Sending request to: $url');
      print('📤 Request body: ${jsonEncode(body)}');

      if (isBlockingMode) {
        // Blocking mode: wait for full response
        final response = await http.post(
          url,
          headers: _headersBlocking,
          body: jsonEncode(body),
        );

        print('📥 Response status: ${response.statusCode}');
        print('📥 Response body: ${response.body}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data;
        } else {
          throw Exception(
            'API Error: ${response.statusCode} - ${response.body}',
          );
        }
      } else {
        // Streaming mode: listen to response stream (SSE)
        final request = http.Request('POST', url);
        request.headers.addAll(_headersStreaming);
        request.body = jsonEncode(body);

        final streamedResponse = await request.send();

        if (streamedResponse.statusCode != 200) {
          final respBody = await streamedResponse.stream.bytesToString();
          throw Exception(
            'API Error: ${streamedResponse.statusCode} - $respBody',
          );
        }

        final stream = streamedResponse.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter());

        String answer = '';

        await for (final line in stream) {
          if (line.startsWith('data:')) {
            final jsonLine = line.substring(5).trim();
            if (jsonLine.isNotEmpty) {
              try {
                final jsonData = jsonDecode(jsonLine);
                if (jsonData['event'] == 'agent_message' &&
                    jsonData.containsKey('answer')) {
                  answer += jsonData['answer'];
                }
              } catch (e) {
                print('Failed to decode SSE line: $jsonLine\nError: $e');
              }
            }
          }
        }

        return {'answer': answer};
      }
    } catch (e) {
      print('❌ Error sending message: $e');
      throw Exception('Failed to send message: $e');
    }
  }

  // Get conversation history
  Future<List<Map<String, dynamic>>> getConversationHistory({
    required String conversationId,

    int limit = 20,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/messages').replace(
        queryParameters: {
          'conversation_id': conversationId,
          'user': userId ?? 'default_user',
          'limit': limit.toString(),
        },
      );

      print('📤 Getting conversation history from here: $url');

      final response = await http.get(url, headers: _headersBlocking);

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error getting conversation history: $e');
      throw Exception('Failed to get conversation history: $e');
    }
  }

  // Get conversations list
  Future<List<Map<String, dynamic>>> getConversations({int limit = 20}) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/conversations',
      ).replace(queryParameters: {'user': userId, 'limit': limit.toString()});

      print('📤 Getting conversations from: $url');

      final response = await http.get(url, headers: _headersBlocking);

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data['data']);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error getting conversations: $e');
      throw Exception('Failed to get conversations: $e');
    }
  }

  Future<Map<String, dynamic>> getParameters() async {
    try {
      final url = Uri.parse('${_baseUrl}/parameters');

      final response = await http.get(url, headers: _headersBlocking);
      print('📥 Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error getting parameters: $e');
      throw Exception('Failed to get parameters: $e');
    }
  }

  Future<bool> deleteConversation({required String conversationId}) async {
    try {
      final url = Uri.parse('$_baseUrl/conversations/$conversationId');

      final response = await http.delete(
        url,
        headers: _headersBlocking,
        body: jsonEncode({'user': userId ?? 'default_user'}),
      );

      print('📥 Delete response status: ${response.statusCode}');

      return response.statusCode == 204;
    } catch (e) {
      print('❌ Error deleting conversation: $e');
      return false;
    }
  }

  // Generate a unique user ID
  String generateUserId() {
    return 'flutter_${_uuid.v4()}';
  }
}
