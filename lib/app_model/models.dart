// ============================================================
// models/salon.dart
// ============================================================

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
  final double distance; // km (mock)
  final String priceRange; // $, $$, $$$
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

  factory Salon.fromJson(Map<String, dynamic> j) => Salon(
    id: j['id'],
    name: j['name'],
    tagline: j['tagline'] ?? '',
    address: j['address'],
    city: j['city'] ?? '',
    lat: (j['lat'] as num).toDouble(),
    lng: (j['lng'] as num).toDouble(),
    rating: (j['rating'] as num).toDouble(),
    reviewCount: j['reviewCount'],
    coverImage: j['coverImage'],
    images: List<String>.from(j['images'] ?? []),
    categories: List<String>.from(j['categories'] ?? []),
    openTime: j['openTime'] ?? '09:00',
    closeTime: j['closeTime'] ?? '20:00',
    isOpen: j['isOpen'] ?? true,
    distance: (j['distance'] as num).toDouble(),
    priceRange: j['priceRange'] ?? '\$\$',
    serviceIds: List<String>.from(j['serviceIds'] ?? []),
    phone: j['phone'] ?? '',
    description: j['description'] ?? '',
  );

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

// ============================================================
// models/service.dart
// ============================================================

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

// ============================================================
// models/stylist.dart
// ============================================================

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

// ============================================================
// models/review.dart
// ============================================================

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

// ============================================================
// models/promotion.dart
// ============================================================

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

// ============================================================
// models/booking.dart
// ============================================================

class Booking {
  final String id;
  final String salonId;
  final String salonName;
  final List<String> serviceIds;
  final List<String> serviceNames;
  final String stylistId;
  final String stylistName;
  final DateTime date;
  final String timeSlot;
  final String customerName;
  final String customerPhone;
  final double totalPrice;
  final String status; // upcoming, past, cancelled
  final String confirmationCode;

  const Booking({
    required this.id,
    required this.salonId,
    required this.salonName,
    required this.serviceIds,
    required this.serviceNames,
    required this.stylistId,
    required this.stylistName,
    required this.date,
    required this.timeSlot,
    required this.customerName,
    required this.customerPhone,
    required this.totalPrice,
    required this.status,
    required this.confirmationCode,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'salonId': salonId,
    'salonName': salonName,
    'serviceIds': serviceIds,
    'serviceNames': serviceNames,
    'stylistId': stylistId,
    'stylistName': stylistName,
    'date': date.toIso8601String(),
    'timeSlot': timeSlot,
    'customerName': customerName,
    'customerPhone': customerPhone,
    'totalPrice': totalPrice,
    'status': status,
    'confirmationCode': confirmationCode,
  };

  factory Booking.fromJson(Map<String, dynamic> j) => Booking(
    id: j['id'],
    salonId: j['salonId'],
    salonName: j['salonName'],
    serviceIds: List<String>.from(j['serviceIds']),
    serviceNames: List<String>.from(j['serviceNames']),
    stylistId: j['stylistId'],
    stylistName: j['stylistName'],
    date: DateTime.parse(j['date']),
    timeSlot: j['timeSlot'],
    customerName: j['customerName'],
    customerPhone: j['customerPhone'],
    totalPrice: (j['totalPrice'] as num).toDouble(),
    status: j['status'],
    confirmationCode: j['confirmationCode'],
  );
}

// ============================================================
// models/chat_message.dart
// ============================================================

class ChatMessage {
  final String id;
  final String salonId;
  final String text;
  final bool isMe;
  final DateTime timestamp;
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.salonId,
    required this.text,
    required this.isMe,
    required this.timestamp,
    required this.isRead,
  });
}

class ChatThread {
  final String salonId;
  final String salonName;
  final String salonAvatar;
  final String lastMessage;
  final DateTime lastTime;
  final int unreadCount;

  const ChatThread({
    required this.salonId,
    required this.salonName,
    required this.salonAvatar,
    required this.lastMessage,
    required this.lastTime,
    required this.unreadCount,
  });
}

// ============================================================
// models/gallery_item.dart
// ============================================================

class GalleryItem {
  final String id;
  final String salonId;
  final String url;
  final bool isVideo;
  final String caption;
  final String category;

  const GalleryItem({
    required this.id,
    required this.salonId,
    required this.url,
    required this.isVideo,
    required this.caption,
    required this.category,
  });

  factory GalleryItem.fromJson(Map<String, dynamic> j) => GalleryItem(
    id: j['id'],
    salonId: j['salonId'] ?? '',
    url: j['url'],
    isVideo: j['isVideo'] ?? false,
    caption: j['caption'] ?? '',
    category: j['category'] ?? 'All',
  );
}