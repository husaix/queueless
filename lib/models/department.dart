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

/// Predefined departments available in the application (exactly two)
class Departments {
  static const Department cafe = Department(
    id: 'cafe',
    name: 'Café',
    description: 'Food, snacks & beverage orders',
    avgServiceMinutes: 3,
  );

  static const Department adminOffice = Department(
    id: 'admin_office',
    name: 'Administration Office',
    description: 'Student services, forms & official approvals',
    avgServiceMinutes: 5,
  );

  static const List<Department> all = [cafe, adminOffice];

  static Department? byId(String id) {
    try {
      return all.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }
}
