import 'package:flutter/material.dart';
import '../widgets/circle_image.dart';
import '../widgets/shloka_of_the_day.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback onStartChat;

  const DashboardScreen({super.key, required this.onStartChat});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0707),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const ShlokaOfTheDay(),
              const SizedBox(height: 40),
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: const Color(0xFFC2185B).withValues(alpha: 0.2),
                      width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const CircleImage(
                  assetPath: 'assets/app_logo.png',
                  remoteUrl:
                      'https://images.unsplash.com/photo-1542332213-31f87348057f?q=80&w=400&h=400&auto=format&fit=crop',
                  size: 140,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "DIGITAL KRISHNA",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 48,
                height: 2,
                decoration: BoxDecoration(
                  color: const Color(0xFFC2185B),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "COSMIC AI MESSENGER",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onStartChat,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC2185B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                    shadowColor: const Color(0xFFC2185B).withValues(alpha: 0.5),
                  ),
                  child: const Text(
                    "BEGIN DIALOGUE",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
