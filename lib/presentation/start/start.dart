import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quest/presentation/game/pages/gamepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  
  // User data variables
  Map<String, dynamic>? _userData;
  bool _isLoadingUserData = true;
  String? _profileImageUrl;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserData();
  }

  void _initializeAnimations() {
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

  Future<void> _loadUserData() async {
    setState(() => _isLoadingUserData = true);
    try {
      final user = _auth.currentUser;
      final prefs = await SharedPreferences.getInstance();
      final storedUsername = prefs.getString('username');

      if (user != null) {
        // Authenticated user
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          setState(() => _userData = doc.data());
        }
      } else if (storedUsername != null) {
        // Guest user
        final doc = await _firestore.collection('guest_users').doc(storedUsername).get();
        if (doc.exists) {
          setState(() => _userData = doc.data());
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      setState(() => _isLoadingUserData = false);
    }
  }

  String _formatBirthDate() {
    if (_userData == null || _userData!['birthDate'] == null) {
      return 'Not specified';
    }
    final birthDate = _userData!['birthDate'];
    return '${birthDate['day']}/${birthDate['month']}/${birthDate['year']}';
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

  Future<void> _signOut() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final storedUsername = prefs.getString('username');
    final user = _auth.currentUser;

    // Delete guest user data if this is a guest session
    if (user == null && storedUsername != null) {
      await _firestore.collection('guest_users').doc(storedUsername).delete();
    }

    // Clear local storage
    await prefs.remove('username');
    if (user != null) {
      await _auth.signOut();
    }

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logout failed: ${e.toString()}')),
    );
  }
}

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                _buildMenuButton('START', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CharacterCreationPage()),
                  );
                }),
                _buildMenuButton('OPTIONS', () {}),
                _buildMenuButton('LOAD GAME', () async {
                  final loadedGameData = await Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => LoadGameScreen(
      isFromGamePage: false,
    ),
  ),
);

if (loadedGameData != null) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => GamePage(
        characterName: loadedGameData['characterName'],
        characterDescription: loadedGameData['characterDescription'],
        genre: loadedGameData['genre'],
        gender: loadedGameData['gender'],
        playTime: loadedGameData['playTime'] ?? 30, // Default if not saved
        age: loadedGameData['age'] ?? 18, // Default if not saved
        // Initialize with loaded story data
      ),
    ),
  );
}
                }),
                _buildMenuButton('QUIT GAME', () {
                  SystemNavigator.pop();
                }),
              ],
            ),
          ),

          // Profile Button and Details
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
                      child: _isLoadingUserData
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                ),

                // Profile Details Card
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
                          child: _isLoadingUserData
                              ? const Center(child: CircularProgressIndicator())
                              : Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircleAvatar(
                                      radius: 40,
                                      backgroundImage: _profileImageUrl != null
                                          ? NetworkImage(_profileImageUrl!)
                                          : const AssetImage('assets/images/default_profile.png')
                                              as ImageProvider,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _userData?['username'] ?? 'Guest',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _userData?['name'] ?? 'No name provided',
                                      style: const TextStyle(color: Colors.white70),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Age: ${_userData?['age'] ?? 'N/A'}',
                                      style: const TextStyle(color: Colors.white70),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Birth Date: ${_formatBirthDate()}',
                                      style: const TextStyle(color: Colors.white70),
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        minimumSize: const Size(double.infinity, 50),
                                      ),
                                      onPressed: _signOut,
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

  Widget _buildMenuButton(String text, VoidCallback onPressed) {
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