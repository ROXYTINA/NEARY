import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../app_data/mock_repository.dart';
import '../../app_theme/app_text_styles.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final salons = MockRepository.instance.getAllSalons();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
      ),
      body: FlutterMap(
        options: const MapOptions(
          // 🇰🇭 Center on Phnom Penh, Cambodia
          initialCenter: LatLng(11.5564, 104.9282),
          initialZoom: 11,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.salon_beauty_app',
          ),

          MarkerLayer(
            markers: salons.map((salon) {
              return Marker(
                point: LatLng(salon.lat, salon.lng),
                width: 80,
                height: 80,
                child: GestureDetector(
                  onTap: () => _showSalonInfo(context, salon),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.red,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showSalonInfo(BuildContext context, dynamic salon) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                salon.name,
                style: AppTextStyles.titleMd,
              ),
              const SizedBox(height: 4),
              Text(
                salon.address,
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: navigate to salon detail page
                    },
                    child: const Text('View Salon'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {
                      // TODO: open maps directions
                    },
                    child: const Text('Directions'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}