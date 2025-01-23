# Personal Expense Tracker

A mobile application built with Flutter that helps users track their personal expenses. The app allows users to log expenses, categorize them, view monthly summaries, and manage their data securely with Firebase Authentication and SQLite.

## Features

- **User Authentication**: Sign up and login functionality using Firebase Authentication.
- **Expense Management**: Add, edit, and delete expenses with details such as title, amount, date, and category.
- **Monthly Summary**: View expenses grouped by month and category with a detailed breakdown.
- **Category Budgeting**: Set and track budgets for different categories.
- **Session Management**: User session is managed using Firebase and SharedPreferences for persistent login.
- **Secure Data Storage**: All user data (expenses, budgets, etc.) is stored securely in SQLite.

## Requirements

- Flutter 3.0 or later
- Dart 2.14 or later
- Android Studio or Visual Studio Code (with Flutter & Dart plugins)
- Firebase account for Authentication
- SQLite for local data storage
- SharedPreferences for session management

## Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/rediuw/personal_expense_tracker.git
2. **Install dependencies:** In your terminal, navigate to the project directory and run:
   flutter pub get
3. **Configure Firebase:**
  -Create a Firebase project at Firebase Console.
  -Add your Android app to Firebase and download the google-services.json file.
  -Place google-services.json in the android/app directory of the Flutter project.
  -Enable Firebase Authentication in the Firebase console.
4. **Run the app:**  To run the app on an Android device, use the following command:
    flutter run

## Screens
1. **Login Screen**
Allows users to log in using their email/username and password.
2. **Sign-Up Screen**
Allows new users to sign up by entering their username, email, and password.
3. **Home Screen**
Displays the list of expenses, with an option to filter and sort by category and date.
4. **Expense Details Screen**
View a detailed breakdown of expenses grouped by month and category.
5. **Category Budget Screen**
Set and manage budgets for different categories of expenses.

## Technologies Used
**Flutter:** A UI toolkit for building natively compiled applications for mobile.

**Firebase Authentication:** For managing user authentication and sign-in.

**SQLite:** For local data storage of expenses, categories, and budgets.

**SharedPreferences:** For session management to keep users logged in.

**Dart:** The programming language used for the app's logic.

## Contributions
Feel free to fork the repository, make improvements, or suggest new features. Contributions are welcome!

## License
This project is open-source and available under the MIT License. See the LICENSE file for more information.

## Contact
For further questions or collaborations, please contact me at:
redietbirhanu64@gmail.com

GitHub: https://github.com/rediuw

## Acknowledgements
Thanks to Firebase for providing the Authentication service.
Thanks to SQLite for the local storage solution.

