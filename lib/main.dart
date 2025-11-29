import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/themes/app_theme.dart';
import 'core/utils/audio_manager.dart';
import 'core/utils/storage_manager.dart';
import 'features/menu/presentation/pages/main_menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const ZeusApp());
}

class ZeusApp extends StatelessWidget {
  const ZeusApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZEUS - Rise of Olympus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.purple,
        fontFamily: 'Roboto',
      ),
      home: SplashScreen(),
    );
  }
}

// class ZeusGameApp extends StatelessWidget {
//   const ZeusGameApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return ScreenUtilInit(
//       designSize: const Size(375, 812),
//       minTextAdapt: true,
//       splitScreenMode: true,
//       child: MaterialApp(
//         title: 'ZEUS - Rise of Olympus',
//         debugShowCheckedModeBanner: false,
//         theme: AppTheme.darkTheme,
//         home: const SplashScreen(),
//       ),
//     );
//   }
// }

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    // Navigate to main menu after splash
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MenuScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF4B0082), const Color(0xFF1A1A1A)],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Stack(
            children: [
              // Background image with error handling
              Positioned.fill(
                child: Image.asset(
                  'assets/images/loader.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // If image fails to load, show gradient background
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFFFF8C00),
                            const Color(0xFF4B0082),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Zeus Icon (center)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Zeus lightning icon
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withOpacity(0.6),
                            blurRadius: 40,
                            spreadRadius: 15,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.flash_on,
                        size: 100,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ZEUS text
                    const Text(
                      'ZEUS',
                      style: TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,

                        color: Color(0xFFFFD700),
                        shadows: [
                          Shadow(
                            color: Color(0xFFFF8C00),
                            offset: Offset(0, 4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Rise of Olympus',
                      style: TextStyle(
                        fontSize: 24,
                        color: Color(0xFFF5F5DC),
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                ),
              ),

              // Loading indicator
              Positioned(
                bottom: 80,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    const SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        color: Color(0xFFFFD700),
                        strokeWidth: 4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'LOADING...',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFD700),
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
