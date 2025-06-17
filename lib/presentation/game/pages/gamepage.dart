// ignore_for_file: unnecessary_to_list_in_spreads

import 'dart:typed_data';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quest/core/config/assets/app_images.dart';
import 'package:quest/presentation/load.dart';
import 'package:quest/presentation/start/start.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hidden_drawer_menu/hidden_drawer_menu.dart';

class GamePage extends StatefulWidget {
  final String characterName;
  final String characterDescription;
  final String genre;
  final String gender;  // New parameter
  final int playTime;
  final int age;  // New parameter
  
  

  const GamePage({  
    super.key,
    required this.characterName,
    required this.characterDescription,
    required this.genre,
    required this.gender,
    required this.playTime,
    required this.age,
  });
  


  @override
  GamePageState createState() => GamePageState();
}

class StoryNode {
  String story;
  String choice;
  StoryNode? next;

  StoryNode({required this.story, required this.choice, this.next});
}

class StoryHistory {
  StoryNode? head;
  StoryNode? tail;

  void addStory(String story, String choice) {
    StoryNode newNode = StoryNode(story: story, choice: choice);
    if (head == null) {
      head = newNode;
    } else {
      tail!.next = newNode;
    }
    tail = newNode;
  }

  List<String> toList() {
    List<String> history = [];
    StoryNode? current = head;
    while (current != null) {
      history.add("Choice: ${current.choice} → Story: ${current.story}");
      current = current.next;
    }
    return history;
  }

  void clear() {
    head = null;
    tail = null;
  }
}

class GamePageState extends State<GamePage> {
  String _storyText = ""; // Full story text
  String _displayedStoryText = ""; // Text displayed with typewriter effect
  bool _isTyping = false; // Whether the typewriter effect is active
  Timer? _typewriterTimer; // Timer for typewriter effect
  List<String> _choices = [];
  final StoryHistory _storyHistory = StoryHistory();
  int _storyProgress = 0;
  int _achievements = 0;
  Uint8List? _backgroundImage;

  @override
  void initState() {
    super.initState();
    _loadGameState();
    _generateStory("");
  }

  @override
  void dispose() {
    _typewriterTimer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  Future<void> _loadGameState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedHistory = prefs.getStringList("storyHistory");
    _storyProgress = prefs.getInt("storyProgress") ?? 0;
    _achievements = prefs.getInt("achievements") ?? 0;

    if (savedHistory != null) {
      _storyHistory.clear();
      for (String entry in savedHistory) {
        List<String> parts = entry.split(" → Story: ");
        if (parts.length == 2) {
          _storyHistory.addStory(parts[1], parts[0].replaceFirst("Choice: ", ""));
        }
      }
    }
  }

  Future<void> _saveGameState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("storyHistory", _storyHistory.toList());
    await prefs.setInt("storyProgress", _storyProgress);
    await prefs.setInt("achievements", _achievements);
  }

  Future<void> _generateStory(String userChoice) async {
    setState(() {
      _isTyping = true;
      _storyText = "";
      _displayedStoryText = "";
      _choices = [];
    

     if (_storyProgress == 0) {
      _storyHistory.clear();
      _saveGameState();
    }
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

    String prompt = "You are an AI storyteller crafting a deep and immersive narrative with complex branching paths that last atmost an hour but can end early by risky choices that must conclude within ${widget.playTime} minutes of gameplay.\n" 
                    "Character Name: ${widget.characterName}\n" 
                    "Character Description: ${widget.characterDescription}\n" 
                    "Character Gender : ${widget.gender}\n"
                    "Genre: ${widget.genre}\n" 
                    "Story so far: ${_storyHistory.toList().join(' ')}\n"
                    "Most Recent Choice: $userChoice\n" 
                    "Ensure the narrative builds on previous events, making choices impact future events logically.\n" 
                    "$introduction\n"
                    "$contentRating\n"
                    "The story should have natural pacing that fits this duration, with approximately ${(widget.playTime/5).round()} major story beats."
                    "Introduce objectives, unexpected plot twists, and character interactions based on past decisions.\n" 
                    "Provide a rich, immersive story continuation in well-formatted single paragraph containing no more than 200 words, followed by at least three and at most five meaningful choices.\n" 
                    "Choices should be diverse: some safe, some risky, some creative and some dangerous. Format them as a numbered list. \n"
                    "Use short phrases instead of  sentences. \n"
                    "Followed by at least three and at most five meaningful choices.\n"
                    """Include subtle time cues like:
  - "As the hour grows late..." (if >75% time used)
   - "Dawn approaches..." (if nearing conclusion)
   - "Time is running short..." (final 25%)\n""";
                    

    String apiKey = dotenv.env['API_KEY'] ?? '';
    final response = await http.post(
      Uri.parse("https://openrouter.ai/api/v1/chat/completions"),
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "model": "mistralai/devstral-small:free",
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
        _storyText = generatedStory.replaceAll(RegExp(r'\n\d+\.\s.*'), "").trim();
        _storyHistory.addStory(_storyText, userChoice);
        _storyProgress++;
        _isTyping = false;
        _choices = extractedChoices;
      });
      _saveGameState();

      _generateBackgroundImage(_storyText);
    } else {
      setState(() {
        _storyText = "Error loading story. Please try again.";
        _isTyping = false;
      });
    }

    // Start the typewriter effect
    _startTypewriterEffect();
  }

  void _startTypewriterEffect() {
    int index = 0;
    _typewriterTimer?.cancel(); // Cancel any existing timer
    setState(() {
      _displayedStoryText = ""; // Reset displayed text to start typing from the top
    });
    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      if (index < _storyText.length) {
        setState(() {
          _displayedStoryText += _storyText[index];
          index++;
        });
      } else {
        timer.cancel();
        setState(() {
          _isTyping = false; // Typing is complete
        });
      }
    });
  }

  void _skipTypewriterEffect() {
    _typewriterTimer?.cancel(); // Cancel the timer
    setState(() {
      _displayedStoryText = _storyText; // Display the full story immediately
      _isTyping = false; // Typing is complete
    });
  }

  String backgroundImageUrl = "https://source.unsplash.com/random/800x600"; // Default placeholder image


  List<String> _extractChoices(String responseText) {
    List<String> choices = [];
    RegExp regExp = RegExp(r"\d+\.\s(.*)");
    for (Match match in regExp.allMatches(responseText)) {
      choices.add(match.group(1)!);
    }
    return choices;
  }

  void _onChoiceSelected(String choice) {
    _generateStory(choice);
  }

  Future<void> _generateBackgroundImage(String sceneDescription) async {
  try {
    String apiKey2 = dotenv.env['API_KEY3'] ?? '';
    if (apiKey2.isEmpty) {
      debugPrint("Hugging Face API key not found");
      return;
    }

    // Shorten the description if needed (some APIs have length limits)
    String prompt = "Digital comic-style illustration of: ${sceneDescription.length > 200 
        ? sceneDescription.substring(0, 200) 
        : sceneDescription}";

    final imageResponse = await http.post(
      Uri.parse("https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-xl-base-1.0"),
      headers: {
        "Authorization": "Bearer $apiKey2",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "inputs": prompt,
        "options": {"wait_for_model": true}
      }),
    );

    if (imageResponse.statusCode == 200) {
      // Verify it's actually an image
      if (imageResponse.bodyBytes.isNotEmpty && 
          imageResponse.headers['content-type']?.startsWith('image/') == true) {
        setState(() {
          _backgroundImage = imageResponse.bodyBytes;
        });
      } else {
        debugPrint("Response is not an image");
      }
    } else {
      debugPrint("Failed to load image: ${imageResponse.statusCode}");
      debugPrint("Response body: ${imageResponse.body}");
    }
  } catch (e) {
    debugPrint("Error generating image: $e");
  }
}

  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
          children: [HiddenDrawerMenu(
            
            backgroundColorMenu: const Color.fromARGB(255, 97, 97, 97),
            tittleAppBar: const Text(""),
            backgroundColorAppBar: Colors.transparent,
            elevationAppBar: 0,
            
            slidePercent: 40.0,
            typeOpen: TypeOpen.FROM_LEFT,
            boxShadow: [
              BoxShadow(color: const Color.fromARGB(255, 255, 255, 255), blurRadius: 20.0),
            ],
            leadingAppBar: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(Icons.menu, size: 30),
            ),
            actionsAppBar: [

              Spacer(),
              
              SizedBox(width: 20),
            ],
            
          
            screens: [
              ScreenHiddenDrawer(
                ItemHiddenMenu(
                  name: "Resume",
                  baseStyle: TextStyle(color: Colors.white),
                  selectedStyle: TextStyle(color: Colors.yellow),
                ),
                Scaffold(
                  extendBodyBehindAppBar: true, 
                  body: Stack(
                    children: [
                      _backgroundImage != null
                ? Image.memory(_backgroundImage!, fit: BoxFit.fill, width: double.infinity, height: double.infinity )
                : Container(color: const Color.fromARGB(255, 255, 255, 255)),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Column(
                            children: [
                                Container(
                                  padding: EdgeInsets.all(16),
                                  width: MediaQuery.of(context).size.width * 0.8,
                                  height: MediaQuery.of(context).size.height * 0.6,
                                  decoration: BoxDecoration(
                                  color: const Color.fromARGB(43, 255, 253, 253),
                                  border: Border.all(color: const Color.fromARGB(0, 0, 0, 0), width: 2),
                                  borderRadius: BorderRadius.circular(20),
                                  ),
                                  alignment: Alignment.center,
                                  child: SingleChildScrollView(
                                  child: Column(
                                    
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                    Text(
                                      
                                      _displayedStoryText, // Display the text with typewriter effect
                                      textAlign: TextAlign.justify,
                                      style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      height: 1.5,
                                      fontFamily: 'monospace',
                                      color: Colors.black,
                                      ),
                                    ),
                                    if (_isTyping)
                                      ...[
                                      SizedBox(height: 10),
                                      CircularProgressIndicator(),
                                      ],
                                    GestureDetector(
                                      onTap: _skipTypewriterEffect, // Skip the typewriter effect on tap
                                      child: Container(
                                      color: Colors.transparent, // Ensure the container is tappable
                                      child: _isTyping
                                        ? const Text("") // Show the skip button only when typing
                                        : const SizedBox.shrink(),
                                      ),
                                    ),
                                    ],
                                  ),
                                  ),
                                ),
                                SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                                if (!_isTyping)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                  ChoiceScroller(
                                    choices: _choices,
                                    onChoiceSelected: _onChoiceSelected,
                                  ),
                                    SizedBox(width: 1.5),
                                    IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        TextEditingController textController = TextEditingController();
                                        return StatefulBuilder(
                                        builder: (context, setState) {
                                          return AlertDialog(
                                          title: Text("Enter your choice"),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                            TextField(
                                              controller: textController,
                                              maxLength: 50,
                                              decoration: InputDecoration(
                                              hintText: "Type your own choice here",
                                              counterText: "${textController.text.length}/50",
                                              ),
                                              onChanged: (value) {
                                              setState(() {});
                                              },
                                            ),
                                            if (textController.text.length > 50)
                                              Text(
                                              "Limit exceeded!",
                                              style: TextStyle(color: Colors.red, fontSize: 12),
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text("Cancel"),
                                            ),
                                            TextButton(
                                            onPressed: () {
                                              String userInput = textController.text.trim();
                                              if (userInput.isNotEmpty && userInput.length <= 50) {
                                              _onChoiceSelected(userInput);
                                              }
                                              Navigator.of(context).pop();
                                            },
                                            child: Text("Submit"),
                                            ),
                                          ],
                                          );
                                        },
                                        );
                                      },
                                      );
                                    },
                                    ),
                                  ],
                                )
                            
                      
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ScreenHiddenDrawer(
                ItemHiddenMenu(
                  name: "Story History",
                  baseStyle: TextStyle(color: Colors.white),
                  selectedStyle: TextStyle(color: Colors.yellow),
                ),
                Scaffold(
                  body: Container(
    decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage(AppImages.history), 
        fit: BoxFit.cover, 
      ),
    ),
    child: _storyHistory.toList().isEmpty
        ? Center(
            child: Text(
              "No story history yet.",
              style: TextStyle(fontSize: 16),
            ),
          )
        : ListView.builder(
            padding: EdgeInsets.all(25),
            itemCount: _storyHistory.toList().length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            child: Container(
                              padding: EdgeInsets.all(20),
                              child: SingleChildScrollView(
                                child: Text(
                                  _storyHistory.toList()[index],
                                  style: TextStyle(
                                    fontSize: 18,
                                    height: 1.4,
                                    fontFamily: 'Aladin-Regular',
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: SizedBox(
                      height: 200,
                      child: Card(
                        elevation: 10,
                        color: const Color.fromARGB(133, 249, 248, 248),
                        margin: EdgeInsets.symmetric(vertical: 20),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            _storyHistory.toList()[index],
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18,
                              height: 1.4,
                              fontFamily: 'Aladin-Regular',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Add an arrow symbol between cards
                  if (index < _storyHistory.toList().length - 1) // Avoid adding an arrow after the last card
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Icon(
                        Icons.arrow_downward, // Arrow symbol
                        size: 24,
                        color: Colors.grey,
                      ),
                    ),
                ],
              );
            },
          ),
  ),
                ),
              ),
                ScreenHiddenDrawer(
                ItemHiddenMenu(
                  name: "Save/Load",
                  baseStyle: TextStyle(color: Colors.white),
                  selectedStyle: TextStyle(color: Colors.yellow),
                ),
                Scaffold(
                  body: LoadGameScreen(
                  isFromGamePage: true,
                  currentGameData: {
                    'characterName': widget.characterName,
                    'characterDescription': widget.characterDescription,
                    'genre': widget.genre,
                    'gender': widget.gender,
                    'storyHistory': _storyHistory.toList(),
                    'storyProgress': _storyProgress,
                  },
                  ),
                ),
                ),
                ScreenHiddenDrawer(
  ItemHiddenMenu(
    name: "Quit",
    baseStyle: TextStyle(color: Colors.white),
    selectedStyle: TextStyle(color: Colors.yellow),
    onTap: () {
      // Show the dialog box when "Quit" is selected
      Future.delayed(Duration.zero, () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Quit Game"),
              content: Text("Do you want to save before quitting?"),
              actions: [
                TextButton(
                  onPressed: () {
                    // Navigate to LoadGameScreen
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoadGameScreen(isFromGamePage: true,),
                      ),
                    );
                  },
                  child: Text("Yes"),
                ),
                TextButton(
                  onPressed: () {
                    // Quit without saving
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainMenuScreen(),
                      ),
                    );
                  },
                  child: Text("No"),
                ),
              ],
            );
          },
        );
      });
    },
  ),
  Scaffold(
    body: Stack(
      children: [
        _backgroundImage != null
            ? Image.memory(
                _backgroundImage!,
                fit: BoxFit.fill,
                width: double.infinity,
                height: double.infinity,
              )
            : Container(color: Colors.black),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(50.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Additional content can go here if needed
              ],
            ),
          ),
        ),
      ],
    ),
  ),
),
            ],
          ),]
      ),
    );
  }
}


class ChoiceScroller extends StatefulWidget {
  final List<String> choices;
  final Function(String) onChoiceSelected;

  const ChoiceScroller({super.key, required this.choices, required this.onChoiceSelected});

  @override
  _ChoiceScrollerState createState() => _ChoiceScrollerState();
}

class _ChoiceScrollerState extends State<ChoiceScroller> {
  late PageController _pageController;
  double _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.7);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.15,
      width: MediaQuery.of(context).size.width * 0.675,
      padding: const EdgeInsets.only(top:0 , bottom: 10 , left: 10 , right: 10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(103, 0, 0, 0), width: 1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20), // Adds spacing for indicator
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: widget.choices.length,
              itemBuilder: (context, index) {
                double distance = (index - _currentPage).abs();
                double scale = 1.0 - (distance * 0.15);
                scale = scale.clamp(0.85, 1.0);

                double opacity = 1.0 - (distance * 0.3);
                opacity = opacity.clamp(0.6, 1.0);

                return Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: opacity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.6,
                        // Allow the button height to adjust dynamically
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(155, 255, 255, 255),
                            foregroundColor: Colors.black,
                            side: BorderSide(color: const Color.fromARGB(255, 95, 95, 95), width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          onPressed: () => widget.onChoiceSelected(widget.choices[index]),
                          child: Text(
                            widget.choices[index],
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Page Indicator Dots
          Positioned(
            right: 2, 
            top: 0,
            bottom: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.choices.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  width: index == _currentPage.round() ? 10 : 6,
                  height: index == _currentPage.round() ? 10 : 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentPage.round() ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StoryBackground extends StatefulWidget {
  final String storyText;

  const StoryBackground({super.key, required this.storyText});

  @override
  @override
  _StoryBackgroundState createState() => _StoryBackgroundState();
}

class StoryBackgroundState {
}

class _StoryBackgroundState extends State<StoryBackground> {
  String imageUrl = "https://via.placeholder.com/600x400"; // Default placeholder image

  @override
  void didUpdateWidget(StoryBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.storyText != widget.storyText) {
      fetchNewBackground(widget.storyText);
    }
  }

  Future<void> fetchNewBackground(String storyText) async {
    String generatedImageUrl = await generateAIImage(storyText);
    setState(() {
      imageUrl = generatedImageUrl;
    });
  }

  Future<String> generateAIImage(String prompt) async {
    // Simulate API Call - Replace with real API
    await Future.delayed(const Duration(seconds: 2)); // Simulate API delay
    return "https://via.placeholder.com/600x400?text=${Uri.encodeComponent(prompt)}"; // Replace with real response
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            widget.storyText,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}