import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/dashboard_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Error loading .env file: $e");
    // Handle missing env file if necessary
  }
  runApp(const DigitalKrishnaApp());
}

class DigitalKrishnaApp extends StatefulWidget {
  const DigitalKrishnaApp({super.key});

  @override
  State<DigitalKrishnaApp> createState() => _DigitalKrishnaAppState();
}

class _DigitalKrishnaAppState extends State<DigitalKrishnaApp> {
  // Simple navigation state
  bool _showSplash = true;
  bool _isChatView = false;

  void _onSplashFinished() {
    setState(() {
      _showSplash = false;
    });
  }

  void _navigateToChat() {
    setState(() {
      _isChatView = true;
    });
  }

  void _navigateToDashboard() {
    setState(() {
      _isChatView = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Krishna',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: const Color(0xFF0A0707),
        useMaterial3: true,
        textTheme: GoogleFonts.muktaTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      home: _showSplash
          ? SplashScreen(onFinished: _onSplashFinished)
          : (_isChatView
              ? ChatScreen(onBack: _navigateToDashboard)
              : DashboardScreen(onStartChat: _navigateToChat)),
    );
  }
}
