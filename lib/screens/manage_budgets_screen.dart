import 'package:flutter/material.dart';
import 'package:personal_expense_tracker/db_helper.dart' as db_helper;
import 'package:personal_expense_tracker/models/category_budget.dart';
import 'package:personal_expense_tracker/screens/budget_setting_screen.dart'; // Correct import

class ManageBudgetsScreen extends StatefulWidget {
  const ManageBudgetsScreen({super.key});

  @override
  _ManageBudgetsScreenState createState() => _ManageBudgetsScreenState();
}

class _ManageBudgetsScreenState extends State<ManageBudgetsScreen> {
  Map<String, List<CategoryBudget>> _groupedBudgets = {};
  double _totalBudget = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchAndGroupByDate();
  }

  void _fetchAndGroupByDate() async {
    final dbHelper = db_helper.DatabaseHelper();
    List<CategoryBudget> allBudgets = await dbHelper.getCategoryBudgets();

    Map<String, Map<String, double>> groupedByDate = {};
    for (var budget in allBudgets) {
      if (!groupedByDate.containsKey(budget.date)) {
        groupedByDate[budget.date] = {};
      }

      groupedByDate[budget.date]!.update(
        budget.category,
        (existing) => existing + budget.budget,
        ifAbsent: () => budget.budget,
      );
    }

Map<String, List<CategoryBudget>> groupedBudgets = {};
groupedByDate.forEach((date, categories) {
  groupedBudgets[date] = categories.entries
      .map((entry) {
        var categoryBudget = allBudgets.firstWhere((budget) =>
            budget.category == entry.key && budget.date == date,
            orElse: () => CategoryBudget(id: null, category: entry.key, budget: 0.0, date: date)); 

        return CategoryBudget(
          id: categoryBudget.id,  // Get the id from the found CategoryBudget
          category: entry.key,    // Category name (from entry.key)
          budget: entry.value,    // Total budget for this category (from entry.value)
          date: date,             // Date (from the outer key)
        );
      })
      .toList();
});

    double totalBudget = allBudgets.fold(0.0, (sum, budget) => sum + budget.budget);

    setState(() {
      _groupedBudgets = groupedBudgets;
      _totalBudget = totalBudget;
    });
  }

  void _deleteBudget(int? id) async {
     print("Deleting budget with ID: $id"); 
    if (id == null) return;
    final dbHelper = db_helper.DatabaseHelper();
    await dbHelper.deleteCategoryBudget(id);
    _fetchAndGroupByDate();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Budget deleted successfully')));
  }

  void _editBudget(CategoryBudget categoryBudget) {
    print("Editing budget: ${categoryBudget.id}, ${categoryBudget.category}, ${categoryBudget.budget}");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SetBudgetScreen(categoryBudget: categoryBudget)),
    ).then((_) => _fetchAndGroupByDate());
  }

  // Function to format the date (e.g., '2024-12-25' => 'December 25, 2024')
  String _formatDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    return "${_getMonthName(dateTime.month)} ${dateTime.day}, ${dateTime.year}";
  }

  // Helper function to get the month name from the month number
  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Budgets'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          
          Expanded(
            child: _groupedBudgets.isEmpty
                ? const Center(child: Text('No budgets added yet!'))
                : ListView(
                    children: _groupedBudgets.entries.map((entry) {
                      final date = entry.key;
                      final budgets = entry.value;

                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ExpansionTile(
                          title: Text(
                            _formatDate(date),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Total: ${budgets.fold(0.0, (total, budget) => total + budget.budget)} ETB',
                            style: const TextStyle(color: Colors.green),
                          ),
                          children: budgets.map<Widget>((budget) {
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: ExpansionTile(
                                title: Text(budget.category),
                                subtitle: Text('Total: ${budget.budget} ETB'),
                                children: [
                                  ListTile(
                                    dense: true,
                                    title: Text('Category: ${budget.category}'),
                                    trailing: Text('${budget.budget} ETB'),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () => _editBudget(budget),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: (){
                                          print("Deleting budget: ${budget.id}"); 
                                           _deleteBudget(budget.id);
                                        }
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
