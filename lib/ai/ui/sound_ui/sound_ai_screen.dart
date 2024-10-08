import 'dart:async';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:gemini_ai_app_flutter/ai/state/sound_ai_state.dart';

class ErenAiScreenPerson extends StatefulWidget {
  @override
  _ErenAiScreenPersonState createState() => _ErenAiScreenPersonState();
}

class _ErenAiScreenPersonState extends State<ErenAiScreenPerson>
    with TickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  String _text = '';
  bool _isListening = false;
  int _remainingSeconds = 6;
  bool _isCountingDown = false;
  Timer? _timer;
  int _seconds = 0;

  late AnimationController _animationControllerClock;
  late AnimationController _animationControllerRefresh;
  late Animation<double> _rotationAnimationClock;
  late Animation<double> _rotationAnimationRefresh;
  bool _isLoading = true;
  bool _hasPlayedAnimation = false;

  void _performClockAnimation() {
    setState(() {
      _remainingSeconds = 2;
    });
    _animationControllerClock.forward();
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
        _hasPlayedAnimation = true;
      });
    });
    _startTimer();

    _animationControllerClock = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationControllerClock.reset();
        }
      });

    _animationControllerRefresh = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationControllerRefresh.reset();
        }
      });

    _rotationAnimationClock =
        Tween<double>(begin: 0, end: 2 * 3.141592653589793).animate(
      CurvedAnimation(
          parent: _animationControllerClock, curve: Curves.easeInOut),
    );

    _rotationAnimationRefresh =
        Tween<double>(begin: 0, end: 2 * 3.141592653589793).animate(
      CurvedAnimation(
          parent: _animationControllerRefresh, curve: Curves.easeInOut),
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _seconds = 0;
    });
    _startTimer();
  }

  String _formatDuration(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationControllerClock.dispose();
    _animationControllerRefresh.dispose();
    super.dispose();
  }

  void _performRefreshAnimation() {
    _animationControllerRefresh.forward();
  }

  void _startListening(SpeakStateAI state) async {
    bool available = await _speech.initialize();

    if (available) {
      setState(() {
        _isListening = true;
        _isCountingDown = true;
        _remainingSeconds = 7;
      });

      Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _remainingSeconds--;
        });

        if (_remainingSeconds <= 0) {
          timer.cancel();
          _stopListening(state);
        }
      });

      _speech.listen(
        onResult: (result) => _onSpeechResult(result, state),
      );
    }
  }

  void _stopListening(SpeakStateAI state) {
    _speech.stop();
    setState(() {
      _isListening = false;
      _isCountingDown = false;
    });
    if (_text.isNotEmpty) {
      state.onSend(
        ChatMessage(
          text: _text,
          user: state.user,
          createdAt: DateTime.now(),
        ),
      );
      setState(() => _text = '');
    }
  }

  void _onSpeechResult(result, SpeakStateAI state) {
    setState(() => _text = result.recognizedWords);
    if (result.finalResult) {
      state.onSend(
        ChatMessage(
          text: _text,
          user: state.user,
          createdAt: DateTime.now(),
        ),
      );
      setState(() => _text = '');
    }
  }

  Future<void> _speak(String text) async {
    await _flutterTts.setLanguage("tr-TR");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }

  String? _imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(69),
        child: CustomAppBar(),
      ),
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : Consumer<SpeakStateAI>(builder: (context, state, child) {
              return Stack(
                children: [
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
                                  child: Image.asset("lib/assets/g670.png"),
                                ),
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
                                  child: Image.asset("lib/assets/path746.png"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GestureDetector(
                        onTap: () {
                          if (state is SpeakStateAI) {
                            _startListening(state);
                          }
                        },
                        child: Visibility(
                          visible: !_isListening,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                EvaIcons.mic,
                                color: Colors.black,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: _performClockAnimation,
                            child: AnimatedBuilder(
                              animation: _rotationAnimationClock,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _rotationAnimationClock.value,
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          spreadRadius: 2,
                                          blurRadius: 2,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        EvaIcons.clock,
                                        color: Colors.black,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () {
                              state.stop();
                              _performRefreshAnimation();
                            },
                            child: AnimatedBuilder(
                              animation: _rotationAnimationRefresh,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _rotationAnimationRefresh.value,
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          spreadRadius: 2,
                                          blurRadius: 2,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        EvaIcons.refresh,
                                        color: Colors.black,
                                        size: 24,
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
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Visibility(
                        visible: _isListening,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _remainingSeconds.toString(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
    );
  }
}

class CustomAppBar extends StatefulWidget {
  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context);
    var screenWidth = screenSize.size.width;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_outlined,
                  color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
