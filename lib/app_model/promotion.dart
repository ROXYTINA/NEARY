class Promotion {
  final String id;
  final String salonId;
  final String salonName;
  final String title;
  final String description;
  final String code;
  final int discountPercent;
  final String expiryDate;
  final String image;
  final String category;

  const Promotion({
    required this.id,
    required this.salonId,
    required this.salonName,
    required this.title,
    required this.description,
    required this.code,
    required this.discountPercent,
    required this.expiryDate,
    required this.image,
    required this.category,
  });

  factory Promotion.fromJson(Map<String, dynamic> j) => Promotion(
    id: j['id'],
    salonId: j['salonId'] ?? '',
    salonName: j['salonName'] ?? '',
    title: j['title'],
    description: j['description'],
    code: j['code'],
    discountPercent: j['discountPercent'],
    expiryDate: j['expiryDate'],
    image: j['image'],
    category: j['category'] ?? 'General',
  );
}
