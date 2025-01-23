import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get the currently signed-in user
  User? get currentUser => _auth.currentUser;

  /// Sign up with email, password, and username
  Future<User?> signUp(String username, String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        // Save user data to Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'username': username,
          'email': email,
          'createdAt': DateTime.now(),
        });

        // Save login state locally
        await _saveUserIdToLocalStorage(user.uid);
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  /// Log in with email or username and password
  Future<User?> logIn(String identifier, String password) async {
    try {
      UserCredential result;

      if (identifier.contains('@')) {
        // If identifier is an email
        result = await _auth.signInWithEmailAndPassword(
          email: identifier,
          password: password,
        );
      } else {
        // If identifier is a username
        QuerySnapshot query = await _firestore
            .collection('users')
            .where('username', isEqualTo: identifier)
            .get();

        if (query.docs.isEmpty) {
          throw Exception('No user found with this username.');
        }

        String email = query.docs.first.get('email');

        // Log in using email fetched from Firestore
        result = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }

      User? user = result.user;

      if (user != null) {
        // Save login state locally
        await _saveUserIdToLocalStorage(user.uid);
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  /// Log out and clear session
  Future<void> logOut() async {
    await _auth.signOut();
    await _clearLocalStorage();
  }

  /// Check authentication state changes
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  /// Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    if (currentUser == null) return null;

    DocumentSnapshot doc =
        await _firestore.collection('users').doc(currentUser!.uid).get();
    return doc.data() as Map<String, dynamic>?;
  }

  /// Save user login state to local storage
  Future<void> _saveUserIdToLocalStorage(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  /// Fetch user login state from local storage
  Future<String?> getUserIdFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  /// Clear user session from local storage
  Future<void> _clearLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
  }
}
