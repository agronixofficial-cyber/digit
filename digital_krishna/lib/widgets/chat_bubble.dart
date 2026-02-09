import 'package:flutter/material.dart';
import '../models/message.dart';
import 'circle_image.dart';
import 'shloka_card.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatelessWidget {
  final Message message;
  final Function(String)? onSpeak;
  final bool isSpeaking;

  const ChatBubble({
    super.key,
    required this.message,
    this.onSpeak,
    this.isSpeaking = false,
  });

  @override
  Widget build(BuildContext context) {
    final isKrishna = message.role == MessageRole.krishna;
    final timeStr = DateFormat('HH:mm').format(message.timestamp);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        mainAxisAlignment:
            isKrishna ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isKrishna)
            const Padding(
              padding: EdgeInsets.only(right: 8.0, bottom: 4.0),
              child: CircleImage(
                assetPath: 'assets/krishna_avatar.png',
                remoteUrl:
                    'https://images.unsplash.com/photo-1617651139622-371631c7611a?q=80&w=400&h=400&auto=format&fit=crop',
                size: 36,
                isKrishna: true,
              ),
            ),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.88,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomRight:
                      isKrishna ? const Radius.circular(16) : Radius.zero,
                  bottomLeft:
                      isKrishna ? Radius.zero : const Radius.circular(16),
                ),
                border: isKrishna
                    ? const Border(
                        left: BorderSide(color: Color(0xFFC2185B), width: 2))
                    : const Border(
                        right:
                            BorderSide(color: Color(0x33FFFFFF), width: 2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isKrishna)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "SUPREME SOUL",
                            style: TextStyle(
                              color: Color(0xFFC2185B),
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                          if (onSpeak != null)
                            GestureDetector(
                              onTap: () => onSpeak!(message.text),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSpeaking
                                      ? const Color(0xFFC2185B)
                                      : Colors.white.withValues(alpha: 0.05),
                                  border: Border.all(
                                    color: isSpeaking
                                        ? const Color(0xFFC2185B)
                                        : Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: Icon(
                                  Icons.volume_up,
                                  size: 14,
                                  color: isSpeaking
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  Text(
                    message.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  if (isKrishna &&
                      message.verses != null &&
                      message.verses!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Column(
                        children: message.verses!
                            .map((v) => ShlokaCard(verse: v))
                            .toList(),
                      ),
                    ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        timeStr,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                          fontSize: 8,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!isKrishna)
            const Padding(
              padding: EdgeInsets.only(left: 8.0, bottom: 4.0),
              child: CircleImage(
                assetPath: 'assets/user_avatar.png',
                remoteUrl:
                    'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=400&h=400&auto=format&fit=crop',
                size: 36,
              ),
            ),
        ],
      ),
    );
  }
}
