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

  factory Review.fromJson(Map<String, dynamic> j) =>
      Review(
        id: j['id']?.toString() ?? '',
        salonId: j['salon_id']?.toString() ?? j['salonId']?.toString() ?? '',
        userName: j['userName']?.toString() ?? j['user_id']?.toString() ??
            'Anonymous',
        userAvatar: j['userAvatar']?.toString() ?? '',
        rating: (j['rating'] as num? ?? 0).toDouble(),
        comment: j['comment']?.toString() ?? '',
        date: j['date']?.toString() ?? j['created_at']?.toString() ?? '',
        photos: List<String>.from(j['photos'] ?? []),
        service: j['service']?.toString() ?? '',
      );
}