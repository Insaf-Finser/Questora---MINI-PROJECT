import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:popover/popover.dart';
import 'package:quest/core/config/assets/app_images.dart';
import 'package:quest/core/config/assets/app_vectors.dart';
import 'package:quest/presentation/game/pages/gamepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'game_page.dart';

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

  Future<void> _startGame() async {
    if (_nameController.text.isNotEmpty && _descriptionController.text.isNotEmpty && _genreController.text.isNotEmpty) {  

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
                    IconButton(
                      icon: Icon(Icons.arrow_drop_down, color: Colors.amber),
                      onPressed: () {
                        showPopover(
                          context: context,
                          bodyBuilder: (context) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: genres.map((String genre) {
                              return ListTile(
                                title: Text(genre, style: TextStyle(color: Colors.black)),
                                onTap: () {
                                  setState(() {
                                    _genreController.text = genre;  // Update TextField with selected genre
                                  });
                                  Navigator.pop(context); // Close the popover
                                },
                              );
                            }).toList(),
                          ),
                          onPop: () {},
                          direction: PopoverDirection.top,
                          width: 200,
                          height: 200,
                          arrowHeight: 15,
                          arrowWidth: 30,
                        );
                      },
                    ),
                  ],
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
            child: Text("Start Story"),
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
