import 'dart:io';
import 'package:adult_story_book/screens/save_story.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';



class ImageToText extends StatelessWidget {
  final String userId;
  ImageToText({required this.userId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: TextExtractor(userId: userId),
    );
  }
}


class TextExtractor extends StatefulWidget {
  final String userId;
  TextExtractor({required this.userId});
  @override
  _TextExtractorState createState() => _TextExtractorState();
}

class _TextExtractorState extends State<TextExtractor> {
  List<File?> selectedImages = [];
  TextEditingController extractedTextController = TextEditingController();
  TextRecognizer textRecognizer = GoogleMlKit.vision.textRecognizer();

  Future<void> _selectAndExtractImage() async {
    final imagePicker = ImagePicker();

    while (true) {
      final pickedFile = await imagePicker.getImage(source: ImageSource.gallery);

      if (pickedFile == null) {
        break;
      }

      final imageFile = File(pickedFile.path);

      setState(() {
        selectedImages.add(imageFile);
      });

      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      String text = '';

      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          text += line.text + ' ';
        }
        text += '\n';
      }

      extractedTextController.text += text;
    }
  }

  @override
  void dispose() {

    textRecognizer.close();
    extractedTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Extractor'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            selectedImages.isNotEmpty
                ? Expanded(
              child: ListView.builder(
                itemCount: selectedImages.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Image.file(selectedImages[index]!),
                      SizedBox(height: 8),
                      // Text(
                      //   'Extracted Text:',
                      //   style: TextStyle(fontWeight: FontWeight.bold),
                      // ),
                      // SizedBox(height: 8),
                      // Text(extractedTextController.text),
                    ],
                  );
                },
              ),
            )
                : Text('Select images from the gallery to extract text.'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _selectAndExtractImage,
              child: Text('Select Image'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SaveStoryPage(userId: widget.userId,story: extractedTextController.text),
                  ),
                );
              },
              child: Text('Save Story'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: extractedTextController,
              decoration: InputDecoration(
                labelText: 'Extracted Text',
                border: OutlineInputBorder(),
              ),
              maxLines: null, // Allows multiple lines in the TextField.
            ),
          ],
        ),
      ),
    );
  }
}


