import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:personal_expense_tracker/screens/add_expense_screen.dart';
import 'package:personal_expense_tracker/screens/login_screen.dart';
import 'package:personal_expense_tracker/screens/monthly_expense_summary_screen.dart';
import 'package:personal_expense_tracker/screens/expense_analytics_screen.dart';
import 'package:personal_expense_tracker/screens/budget_setting_screen.dart';
import 'package:personal_expense_tracker/screens/signup_screen.dart';
//import 'package:personal_expense_tracker/services/auth_service.dart';
import 'package:personal_expense_tracker/services/shared_preferences.dart';

void main() async {
 WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove the debug banner
      title: 'Expense Tracker',
      theme: ThemeData(
        useMaterial3: true,
      ),
      initialRoute: '/login',
      home: const AuthChecker(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const WelcomeScreen(),
        '/addExpense': (context) => const AddExpenseScreen(),
        '/monthlySummary': (context) => const MonthlyExpenseSummaryScreen(),
        '/analytics': (context) => const ExpenseAnalyticsScreen(),
        '/setBudget': (context) => const SetBudgetScreen(),
      },
    );
  }
}
class AuthChecker extends StatelessWidget {
  const AuthChecker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int?>(
      future: SharedPreferencesHelper().getUserSession(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data != null) {
          // User is logged in
          return const WelcomeScreen(); 
        } else {
          // User is not logged in
          return const LoginScreen();
        }
      },
    );
  }
}
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  Color buttonColor = const Color.fromARGB(235, 11, 173, 16); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome to Expense Tracker"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(235, 11, 173, 16),
        foregroundColor: Colors.white,
         actions: [
    IconButton(
  icon: const Icon(Icons.logout),
  onPressed: () async {
    // Clear the user session using SharedPreferences
    await SharedPreferencesHelper().clearUserSession(); 

    // Navigate to the login screen
    //Navigator.pushReplacementNamed(context, '/login');
    Navigator. pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false, // Remove all previous routes
    );
  },
  tooltip: "Log Out",
),

  ],
      ),
      body: Stack(
        children: [
          // Background Image with Blur Effect
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.webp'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.2),
            ),
          ),
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  // ignore: deprecated_member_use
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Main Content
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.account_balance_wallet,
                    size: 100.0,
                    color: Color.fromARGB(235, 11, 173, 16),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Track your expenses and manage your budget easily.",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  // Button Grid
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Left Column
                      Expanded(
                        child: Column(
                          children: [
                            _buildCustomButton(
                              context,
                              "Start Tracking",
                              '/addExpense',
                            ),
                            const SizedBox(height: 20),
                            _buildCustomButton(
                              context,
                              "View Analytics",
                              '/analytics',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Right Column
                      Expanded(
                        child: Column(
                          children: [
                            _buildCustomButton(
                              context,
                              "View Summary",
                              '/monthlySummary',
                            ),
                            const SizedBox(height: 20),
                            _buildCustomButton(
                              context,
                              "Set Budget",
                              '/setBudget',
                            ),
                        
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Custom Button Builder
  Widget _buildCustomButton(BuildContext context, String label, String route) {
    return GestureDetector(
      //onTap: () {
        //Navigator.pushNamed(context, route);
      //},
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, route);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor, 
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50), // Full width
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          
          child: Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
} 