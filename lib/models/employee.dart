class Employee {
  final int id;
  final String name;
  final double salary;
  final String username;
  final bool active;

  const Employee({
    required this.id,
    required this.name,
    required this.salary,
    required this.username,
    required this.active,
  });

  factory Employee.fromMap(Map<String, Object?> map) {
    return Employee(
      id: map['id'] as int,
      name: map['name'] as String,
      salary: (map['salary'] as num).toDouble(),
      username: map['username'] as String,
      active: (map['active'] as int? ?? 0) == 1,
    );
  }
}
