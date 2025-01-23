import 'package:flutter/material.dart';
import 'package:personal_expense_tracker/db_helper.dart';
import 'package:personal_expense_tracker/services/auth_service.dart';
import 'package:personal_expense_tracker/screens/signup_screen.dart';
import 'package:personal_expense_tracker/services/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkUserLoginStatus();
  }

  // Check login status on startup
  _checkUserLoginStatus() async {
    bool isLoggedIn = await SharedPreferencesHelper().getUserLoginState();
    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  // Email/Username validation
  bool validateEmailOrUsername(String input) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return input.isNotEmpty && (emailRegex.hasMatch(input) || input.length >= 3);
  }

  // Password validation
  bool validatePassword(String password) {
    final passwordRegex = RegExp(
        r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    return passwordRegex.hasMatch(password);
  }

  // Login logic with validation
  void login(String emailOrUsername, String password) async {
    if (!validateEmailOrUsername(emailOrUsername)) {
      setState(() {
        errorMessage = "Invalid email or username. Please try again.";
      });
      return;
    }

    if (!validatePassword(password)) {
      setState(() {
        errorMessage = "Invalid password. Please try again.";
      });
      return;
    }

    try {
      final user = await DatabaseHelper().getUser(emailOrUsername, password);

      if (user != null) {
        final userId = user['id'] as int;
        await SharedPreferencesHelper().saveUserSession(userId);
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() {
          errorMessage = "Invalid credentials!";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Login failed. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(235, 11, 173, 16),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email/Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                final emailOrUsername = emailController.text;
                final password = passwordController.text;

                // Call login with validation
                login(emailOrUsername, password);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(235, 11, 173, 16),
              ),
              child: const Text('Login'),
            ),
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpScreen()),
                );
              },
              child: const Text("Don't have an account? Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
