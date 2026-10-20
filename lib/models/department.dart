class Department {
  final String id;
  final String name;
  final String description;
  final int avgServiceMinutes;

  const Department({
    required this.id,
    required this.name,
    required this.description,
    this.avgServiceMinutes = 5,
  });
}

/// Predefined departments - restricted to exactly two departments as required.
class Departments {
  static const String cafeId = 'cafe';
  static const String adminOfficeId = 'admin_office';

  static const List<Department> all = [
    Department(
      id: cafeId,
      name: 'Café',
      description: 'Order food, coffee, beverages & snacks',
      avgServiceMinutes: 3,
    ),
    Department(
      id: adminOfficeId,
      name: 'Administration Office',
      description: 'Student records, certificates & official approvals',
      avgServiceMinutes: 5,
    ),
  ];

  static Department? byId(String id) {
    try {
      return all.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }
}
