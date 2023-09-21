import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:share/share.dart';
import 'package:translator/translator.dart';
import 'package:adult_story_book/screens/login.dart';

class Story {
  final String title;
  final String genre;
  final String content;

  Story({
    required this.title,
    required this.genre,
    required this.content,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      title: json['title'],
      genre: json['genre'],
      content: json['content'],
    );
  }
}

class StoryDashboard extends StatefulWidget {
  @override
  _StoryDashboardState createState() => _StoryDashboardState();
}

class _StoryDashboardState extends State<StoryDashboard> {
  List<Story> stories = [];

  TextEditingController searchController = TextEditingController();
  FlutterTts flutterTts = FlutterTts();
  bool isDarkMode = true;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    fetchStories();
  }

  Future<void> fetchStories() async {
    final apiUrl = 'http://127.0.0.1:8000/api/stories';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);

      final storiesList = jsonData['data'];

      setState(() {
        stories = storiesList.map<Story>((json) => Story.fromJson(json)).toList();
      });
    } else {
      print('Failed to fetch stories. Status Code: ${response.statusCode}');
    }
  }

  List<Story> getFilteredStories(String query) {
    return stories.where((story) {
      final title = story.title.toLowerCase();
      final genre = story.genre.toLowerCase();
      final content = story.content.toLowerCase();
      final searchQuery = query.toLowerCase();

      return title.contains(searchQuery) ||
          genre.contains(searchQuery) ||
          content.contains(searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Story Viewer',
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Story Viewer'),
          actions: [
            IconButton(
              icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: () {
                setState(() {
                  isDarkMode = !isDarkMode;
                });
              },
            ),
            if (isLoggedIn)
              IconButton(
                icon: Icon(Icons.logout),
                onPressed: () {
                  setState(() {
                    isLoggedIn = false;
                  });
                },
              ),
            if (!isLoggedIn)
              IconButton(
                icon: Icon(Icons.login),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(),
                    ),
                  );
                },
              ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                onChanged: (_) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: 'Search...',
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                ),
                itemCount: searchController.text.isEmpty
                    ? stories.length
                    : getFilteredStories(searchController.text).length,
                itemBuilder: (context, index) {
                  final story = searchController.text.isEmpty
                      ? stories[index]
                      : getFilteredStories(searchController.text)[index];
                  return StoryCard(
                    story: story,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              StoryDetail(story: story, flutterTts: flutterTts),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StoryCard extends StatelessWidget {
  final Story story;
  final VoidCallback onTap;

  StoryCard({required this.story, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        child: Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    story.title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    story.genre,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StoryDetail extends StatefulWidget {
  final Story story;
  final FlutterTts flutterTts;

  StoryDetail({required this.story, required this.flutterTts});

  @override
  _StoryDetailState createState() => _StoryDetailState();
}

class _StoryDetailState extends State<StoryDetail> {
  double fontSize = 16.0;
  bool readingMode = false;
  int currentPage = 0;
  int maxPages = 0;
  bool isDarkMode = false;
  bool isPlaying = false;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String currentTranslation = '';
  GoogleTranslator translator = GoogleTranslator();

  _StoryDetailState() {
    _speech = stt.SpeechToText();
  }

  @override
  void initState() {
    super.initState();
    splitContentIntoPages();
    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  void increaseFontSize() {
    setState(() {
      fontSize += 2.0;
    });
  }

  void decreaseFontSize() {
    setState(() {
      fontSize -= 2.0;
    });
  }

  void toggleReadingMode() {
    setState(() {
      readingMode = !readingMode;
    });
  }

  void nextPage() {
    if (currentPage < maxPages - 1) {
      setState(() {
        currentPage++;
      });
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
      });
    }
  }

  Future<void> toggleTTS() async {
    if (isPlaying) {
      await widget.flutterTts.stop();
    } else {
      await widget.flutterTts.speak(pages[currentPage]);
    }

    setState(() {
      isPlaying = !isPlaying;
    });

    if (_isListening) {
      _speech.stop();
    } else {
      _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            handleVoiceCommand(result.recognizedWords);
            _speech.stop();
          }
        },
      );
    }
  }

  void handleVoiceCommand(String command) {
    if (command.toLowerCase().contains('next')) {
      nextPage();
    } else if (command.toLowerCase().contains('previous')) {
      previousPage();
    }
  }

  List<String> pages = [];

  void splitContentIntoPages() {
    final content = widget.story.content;
    final words = content.split(' ');
    final maxWordsPerPage = 150;
    int start = 0;

    while (start < words.length) {
      int end = start + maxWordsPerPage;
      if (end > words.length) {
        end = words.length;
      }

      final page = words.sublist(start, end).join(' ');
      pages.add(page);

      start = end;
    }
    maxPages = pages.length;
  }

  Future<void> translateContent(Locale targetLocale) async {
    if (targetLocale == Locale('en')) {
      setState(() {
        currentTranslation = '';
      });
      return;
    }

    try {
      final translation = await translator.translate(
        pages[currentPage],
        from: 'en',
        to: targetLocale.languageCode,
      );
      setState(() {
        currentTranslation = translation.text;
      });
    } catch (e) {
      print('Translation error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final contentText = currentPage < pages.length ? pages[currentPage] : '';
    final translatedText = currentTranslation.isNotEmpty ? currentTranslation : contentText;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.story.title),
        actions: [
          PopupMenuButton<Locale>(
            onSelected: (Locale targetLocale) {
              translateContent(targetLocale);
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<Locale>(
                  value: Locale('en', 'US'),
                  child: Text('English'),
                ),
                PopupMenuItem<Locale>(
                  value: Locale('es', 'ES'),
                  child: Text('Español'),
                ),
                // Add more languages as needed
              ];
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      isDarkMode = !isDarkMode;
                    });
                  },
                  child: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
                ),
                ElevatedButton(
                  onPressed: toggleTTS,
                  child: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
                ),
                ElevatedButton(
                  onPressed: () {
                    Share.share(
                        'Check out this story: ${widget.story.title}\n\n${widget.story.content}');
                  },
                  child: Icon(Icons.share),
                )
              ],
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      increaseFontSize();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                    ),
                    icon: Icon(
                      Icons.add,
                      color: Colors.green,
                    ),
                    label: Text(
                      'Increase Font Size',
                      style: TextStyle(
                        color: Colors.green,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      decreaseFontSize();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                    ),
                    icon: Icon(
                      Icons.remove,
                      color: Colors.red,
                    ),
                    label: Text(
                      'Decrease Font Size  ',
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: toggleReadingMode,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: readingMode ? Colors.blue : Colors.transparent,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                  color: isDarkMode ? Colors.black : Colors.white,
                ),
                padding: EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Text(
                    translatedText,
                    style: TextStyle(
                      fontSize: fontSize,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: previousPage,
                  child: Text('Previous Page'),
                ),
                ElevatedButton(
                  onPressed: nextPage,
                  child: Text('Next Page'),
                ),
              ],
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(StoryDashboard());
}
