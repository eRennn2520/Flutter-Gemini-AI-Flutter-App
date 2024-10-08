import 'dart:convert';
import 'package:gemini_ai_app_flutter/ai/core/constants/app_string.dart';
import 'package:gemini_ai_app_flutter/ai/core/data/remote/http_service.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';

// SESLİ AI
class SpeakStateAI extends ChangeNotifier {
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

  List<ChatMessage> messages = <ChatMessage>[];

  bool _isSpeaking = false;
  bool get isSpeaking => _isSpeaking;

  FlutterTts flutterTts = FlutterTts();
  void stop() async {
    await _flutterTts.stop();
  }

  Future<void> onSend(ChatMessage message) async {
    messages.insert(0, message);
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
          speakAndAnimate(botMessage.text);
        } catch (e) {
          botMessage = ChatMessage(
            user: aiBot,
            text: "Dediğinizi anlayamadım. Lütfen tekrar söylermisiniz",
            createdAt: DateTime.now(),
          );
          speakAndAnimate(botMessage.text);
        }
        messages.insert(0, botMessage);
      } else {
        ChatMessage errorMessage = ChatMessage(
          user: aiBot,
          text: "Dediğinizi anlayamadım. Lütfen tekrar söylermisiniz",
          createdAt: DateTime.now(),
        );
        speakAndAnimate(errorMessage.text);
        messages.insert(0, errorMessage);
        notifyListeners();
      }
    });

    notifyListeners();
  }

  final FlutterTts _flutterTts = FlutterTts();

  Future<void> speakAndAnimate(String text) async {
    await _flutterTts.setLanguage("tr-TR");
    await _flutterTts
        .setVoice({"name": "tr-tr-x-kda#male_1-local", "locale": "tr-TR"});
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }

  void _startSpeaking() {
    _isSpeaking = true;
    notifyListeners();
  }

  void _stopSpeaking() {
    _isSpeaking = false;
    notifyListeners();
  }
}