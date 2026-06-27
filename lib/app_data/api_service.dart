import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../app_model/models.dart';

class ApiService {
  final String baseUrl;
  ApiService(this.baseUrl);


  // ============================================================
  // GET all salons
  // ============================================================
  Future<List<Salon>> getSalons() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/salons/'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((j) => Salon.fromJson(j)).toList();
      }
    } catch (e) {
      print('API Error (Salons): $e');

    }
    return [];
  }


  // ============================================================
  // GET all salons details
  // ============================================================
  Future<Salon?> getSalonDetails(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/salons/$id'));
      if (response.statusCode == 200) {
        return Salon.fromJson(json.decode(response.body));
      }
    } catch (e) {
      print('API Error (Salon Details): $e');
    }
    return null;
  }


  // ============================================================
  // GET all salons services
  // ============================================================
  Future<List<SalonService>> getServicesForSalon(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/salons/$id/services'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((j) => SalonService.fromJson(j)).toList();
      }
    } catch (e) {
      print('API Error (Services for Salon): $e');
    }
    return [];
  }

  // ============================================================
  // GET all salons reviews
  // ============================================================
  Future<List<Review>> getReviewsForSalon(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/salons/$id/reviews'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((j) => Review.fromJson(j)).toList();
      }
    } catch (e) {
      print('API Error (Reviews for Salon): $e');
    }
    return [];
  }


  // ============================================================
  // GET all salons stylists
  // ============================================================
  Future<List<Stylist>> getStylistsForSalon(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/salons/$id/stylists'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((j) => Stylist.fromJson(j)).toList();
      }
    } catch (e) {
      print('API Error (Stylists for Salon): $e');
    }
    return [];
  }

  // ============================================================
  // GET all salons available slots for booking
  // ============================================================
  Future<List<String>> getAvailableSlots(String salonId, DateTime date) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final response = await http.get(Uri.parse('$baseUrl/api/salons/$salonId/slots?date=$dateStr'));
      if (response.statusCode == 200) {
        return List<String>.from(json.decode(response.body));
      }
    } catch (e) {
      print('API Error (Slots): $e');
    }
    return [];
  }


  // ============================================================
  // GET all user's bookings
  // ============================================================
  Future<List<Booking>> getMyBookings() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/bookings/my-bookings'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((j) => Booking.fromJson(j)).toList();
      }
    } catch (e) {
      print('API Error (My Bookings): $e');
    }
    return [];
  }


  // ============================================================
  // POST user's booking
  // ============================================================
  Future<bool> createBooking(Map<String, dynamic> payload) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/bookings/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('API Error (Create Booking): $e');
      return false;
    }
  }

  // ============================================================
  // GET all promotions
  // ============================================================
  Future<List<Promotion>> getPromotions() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/promotions/'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((j) => Promotion.fromJson(j)).toList();
      }
    } catch (e) {
      print('API Error (Promotions): $e');
    }
    return [];
  }

  // ============================================================
  // GET single service by ID
  // ============================================================
  Future<SalonService?> getServiceById(String serviceId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/services/$serviceId'));
      if (response.statusCode == 200) {
        return SalonService.fromJson(json.decode(response.body));
      }
    } catch (e) {
      print('API Error (Service Detail): $e');
    }
    return null;
  }

  // ============================================================
  // GET all user's chat threads (Stylists they have booked)
  // ============================================================
  Future<List<ChatThread>> getChatThreads(String stylistId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/chat/threads?stylist_id=$stylistId'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((j) => ChatThread.fromJson(j)).toList();
      }
    } catch (e) {
      print('API Error (Get Chat Threads): $e');
    }
    return [];
  }

  // ============================================================
  // GET message history between user and stylist
  // ============================================================
  Future<List<dynamic>> getChatMessages(String stylistId, String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/chat/messages?stylist_id=$stylistId&user_id=$userId'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('API Error (Get Chat Messages): $e');
    }
    return [];
  }

  // ============================================================
  // POST send a message
  // ============================================================
  Future<bool> sendMessage(Map<String, dynamic> payload) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/chat/send'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('API Error (Send Message): $e');
      return false;
    }
  }

}
