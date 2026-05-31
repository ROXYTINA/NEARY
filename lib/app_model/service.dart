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
    id: j['id'],
    salonId: j['salonId'],
    name: j['name'],
    category: j['category'],
    durationMinutes: j['durationMinutes'],
    price: (j['price'] as num).toDouble(),
    description: j['description'] ?? '',
    beforeAfterImages: List<String>.from(j['beforeAfterImages'] ?? []),
    stylistIds: List<String>.from(j['stylistIds'] ?? []),
    rating: (j['rating'] as num? ?? 4.5).toDouble(),
  );

  String get durationLabel {
    final h = durationMinutes ~/ 60;
    final m = durationMinutes % 60;
    if (h == 0) return '${m}min';
    if (m == 0) return '${h}h';
    return '${h}h ${m}min';
  }
}
