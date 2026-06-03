import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../app_model/models.dart';
import '../app_data/api_service.dart';
import '../app_data/mock_repository.dart';
import 'api_settings.dart';

// ============================================================
// FavoritesNotifier
// ============================================================
class FavoritesNotifier extends ChangeNotifier {
  static const _salonsKey = 'fav_salons';
  static const _servicesKey = 'fav_services';

  Set<String> _favSalonIds = {};
  Set<String> _favServiceIds = {};

  Set<String> get favSalonIds => Set.unmodifiable(_favSalonIds);
  Set<String> get favServiceIds => Set.unmodifiable(_favServiceIds);

  List<Salon> get favSalons => MockRepository.instance
      .getAllSalons()
      .where((s) => _favSalonIds.contains(s.id))
      .toList();

  List<SalonService> get favServices => MockRepository.instance
      .getAllServices()
      .where((s) => _favServiceIds.contains(s.id))
      .toList();

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _favSalonIds = Set<String>.from(prefs.getStringList(_salonsKey) ?? []);
    _favServiceIds = Set<String>.from(prefs.getStringList(_servicesKey) ?? []);
    notifyListeners();
  }

  bool isSalonFav(String id) => _favSalonIds.contains(id);
  bool isServiceFav(String id) => _favServiceIds.contains(id);

  Future<void> toggleSalon(String id) async {
    if (_favSalonIds.contains(id)) {
      _favSalonIds.remove(id);
    } else {
      _favSalonIds.add(id);
    }
    notifyListeners();
    await _persist();
  }

  Future<void> toggleService(String id) async {
    if (_favServiceIds.contains(id)) {
      _favServiceIds.remove(id);
    } else {
      _favServiceIds.add(id);
    }
    notifyListeners();
    await _persist();
  }

  Future<void> removeSalon(String id) async {
    _favSalonIds.remove(id);
    notifyListeners();
    await _persist();
  }

  Future<void> removeService(String id) async {
    _favServiceIds.remove(id);
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_salonsKey, _favSalonIds.toList());
    await prefs.setStringList(_servicesKey, _favServiceIds.toList());
  }
}

// ============================================================
// BookingNotifier
// ============================================================
class BookingNotifier extends ChangeNotifier {
  static const _bookingsKey = 'bookings';

  // Current booking draft
  String? draftSalonId;
  String? draftSalonName;
  List<SalonService> draftServices = [];
  Stylist? draftStylist;
  DateTime? draftDate;
  String? draftTimeSlot;
  String draftCustomerName = '';
  String draftCustomerPhone = '';

  // Saved bookings
  List<Booking> _bookings = [];
  List<Booking> get upcomingBookings =>
      _bookings.where((b) => b.status == 'upcoming').toList()
        ..sort((a, b) => a.date.compareTo(b.date));
  List<Booking> get pastBookings =>
      _bookings.where((b) => b.status == 'past').toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  double get draftTotal =>
      draftServices.fold(0.0, (sum, s) => sum + s.price);

  Future<void> load(String baseUrl) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_bookingsKey) ?? [];
    
    // Try to load from API first
    try {
      final api = ApiService(baseUrl);
      final remote = await api.getMyBookings();
      // If we got a successful response (even empty), we use it. 
      // api.getMyBookings should probably throw or return null if it failed.
      // For now, if it returns an empty list, we'll check local storage as a secondary source.
      if (remote.isNotEmpty) {
        _bookings = remote;
        notifyListeners();
        return;
      }
    } catch (e) {
      debugPrint('BookingNotifier: Failed to load from API: $e');
    }

    // Secondary source: Local persistence (for offline or mock usage)
    _bookings = raw.map((s) => Booking.fromJson(json.decode(s))).toList();
    notifyListeners();
  }

  void startBooking(Salon salon) {
    draftSalonId = salon.id;
    draftSalonName = salon.name;
    draftServices = [];
    draftStylist = null;
    draftDate = null;
    draftTimeSlot = null;
    draftCustomerName = '';
    draftCustomerPhone = '';
    notifyListeners();
  }

  void toggleService(SalonService service) {
    if (draftServices.any((s) => s.id == service.id)) {
      draftServices = draftServices.where((s) => s.id != service.id).toList();
    } else {
      draftServices = [...draftServices, service];
    }
    notifyListeners();
  }

  void selectStylist(Stylist? stylist) {
    draftStylist = stylist;
    notifyListeners();
  }

  void selectDate(DateTime? date) {
    draftDate = date;
    draftTimeSlot = null;
    notifyListeners();
  }

  void selectTimeSlot(String? slot) {
    draftTimeSlot = slot;
    notifyListeners();
  }

  void updateCustomerInfo(String name, String phone) {
    draftCustomerName = name;
    draftCustomerPhone = phone;
    notifyListeners();
  }

  Future<Booking?> confirmBooking(String baseUrl) async {
    if (draftSalonId == null || draftDate == null || draftTimeSlot == null) {
      return null;
    }

    final payload = {
      'salon_id': draftSalonId,
      'service_ids': draftServices.map((s) => s.id).toList(),
      'stylist_id': draftStylist?.id ?? '',
      'date': DateFormat('yyyy-MM-dd').format(draftDate!),
      'time_slot': draftTimeSlot,
      'customer_name': draftCustomerName,
      'customer_phone': draftCustomerPhone,
      'total_price': draftTotal,
    };

    final api = ApiService(baseUrl);
    try {
      final success = await api.createBooking(payload);

      if (success) {
        final code = 'SB${DateTime.now().millisecondsSinceEpoch % 100000}';
        final booking = Booking(
          id: 'b${DateTime.now().millisecondsSinceEpoch}',
          salonId: draftSalonId!,
          salonName: draftSalonName!,
          serviceIds: draftServices.map((s) => s.id).toList(),
          serviceNames: draftServices.map((s) => s.name).toList(),
          stylistId: draftStylist?.id ?? '',
          stylistName: draftStylist?.name ?? 'Any Stylist',
          date: draftDate!,
          timeSlot: draftTimeSlot!,
          customerName: draftCustomerName,
          customerPhone: draftCustomerPhone,
          totalPrice: draftTotal,
          status: 'upcoming',
          confirmationCode: code,
        );

        _bookings = [booking, ..._bookings];
        notifyListeners();
        await _persist();
        return booking;
      }
    } catch (_) {}
    return null;
  }

  Future<void> cancelBooking(String id) async {
    _bookings = _bookings.map((b) {
      if (b.id == id) {
        return Booking(
          id: b.id,
          salonId: b.salonId,
          salonName: b.salonName,
          serviceIds: b.serviceIds,
          serviceNames: b.serviceNames,
          stylistId: b.stylistId,
          stylistName: b.stylistName,
          date: b.date,
          timeSlot: b.timeSlot,
          customerName: b.customerName,
          customerPhone: b.customerPhone,
          totalPrice: b.totalPrice,
          status: 'cancelled',
          confirmationCode: b.confirmationCode,
        );
      }
      return b;
    }).toList();
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = _bookings.map((b) => json.encode(b.toJson())).toList();
    await prefs.setStringList(_bookingsKey, raw);
  }
}

// ============================================================
// OnboardingNotifier
// ============================================================
class OnboardingNotifier extends ChangeNotifier {
  static const _key = 'onboarding_done';
  bool _done = false;
  bool get isDone => _done;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _done = prefs.getBool(_key) ?? false;
    notifyListeners();
  }

  Future<void> complete() async {
    _done = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}

// ============================================================
// ChatNotifier
// ============================================================
class ChatNotifier extends ChangeNotifier {
  final Map<String, List<ChatMessage>> _threads = {};
  final Map<String, bool> _typing = {};

  List<ChatThread> get threads {
    return MockRepository.instance
        .getAllSalons()
        .take(5)
        .map((s) {
          final msgs = _threads[s.id] ?? [];
          return ChatThread(
            salonId: s.id,
            salonName: s.name,
            salonAvatar: s.coverImage,
            lastMessage: msgs.isNotEmpty ? msgs.last.text : 'Tap to start chatting',
            lastTime: msgs.isNotEmpty ? msgs.last.timestamp : DateTime.now().subtract(const Duration(hours: 2)),
            unreadCount: 0,
          );
        })
        .toList();
  }

  List<ChatMessage> getMessages(String salonId) =>
      _threads[salonId] ?? [];

  bool isTyping(String salonId) => _typing[salonId] ?? false;

  Future<void> sendMessage(String salonId, String text) async {
    final msg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      salonId: salonId,
      text: text,
      isMe: true,
      timestamp: DateTime.now(),
      isRead: true,
    );
    _threads[salonId] = [...(_threads[salonId] ?? []), msg];
    _typing[salonId] = true;
    notifyListeners();

    // Mock auto-reply after 1s
    await Future.delayed(const Duration(milliseconds: 1200));
    _typing[salonId] = false;
    final reply = ChatMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}r',
      salonId: salonId,
      text: MockRepository.instance.getMockReply(salonId),
      isMe: false,
      timestamp: DateTime.now(),
      isRead: false,
    );
    _threads[salonId] = [...(_threads[salonId] ?? []), reply];
    notifyListeners();
  }
}