import 'package:adult_story_book/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:adult_story_book/screens/login.dart';
import 'package:adult_story_book/screens/registration.dart';
import 'package:adult_story_book/screens/dashboard.dart';
import 'package:adult_story_book/screens/speech_to_text.dart';
import 'package:adult_story_book/screens/recording_lists.dart';
import 'package:adult_story_book/screens/social_media.dart';
import 'package:adult_story_book/screens/create_story.dart';
import 'package:adult_story_book/screens/all_stories.dart';
import 'package:adult_story_book/screens/image_to_text.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: 'main',
    routes: {
      'login': (context) => LoginScreen(),
      'registration': (context) => Registration(),
      // 'dashboard': (context) => DashboardApp(),
      // 'create_story': (context) => MyApp(),
      'speech_to_text': (context) => SpeechToTextScreen(),
      'recording_lists': (context) => AttractiveListViewScreen(),
      'social_media': (context) => StoryBoard(),
      'all_stories': (context) => AllStories(),
      'main': (context) => StoryDashboard(),
      // 'images': (context) => ImageToText(),
    },
  ));
}