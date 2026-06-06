import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../app_model/models.dart';

class ApiService {
  final String baseUrl;
  ApiService(this.baseUrl);

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


}
