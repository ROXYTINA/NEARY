import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_model/models.dart';
import '../app_data/mock_repository.dart';

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
      draftServices.fold(0, (sum, s) => sum + s.price);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_bookingsKey) ?? [];
    _bookings = raw.map((s) => Booking.fromJson(json.decode(s))).toList();

    // Age upcoming bookings that have passed
    final now = DateTime.now();
    for (var i = 0; i < _bookings.length; i++) {
      if (_bookings[i].status == 'upcoming' &&
          _bookings[i].date.isBefore(now.subtract(const Duration(hours: 1)))) {
        _bookings[i] = Booking(
          id: _bookings[i].id,
          salonId: _bookings[i].salonId,
          salonName: _bookings[i].salonName,
          serviceIds: _bookings[i].serviceIds,
          serviceNames: _bookings[i].serviceNames,
          stylistId: _bookings[i].stylistId,
          stylistName: _bookings[i].stylistName,
          date: _bookings[i].date,
          timeSlot: _bookings[i].timeSlot,
          customerName: _bookings[i].customerName,
          customerPhone: _bookings[i].customerPhone,
          totalPrice: _bookings[i].totalPrice,
          status: 'past',
          confirmationCode: _bookings[i].confirmationCode,
        );
      }
    }
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

  void selectDate(DateTime date) {
    draftDate = date;
    draftTimeSlot = null;
    notifyListeners();
  }

  void selectTimeSlot(String slot) {
    draftTimeSlot = slot;
    notifyListeners();
  }

  void updateCustomerInfo(String name, String phone) {
    draftCustomerName = name;
    draftCustomerPhone = phone;
    notifyListeners();
  }

  Future<Booking> confirmBooking() async {
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

  List<ChatThread> get threads => MockRepository.instance
      .getAllSalons()
      .take(5)
      .map((s) => ChatThread(
    salonId: s.id,
    salonName: s.name,
    salonAvatar: s.coverImage,
    lastMessage: _threads[s.id]?.lastOrNull?.text ?? 'Tap to start chatting',
    lastTime: _threads[s.id]?.lastOrNull?.timestamp ?? DateTime.now().subtract(const Duration(hours: 2)),
    unreadCount: 0,
  ))
      .toList();

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