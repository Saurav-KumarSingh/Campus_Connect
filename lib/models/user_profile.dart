class UserProfile {
  String id;
  String name;
  String email;
  String graduationYear;
  String admissionNo;
  String bio;
  String? profileImage; // Add profileImage field

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.graduationYear,
    required this.admissionNo,
    required this.bio,
    this.profileImage, // Initialize profileImage as nullable
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'graduationYear': graduationYear,
      'admissionNo': admissionNo,
      'bio': bio,
      'profileImage': profileImage, // Include profileImage
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      graduationYear: map['graduationYear'],
      admissionNo: map['admissionNo'],
      bio: map['bio'],
      profileImage: map['profileImage'], // Get profileImage from map
    );
  }
}
