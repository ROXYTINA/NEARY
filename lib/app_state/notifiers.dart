import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../app_model/models.dart';
import '../app_data/api_service.dart';
import '../app_data/mock_repository.dart';
import 'api_settings.dart';
import 'package:flutter/material.dart';
import '../app_data/api_service.dart';


// ============================================================
// AuthNotifier
// ============================================================
class AuthNotifier extends ChangeNotifier {
  static const _tokenKey = 'auth_token';
  static const _nameKey  = 'auth_name';
  static const _emailKey = 'auth_email';

  String? _token;
  String? _fullName;
  String? _email;

  bool get isLoggedIn => _token != null;
  String? get token    => _token;
  String? get fullName => _fullName;
  String? get email    => _email;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _token    = prefs.getString(_tokenKey);
    _fullName = prefs.getString(_nameKey);
    _email    = prefs.getString(_emailKey);
    notifyListeners();
  }

  Future<bool> login(String baseUrl, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'username': email, 'password': password},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['access_token'];
        _email = email;
        notifyListeners();
        await _persist();
        return true;
      }
    } catch (e) {
      debugPrint('Login error: $e');
    }
    return false;
  }

  Future<bool> register(String baseUrl, String email, String password, String fullName) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'full_name': fullName,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return await login(baseUrl, email, password);
      }
    } catch (e) {
      debugPrint('Register error: $e');
    }
    return false;
  }

  Future<bool> updateProfile(String baseUrl, {String? fullName, String? email}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/auth/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({
          if (fullName != null) 'full_name': fullName,
          if (email != null) 'email': email,
        }),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _fullName = data['full_name'];
        _email    = data['email'];
        notifyListeners();
        await _persist();
        return true;
      }
    } catch (e) {
      debugPrint('Update profile error: $e');
    }
    return false;
  }

  Future<bool> changePassword(String baseUrl, {
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Change password error: $e');
    }
    return false;
  }

  Future<void> logout() async {
    _token    = null;
    _fullName = null;
    _email    = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_nameKey);
    await prefs.remove(_emailKey);
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    if (_token    != null) await prefs.setString(_tokenKey, _token!);
    if (_fullName != null) await prefs.setString(_nameKey,  _fullName!);
    if (_email    != null) await prefs.setString(_emailKey, _email!);
  }
}



// ============================================================
// FavoritesNotifier
// ============================================================
class FavoritesNotifier extends ChangeNotifier {
  static const _salonsKey   = 'fav_salons';
  static const _servicesKey = 'fav_services';

  Set<String>  _favSalonIds   = {};
  Set<String>  _favServiceIds = {};

  // ✅ Store full objects from API
  final Map<String, Salon>        _salonCache   = {};
  final Map<String, SalonService> _serviceCache = {};

  Set<String> get favSalonIds   => Set.unmodifiable(_favSalonIds);
  Set<String> get favServiceIds => Set.unmodifiable(_favServiceIds);

  // ✅ Return from cache, not MockRepository
  List<Salon> get favSalons =>
      _favSalonIds.map((id) => _salonCache[id]).whereType<Salon>().toList();

  List<SalonService> get favServices =>
      _favServiceIds.map((id) => _serviceCache[id]).whereType<SalonService>().toList();

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _favSalonIds   = Set<String>.from(prefs.getStringList(_salonsKey)   ?? []);
    _favServiceIds = Set<String>.from(prefs.getStringList(_servicesKey) ?? []);
    notifyListeners();
  }

  bool isSalonFav(String id)   => _favSalonIds.contains(id);
  bool isServiceFav(String id) => _favServiceIds.contains(id);
  bool isServiceFavorite(String id) => _favServiceIds.contains(id);

  Future<void> toggleSalon(Salon salon) async {
    if (_favSalonIds.contains(salon.id)) {
      _favSalonIds.remove(salon.id);
      _salonCache.remove(salon.id);
    } else {
      _favSalonIds.add(salon.id);
      _salonCache[salon.id] = salon;  // cache it
    }
    notifyListeners();
    await _persist();
  }

  Future<void> toggleService(SalonService service) async {
    if (_favServiceIds.contains(service.id)) {
      _favServiceIds.remove(service.id);
      _serviceCache.remove(service.id);
    } else {
      _favServiceIds.add(service.id);
      _serviceCache[service.id] = service;
    }
    notifyListeners();
    await _persist();
  }

  Future<void> removeSalon(String id) async {
    _favSalonIds.remove(id);
    _salonCache.remove(id);
    notifyListeners();
    await _persist();
  }

  Future<void> removeService(String id) async {
    _favServiceIds.remove(id);
    _serviceCache.remove(id);
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_salonsKey,   _favSalonIds.toList());
    await prefs.setStringList(_servicesKey, _favServiceIds.toList());
  }

  Future<void> rehydrate(String baseUrl) async {
    if (_favSalonIds.isEmpty) return;
    try {
      final api = ApiService(baseUrl);
      for (final id in _favSalonIds) {
        if (!_salonCache.containsKey(id)) {
          final salon = await api.getSalonDetails(id);
          if (salon != null) _salonCache[id] = salon;
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('FavoritesNotifier rehydrate error: $e');
    }
  }

  Future<void> toggleServiceFav(SalonService service) async {
    await toggleService(service);
  }

  Future<void> toggleServiceFavById(String serviceId, SalonService service) async {
    if (_favServiceIds.contains(serviceId)) {
      _favServiceIds.remove(serviceId);
      _serviceCache.remove(serviceId);
    } else {
      _favServiceIds.add(serviceId);
      _serviceCache[serviceId] = service;
    }

    notifyListeners();
    await _persist();
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
// ThemeNotifier
// ============================================================
class ThemeNotifier extends ChangeNotifier {
  static const _key = 'theme_mode';
  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  bool get isDark => _mode == ThemeMode.dark;
  bool get isLight => _mode == ThemeMode.light;
  bool get isSystem => _mode == ThemeMode.system;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    _mode = switch (saved) {
      'dark'   => ThemeMode.dark,
      'light'  => ThemeMode.light,
      _        => ThemeMode.system,
    };
    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, switch (mode) {
      ThemeMode.dark   => 'dark',
      ThemeMode.light  => 'light',
      ThemeMode.system => 'system',
    });
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