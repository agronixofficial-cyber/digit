import 'package:flutter/material.dart';

class CircleImage extends StatelessWidget {
  final String assetPath;
  final String? remoteUrl;
  final double size;
  final bool isKrishna;

  const CircleImage({
    super.key,
    required this.assetPath,
    this.remoteUrl,
    this.size = 40,
    this.isKrishna = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        gradient: LinearGradient(
          colors: isKrishna
              ? [const Color(0xFFC2185B), const Color(0xFF4A148C)]
              : [const Color(0xFF455A64), const Color(0xFF263238)],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
      child: ClipOval(
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            if (remoteUrl != null) {
              return Image.network(
                remoteUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      isKrishna ? "ॐ" : "U",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              );
            }
            return Center(
              child: Text(
                isKrishna ? "ॐ" : "U",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
