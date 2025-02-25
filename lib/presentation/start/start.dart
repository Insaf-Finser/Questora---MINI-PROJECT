import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:quest/presentation/chardescpage/pages/chardescpage.dart';
import 'package:quest/presentation/load.dart'; 

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/fir.png',  // Main Menu Background
              fit: BoxFit.cover,
            ),
          ),
          // Buttons & Title
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
                SizedBox(height: 50),
                buildMenuButton('START', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CharacterCreationPage()),
                  );
                }),
                buildMenuButton('OPTIONS', () {}),
                buildMenuButton('LOAD GAME', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoadGameScreen()),
                  );
                }),
                buildMenuButton('QUIT GAME', () {
                  SystemNavigator.pop();
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Custom Button Widget
  Widget buildMenuButton(String text, VoidCallback onPressed) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
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
          style: TextStyle(
            color: const Color.fromARGB(255, 244, 244, 240),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
