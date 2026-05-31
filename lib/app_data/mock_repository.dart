import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../app_model/models.dart';

class MockRepository {
  static MockRepository? _instance;
  MockRepository._();
  static MockRepository get instance => _instance ??= MockRepository._();

  List<Salon> _salons = [];
  List<SalonService> _services = [];
  List<Stylist> _stylists = [];
  List<Review> _reviews = [];
  List<Promotion> _promotions = [];
  List<GalleryItem> _gallery = [];

  bool _loaded = false;

  Future<void> init() async {
    if (_loaded) return;

    try {
      _salons = await _loadJsonList<Salon>(
        assetPath: 'assets/mock/salons.json',
        label: 'salons',
        fallback: _defaultSalons(),
        fromJson: (json) => Salon.fromJson(json),
      );

      _services = await _loadJsonList<SalonService>(
        assetPath: 'assets/mock/services.json',
        label: 'services',
        fallback: _defaultServices(),
        fromJson: (json) => SalonService.fromJson(json),
      );

      final data = await _loadJsonMap(
        assetPath: 'assets/mock/data.json',
        label: 'mock data blob',
      );

      _stylists = _parseNestedList<Stylist>(
        data['stylists'],
        label: 'stylists',
        fallback: _defaultStylists(),
        fromJson: (json) => Stylist.fromJson(json),
      );

      _reviews = _parseNestedList<Review>(
        data['reviews'],
        label: 'reviews',
        fallback: _defaultReviews(),
        fromJson: (json) => Review.fromJson(json),
      );

      _promotions = _parseNestedList<Promotion>(
        data['promotions'],
        label: 'promotions',
        fallback: _defaultPromotions(),
        fromJson: (json) => Promotion.fromJson(json),
      );

      _gallery = _parseNestedList<GalleryItem>(
        data['gallery'],
        label: 'gallery',
        fallback: _defaultGallery(),
        fromJson: (json) => GalleryItem.fromJson(json),
      );
    } catch (e, st) {
      debugPrint('MockRepository.init failed unexpectedly: $e');
      debugPrint('$st');
      _applyFallbackData();
    } finally {
      _loaded = true;
    }
  }

  Future<String?> _loadAssetString(String assetPath, {required String label}) async {
    try {
      final raw = await rootBundle.loadString(assetPath);
      if (raw.trim().isEmpty) {
        debugPrint('MockRepository: $label asset is empty: $assetPath');
        return null;
      }
      return raw;
    } catch (e, st) {
      debugPrint('MockRepository: failed to load $label from $assetPath: $e');
      debugPrint('$st');
      return null;
    }
  }

  Future<List<T>> _loadJsonList<T>({
    required String assetPath,
    required String label,
    required T Function(Map<String, dynamic>) fromJson,
    required List<T> fallback,
  }) async {
    final raw = await _loadAssetString(assetPath, label: label);
    if (raw == null) return fallback;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        debugPrint('MockRepository: expected a JSON list for $label at $assetPath, got ${decoded.runtimeType}');
        return fallback;
      }

      return decoded.map((item) {
        if (item is Map<String, dynamic>) {
          return fromJson(item);
        }
        if (item is Map) {
          return fromJson(Map<String, dynamic>.from(item));
        }
        throw const FormatException('JSON list item is not an object');
      }).toList();
    } on FormatException catch (e, st) {
      debugPrint('MockRepository: invalid JSON in $label at $assetPath: $e');
      debugPrint('$st');
      return fallback;
    } catch (e, st) {
      debugPrint('MockRepository: failed parsing $label at $assetPath: $e');
      debugPrint('$st');
      return fallback;
    }
  }

  Future<Map<String, dynamic>> _loadJsonMap({
    required String assetPath,
    required String label,
  }) async {
    final raw = await _loadAssetString(assetPath, label: label);
    if (raw == null) return <String, dynamic>{};

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }

      debugPrint('MockRepository: expected a JSON object for $label at $assetPath, got ${decoded.runtimeType}');
      return <String, dynamic>{};
    } on FormatException catch (e, st) {
      debugPrint('MockRepository: invalid JSON in $label at $assetPath: $e');
      debugPrint('$st');
      return <String, dynamic>{};
    } catch (e, st) {
      debugPrint('MockRepository: failed parsing $label at $assetPath: $e');
      debugPrint('$st');
      return <String, dynamic>{};
    }
  }

  List<T> _parseNestedList<T>(
    Object? raw, {
    required String label,
    required List<T> fallback,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    if (raw == null) {
      debugPrint('MockRepository: $label list missing, using fallback data');
      return fallback;
    }

    try {
      if (raw is! List) {
        debugPrint('MockRepository: expected a JSON list for $label, got ${raw.runtimeType}');
        return fallback;
      }

      return raw.map((item) {
        if (item is Map<String, dynamic>) {
          return fromJson(item);
        }
        if (item is Map) {
          return fromJson(Map<String, dynamic>.from(item));
        }
        throw const FormatException('JSON list item is not an object');
      }).toList();
    } on FormatException catch (e, st) {
      debugPrint('MockRepository: invalid nested JSON in $label: $e');
      debugPrint('$st');
      return fallback;
    } catch (e, st) {
      debugPrint('MockRepository: failed parsing nested $label: $e');
      debugPrint('$st');
      return fallback;
    }
  }

  void _applyFallbackData() {
    _salons = _defaultSalons();
    _services = _defaultServices();
    _stylists = _defaultStylists();
    _reviews = _defaultReviews();
    _promotions = _defaultPromotions();
    _gallery = _defaultGallery();
  }

  List<Salon> _defaultSalons() => const [
        Salon(
          id: 's1',
          name: 'Serenity Salon & Spa',
          tagline: 'Luxury beauty at its finest',
          address: '123 Rose Avenue, Downtown',
          city: 'New York',
          lat: 40.758,
          lng: -73.9855,
          rating: 4.8,
          reviewCount: 245,
          coverImage: 'https://images.unsplash.com/photo-1600948836101-f3271d530e0f?w=400&h=300&fit=crop',
          images: [
            'https://images.unsplash.com/photo-1600948836101-f3271d530e0f?w=400&h=300&fit=crop',
          ],
          categories: ['Hair', 'Makeup', 'Spa'],
          openTime: '09:00',
          closeTime: '20:00',
          isOpen: true,
          distance: 0.8,
          priceRange: r'$$$',
          serviceIds: ['svc1'],
          phone: '(555) 123-4567',
          description: 'Fallback salon data used when assets are missing or invalid.',
        ),
      ];

  List<SalonService> _defaultServices() => const [
        SalonService(
          id: 'svc1',
          salonId: 's1',
          name: 'Classic Haircut',
          category: 'Hair',
          durationMinutes: 30,
          price: 45.0,
          description: 'Fallback service data used when assets are missing or invalid.',
          beforeAfterImages: [],
          stylistIds: ['st1'],
          rating: 4.8,
        ),
      ];

  List<Stylist> _defaultStylists() => const [
        Stylist(
          id: 'st1',
          salonId: 's1',
          name: 'Emma Stone',
          role: 'Senior Stylist',
          rating: 4.9,
          avatar: '',
          specialties: ['Hair', 'Styling'],
          yearsExp: 7,
        ),
      ];

  List<Review> _defaultReviews() => const <Review>[];

  List<Promotion> _defaultPromotions() => const <Promotion>[];

  List<GalleryItem> _defaultGallery() => const <GalleryItem>[];

  // ---- Salons ----
  List<Salon> getAllSalons() => List.unmodifiable(_salons);

  List<Salon> getFeaturedSalons() =>
      _salons.where((s) => s.rating >= 4.7).take(6).toList();

  List<Salon> getSalonsByCategory(String category) =>
      category == 'All'
          ? _salons
          : _salons.where((s) => s.categories.contains(category)).toList();

  List<Salon> searchSalons(String query) {
    final q = query.toLowerCase();
    return _salons
        .where((s) =>
    s.name.toLowerCase().contains(q) ||
        s.tagline.toLowerCase().contains(q) ||
        s.categories.any((c) => c.toLowerCase().contains(q)))
        .toList();
  }

  Salon? getSalonById(String id) =>
      _salons.where((s) => s.id == id).firstOrNull;

  List<Salon> getNearbySalons({String? filterCategory, bool openOnly = false}) {
    var list = List<Salon>.from(_salons);
    if (filterCategory != null && filterCategory != 'All') {
      list = list.where((s) => s.categories.contains(filterCategory)).toList();
    }
    if (openOnly) {
      list = list.where((s) => s.isOpen).toList();
    }
    list.sort((a, b) => a.distance.compareTo(b.distance));
    return list;
  }

  // ---- Services ----
  List<SalonService> getAllServices() => List.unmodifiable(_services);

  List<SalonService> getServicesForSalon(String salonId) =>
      _services.where((s) => s.salonId == salonId).toList();

  SalonService? getServiceById(String id) =>
      _services.where((s) => s.id == id).firstOrNull;

  List<SalonService> getServicesByCategory(String category) =>
      _services.where((s) => s.category == category).toList();

  // ---- Stylists ----
  List<Stylist> getStylesForSalon(String salonId) =>
      _stylists.where((s) => s.salonId == salonId).toList();

  Stylist? getStylistById(String id) =>
      _stylists.where((s) => s.id == id).firstOrNull;

  // ---- Reviews ----
  List<Review> getReviewsForSalon(String salonId) =>
      _reviews.where((r) => r.salonId == salonId).toList();

  List<Review> getAllReviews() => List.unmodifiable(_reviews);

  Map<int, int> getRatingDistribution(String salonId) {
    final reviews = getReviewsForSalon(salonId);
    final dist = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final r in reviews) {
      final key = r.rating.round().clamp(1, 5);
      dist[key] = (dist[key] ?? 0) + 1;
    }
    return dist;
  }

  // ---- Promotions ----
  List<Promotion> getAllPromotions() => List.unmodifiable(_promotions);

  List<Promotion> getPromotionsByCategory(String category) =>
      category == 'All'
          ? _promotions
          : _promotions.where((p) => p.category == category).toList();

  // ---- Gallery ----
  List<GalleryItem> getGalleryForSalon(String salonId) =>
      _gallery.where((g) => g.salonId == salonId).toList();

  List<GalleryItem> getAllGallery() => List.unmodifiable(_gallery);

  // ---- Mock Time Slots ----
  List<String> getAvailableSlots(DateTime date) {
    final all = [
      '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
      '12:00', '12:30', '13:00', '13:30', '14:00', '14:30',
      '15:00', '15:30', '16:00', '16:30', '17:00', '17:30',
      '18:00', '18:30', '19:00',
    ];
    // Pseudo-random unavailable slots based on date
    final seed = date.day + date.month;
    return all.asMap().entries.where((e) => (e.key + seed) % 4 != 0).map((e) => e.value).toList();
  }

  // ---- Mock Chat Replies ----
  String getMockReply(String salonId) {
    final replies = [
      'Thank you for reaching out! How can we assist you today?',
      'Hello! We\'d be happy to help you book an appointment.',
      'Hi there! Our team is available Mon–Sat, 9am–8pm.',
      'Of course! Would you like to know more about our services or promotions?',
      'Great question! Please let us know your preferred date and we\'ll check availability.',
      'We look forward to welcoming you to our salon! 💐',
      'That service is available! Shall we book you in?',
      'Our stylists are amazing — you\'re in for a treat! ✨',
    ];
    if (salonId.isEmpty) return replies.first;
    final idx = salonId.codeUnitAt(salonId.length - 1) % replies.length;
    return replies[idx];
  }
}