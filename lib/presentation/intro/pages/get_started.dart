// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  void _onTap() {
    setState(() {
      _isTaped = true;
      _scale = 0.7; // Shrink the button before expanding
    });

    

    if (auth.currentUser != null) {
      Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const MainMenuScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation, // Fade effect
          child: child,
        );
        },
      ),
      );
    } else {
      Future.delayed(const Duration(milliseconds: 400), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
          opacity: animation, // Fade effect
          child: child,
          );
        },
        ),
      );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration (milliseconds: 800), () {});
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

              // Shrinking and morphing button into a large box
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
                        height:65,
                        width:65,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: _isTaped ? Border.all(color: const Color.fromARGB(0, 173, 154, 92), width: 1) :Border.all(color: AppColors.primary, width: 3),
                          borderRadius: BorderRadius.circular(32), // Optional: rounded corners
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(0, -4),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          height: 52,
                          width: 52,
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: _isTaped ? Border.all(color: const Color.fromARGB(0, 173, 154, 92), width: 1) :Border.all(color: AppColors.primary, width: 5),
                            borderRadius: BorderRadius.circular(32), // Optional: rounded corners
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                offset: const Offset(0, -4),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child:  null, 
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
