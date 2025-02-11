// ignore_for_file: unnecessary_to_list_in_spreads

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GamePage extends StatefulWidget {
  final String characterName;
  final String characterDescription;
  final String genre;
  final int age;

  const GamePage({
    super.key,
    required this.characterName,
    required this.characterDescription,
    required this.genre,
    required this.age,
  });

  @override
  GamePageState createState() => GamePageState();
}

class GamePageState extends State<GamePage> {
  String _storyText = "";
  bool _isTyping = false;
  List<String> _choices = [];
  List<String> _storyHistory = [];
  int _storyProgress = 0;
  int _achievements = 0;

  @override
  void initState() {
    super.initState();
    _loadGameState();
    _generateStory("");
  }

  Future<void> _loadGameState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _storyHistory = prefs.getStringList("storyHistory") ?? [];
      _storyProgress = prefs.getInt("storyProgress") ?? 0;
      _achievements = prefs.getInt("achievements") ?? 0;
    });
  }

  Future<void> _saveGameState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("storyHistory", _storyHistory);
    await prefs.setInt("storyProgress", _storyProgress);
    await prefs.setInt("achievements", _achievements);
  }

  void _trackAchievements() {
    if (_storyProgress % 5 == 0) {
      setState(() {
        _achievements++;
      });
      _saveGameState();
    }
  }

  Future<void> _generateStory(String userChoice) async {
    setState(() {
      _isTyping = true;
      _storyText = "";
      _choices = [];
    });

    String contentRating = widget.age < 13
        ? "Ensure the story is child-friendly, avoiding violence or complex themes."
        : widget.age < 18
            ? "Keep the story appropriate for teenagers, with moderate complexity and action."
            : "Allow for mature storytelling with deeper themes and challenges.";

    String introduction;
    if (_storyProgress == 0) {
      switch (widget.genre.toLowerCase()) {
        case "fantasy":
          introduction = "Long ago, in a kingdom forgotten by time...";
          break;
        case "sci-fi":
          introduction = "In the distant reaches of the cosmos, a lone traveler awakens...";
          break;
        case "mystery":
          introduction = "The rain poured heavily as the detective examined the scene...";
          break;
        default:
          introduction = "Once upon a time, a great journey began...";
      }
    } else {
      introduction = "Ensure the narrative builds on previous events, making choices impact future events logically.";
    }

    String prompt = "You are an AI storyteller crafting a deep and immersive narrative with complex branching paths that last atmost an hour but can end early by risky choices.\n" 
                    "Character Name: ${widget.characterName}\n" 
                    "Character Description: ${widget.characterDescription}\n" 
                    "Genre: ${widget.genre}\n" 
                    "Story so far: ${_storyHistory.join(' ')}\n"
                    "Most Recent Choice: $userChoice\n" 
                    "Ensure the narrative builds on previous events, making choices impact future events logically.\n" 
                    "$introduction\n"
                    "$contentRating\n"
                    "Introduce objectives, unexpected plot twists, and character interactions based on past decisions.\n" 
                    "Provide a rich, immersive story continuation in well-formatted single paragraph containing no more than 120 words, followed by at least three and at most five meaningful choices.\n" 
                    "Choices should be diverse: some safe, some risky, some creative and some dangerous. Format them as a numbered list. Use short phrases instead of  sentences. \n";

    String apiKey = dotenv.env['API_KEY'] ?? '';
    final response = await http.post(
      Uri.parse("https://openrouter.ai/api/v1/chat/completions"),
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "model": "mistralai/mistral-7b-instruct:free",
        "prompt": prompt,
        "max_tokens": 600,
        "temperature": 0.85,
        "n": 1,
      }),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      String generatedText = data["choices"][0]["text"].trim();
      List<String> extractedChoices = _extractChoices(generatedText);
      String generatedStory = generatedText.split("\nChoices:")[0].trim();

      setState(() {
        _storyText = generatedStory.replaceAll("\n", "\n\n");
        _storyHistory.add("Choice: $userChoice → Story: $_storyText");
        _storyProgress++;
        _isTyping = false;
        _choices = extractedChoices;
      });
      _trackAchievements();
      _saveGameState();
    } else {
      setState(() {
        _storyText = "Error loading story. Please try again.";
        _isTyping = false;
      });
    }
  }

  List<String> _extractChoices(String responseText) {
    List<String> choices = [];
    RegExp regExp = RegExp(r"\d+\.\s(.*)");
    for (Match match in regExp.allMatches(responseText)) {
      choices.add(match.group(1)!);
    }
    return choices.isNotEmpty ? choices : ["Explore the ruins", "Seek guidance from a mentor", "Venture into the unknown"];
  }

  void _onChoiceSelected(String choice) {
    _generateStory(choice);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Questora - Story Mode"),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text("Achievements: $_achievements", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _storyText,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, height: 1.5),
            ),
            if (_isTyping) ...[
              SizedBox(height: 10),
              LinearProgressIndicator()
            ],
            SizedBox(height: 20),
            if (!_isTyping) ..._choices.map((choice) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: ElevatedButton(
                onPressed: () => _onChoiceSelected(choice),
                child: Text(choice),
              ),
            )).toList(),
          ],
        ),
      ),
      ),
    );
  }
}