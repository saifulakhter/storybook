import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'story_list.dart'; // Import your story list page

class SaveStoryPage extends StatefulWidget {
  final String userId;
  final String story;

  SaveStoryPage({
    required this.userId,
    required this.story,
  });

  @override
  _SaveStoryPageState createState() => _SaveStoryPageState();
}

class _SaveStoryPageState extends State<SaveStoryPage> {
  String? selectedGenre;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController genreController = TextEditingController();

  final List<String> genreOptions = [
    'Adventure',
    'Fantasy',
    'Mystery',
    'Romance',
    'Science Fiction',
    'Thriller',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    selectedGenre = genreOptions[0]; // Initialize with the first genre option.
  }

  Future<void> saveStory() async {
    final apiUrl = Uri.parse('http://127.0.0.1:8000/api/stories');

    final response = await http.post(
      apiUrl,
      body: jsonEncode({
        'user_id': widget.userId,
        'title': titleController.text,
        'genre': selectedGenre,
        'content': widget.story,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      // Story successfully saved, navigate to the story list page.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => StoryListPage(userId: widget.userId), // Replace with your story list page.
        ),
      );
    } else {
      // Handle error if the API request fails.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save the story.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Story'),
        actions: [
          IconButton(
            onPressed: saveStory,
            icon: Icon(Icons.save_alt),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Title:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              'Genre:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            DropdownButton<String>(
              value: selectedGenre,
              onChanged: (String? newValue) {
                setState(() {
                  selectedGenre = newValue;
                });
              },
              items: genreOptions.map((String genre) {
                return DropdownMenuItem<String>(
                  value: genre,
                  child: Text(genre),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            Text(
              'Story:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              widget.story,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
