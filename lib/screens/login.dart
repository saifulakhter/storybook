import 'dart:convert';
import 'package:adult_story_book/screens/dashboard.dart';
import 'package:adult_story_book/screens/registration.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: LoginScreen(),
    ),
  );
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController(text: 'r@gmail.com');
  final TextEditingController _passwordController = TextEditingController(text: '123456');
  final String _apiUrl = 'http://127.0.0.1:8000/api/login'; // Replace with your API URL
  bool _loginFailed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),

        backgroundColor: Colors.black87,
      ),

      // backgroundColor: Colors.brown,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: <InlineSpan>[
                  TextSpan(
                    text: 'Welcome to Storybook. \n',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  WidgetSpan(
                    child: SizedBox(height: 40), // Adjust the height as needed
                  ),
                  TextSpan(
                    text: 'Please login to the system to share your story.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey, // You can adjust the color as needed
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Image.network(
              'https://thegreen.studio/saiful/study.png', // Replace with your image URL
              width: 200, // Adjust the width as needed
              height: 200, // Adjust the height as needed
              fit: BoxFit.cover, // Adjust the fit as needed
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(

                labelText: 'Email',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
            ),
            SizedBox(height: 24),
            Container(
              width: double.infinity, // Make the button take up full width
              child: ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(16),
                  primary: Colors.black,
                ),
                child: Text(
                  'Login',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),

            if (_loginFailed)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Invalid email or password',
                  style: TextStyle(color: Colors.red),
                ),
              ),

            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Registration(),
                      ),
                    );
                  },
                  child: Text('Already have an account? Sign In',
                    style: TextStyle(
                      color: Colors.black, // Set text color to black
                    ),),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to the forgot password screen
                  },
                  child: Text('Forgot Password',style: TextStyle(
    color: Colors.black, // Set text color to black
    ),),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text;

    // Create a Map with the credentials to send in the request body
    Map<String, String> credentials = {
      'email': email,
      'password': password,
    };

    // Send a POST request to your API
    final response = await http.post(
      Uri.parse(_apiUrl),
      body: credentials,
    );

    if (response.statusCode == 200) {
      // Successful login
      final Map<String, dynamic> data = jsonDecode(response.body);


      // Check if 'user' field is present and it's a Map
      if (data.containsKey('user') && data['user'] is Map<String, dynamic>) {
        Map<String, dynamic> userData = data['user'] as Map<String, dynamic>;
        // print('Login successful. User ID: ${userData['id']}');

        // Extract the user ID and name from the response data
        String userId = userData['id'].toString();
        String userName = userData['name'].toString();
        //Navigate to the Dashboard screen with the userId
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Dashboard(userId: userId,userName: userName),
          ),
        );

        setState(() {
          _loginFailed = false;
        });
      } else {
        setState(() {
          _loginFailed = true;
        });
      }
    } else {
      // Login failed
      setState(() {
        _loginFailed = true;
      });
    }
  }
}
