import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quest/core/config/assets/app_images.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class LoadGameScreen extends StatefulWidget {
  final bool isFromGamePage;
  final Map<String, dynamic>? currentGameData;
  
  const LoadGameScreen({
    super.key,
    required this.isFromGamePage,
    this.currentGameData,
  });

  @override
  State<LoadGameScreen> createState() => _LoadGameScreenState();
}

class _LoadGameScreenState extends State<LoadGameScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> savedGames = [];
  bool isLoading = true;
  bool isGuest = false;

  Future<void> fetchDataFromDatabase() async {
    try {
      final collection = _firestore
          .collection('guest_useras')
          .doc(_userId);

      final snapshot = await collection.get();

      isGuest = snapshot.data()?['isGuest'] ?? false;
    } catch (e) {
      print('Error fetching data: $e');
    }
  }
  String? _userId;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    final user = _auth.currentUser;
    final prefs = await SharedPreferences.getInstance();
    
    if (user == null) {
      isGuest = true;
      _userId = prefs.getString('username');
      
      if (_userId == null) {
        _userId = 'guest_${DateTime.now().millisecondsSinceEpoch}';
        await prefs.setString('username', _userId!);
      }
    } else {
      _userId = user.uid;
    }
    _loadSavedGames();
  }

  Future<void> _loadSavedGames() async {
  setState(() => isLoading = true);
  try {
    final collection = _firestore
        .collection('guest_users') // Ensure correct path
        .doc(_userId)
        .collection('gameSaves');

    final snapshot = await collection.orderBy('saveTime', descending: true).get();

    print("Documents found: ${snapshot.docs.length}");

    setState(() {
      savedGames = snapshot.docs.map((doc) {
        final data = doc.data();
        print("Game Data: $data"); // Debugging output
        return {...data, 'id': doc.id};
      }).toList();
      isLoading = false;
    });
  } catch (e) {
    print('Error loading games: $e'); // Print full error
    setState(() => isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error loading saved games: $e')),
    );
  }
}


Future<void> _saveGame() async {
  if (widget.currentGameData == null || _userId == null) return;

  setState(() => isLoading = true);

  try {
    await _firestore
        .collection('guest_users')  // Corrected path
        .doc(_userId)
        .collection('gameSaves')
        .add({
          ...widget.currentGameData!,
          'saveTime': DateTime.now(),
          'username': _userId, // Ensure username is stored
        });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Game saved successfully!')),
    );

    await _loadSavedGames();
  } catch (e) {
    print('Error saving game: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to save game: ${e.toString()}')),
    );
  } finally {
    setState(() => isLoading = false);
  }
}


  void _loadGame(Map<String, dynamic> gameData) {
    Navigator.pop(context, gameData);
  }

  Future<void> _deleteGame(String docId) async {
    if (_userId == null) return;
    
    try {
      await _firestore
          .collection(isGuest ? 'guest_saves' : 'user_saves')
          .doc(_userId)
          .collection('games')
          .doc(docId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Game deleted')),
      );
      
      await _loadSavedGames();
    } catch (e) {
      print('Error deleting game: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete game')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              AppImages.load,  
              fit: BoxFit.cover,      
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.isFromGamePage ? 'SAVE GAME' : 'LOAD GAME',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 20),
                if (isLoading)
                  const CircularProgressIndicator()
                else if (savedGames.isEmpty && !widget.isFromGamePage)
                  const Text(
                    'No saved games found',
                    style: TextStyle(color: Colors.white),
                  )
                else if (widget.isFromGamePage)
                  _buildSaveButton()
                else
                  ...savedGames.map((game) => _buildGameTile(game)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: 250,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(10),
        color: isLoading ? Colors.grey : Colors.black.withOpacity(0.5),
      ),
      child: InkWell(
        onTap: isLoading ? null : _saveGame,
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  'SAVE CURRENT GAME',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildGameTile(Map<String, dynamic> gameData) {
    final saveTime = (gameData['saveTime'] as Timestamp).toDate();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: 250,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(10),
        color: Colors.black.withOpacity(0.5),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              gameData['characterName'] ?? 'Unnamed Character',
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              '${gameData['genre'] ?? 'No genre'} - ${DateFormat('MMM dd, hh:mm a').format(saveTime)}',
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteDialog(gameData['id']),
            ),
            onTap: () => _loadGame(gameData),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Save?'),
        content: const Text('Are you sure you want to delete this saved game?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteGame(docId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}