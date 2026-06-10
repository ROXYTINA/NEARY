
import 'dart:convert';

class Stylist {
  final String id;
  final String salonId;
  final String name;
  final String role;
  final double rating;
  final String avatar;
  final List<String> skills;

  Stylist({
    required this.id,
    required this.salonId,
    required this.name,
    required this.role,
    required this.rating,
    required this.avatar,
    required this.skills,
  });

  factory Stylist.fromJson(Map<String, dynamic> json) {
    final rawSkills = json['specialties'] ?? json['skills']; // support both

    return Stylist(
      id: json['id'] ?? '',
      salonId: json['salon_id'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      avatar: json['avatar'] ?? '',
      skills: rawSkills == null
          ? []
          : rawSkills is String
          ? List<String>.from(jsonDecode(rawSkills))
          : List<String>.from(rawSkills),
    );
  }

}