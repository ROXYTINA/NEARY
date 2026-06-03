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
