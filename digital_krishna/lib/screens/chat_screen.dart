import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../models/message.dart';
import '../services/gemini_service.dart';
import '../services/gita_search_service.dart';
import '../services/tts_service.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/circle_image.dart';

class ChatScreen extends StatefulWidget {
  final VoidCallback onBack;

  const ChatScreen({super.key, required this.onBack});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final TtsService _ttsService = TtsService();
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isLoading = false;
  bool _isMuted = false;
  bool _isListening = false;
  String? _speakingText;
  Timer? _silenceTimer;

  @override
  void dispose() {
    _silenceTimer?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    _ttsService.stop();
    _speech.stop();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isLoading) return;

    _textController.clear();
    setState(() {
      _messages.add(Message(
        id: const Uuid().v4(),
        role: MessageRole.user,
        text: text,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final relevantVerses = GitaSearchService.findRelevantVerses(text);
      final responseText = await GeminiService.getKrishnaResponse(
        text,
        relevantVerses,
        false,
      );

      setState(() {
        _messages.add(Message(
          id: const Uuid().v4(),
          role: MessageRole.krishna,
          text: responseText,
          timestamp: DateTime.now(),
          verses: relevantVerses,
        ));
        _isLoading = false;
      });
      _scrollToBottom();

      if (!_isMuted) {
        _handleSpeak(responseText);
      }
    } catch (e) {
      setState(() {
        _messages.add(Message(
          id: const Uuid().v4(),
          role: MessageRole.krishna,
          text: "The divine flow is temporarily paused, Arjun. Ask again.",
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  Future<void> _handleSpeak(String text) async {
    setState(() {
      _speakingText = text;
    });
    await _ttsService.speak(text);
    setState(() {
      _speakingText = null;
    });
  }

  void _listen() async {
    if (!_isListening) {
      // Check for supported platforms (Windows and Linux are generally not supported by speech_to_text out of the box)
      if (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.windows ||
              defaultTargetPlatform == TargetPlatform.linux)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Voice input is not supported on this platform.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        bool available = await _speech.initialize(
          onStatus: (val) {
            debugPrint('STT Status: $val');
            if (val == 'done' || val == 'notListening') {
              if (mounted) setState(() => _isListening = false);
            }
          },
          onError: (val) {
            debugPrint('STT Error: $val');
            if (mounted) setState(() => _isListening = false);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Microphone Error: ${val.errorMsg}')),
              );
            }
          },
        );
        if (available) {
          if (mounted) setState(() => _isListening = true);
          _speech.listen(
            onResult: (val) {
              if (mounted) {
                setState(() {
                  _textController.text = val.recognizedWords;
                });

                // Reset silence timer
                _silenceTimer?.cancel();
                _silenceTimer = Timer(const Duration(seconds: 2), () {
                  if (mounted && _isListening && _textController.text.isNotEmpty) {
                    _handleSend();
                    setState(() => _isListening = false);
                    _speech.stop();
                  }
                });

                if (val.finalResult) {
                  _silenceTimer?.cancel();
                  _handleSend();
                  setState(() => _isListening = false);
                }
              }
            },
          );
        } else {
          debugPrint('STT not available');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Speech recognition not available')),
            );
          }
        }
      } on MissingPluginException {
        // This specific error happens when the native plugin code is not found,
        // usually because the app needs a full restart (not just hot reload)
        // or the platform is not supported.
        debugPrint('STT MissingPluginException: Plugin not found.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Voice initialization failed. Please restart the app completely.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        debugPrint('STT Exception: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error initializing speech: $e')),
          );
        }
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0707),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.9),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: widget.onBack,
                        icon: const Icon(Icons.arrow_back, color: Colors.white70),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 12),
                      const CircleImage(
                        assetPath: 'assets/krishna_avatar.png',
                        remoteUrl:
                            'https://images.unsplash.com/photo-1617651139622-371631c7611a?q=80&w=400&h=400&auto=format&fit=crop',
                        size: 36,
                        isKrishna: true,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Digital Krishna",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            "UNIVERSAL WISDOM",
                            style: TextStyle(
                              color: const Color(0xFFC2185B),
                              fontSize: 7,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isMuted = !_isMuted;
                        if (_isMuted) {
                          _ttsService.stop();
                          _speakingText = null;
                        }
                      });
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isMuted
                            ? Colors.white.withValues(alpha: 0.1)
                            : const Color(0xFFC2185B),
                        border: Border.all(
                          color: _isMuted
                              ? Colors.white.withValues(alpha: 0.2)
                              : const Color(0xFFC2185B),
                        ),
                      ),
                      child: Icon(
                        _isMuted ? Icons.volume_off : Icons.volume_up,
                        size: 16,
                        color: _isMuted ? Colors.white54 : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Chat Area
            Expanded(
              child: Stack(
                children: [
                  if (_messages.isEmpty)
                    const Center(
                      child: Text(
                        '"Fear not, for I am with thee."',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 20,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFFC2185B)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      final message = _messages[index];
                      return ChatBubble(
                        message: message,
                        onSpeak: message.role == MessageRole.krishna
                            ? _handleSpeak
                            : null,
                        isSpeaking: _speakingText == message.text,
                      );
                    },
                  ),
                ],
              ),
            ),

            // Input Area
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black,
                    Colors.black.withValues(alpha: 0.9),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: _isListening 
                                    ? const Color(0xFFC2185B).withValues(alpha: 0.2) 
                                    : Colors.white.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: _listen,
                                tooltip: 'Voice Search',
                                icon: Icon(
                                  Icons.mic,
                                  color: _isListening
                                      ? const Color(0xFFC2185B)
                                      : Colors.white,
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _textController,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  hintText: "Thy dialogue...",
                                  hintStyle: TextStyle(color: Colors.white24),
                                  border: InputBorder.none,
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 0),
                                ),
                                onSubmitted: (_) => _handleSend(),
                              ),
                            ),
                            IconButton(
                              onPressed: _handleSend,
                              icon: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFC2185B),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.arrow_upward,
                                    size: 16, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
