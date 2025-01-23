import 'package:flutter/material.dart';
import 'package:personal_expense_tracker/db_helper.dart';

class MonthlyExpenseSummaryScreen extends StatefulWidget {
  const MonthlyExpenseSummaryScreen({super.key});

  @override
  State<MonthlyExpenseSummaryScreen> createState() =>
      _MonthlyExpenseSummaryScreenState();
}

class _MonthlyExpenseSummaryScreenState
    extends State<MonthlyExpenseSummaryScreen> {
  late Future<List<Map<String, dynamic>>> _monthlyExpenses;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadMonthlyExpenses();
  }

  // Function to load the monthly expenses
  void _loadMonthlyExpenses() {
    setState(() {
      _monthlyExpenses = _dbHelper.getMonthlyExpenses();
    });
  }

  // Function to format the month-year (e.g., '2024-12' => 'December 2024')
  String _formatMonthYear(String monthYear) {
    DateTime date = DateTime.parse('$monthYear-01');
    return "${_getMonthName(date.month)} ${date.year}";
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
        title: const Text('Monthly Expense Summary'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>( 
        future: _monthlyExpenses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available.'));
          }

          final monthlyExpenses = snapshot.data!;

          // Grouping the expenses by month
          Map<String, List<Map<String, dynamic>>> groupedByMonth = {};

          for (var expense in monthlyExpenses) {
            final monthYear = expense['month_year'];
            if (!groupedByMonth.containsKey(monthYear)) {
              groupedByMonth[monthYear] = [];
            }
            groupedByMonth[monthYear]!.add(expense);
          }

          return ListView(
            children: groupedByMonth.keys.map<Widget>((monthYear) {
              final monthName = _formatMonthYear(monthYear);
              final expenses = groupedByMonth[monthYear]!;

              // Grouping expenses by category
              Map<String, List<Map<String, dynamic>>> groupedByCategory = {};

              for (var expense in expenses) {
                final category = expense['category'];
                if (!groupedByCategory.containsKey(category)) {
                  groupedByCategory[category] = [];
                }
                groupedByCategory[category]!.add(expense);
              }

              return Card(
                margin: const EdgeInsets.all(8),
                child: ExpansionTile(
                  title: Text(
                    monthName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Total: ${expenses.fold(0.0, (total, e) => total + (e['total'] ?? 0.0))} ETB',
                    style: const TextStyle(color: Colors.green),
                  ),
                  children: groupedByCategory.keys.map<Widget>((category) {
                    final categoryExpenses = groupedByCategory[category]!;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ExpansionTile(
                        title: Text(category),
                        subtitle: Text(
                            'Total: ${categoryExpenses.fold(0.0, (total, e) => total + (e['total'] ?? 0.0))} ETB'),
                        children: categoryExpenses.map<Widget>((expense) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                child: Text(
                                  'Date: ${expense['day']}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              ListTile(
                                dense: true,
                                title: Text(expense['title'] ?? 'No description'),
                                trailing: Text('${expense['total']} ETB'),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
