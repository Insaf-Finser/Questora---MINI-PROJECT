import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quest/core/config/assets/app_images.dart';
import 'package:quest/core/config/assets/app_vectors.dart';
import 'package:quest/presentation/info/pages/infopage.dart';
import 'package:quest/presentation/start/start.dart';
import 'package:quest/services/auth/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ... other imports ...

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Future<void> _handleLogin(BuildContext context, bool isGuest) async {
  try {
    if (isGuest) {
      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => InfoPage(),
        ),
      );
      return;
    }

    final authResult = await AuthServices().signInWithGoogle();
    if (!authResult.status) {
      if (context.mounted) {
        _showError(context, authResult.error ?? "Google Sign-In Failed");
      }
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final userId = authResult.user?.uid ?? "guest";
    final isFirstLogin = !(prefs.getBool('${userId}_hasLoggedInBefore') ?? false) ;

    if (isFirstLogin) {
      await prefs.setBool('${userId}_hasLoggedInBefore', true);
    }

    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => isFirstLogin
            ? InfoPage()
            : const MainMenuScreen(),
      ),
    );
  } catch (e) {
    if (context.mounted) {
      _showError(context, "An error occurred. Please try again.");
    }
  }
}

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with overlay
          _buildBackground(),
          
          // Main content
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 50),
                      _buildLogo(),
                      const SizedBox(height: 40),
                      _buildLoginCard(context),
                      const SizedBox(height: 50),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() => Stack(
    children: [
      Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.introBG),
            fit: BoxFit.cover,
          ),
        ),
      ),
      Container(color: Colors.black.withAlpha(128)), // Replaced deprecated withOpacity
    ],
  );

  Widget _buildLogo() => SvgPicture.asset(
    AppVectors.logodark,
    alignment: Alignment.center,
    height: 120, // Consider fixed height for consistency
  );

  Widget _buildLoginCard(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white.withAlpha(204), // Replaced deprecated withOpacity
      borderRadius: BorderRadius.circular(50),
      border: Border.all(
        color: const Color.fromARGB(255, 194, 172, 98),
        width: 5,
      ),
    ),
    child: Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color.fromARGB(153, 248, 244, 234), // Replaced deprecated withOpacity
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: const Color.fromARGB(255, 189, 167, 97),
          width: 5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          _buildLoginTitle(),
          const SizedBox(height: 20),
          _buildLoginButtons(context),
        ],
      ),
    ),
  );

  Widget _buildLoginTitle() => const Text(
    'LOGIN',
    style: TextStyle(
      fontSize: 40,
      fontFamily: 'Smooch',
      letterSpacing: 9,
      fontWeight: FontWeight.bold,
    ),
  );

  Widget _buildLoginButtons(BuildContext context) => Column(
    children: [
      _buildLoginButton(
        icon: AppVectors.man,
        text: "CONNECT AS GUEST",
        onPressed: () => _handleLogin(context,true), // Ensure context is passed correctly
      ),
      _buildLoginButton(
        icon: AppVectors.google1,
        text: "CONNECT WITH GOOGLE",
        onPressed: () => _handleLogin(context, false), // Ensure context is passed correctly
      ),
      _buildLoginButton(
        icon: AppVectors.x,

        text: "CONNECT WITH TWITTER",
        onPressed: () {
          // Implement Twitter login functionality here
        },
      ),
      _buildLoginButton(
        icon: AppVectors.facebook,
        onPressed: () {
          // Implement Facebook login functionality here
        },
        text: "CONNECT WITH FACEBOOK",
        // TODO: Implement Facebook login
      ),
    ],
  );

  Widget _buildLoginButton({
    required String icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(60),
          backgroundColor: const Color.fromARGB(220, 255, 254, 248),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(
              color: Color.fromARGB(255, 142, 142, 142),
              width: 2,
            ),
          ),
          elevation: 2,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              icon,
              height: 35,
              width: 35,
            ),
            const SizedBox(width: 16),
            Flexible(
              child: Text(
                text,
                style: const TextStyle(
                  color: Color.fromARGB(255, 122, 122, 121),
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                softWrap: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}