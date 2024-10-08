import 'dart:async';
import 'dart:io';
import 'package:gemini_ai_app_flutter/ai/state/standart_ai_state.dart';
import 'package:gemini_ai_app_flutter/ai/ui/sound_ui/sound_ai_screen.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:google_fonts/google_fonts.dart';

class CoffeeAiScreen extends StatefulWidget {
  const CoffeeAiScreen({Key? key}) : super(key: key);

  @override
  State<CoffeeAiScreen> createState() => _CoffeeAiScreenState();
}

class _CoffeeAiScreenState extends State<CoffeeAiScreen> {
  bool _isLoading = true;
  bool _hasPlayedAnimation = false;
 
  

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
        _hasPlayedAnimation = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context);
    var screenWidth = screenSize.size.width;
    var screenHeight = screenSize.size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        title: Text(
          "Nova AI",
          style: GoogleFonts.aDLaMDisplay(
              color: Colors.black, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        
        actions: [
          IconButton(
            icon: Icon(
              EvaIcons.refresh,
              color: Colors.grey.shade400,
            ),
            onPressed: () {
              FocusScope.of(context).unfocus();
              Provider.of<HomeChatState>(context, listen: false).resetChat();
            },
            iconSize: 25,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : Consumer<HomeChatState>(
              builder: (context, state, child) {
                return Stack(
                  children: [
                    // if (state.messagess.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                      alignment: Alignment.bottomLeft,
                                      child:
                                          Image.asset("lib/assets/g670.png")),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.bottomRight,
                                    child: Image.asset("lib/assets/star.png"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                      alignment: Alignment.bottomLeft,
                                      child: Image.asset(
                                          "lib/assets/path746.png")),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    DashChat(
                      inputOptions: InputOptions(
                        sendButtonBuilder: (user) {
                          return IconButton(
                            icon: const Icon(EvaIcons.paperPlane,
                                color: Colors.black),
                            onPressed: () async {
                              setState(() {
                                _hasPlayedAnimation = false;
                              });
                              if (textController.text.isNotEmpty) {
                                ChatMessage message = ChatMessage(
                                  text: textController.text,
                                  user: state.user,
                                  createdAt: DateTime.now(),
                                );
                                Provider.of<HomeChatState>(context,
                                        listen: false)
                                    .onSend(message);
                                textController.clear();
                              }
                            },
                          );
                        },
                        leading: [
                        
                            IconButton(
                              icon: const Icon(EvaIcons.phone, color: Colors.black),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ErenAiScreenPerson(),
                                  ),
                                );
                              },
                            ),
                        ],
                        trailing: [],
                        textController: textController,
                        inputDecoration: const InputDecoration(
                          hintText: 'Mesajınızı buraya yazın...',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        inputToolbarPadding: const EdgeInsets.all(9),
                        inputToolbarMargin: const EdgeInsets.all(8),
                        inputToolbarStyle: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade100,
                            width: 1.0,
                          ),
                          color: Colors.grey.shade100,
                        ),
                      ),
                      typingUsers: state.NewUsers,
                      currentUser: state.user,
                      onSend: (messages) {
                        state.onSend(messages as ChatMessage);
                        state.hasText = true;
                        state.hasImage = false;
                      },
                      messages: state.messagess,
                      messageOptions: MessageOptions(
                        messageTextBuilder:
                            (message, previousMessage, nextMessage) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              message.text,
                              style: GoogleFonts.aDLaMDisplay(
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          );
                        },
                        timeTextColor: Colors.black,
                        currentUserTextColor: Colors.black,
                        containerColor: Colors.white,
                        textBeforeMedia: true,
                        showTime: true,
                        messageDecorationBuilder:
                            (message, previousMessage, nextMessage) {
                          return BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(0.2), // Gölge rengi
                                spreadRadius: 1, // Gölgenin yayılma mesafesi
                                blurRadius: 4, // Gölgenin bulanıklık mesafesi
                                offset: const Offset(0, 2), // Gölgenin kayma mesafesi
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
