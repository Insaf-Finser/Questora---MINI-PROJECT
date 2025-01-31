import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:quest/presentation/login/pages/loginpage.dart';

import '../../../../../core/config/assets/app_images.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  bool _isNameValid = false;
  bool _isUsernameValid = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background Image
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 40),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppImages.introBG),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Semi-transparent overlay
          Container(color: const Color.fromARGB(222, 0, 0, 0)),

          // Form and Content
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 60),
                  // Title
                  Text(
                    'SET PROFILE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color.fromARGB(255, 194, 172, 98),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Name TextField
                  TextField(
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: 'Name',
                      hintStyle: TextStyle(
                        color: const Color.fromARGB(255, 194, 172, 98),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 194, 172, 98),
                          width: 4,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    ),
                    style: TextStyle(
                      color: Color.fromARGB(255, 194, 172, 98),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _isNameValid = value.isNotEmpty;
                      });
                    },
                  ),
                  const SizedBox(height: 40),

                  // Username TextField
                  TextField(
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: 'Username',
                      hintStyle: TextStyle(
                        color: const Color.fromARGB(255, 194, 172, 98),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 194, 172, 98),
                          width: 2,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    ),
                    style: TextStyle(
                      color: Color.fromARGB(255, 194, 172, 98),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _isUsernameValid = value.isNotEmpty;
                      });
                    },
                  ),
                  const SizedBox(height: 40),

                  // Day, Month, Year Scrollable Picker with Titles
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Day Scroll Wheel with Title
                      _buildScrollWheelWithTitle(
                        title: 'Day',
                        items: List.generate(31, (index) => index + 1),
                        onChanged: (value) {},
                      ),
                      const SizedBox(width: 10),
                      // Month Scroll Wheel with Title
                      _buildScrollWheelWithTitle(
                        title: 'Month',
                        items: List.generate(12, (index) => index + 1),
                        onChanged: (value) {},
                      ),
                      const SizedBox(width: 10),
                      // Year Scroll Wheel with Title
                      _buildScrollWheelWithTitle(
                        title: 'Year',
                        items: List.generate(100, (index) => DateTime.now().year - index),
                        onChanged: (value) {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Back Button
                  ElevatedButton( 
                    onPressed: _isNameValid && _isUsernameValid
                        ? () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginPage()),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isNameValid && _isUsernameValid
                          ? const Color.fromARGB(255, 194, 172, 98)
                          : const Color.fromARGB(187, 228, 228, 228),
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        
                      ),
                      
                    ),
                    child: _isNameValid && _isUsernameValid
                        ? const Text('DONE', style: TextStyle(color: Colors.black))
                        : const Text('DONE', style: TextStyle(color: Color.fromARGB(255, 194, 193, 193))),
                        
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable Scroll Wheel Widget (ListWheelScrollView) with Title
  Widget _buildScrollWheelWithTitle({
    required String title,
    required List<int> items,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      children: [
        // Title
        Text(
          title,
          style: TextStyle(
            color: const Color.fromARGB(255, 194, 172, 98),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),

        // ListWheelScrollView
        SizedBox(
          width: 80,
          height: 60,
          child: ListWheelScrollView.useDelegate(
            itemExtent: 50, // Height of each item
            physics: FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) {
              onChanged(items[index]);
            },
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) {
                return Center(
                  child: Opacity(
                    opacity: 1.0, // Lower opacity for non-centered items
                    child: BackdropFilter(
                      filter: ImageFilter.blur(), // Apply blur to non-centered items
                      child: Text(
                        items[index].toString(),
                        style: TextStyle(
                          color: const Color.fromARGB(255, 194, 172, 98),
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                );
              },
              childCount: items.length,
            ),
          ),
        ),
      ],
    );
  }
}