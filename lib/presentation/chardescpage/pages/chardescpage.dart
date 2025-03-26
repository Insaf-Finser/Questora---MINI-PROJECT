import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:popover/popover.dart';
import 'package:quest/core/config/assets/app_images.dart';
import 'package:quest/core/config/assets/app_vectors.dart';
import 'package:quest/presentation/game/pages/gamepage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CharacterCreationPage extends StatefulWidget {
  const CharacterCreationPage({super.key});

  @override
  CharacterCreationPageState createState() => CharacterCreationPageState();
}

class CharacterCreationPageState extends State<CharacterCreationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();

  final List<String> genres = ["Fantasy", "Sci-Fi", "Mystery", "Adventure", "Horror"];
  String _selectedGender = "Male";
  double _selectedTime = 5;

  Future<void> _startGame() async {
    if (_nameController.text.isNotEmpty && 
        _descriptionController.text.isNotEmpty && 
        _genreController.text.isNotEmpty) {  

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove("storyHistory");  
      await prefs.remove("storyProgress"); 
      await prefs.remove("achievements");  

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GamePage(
            characterName: _nameController.text,
            characterDescription: _descriptionController.text,
            genre: _genreController.text,
            age: 10,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: Stack(
              children: [
                Image.asset(
                  AppImages.mainBG,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 32),
                IconButton(
                  icon: SvgPicture.asset(AppVectors.back, height: 20),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                SizedBox(height: 20),
                Center(
                  child: Text(
                    "Create Your Character",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 211, 169, 30),
                      fontFamily: 'Aladin-Regular',
                      letterSpacing: 4.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 70),
                Container(
                  height: 400,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.all(30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Character Name:",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 177, 151, 65),
                              fontFamily: 'Aladin-Regular',
                            ),
                          ),
                          TextField(
                            controller: _nameController,
                            cursorColor: const Color.fromARGB(155, 255, 193, 7),
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.amber),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Character Description:",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 177, 151, 65),
                              fontFamily: 'Aladin-Regular',
                            ),
                          ),
                          Focus(
                            onFocusChange: (hasFocus) {
                              setState(() {});
                            },
                            child: TextField(
                              controller: _descriptionController,
                              cursorColor: const Color.fromARGB(155, 255, 193, 7),
                              maxLines: 2,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.amber),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text("Gender: ",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 177, 151, 65),
                              fontFamily: 'Aladin-Regular',
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedGender = "Male";
                                  });
                                },
                                icon: Icon(
                                  Icons.male,
                                  color: _selectedGender == "Male" ? Colors.amber : const Color.fromARGB(255, 250, 248, 248),
                                ),
                              ),
                              SizedBox(width: 16),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedGender = "Female";
                                  });
                                },
                                icon: Icon(
                                  Icons.female,
                                  color: _selectedGender == "Female" ? Colors.amber : const Color.fromARGB(255, 250, 248, 248),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Select Genre:",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 177, 151, 65),
                              fontFamily: 'Aladin-Regular',
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _genreController,
                                  cursorColor: const Color.fromARGB(155, 255, 193, 7),
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: "Enter or select genre",
                                    hintStyle: TextStyle(color: Colors.grey),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.amber),
                                    ),
                                  ),
                                ),
                              ),
                              Builder(
                                builder: (context) {
                                  return IconButton(
                                    icon: Icon(Icons.arrow_drop_down, color: const Color.fromARGB(155, 255, 193, 7),),
                                    onPressed: () {
                                      showPopover(
                                        context: context,
                                        backgroundColor: const Color.fromARGB(67, 255, 255, 255),
                                        bodyBuilder: (context) {
                                          return Container(
                                            width: 200,
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(135, 255, 255, 255),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: genres.length,
                                              itemBuilder: (context, index) {
                                                return ListTile(
                                                  title: Text(genres[index]),
                                                  onTap: () {
                                                    setState(() {
                                                      _genreController.text = genres[index];
                                                    });
                                                    Navigator.of(context).pop();
                                                  },
                                                );
                                              },
                                            ),
                                          );
                                        },
                                        direction: PopoverDirection.bottom,
                                        width: 200,
                                        height: genres.length * 48.0,
                                        arrowHeight: 10,
                                        arrowWidth: 20,
                                        
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Set Time (Minutes):",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 177, 151, 65),
                              fontFamily: 'Aladin-Regular',
                            ),
                          ),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 1.0,
                              activeTrackColor: const Color.fromARGB(255, 177, 151, 65),
                              inactiveTrackColor: const Color.fromARGB(255, 232, 226, 226),
                              thumbColor: const Color.fromARGB(255, 177, 151, 65),
                              overlayColor: Colors.amber.withOpacity(0.2),
                              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),
                            ),
                            child: Slider(
                              value: _selectedTime,
                              min: 5,
                              max: 60,
                              divisions: 11,
                              label: "${_selectedTime.toInt()} min",
                              onChanged: (double value) {
                                setState(() {
                                  _selectedTime = value;
                                });
                              },
                            ),
                          ),
                          Text(
                            "Selected Time: ${_selectedTime.toInt()} minute(s)",
                            style: TextStyle(
                              fontSize: 24,
                              color: const Color.fromARGB(255, 177, 151, 65),
                              fontFamily: 'Aladin-Regular'
                            ),
                          ),
                          SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _startGame,
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(
                        side: BorderSide(color: const Color.fromARGB(255, 177, 151, 65), width: 2),
                      ),
                      backgroundColor: Colors.transparent,
                      padding: EdgeInsets.all(10),
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      color: const Color.fromARGB(255, 177, 151, 65),
                      size: 60,
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
}