import 'package:flutter/material.dart';
import 'package:personal_expense_tracker/models/expense.dart';
import 'package:personal_expense_tracker/db_helper.dart';
import 'package:personal_expense_tracker/screens/expense_details_screen.dart'; // Import ExpenseDetailsScreen

class AddExpenseScreen extends StatefulWidget {
  final Expense? expense; // Make the expense parameter nullable

  const AddExpenseScreen({super.key, this.expense}); // Optional constructor

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String _selectedCategory = 'General';

  final List<String> _categories = ['General', 'Food', 'Transport', 'Shopping', 'Entertainment'];

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      // If editing an existing expense, pre-fill the form with data
      _titleController.text = widget.expense!.title;
      _amountController.text = widget.expense!.amount.toString();
      _selectedCategory = widget.expense!.category;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.expense == null ? const Text('Add Expense') : const Text('Edit Expense'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Expense Title Input
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Expense Title',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),

              // Expense Amount Input
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Expense Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Add/Update Expense Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleAddOrUpdateExpense,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 159, 243, 161),
                  ),
                  child: widget.expense == null
                      ? const Text('Add Expense')
                      : const Text('Update Expense'),
                ),
              ),
              const SizedBox(height: 16),

              // Button to go back to ExpenseDetailsScreen
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _goBackToExpenseDetailsScreen,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 159, 243, 161),
                  ),
                  child: const Text('Expense Details'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAddOrUpdateExpense() async {
    final String title = _titleController.text.trim();
    final String amountText = _amountController.text.trim();

    // Validate inputs
    if (title.isEmpty || amountText.isEmpty) {
      _showSnackBar("Please fill all the fields.");
      return;
    }

    // Validate amount
    final double? amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showSnackBar("Enter a valid amount.");
      return;
    }

    final expense = Expense(
      id: widget.expense?.id, // If editing, retain the original id
      title: title,
      amount: amount,
      date: DateTime.now(),
      category: _selectedCategory,
    );

    try {
      if (widget.expense == null) {
        // Adding a new expense
        await DatabaseHelper().insertExpense(expense);
        _showSnackBar("Expense added successfully!");
      } else {
        // Updating an existing expense
        await DatabaseHelper().updateExpense(expense);
        _showSnackBar("Expense updated successfully!");
      }

      // Keep the user on the same screen (AddExpenseScreen)
      setState(() {
        // Reset the form after adding/updating
        _titleController.clear();
        _amountController.clear();
        _selectedCategory = 'General';
      });
    } catch (e) {
      _showSnackBar("Something went wrong. Please try again.");
    }
  }

  void _goBackToExpenseDetailsScreen() {
    // Navigate back to the ExpenseDetailsScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ExpenseDetailsScreen()),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
