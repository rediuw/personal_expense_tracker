import 'package:personal_expense_tracker/services/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models/expense.dart';
import 'models/category_budget.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  // Column names

  static const id = 'id';
  static const category = 'category';
  static const budget = 'budget';
  static const date = 'date'; 

  // Getter for the database
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'expense_tracker.db');
    print("Initializing database at $path");

    return await openDatabase(
      path,
      version: 2, // Incremented version to trigger onUpgrade
      onCreate: (db, version) async {

        // Create users table
        await db.execute('''
          CREATE TABLE users(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              username TEXT NOT NULL UNIQUE,
              email TEXT NOT NULL UNIQUE,
              password TEXT NOT NULL
          );
     ''');

        // Create expenses table
        await db.execute(''' 
          
          CREATE TABLE expenses(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            amount REAL,
            date TEXT,
            category TEXT,
            userId INTEGER NOT NULL,
            FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
          );
        ''');

        // Create category_budget table 
        await db.execute(''' 
          CREATE TABLE category_budget(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            category TEXT,
            budget REAL,
            date TEXT,
            userId INTEGER NOT NULL,
            FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE

          );
        ''');

        print("Database initialized successfully.");
      },
      onUpgrade: (db, oldVersion, newVersion) async {
          print("Database version upgrade detected: $oldVersion -> $newVersion");
        if (oldVersion < 2) {
          // Add the date column if it does not exist (to handle migrations)
          await db.execute(''' 
            ALTER TABLE category_budget ADD COLUMN date TEXT;
          ''');if (oldVersion < 2) {
  await db.execute("ALTER TABLE expenses ADD COLUMN userId INTEGER;");
  await db.execute("ALTER TABLE category_budget ADD COLUMN userId INTEGER;");
  await db.rawUpdate("UPDATE expenses SET userId = NULL;");
  await db.rawUpdate("UPDATE category_budget SET userId = NULL;");
}


          print("Database upgraded successfully.");

          // Fill the 'date' column with a default value (optional)
          await db.execute(''' 
            UPDATE category_budget 
            SET date = strftime('%Y-%m-%d', 'now') 
            WHERE date IS NULL;
          ''');

        }
      },
    );
  }
  // Insert a new user (Sign-up)
Future<int> insertUser(String username, String email, String password) async {
  final db = await database;
  return await db.insert(
    'users',
    {'username': username, 'email': email, 'password': password},
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

// Retrieve user by email/username and password (Login)
Future<Map<String, dynamic>?> getUser(String identifier, String password) async {
  final db = await database;
  final result = await db.query(
    'users',
    where: '(email = ? OR username = ?) AND password = ?',
    whereArgs: [identifier, identifier, password],
    limit: 1,
  );
  
  return result.isNotEmpty ? result.first : null;
}

// Retrieve user by ID (Session management)
Future<Map<String, dynamic>?> getUserById(int userId) async {
  final db = await database;
  final result = await db.query(
    'users',
    where: 'id = ?',
    whereArgs: [userId],
    limit: 1,
  );
  return result.isNotEmpty ? result.first : null;
}
//Insert new expense
  Future<void> insertExpense(Expense expense) async {
    final db = await database;
     final userId = await SharedPreferencesHelper().getUserSession();
    if(userId==null){
      throw Exception("User not logged in");
    }
    final expenseMap=expense.toMap();
    expenseMap['userId']=userId;
    print("Inserting expense: ${expense.toMap()}");
    await db.insert('expenses', expenseMap, conflictAlgorithm: ConflictAlgorithm.replace);
    print("Expense inserted: ${expense.toMap()}");
  }

  // Fetch all expenses 
  Future<List<Expense>> getExpenses() async {
  final db = await database;
  final userId = await SharedPreferencesHelper().getUserSession(); 
    if (userId == null) {
  throw Exception("User not logged in");
  }
  final List<Map<String, dynamic>> maps = await db.query(
    'expenses',
    where: 'userId = ?',
    whereArgs: [userId],
  );

  return List.generate(maps.length, (i) {
    return Expense.fromMap(maps[i]);
  });
}


  // Fetch monthly expenses summary with categories and budgets
Future<List<Map<String, dynamic>>> getMonthlyExpenses() async {
  final db = await database;
  final userId = await SharedPreferencesHelper().getUserSession();

  if (userId == null) {
    throw Exception("User not logged in");
  }

  final List<Map<String, dynamic>> result = await db.rawQuery(''' 
    SELECT strftime('%Y-%m', date) AS month_year, 
           strftime('%Y-%m-%d', date) AS day, -- Extract only the day
           category, 
           SUM(amount) AS total, 
           title
    FROM expenses
    WHERE userId = ? -- Filter by the userId
    GROUP BY month_year, day, category, title
    ORDER BY day DESC; -- Sort by day
  ''', [userId]);

  return result;
}


  // Fetch category budget details
  Future<List<CategoryBudget>> getCategoryBudgets() async {
    final db = await database;
    final userId=await SharedPreferencesHelper().getUserSession();
    if (userId == null) {
  throw Exception("User not logged in");
}
    
    final List<Map<String, dynamic>> maps = await db.query(
      'category_budget',
      where: 'userId=?',
      whereArgs: [userId],
      );
    return List.generate(maps.length, (i) {
      return CategoryBudget.fromMap(maps[i]);
    });
  }

  // Insert a category budget
  Future<void> insertCategoryBudget(CategoryBudget categoryBudget) async {
    final db = await database;
     final userId=await SharedPreferencesHelper().getUserSession();
    final budgetMap=categoryBudget.toMap();
    budgetMap['userId']=userId;
    await db.insert('category_budget', budgetMap, conflictAlgorithm: ConflictAlgorithm.replace);
    print("Category budget inserted: ${categoryBudget.toMap()}");
  }
  

  // Update an existing category budget
  Future<void> updateCategoryBudget(CategoryBudget categoryBudget) async {
    final db = await database;
    await db.update(
      'category_budget',
      categoryBudget.toMap(),
      where: 'id = ?',
      whereArgs: [categoryBudget.id],
    );
    print("Updated category budget: ${categoryBudget.toMap()}");
    
  }

  // Delete an expense by ID
  Future<void> deleteExpense(int id) async {
    final db = await database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  // Update an existing expense
  Future<void> updateExpense(Expense expense) async {
    final db = await database;
    await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  // Delete a category budget by ID
  Future<void> deleteCategoryBudget(int id) async {
    final db = await database;
    await db.delete('category_budget', where: 'id = ?', whereArgs: [id]);
  }
}