class Expense {
  final int? id; // `int?` to allow null
  final String title;
  final double amount;
  final DateTime date;
  final String category;

  Expense({
    this.id, // id can be nullable
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });

  // Convert Expense to Map for DB insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id, // The id is nullable here
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
    };
  }

  // Convert Map back to Expense object
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'], 
      title: map['title'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      category: map['category'],
    );
  }
}
