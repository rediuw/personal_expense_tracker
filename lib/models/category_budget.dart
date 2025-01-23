class CategoryBudget {
  int? id;            // ID can be nullable
  String category;    // Category name
  double budget;      // Budget amount
  String date;        // Date as a string in YYYY-MM-DD format

  // Constructor to initialize CategoryBudget object
  CategoryBudget({
    this.id,            // ID is nullable, can be null if it's a new object
    required this.category,  // Category name
    required this.budget,    // Budget amount
    required this.date,      // Date of the budget
  });

  // Convert CategoryBudget object to a Map (for inserting into database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,            // Nullable ID
      'category': category, // Category field
      'budget': budget,     // Budget field
      'date': date,         // Date field
    };
  }

  // Convert a Map (from database) to CategoryBudget object
  CategoryBudget.fromMap(Map<String, dynamic> map)
      : id = map['id'],          // Extract ID from map
        category = map['category'],  // Extract category from map
        budget = map['budget'],      // Extract budget from map
        date = map['date'];         // Extract date from map

  // Print method to verify the object
  @override
  String toString() {
    return 'CategoryBudget{id: $id, category: $category, budget: $budget, date: $date}';
  }
}
