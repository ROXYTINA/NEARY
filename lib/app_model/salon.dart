class Salon {
  final String id;
  final String name;
  final String tagline;
  final String address;
  final String city;
  final double lat;
  final double lng;
  final double rating;
  final int reviewCount;
  final String coverImage;
  final List<String> images;
  final List<String> categories;
  final String openTime;
  final String closeTime;
  final bool isOpen;
  final double distance;
  final String priceRange;
  final List<String> serviceIds;
  final String phone;
  final String description;

  const Salon({
    required this.id,
    required this.name,
    required this.tagline,
    required this.address,
    required this.city,
    required this.lat,
    required this.lng,
    required this.rating,
    required this.reviewCount,
    required this.coverImage,
    required this.images,
    required this.categories,
    required this.openTime,
    required this.closeTime,
    required this.isOpen,
    required this.distance,
    required this.priceRange,
    required this.serviceIds,
    required this.phone,
    required this.description,
  });

  factory Salon.fromJson(Map<String, dynamic> j) {
    return Salon(
      id:          j['id']?.toString() ?? '',
      name:        j['name'] ?? 'Unknown Salon',
      tagline:     j['tagline'] ?? '',
      address:     j['address'] ?? '',
      city:        j['city'] ?? '',
      lat:         (j['latitude']  as num? ?? 0.0).toDouble(),
      lng:         (j['longitude'] as num? ?? 0.0).toDouble(),
      rating:      (j['rating']    as num? ?? 0.0).toDouble(),
      reviewCount: j['review_count'] ?? 0,
      coverImage: j['cover_image'] ?? j['coverImage'] ??
          ((j['images'] is List && (j['images'] as List).isNotEmpty)
              ? j['images'][0]
              : ''),
      images:      (j['images'] is List) ? List<String>.from(j['images']) : [],
      categories:  List<String>.from(j['categories'] ?? []),
      openTime:    j['open_time']  ?? '09:00',
      closeTime:   j['close_time'] ?? '20:00',
      isOpen:      j['is_open']    ?? true,
      distance:    (j['distance']  as num? ?? 0.0).toDouble(),
      priceRange:  j['price_range'] ?? '\$\$',
      serviceIds:  List<String>.from(j['service_ids'] ?? []),
      phone:       j['phone'] ?? '',
      description: j['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'tagline': tagline,
    'address': address,
    'city': city,
    'lat': lat,
    'lng': lng,
    'rating': rating,
    'reviewCount': reviewCount,
    'coverImage': coverImage,
    'images': images,
    'categories': categories,
    'openTime': openTime,
    'closeTime': closeTime,
    'isOpen': isOpen,
    'distance': distance,
    'priceRange': priceRange,
    'serviceIds': serviceIds,
    'phone': phone,
    'description': description,
  };
}
