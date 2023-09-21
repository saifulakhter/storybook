import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_error.dart';

class SpeechToTextScreen extends StatefulWidget {
  @override
  _SpeechToTextScreenState createState() => _SpeechToTextScreenState();
}

class _SpeechToTextScreenState extends State<SpeechToTextScreen> {
  stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;
  String _text = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Speech to Text'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_text),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isListening ? _stopListening : _startListening,
              child: Text(_isListening ? 'Stop' : 'Start'),
            ),
          ],
        ),
      ),
    );
  }

  void _startListening() async {
    // bool available = await _speechToText.initialize(
    //   onError: _onSpeechError,
    // );
    //
    // if (available) {
    //   setState(() {
    //     _isListening = true;
    //     _text = 'Listening...';
    //   });
    //
    //   _speechToText.listen(
    //     onResult: _onSpeechResult,
    //   );
    // } else {
    //   print('Speech recognition not available');
    // }
  }

  void _stopListening() {
    // _speechToText.stop();
    // setState(() {
    //   _isListening = false;
    // });
  }

  // void _onSpeechResult(stt.SpeechRecognitionResult result) {
  //   setState(() {
  //     _text = result.recognizedWords;
  //   });
  // }
  //
  // void _onSpeechError(stt.SpeechRecognitionError error) {
  //   setState(() {
  //     _text = 'Error: ${error.errorMsg}';
  //   });
  // }
}
