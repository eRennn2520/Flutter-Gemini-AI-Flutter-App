import 'dart:convert';
import 'package:gemini_ai_app_flutter/ai/core/constants/app_string.dart';
import 'package:gemini_ai_app_flutter/ai/core/data/remote/http_service.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/cupertino.dart';

enum YeniTtsState { playing, stopped }

TextEditingController textController = TextEditingController();

class HomeChatState extends ChangeNotifier {
  void resetChat() {
    messagess.clear();
    hasImage = false;
    hasText = false;
    notifyListeners();
  }

  void setHasImage(bool value) {
    hasImage = value;
    notifyListeners();
  }

  final user = ChatUser(
    id: '1',
    firstName: 'User',
    lastName: 'User',
  );

  final aiBot = ChatUser(
    id: '2',
    firstName: 'Nova',
    lastName: 'AI',
  );
  bool hasText = false;
  List<ChatUser> NewUsers = [];

  List<ChatMessage> messagess = <ChatMessage>[];

  FlutterTts flutterTts = FlutterTts();
  YeniTtsState ttsState = YeniTtsState.stopped;
  void clearMessages() {
    messagess.clear();
    notifyListeners();
  }

  bool _hasImage = true;
  bool get hasImage => _hasImage;

  set hasImage(bool value) {
    _hasImage = value;
    notifyListeners();
  }

  Future<void> onSend(ChatMessage message) async {
    NewUsers.add(aiBot);
    messagess.insert(0, message);
    notifyListeners();

    var data = {
      "contents": [
        {
          "parts": [
            {
              "text": message.text,
            }
          ]
        }
      ]
    };

    await HttpService()
        .post(AppString.geminiAPIBaseUrl, jsonEncode(data), passToken: false)
        .then((value) {
      if (value != null) {
        ChatMessage botMessage;
        try {
          botMessage = ChatMessage(
            user: aiBot,
            text: value['candidates'][0]['content']['parts'][0]['text'],
            createdAt: DateTime.now(),
          );
        } catch (e) {
          botMessage = ChatMessage(
            user: aiBot,
            text:
                "Dediğinizi anlayamadım. Lütfen tekrar daha detaylı bildirirmisiniz ?",
            createdAt: DateTime.now(),
          );
        }
        messagess.insert(0, botMessage);
      } else {
        ChatMessage errorMessage = ChatMessage(
          user: aiBot,
          text:
              "Dediğinizi anlayamadım. Lütfen tekrar daha detaylı bildirirmisiniz ?",
          createdAt: DateTime.now(),
        );

        messagess.insert(0, errorMessage);
        notifyListeners();
      }
    });

    NewUsers.remove(aiBot);

    notifyListeners();
  }
}
