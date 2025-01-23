import 'package:flutter/material.dart';
import 'package:personal_expense_tracker/models/expense.dart';
import 'package:personal_expense_tracker/db_helper.dart';
import 'package:personal_expense_tracker/screens/add_expense_screen.dart';

class ExpenseDetailsScreen extends StatefulWidget {
  const ExpenseDetailsScreen({super.key});

  @override
  _ExpenseDetailsScreenState createState() => _ExpenseDetailsScreenState();
}

class _ExpenseDetailsScreenState extends State<ExpenseDetailsScreen> {
  late Future<List<Expense>> _expenses;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  void _loadExpenses() {
    setState(() {
      _expenses = _dbHelper.getExpenses();
    });
  }

  void _deleteExpense(int id) async {
    try {
      await _dbHelper.deleteExpense(id);
      _showSnackBar("Expense deleted successfully.");
      _loadExpenses();
    } catch (e) {
      _showSnackBar("Error deleting expense: $e");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _openAddExpenseScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddExpenseScreen(expense: null)),
    );

    if (result != null) {
      _showSnackBar("Expense added successfully.");
      _loadExpenses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Details'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _openAddExpenseScreen,
          ),
        ],
      ),
      body: FutureBuilder<List<Expense>>(
        future: _expenses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No expenses added yet.'));
          }

          final expenses = snapshot.data!;

          return ListView.builder(
            itemCount: expenses.length,
            padding: const EdgeInsets.all(16.0),
            itemBuilder: (context, index) {
              final expense = expenses[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Colors.green,
                    radius: 24,
                    child: Text(
                      expense.category[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    expense.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${expense.amount.toStringAsFixed(2)} ETB\n${expense.category}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteExpense(expense.id!),
                  ),
                  onTap: () async {
                    final updatedExpense = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddExpenseScreen(expense: expense),
                      ),
                    );

                    if (updatedExpense != null) {
                      _showSnackBar("Expense updated successfully.");
                      _loadExpenses();
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
