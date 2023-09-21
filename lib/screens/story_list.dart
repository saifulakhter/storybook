import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:adult_story_book/screens/dashboard.dart';

class Story {
  final int id;
  final String title;
  final String genre;
  String content;

  Story({
    required this.id,
    required this.title,
    required this.genre,
    required this.content,
  });
}

class StoryListPage extends StatefulWidget {
  final String userId;

  StoryListPage({required this.userId});

  @override
  _StoryListPageState createState() => _StoryListPageState();
}

class _StoryListPageState extends State<StoryListPage> {
  List<Story> stories = [];

  @override
  void initState() {
    super.initState();
    fetchStories();
  }

  Future<void> fetchStories() async {
    final apiUrl = 'http://localhost:8000/api/stories/user/${widget.userId}';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final dynamic responseData = jsonDecode(response.body);

      if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
        final List<dynamic> storiesData = responseData['data'];

        setState(() {
          stories = storiesData
              .map((data) => Story(
            id: data['id'],
            title: data['title'],
            genre: data['genre'],
            content: data['content'],
          ))
              .toList();
        });
      } else {
        print('Invalid response format. Expected a "data" key with a List, but received: $responseData');
      }
    } else {
      print('Failed to fetch data. Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Story Viewer'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back to the previous screen
          },
        ),
      ),
      body: ListView.builder(
        itemCount: stories.length,
        itemBuilder: (context, index) {
          final story = stories[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(story.title),
              subtitle: Text(story.genre),
              trailing: ElevatedButton(
                onPressed: () async {
                  final editedContent = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => StoryEditPage(storyContent: story.content),
                    ),
                  );

                  // Update the story content if the user saved changes
                  if (editedContent != null) {
                    setState(() {
                      story.content = editedContent;
                    });
                  }
                },
                child: Text('Edit'),
              ),
              onTap: () {
                // Handle the tap event for a story item
                // You can navigate to a detailed view or perform any action here
              },
            ),
          );
        },
      ),
    );
  }
}

void main() {
  // Define the userId here
  final userId = 'your_user_id_here'; // Replace with the actual user ID

  runApp(
    MaterialApp(
      home: StoryListPage(userId: userId),
    ),
  );
}

class StoryEditPage extends StatefulWidget {
  final String storyContent;

  StoryEditPage({required this.storyContent});

  @override
  _StoryEditPageState createState() => _StoryEditPageState();
}

class _StoryEditPageState extends State<StoryEditPage> {
  TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _contentController.text = widget.storyContent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Story'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: TextFormField(
                controller: _contentController,
                maxLines: null, // Allows for multiple lines
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: 'Edit your story here (up to 1000 words)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Save the edited story content and pop the screen to return to the story list
                final editedContent = _contentController.text;
                Navigator.of(context).pop(editedContent);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
