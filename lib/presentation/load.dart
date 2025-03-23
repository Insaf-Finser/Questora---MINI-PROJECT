import 'package:flutter/material.dart';

class LoadGameScreen extends StatelessWidget {
  const LoadGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/im.png',  
              fit: BoxFit.cover,      
            ),
          ),
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'LOAD GAME',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2.0,
                  ),
                ),
                SizedBox(height: 20),
                buildSlotButton('SLOT IS EMPTY'),
                buildSlotButton('SLOT IS EMPTY'),
                buildSlotButton('SLOT IS EMPTY'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSlotButton(String text) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      width: 250,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(10),
        color: Colors.transparent,
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
