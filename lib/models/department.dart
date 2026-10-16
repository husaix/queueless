class Department {
  final String id;
  final String name;
  final String description;
  final int avgServiceMinutes; // for estimated wait

  const Department({
    required this.id,
    required this.name,
    required this.description,
    this.avgServiceMinutes = 5,
  });
}

/// Predefined departments for the prototype (no backend yet)
class Departments {
  static const List<Department> all = [
    Department(
      id: 'student_affairs',
      name: 'Student Affairs',
      description: 'Registration, certificates & general student services',
      avgServiceMinutes: 4,
    ),
    Department(
      id: 'canteen',
      name: 'Canteen',
      description: 'Order & collect food',
      avgServiceMinutes: 3,
    ),
    Department(
      id: 'library',
      name: 'Library Desk',
      description: 'Book issue / return & inquiries',
      avgServiceMinutes: 2,
    ),
    Department(
      id: 'clinic',
      name: 'Campus Clinic',
      description: 'Medical consultation & first aid',
      avgServiceMinutes: 8,
    ),
    Department(
      id: 'admin_office',
      name: 'Admin Office',
      description: 'Official documents & approvals',
      avgServiceMinutes: 6,
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
