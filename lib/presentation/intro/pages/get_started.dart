import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quest/core/config/theme/app_colors.dart';
import 'package:quest/presentation/login/pages/loginpage.dart';
import 'package:quest/presentation/start/start.dart';
import '../../../core/config/assets/app_images.dart';
import '../../../core/config/assets/app_vectors.dart';

class GetStartedPage extends StatefulWidget {
  const GetStartedPage({super.key});

  @override
  GetStartedPageState createState() => GetStartedPageState();
}

class GetStartedPageState extends State<GetStartedPage> {
  bool _isTaped = false;
  double _scale = 1.0;
  FirebaseAuth auth = FirebaseAuth.instance;
  bool _showLoadingScreen = false;

  Future<void> _onTap() async {
    if (_isTaped) return;

    setState(() {
      _isTaped = true;
      _scale = 0.7;
    });

    // Check auth status when button is pressed
    final prefs = await SharedPreferences.getInstance();
    final storedUsername = prefs.getString('username');
    final user = auth.currentUser;

    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      setState(() {
        _scale = 1.0;
        _showLoadingScreen = true;
      });

      // Show loading for 5 seconds if logged in
      if (user != null || storedUsername != null) {
        await Future.delayed(const Duration(seconds: 5));
        if (mounted) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const MainMenuScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          );
        }
      } else {
        // No delay for new users
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showLoadingScreen) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppImages.introBG),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                
                const SizedBox(height: 40),
                const CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 6,
                ),
                const SizedBox(height: 20),
                Text(
                  'Loading your adventure...',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 18,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold( 
      body: Stack( 
        alignment: Alignment.center,
        children: [ 
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppImages.introBG),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.15)),

          Column(
            children: [
              const SizedBox(height: 95),
              SvgPicture.asset(AppVectors.logolight, height: 90),
              const Spacer(),

              TweenAnimationBuilder(
                duration: const Duration(milliseconds: 500),
                tween: Tween<double>(begin: 1.0, end: _scale),
                builder: (context, double scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: InkWell(
                      onTap: _onTap,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        height: 65,
                        width: 65,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: _isTaped ? Border.all(color: const Color.fromARGB(0, 173, 154, 92), width: 1) : Border.all(color: AppColors.primary, width: 3),
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(0, -4),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: _isTaped
                            ? CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 3,
                              )
                            : AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                height: 52,
                                width: 52,
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  border: _isTaped ? Border.all(color: const Color.fromARGB(0, 173, 154, 92), width: 1) : Border.all(color: AppColors.primary, width: 5),
                                  borderRadius: BorderRadius.circular(32),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      offset: const Offset(0, -4),
                                      blurRadius: 20,
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: null,
                              ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 6),
              Text(
                'begin',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontFamily: 'Aladin-Regular',
                  fontSize: 32,
                  letterSpacing: 7,
                ),
              ),
              const SizedBox(height: 62),
            ],
          ),
        ],
      ),
    );
  }
}