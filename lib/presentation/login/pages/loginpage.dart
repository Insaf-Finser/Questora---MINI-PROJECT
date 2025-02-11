// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quest/core/config/assets/app_images.dart';
import 'package:quest/core/config/assets/app_vectors.dart';
import 'package:quest/presentation/chardescpage/pages/chardescpage.dart';
import 'package:quest/presentation/info/pages/infopage.dart';
import 'package:quest/services/auth/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppImages.introBG),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Black overlay for dim effect
          Container(color: Colors.black.withOpacity(0.5)),

          // Scrollable content
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        const SizedBox(height: 50),
                        SvgPicture.asset(AppVectors.logodark, alignment: Alignment.center),
                        const SizedBox(height: 40),

                        // Login Container
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                                color: const Color.fromARGB(255, 194, 172, 98), width: 5),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 248, 244, 234).withOpacity(0.6),
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(
                                  color: const Color.fromARGB(255, 189, 167, 97), width: 5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                const Text(
                                  'LOGIN',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontFamily: 'Smooch',
                                    letterSpacing: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                _buildLoginButton(
                                  icon: AppVectors.man,
                                  text: "CONNECT AS GUEST",
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                        context, MaterialPageRoute(builder: (context) => const InfoPage(text :'Guest')));
                                  },
                                ),
                                _buildLoginButton(
                                  icon: AppVectors.google1,
                                  text: "CONNECT WITH GOOGLE",
                                  onPressed: () async {
                                    

                                      String? userName = await AuthServices().signInWithGoogle();

                                      if (userName != null) {
                                        SharedPreferences prefs = await SharedPreferences.getInstance();
                                        bool hasLoggedInBefore = prefs.getBool('hasLoggedInBefore') ?? false;

                                        // Navigate with userName
                                        if (!hasLoggedInBefore) {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(builder: (context) => InfoPage(text: userName)),
                                          );
                                        } else {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(builder: (context) => const CharacterCreationPage()), // Adjust as needed
                                          );
                                        }
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Google Sign-In Failed")),
                                        );
                                      }
                                    
                                    
                                  },
                                ),

                                _buildLoginButton(
                                  icon: AppVectors.x,
                                  text: "CONNECT WITH TWITTER",
                                  onPressed: () {},
                                ),
                                _buildLoginButton(
                                  icon: AppVectors.facebook,
                                  text: "CONNECT WITH FACEBOOK",
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Reusable Login Button Widget
  Widget _buildLoginButton({required String icon, required String text, required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(60),
          backgroundColor: const Color.fromARGB(220, 255, 254, 248),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color.fromARGB(255, 142, 142, 142), width: 2),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          children: [
            SvgPicture.asset(icon, alignment: Alignment.center, height: 35, width: 35),
            const SizedBox(width: 16),
            Text(
              text,
              style: const TextStyle(
                color: Color.fromARGB(255, 122, 122, 121),
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
