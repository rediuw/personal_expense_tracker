import 'package:flutter/material.dart';
import 'package:personal_expense_tracker/db_helper.dart' as db_helper;
import 'package:personal_expense_tracker/models/category_budget.dart'; 
import 'package:personal_expense_tracker/screens/manage_budgets_screen.dart';

class SetBudgetScreen extends StatefulWidget {
  final CategoryBudget? categoryBudget;

  const SetBudgetScreen({super.key, this.categoryBudget});

  @override
  State<SetBudgetScreen> createState() => _SetBudgetScreenState();
}

class _SetBudgetScreenState extends State<SetBudgetScreen> {
  final TextEditingController _budgetController = TextEditingController();
  final List<String> _categories = ['Food', 'Transport', 'Shopping', 'Entertainment', 'General'];
  String _selectedCategory = 'Food';
  String _errorText = '';

  @override
  void initState() {
    super.initState();
    if (widget.categoryBudget != null) {
      _selectedCategory = widget.categoryBudget!.category;
      _budgetController.text = widget.categoryBudget!.budget.toString();
    }
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryBudget == null ? 'Set Monthly Budget' : 'Edit Budget'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              TextField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Set Budget (ETB)',
                  hintText: 'Enter budget for $_selectedCategory',
                  errorText: _errorText.isEmpty ? null : _errorText,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 159, 243, 161)),
                  onPressed: _handleSaveBudget,
                  child: Text(widget.categoryBudget == null ? 'Save Budget' : 'Update Budget'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 159, 243, 161)),
                  onPressed: _goToManageBudgets,
                  child: const Text('Manage Budgets'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSaveBudget() async {
    final budgetText = _budgetController.text.trim();
    final double? budget = double.tryParse(budgetText);

    if (budget == null || budget <= 0) {
      setState(() {
        _errorText = 'Please enter a valid amount.';
      });
      return;
    }

    // Get the current date in YYYY-MM-DD format (no time)
    final currentDate = DateTime.now();
    final dateString = '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}';

    final categoryBudget = CategoryBudget(
      id: widget.categoryBudget?.id,
      category: _selectedCategory,
      budget: budget,
      date: dateString,
    );

    try {
      final dbHelper = db_helper.DatabaseHelper();

      // Check if a category budget with the same category and date already exists
      final existingBudget = await dbHelper.getCategoryBudgets();
      final existing = existingBudget.firstWhere(
        (item) => item.category == categoryBudget.category && item.date == categoryBudget.date,
        orElse: () => CategoryBudget(id: -1, category: '', budget: 0, date: ''), // Return a default CategoryBudget if not found
      );

      if (existing.id != -1) { // If it's not the default object, update the budget
        await dbHelper.updateCategoryBudget(categoryBudget);
        _showSnackBar('Budget updated successfully!');
      } else { // If no matching budget found, insert a new budget
        await dbHelper.insertCategoryBudget(categoryBudget);
        _showSnackBar('Budget added successfully!');
      }

      setState(() {
        _errorText = '';
        _budgetController.clear();
        _selectedCategory = 'Food';
      });
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
    }
  }

  void _goToManageBudgets() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ManageBudgetsScreen()),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
