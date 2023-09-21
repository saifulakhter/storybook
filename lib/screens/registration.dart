import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:adult_story_book/screens/login.dart';
import 'package:adult_story_book/screens/forgotpassword.dart';

class Registration extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return Material(
      child: RegistrationPage(),
    );
  }
}

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  Future<void> _register() async {
    final String name = _nameController.text;
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      // Passwords do not match, show an error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Password Mismatch'),
          content: Text('The password and confirm password do not match.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Perform the registration API request here
    final url = Uri.parse('http://127.0.0.1:8000/api/register');
    final response = await http.post(
      url,
      body: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': confirmPassword,
      },
    );

    if (response.statusCode == 201) {
      // Registration successful, show a success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Registration Successful'),
          content: Text('You have successfully registered.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to the login page or perform any other action here
                _navigateToLogin();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      // Registration failed, show an error dialog with the response message
      final responseData = json.decode(response.body);
      final errorMessage = responseData['errors'][0]; // Assuming API returns error messages this way
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Registration Failed'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _navigateToLogin() {
    Navigator.push(
      context, // the current build context
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }

  void _forgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration Page'),
        backgroundColor: Colors.black87,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                    text: 'Please register to the system to share your story.',
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
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
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
            SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _register,
                child: Text('Register'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.black, // Set the background color to black
                ),
              ),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: _navigateToLogin,
              child: Text('Already have an account? Login',style: TextStyle(
                color: Colors.black, // Set text color to black
              ),),
            ),
            TextButton(
              onPressed: _forgotPassword,
              child: Text('Forgot Password?',style: TextStyle(
                color: Colors.black, // Set text color to black
              ),),
            ),
          ],
        ),
      ),
    );
  }
}
