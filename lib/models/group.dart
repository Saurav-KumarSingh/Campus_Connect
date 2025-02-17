// group.dart
class Group {
  final String id;
  final String name;
  final List<String> members; // List of admission numbers
  final String admin;         // Admin's admission number

  Group({
    required this.id,
    required this.name,
    required this.members,
    required this.admin,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'members': members,
      'admin': admin,
    };
  }

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      members: List<String>.from(map['members'] ?? []),
      admin: map['admin'] ?? '',
    );
  }
}
