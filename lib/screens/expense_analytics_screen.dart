import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:personal_expense_tracker/db_helper.dart';
import 'package:personal_expense_tracker/models/expense.dart';

class ExpenseAnalyticsScreen extends StatefulWidget {
  const ExpenseAnalyticsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ExpenseAnalyticsScreenState createState() => _ExpenseAnalyticsScreenState();
}

class _ExpenseAnalyticsScreenState extends State<ExpenseAnalyticsScreen> {
  List<Expense> _expenses = [];
  Map<String, double> categoryTotals = {};
  double totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  // Load expenses from the database and calculate totals by category
  void _loadExpenses() async {
    final dbHelper = DatabaseHelper();
    final expenses = await dbHelper.getExpenses();

    setState(() {
      _expenses = expenses;
      categoryTotals.clear();
      totalAmount = 0.0;

      for (var expense in _expenses) {
        final category = expense.category.isNotEmpty ? expense.category : 'Uncategorized';
        categoryTotals[category] = (categoryTotals[category] ?? 0) + expense.amount;
        totalAmount += expense.amount;
      }

      print("Category Totals: $categoryTotals"); // Debugging
      print("Total Amount: $totalAmount"); // Debugging
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Analytics'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: categoryTotals.isEmpty
          ? const Center(child: Text('No data available for analytics.'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Expense Breakdown by Category',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Pie Chart and Legend
                  Expanded(
                    child: Row(
                      children: [
                        // Pie Chart
                        Expanded(
                          child: PieChart(
                            PieChartData(
                              sections: _buildPieChartSections(),
                              borderData: FlBorderData(show: false),
                              sectionsSpace: 4,
                              centerSpaceRadius: 40,
                            ),
                          ),
                        ),
                        // Legend
                        _buildLegend(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Build PieChartSections with percentages
  List<PieChartSectionData> _buildPieChartSections() {
    return categoryTotals.entries.map((entry) {
      final percentage = (entry.value / totalAmount) * 100;

      return PieChartSectionData(
        color: _getCategoryColor(entry.key),
        value: percentage,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  // Build a legend widget
  Widget _buildLegend() {
    return Expanded(
      child: ListView(
        children: categoryTotals.entries.map((entry) {
          final percentage = (entry.value / totalAmount) * 100;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                // Color Indicator
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(entry.key),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                // Category Name and Percentage
                Expanded(
                  child: Text(
                    '${entry.key} - ${percentage.toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // Get a color based on category
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food':
        return Colors.green;
      case 'Transport':
        return Colors.blue;
      case 'Shopping':
        return Colors.orange;
      case 'Entertainment':
        return Colors.purple;
      case 'General':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }
}
