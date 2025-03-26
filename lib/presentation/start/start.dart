import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quest/core/config/assets/app_images.dart';
import 'package:quest/presentation/chardescpage/pages/chardescpage.dart';
import 'package:quest/presentation/load.dart';
import 'package:quest/presentation/login/pages/loginpage.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> 
    with SingleTickerProviderStateMixin {
  bool _showProfileDetails = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _positionAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutBack,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _positionAnimation = Tween<Offset>(
      begin: const Offset(1.0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleProfile() {
    setState(() {
      _showProfileDetails = !_showProfileDetails;
      if (_showProfileDetails) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              AppImages.mainBG,
              fit: BoxFit.cover,
            ),
          ),

          // Main Menu Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'QUESTORA',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 240, 240, 222),
                    fontFamily: 'Serif',
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 50),
                buildMenuButton('START', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CharacterCreationPage()),
                  );
                }),
                buildMenuButton('OPTIONS', () {}),
                buildMenuButton('LOAD GAME', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoadGameScreen()),
                  );
                }),
                buildMenuButton('QUIT GAME', () {
                  SystemNavigator.pop();
                }),
              ],
            ),
          ),

          // Profile Button - Top Right Corner
          Positioned(
            top: 40,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Profile Button
                GestureDetector(
                  onTap: _toggleProfile,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    transform: Matrix4.identity()
                      ..scale(_showProfileDetails ? 1.2 : 1.0),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                ),

                // Profile Popup
                if (_showProfileDetails)
                  SlideTransition(
                    position: _positionAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: FadeTransition(
                        opacity: _opacityAnimation,
                        child: Container(
                          margin: const EdgeInsets.only(top: 20),
                          width: 250,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[900]!.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.yellow),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircleAvatar(
                                radius: 40,
                                backgroundImage: AssetImage('assets/images/default_profile.png'),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Username',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'user@example.com',
                                style: TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                onPressed: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) => const LoginPage()),
                                    (Route<dynamic> route) => false,
                                  );
                                },
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                        ),
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

  Widget buildMenuButton(String text, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: 220,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.yellow),
        borderRadius: BorderRadius.circular(10),
        color: Colors.transparent,
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            color: Color.fromARGB(255, 244, 244, 240),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}