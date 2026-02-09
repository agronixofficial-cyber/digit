import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/verse.dart';

class ShlokaCard extends StatefulWidget {
  final Verse verse;

  const ShlokaCard({super.key, required this.verse});

  @override
  State<ShlokaCard> createState() => _ShlokaCardState();
}

class _ShlokaCardState extends State<ShlokaCard>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  bool _copied = false;

  void _handleCopy() {
    final textToCopy =
        "Gita ${widget.verse.chapter}.${widget.verse.verse}\n\n${widget.verse.text}\n\nTranslation: ${widget.verse.translation}";
    Clipboard.setData(ClipboardData(text: textToCopy));
    setState(() {
      _copied = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _copied = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: const Color(0xFFC2185B).withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isOpen = !_isOpen;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFC2185B),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "GITA ${widget.verse.chapter}.${widget.verse.verse}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  AnimatedRotation(
                    turns: _isOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white.withValues(alpha: 0.4),
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isOpen
                ? Container(
                    width: double.infinity,
                    color: Colors.black.withValues(alpha: 0.3),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 12),
                          decoration: const BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: Color(0xFFC2185B),
                                width: 2,
                              ),
                            ),
                          ),
                          child: Text(
                            widget.verse.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            widget.verse.translation,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: _handleCopy,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _copied
                                    ? const Color(0xFFC2185B)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: _copied
                                      ? const Color(0xFFC2185B)
                                      : Colors.white.withValues(alpha: 0.2),
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _copied ? "COPIED" : "SHARE",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
