import 'package:flutter/material.dart';
import 'package:quest/presentation/game/pages/gamepage.dart';
//import 'game_page.dart';

class CharacterCreationPage extends StatefulWidget {
  const CharacterCreationPage({super.key});

  @override
  CharacterCreationPageState createState() => CharacterCreationPageState();
}

class CharacterCreationPageState extends State<CharacterCreationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedGenre = "Fantasy";

  final List<String> genres = ["Fantasy", "Sci-Fi", "Mystery", "Adventure", "Horror"];

  void _startGame() {
    if (_nameController.text.isNotEmpty && _descriptionController.text.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GamePage(
            characterName: _nameController.text,
            characterDescription: _descriptionController.text,
            genre: _selectedGenre,
            age: 20,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Your Character")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Character Name:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(controller: _nameController),
            SizedBox(height: 16),

            Text("Character Description:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(controller: _descriptionController, maxLines: 3),
            SizedBox(height: 16),

            Text("Select Genre:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _selectedGenre,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGenre = newValue!;
                });
              },
              items: genres.map((genre) {
                return DropdownMenuItem<String>(
                  value: genre,
                  child: Text(genre),
                );
              }).toList(),
            ),
            SizedBox(height: 32),

            Center(
              child: ElevatedButton(
                onPressed: _startGame,
                child: Text("Start Story"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
