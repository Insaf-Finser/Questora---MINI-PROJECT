import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quest/presentation/login/pages/loginpage.dart';
import 'package:quest/presentation/start/start.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/config/assets/app_images.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  int? _selectedDay = 1;
  int? _selectedMonth = 1;
  int? _selectedYear = DateTime.now().year - 18; // Default to 18 years old
  bool _isLoading = false;
  String? _errorMessage;

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  bool get _isFormValid =>
      _nameController.text.trim().isNotEmpty &&
      _usernameController.text.trim().isNotEmpty &&
      _selectedDay != null &&
      _selectedMonth != null &&
      _selectedYear != null;

  Future<void> _saveGuestUserData() async {
    if (!_isFormValid) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final username = _usernameController.text.trim().toLowerCase();
      final name = _nameController.text.trim();
      final birthDate = DateTime(_selectedYear!, _selectedMonth!, _selectedDay!);
      final age = _calculateAge(birthDate);

      // Validate username format
      if (!RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(username)) {
        throw 'Username must be 3-20 characters (letters, numbers, _)';
      }

      // Validate age (minimum 13 years old)
      if (age < 13) {
        throw 'You must be at least 13 years old';
      }

      // Check username availability
      final doc = await _firestore.collection('guest_users').doc(username).get();
      if (doc.exists) {
        throw 'Username already taken';
      }

      // Save data with age
      await _firestore.collection('guest_users').doc(username).set({
        'name': name,
        'username': username,
        'birthDate': {
          'day': _selectedDay,
          'month': _selectedMonth,
          'year': _selectedYear,
        },
        'age': age, // Storing the calculated age
        'createdAt': FieldValue.serverTimestamp(),
        'lastActive': FieldValue.serverTimestamp(),
        'isGuest': true,
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', username);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainMenuScreen()),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 194, 172, 98)),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppImages.introBG),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: const Color.fromARGB(222, 0, 0, 0)),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(40),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 60),
                  Text(
                    'GUEST PROFILE',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 194, 172, 98),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  const SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    textAlign: TextAlign.center,
                    decoration: _buildInputDecoration('Display Name'),
                    style: _textStyle(),
                    maxLength: 30,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _usernameController,
                    textAlign: TextAlign.center,
                    decoration: _buildInputDecoration('Username'),
                    style: _textStyle(),
                    maxLength: 20,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 20),
                  _buildDatePicker(),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isFormValid && !_isLoading ? _saveGuestUserData : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isFormValid
                            ? const Color.fromARGB(255, 194, 172, 98)
                            : Colors.grey[700],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'CONTINUE AS GUEST',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: _textStyle(),
      counterStyle: _textStyle(),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color.fromARGB(255, 194, 172, 98),
          width: 2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color.fromARGB(255, 194, 172, 98),
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    );
  }

  TextStyle _textStyle() {
    return const TextStyle(
      color: Color.fromARGB(255, 194, 172, 98),
      fontSize: 16,
    );
  }

  Widget _buildDatePicker() {
    return Column(
      children: [
        const Text(
          'DATE OF BIRTH',
          style: TextStyle(
            color: Color.fromARGB(255, 194, 172, 98),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNumberPicker(
              title: 'DAY',
              minValue: 1,
              maxValue: 31,
              value: _selectedDay!,
              onChanged: (value) => setState(() => _selectedDay = value),
            ),
            const SizedBox(width: 16),
            _buildNumberPicker(
              title: 'MONTH',
              minValue: 1,
              maxValue: 12,
              value: _selectedMonth!,
              onChanged: (value) => setState(() => _selectedMonth = value),
            ),
            const SizedBox(width: 16),
            _buildNumberPicker(
              title: 'YEAR',
              minValue: 1900,
              maxValue: DateTime.now().year,
              value: _selectedYear!,
              onChanged: (value) => setState(() => _selectedYear = value),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberPicker({
    required String title,
    required int minValue,
    required int maxValue,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color.fromARGB(255, 194, 172, 98),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color.fromARGB(255, 194, 172, 98),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: NumberPicker(
            minValue: minValue,
            maxValue: maxValue,
            value: value,
            onChanged: onChanged,
            itemHeight: 40,
            textStyle: const TextStyle(
              color: Colors.grey,
              fontSize: 18,
            ),
            selectedTextStyle: const TextStyle(
              color: Color.fromARGB(255, 194, 172, 98),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class NumberPicker extends StatelessWidget {
  final int minValue;
  final int maxValue;
  final int value;
  final ValueChanged<int> onChanged;
  final double itemHeight;
  final TextStyle textStyle;
  final TextStyle selectedTextStyle;

  const NumberPicker({
    super.key,
    required this.minValue,
    required this.maxValue,
    required this.value,
    required this.onChanged,
    this.itemHeight = 40,
    this.textStyle = const TextStyle(fontSize: 18),
    this.selectedTextStyle = const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: itemHeight * 3,
      child: ListWheelScrollView.useDelegate(
        diameterRatio: 1.5,
        perspective: 0.01,
        offAxisFraction: 0,
        useMagnifier: true,
        magnification: 1.1,
        itemExtent: itemHeight,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (index) => onChanged(minValue + index),
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) {
            final number = minValue + index;
            final isSelected = number == value;
            return Center(
              child: Text(
                number.toString(),
                style: isSelected ? selectedTextStyle : textStyle,
              ),
            );
          },
          childCount: maxValue - minValue + 1,
        ),
      ),
    );
  }
}