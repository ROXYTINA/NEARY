class SalonService {
  final String id;
  final String salonId;
  final String name;
  final String category;
  final int durationMinutes;
  final double price;
  final String description;
  final List<String> beforeAfterImages;
  final List<String> stylistIds;
  final double rating;

  const SalonService({
    required this.id,
    required this.salonId,
    required this.name,
    required this.category,
    required this.durationMinutes,
    required this.price,
    required this.description,
    required this.beforeAfterImages,
    required this.stylistIds,
    required this.rating,
  });

  factory SalonService.fromJson(Map<String, dynamic> j) => SalonService(
    id: j['id']?.toString() ?? '',
    salonId: j['salonId']?.toString() ?? j['salon_id']?.toString() ?? '',
    name: j['name']?.toString() ?? '',
    category: j['category']?.toString() ?? '',
    durationMinutes: (j['durationMinutes'] as num?)?.toInt() ?? 0,
    price: (j['price'] as num?)?.toDouble() ?? 0.0,
    description: j['description']?.toString() ?? '',
    beforeAfterImages: List<String>.from(j['beforeAfterImages'] ?? []),
    stylistIds: List<String>.from(j['stylistIds'] ?? []),
    rating: (j['rating'] as num?)?.toDouble() ?? 4.5,
  );

  String get durationLabel {
    final h = durationMinutes ~/ 60;
    final m = durationMinutes % 60;
    if (h == 0) return '${m}min';
    if (m == 0) return '${h}h';
    return '${h}h ${m}min';
  }
}
