class Stylist {
  final String id;
  final String salonId;
  final String name;
  final String role;
  final double rating;
  final String avatar;
  final List<String> specialties;
  final int yearsExp;

  const Stylist({
    required this.id,
    required this.salonId,
    required this.name,
    required this.role,
    required this.rating,
    required this.avatar,
    required this.specialties,
    required this.yearsExp,
  });

  factory Stylist.fromJson(Map<String, dynamic> j) => Stylist(
    id: j['id'],
    salonId: j['salonId'],
    name: j['name'],
    role: j['role'],
    rating: (j['rating'] as num).toDouble(),
    avatar: j['avatar'],
    specialties: List<String>.from(j['specialties'] ?? []),
    yearsExp: j['yearsExp'] ?? 1,
  );
}
