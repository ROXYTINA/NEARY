class Review {
  final String id;
  final String salonId;
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final String date;
  final List<String> photos;
  final String service;

  const Review({
    required this.id,
    required this.salonId,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    required this.date,
    required this.photos,
    required this.service,
  });

  factory Review.fromJson(Map<String, dynamic> j) => Review(
    id: j['id'],
    salonId: j['salonId'] ?? '',
    userName: j['userName'],
    userAvatar: j['userAvatar'],
    rating: (j['rating'] as num).toDouble(),
    comment: j['comment'],
    date: j['date'],
    photos: List<String>.from(j['photos'] ?? []),
    service: j['service'] ?? '',
  );
}
