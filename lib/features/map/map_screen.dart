import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app_data/mock_repository.dart';
import '../../app_data/api_service.dart';
import '../../app_state/api_settings.dart';
import '../../app_model/models.dart';
import '../../app_theme/app_text_styles.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  String? _selectedSalonId;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  List<Salon>? _remoteSalons;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchRemoteSalons();
    });
  }

  Future<void> _fetchRemoteSalons() async {
    final baseUrl = context.read<ApiSettingsNotifier>().baseUrl;
    setState(() {
      _isLoading = true;
    });
    try {
      final api = ApiService(baseUrl);
      final results = await api.getSalons();
      if (mounted) {
        setState(() {
          _remoteSalons = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Fetch salons from Python API if loaded/available, otherwise use local fallback mocks
    final localSalons = MockRepository.instance.getAllSalons();
    final sourceSalons = (_remoteSalons != null && _remoteSalons!.isNotEmpty)
        ? _remoteSalons!
        : localSalons;

    // Filter salons based on selected category and search text query
    final filteredSalons = sourceSalons.where((salon) {
      final matchesCategory = _selectedCategory == 'All' ||
          salon.categories.any((cat) => cat.toLowerCase() == _selectedCategory.toLowerCase());

      final q = _searchQuery.trim().toLowerCase();
      final matchesSearch = q.isEmpty ||
          salon.name.toLowerCase().contains(q) ||
          salon.address.toLowerCase().contains(q) ||
          salon.categories.any((cat) => cat.toLowerCase().contains(q));

      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. The Map Layer
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              // Center on Phnom Penh, Cambodia
              initialCenter: const LatLng(11.5564, 104.9282),
              initialZoom: 13,
              onTap: (_, __) {
                if (_searchFocusNode.hasFocus) {
                  _searchFocusNode.unfocus();
                }
                setState(() => _selectedSalonId = null);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.salon_beauty_app',
              ),

              // Salon markers layer
              MarkerLayer(
                markers: filteredSalons.map((salon) {
                  final isSelected = _selectedSalonId == salon.id;
                  return Marker(
                    point: LatLng(salon.lat, salon.lng),
                    width: 140,
                    height: 80,
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: () {
                        if (_searchFocusNode.hasFocus) {
                          _searchFocusNode.unfocus();
                        }
                        setState(() => _selectedSalonId = salon.id);
                        _showSalonInfo(context, salon);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Name label chip
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFE91E8C)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.18),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              salon.name,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF1A1A2E),
                                letterSpacing: 0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Teardrop pin
                          CustomPaint(
                            size: const Size(36, 44),
                            painter: _TearDropPainter(
                              color: const Color(0xFFE91E8C),
                              isSelected: isSelected,
                            ),
                            child: SizedBox(
                              width: 36,
                              height: 44,
                              child: Align(
                                alignment: const Alignment(0, -0.4),
                                child: Icon(
                                  Icons.content_cut,
                                  color: Colors.white,
                                  size: isSelected ? 17 : 15,
                                ),
                              ),
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

          // 2. Floating Search & Filtering Overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Search Bar Container
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 18),
                        const Icon(
                          Icons.search,
                          color: Color(0xFFE91E8C),
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            decoration: const InputDecoration(
                              hintText: 'Search salon name, service, address...',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 14),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF1A1A2E),
                              fontWeight: FontWeight.w500,
                            ),
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val;
                              });
                            },
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        else if (_isLoading)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFE91E8C),
                            ),
                          )
                        else
                          const SizedBox(width: 18),
                      ],
                    ),
                  ),

                  // Horizontal Category Filter Chips Bar
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildCategoryChip('All', Icons.grid_view),
                        _buildCategoryChip('Hair', Icons.content_cut),
                        _buildCategoryChip('Makeup', Icons.face),
                        _buildCategoryChip('Bridal', Icons.favorite_border),
                        _buildCategoryChip('Nails', Icons.brush),
                        _buildCategoryChip('Spa', Icons.spa),
                      ],
                    ),
                  ),

                  // Suggestions / Dropdown List Overlay
                  if (_searchFocusNode.hasFocus && _searchQuery.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Flexible(
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 300),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: filteredSalons.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.search_off, color: Colors.grey.shade400, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'No salons found',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                itemCount: filteredSalons.length,
                                separatorBuilder: (_, __) => Divider(
                                  height: 1,
                                  color: Colors.grey.shade100,
                                  indent: 16,
                                  endIndent: 16,
                                ),
                                itemBuilder: (context, index) {
                                  final salon = filteredSalons[index];
                                  return ListTile(
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE91E8C).withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.storefront,
                                        color: Color(0xFFE91E8C),
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(
                                      salon.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Color(0xFF1A1A2E),
                                      ),
                                    ),
                                    subtitle: Text(
                                      salon.address,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    onTap: () {
                                      _searchFocusNode.unfocus();
                                      _searchController.text = salon.name;
                                      setState(() {
                                        _searchQuery = salon.name;
                                        _selectedSalonId = salon.id;
                                      });
                                      _mapController.move(LatLng(salon.lat, salon.lng), 14.5);
                                      _showSalonInfo(context, salon);
                                    },
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category, IconData icon) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
          _selectedSalonId = null;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE91E8C) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : const Color(0xFFE91E8C),
            ),
            const SizedBox(width: 6),
            Text(
              category,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF1A1A2E),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSalonInfo(BuildContext context, dynamic salon) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Salon icon avatar
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE91E8C).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFE91E8C).withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.content_cut,
                      color: Color(0xFFE91E8C),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name + address + rating
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          salon.name,
                          style: AppTextStyles.titleMd.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 13, color: Color(0xFFE91E8C)),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                salon.address,
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            ...List.generate(5, (i) {
                              return Icon(
                                i < salon.rating.floor()
                                    ? Icons.star
                                    : (i < salon.rating
                                        ? Icons.star_half
                                        : Icons.star_border),
                                color: const Color(0xFFFFC107),
                                size: 14,
                              );
                            }),
                            const SizedBox(width: 5),
                            Text(
                              '${salon.rating} · ${salon.reviewCount} reviews',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Open / Closed badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: salon.isOpen
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      salon.isOpen ? 'Open' : 'Closed',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: salon.isOpen
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        context.push('/salon/${salon.id}');
                      },
                      icon: const Icon(Icons.storefront, size: 16),
                      label: const Text('View Salon'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE91E8C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final url = Uri.parse(
                          'https://www.google.com/maps/search/?api=1&query=${salon.lat},${salon.lng}',
                        );
                        if (await canLaunchUrl(url)) {
                          await launchUrl(
                              url, mode: LaunchMode.externalApplication);
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Could not launch Google Maps'),
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.directions, size: 16),
                      label: const Text('Directions'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE91E8C),
                        side: const BorderSide(color: Color(0xFFE91E8C)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      if (mounted) setState(() => _selectedSalonId = null);
    });
  }
}

/// Paints a Google Maps-style teardrop pin shape.
class _TearDropPainter extends CustomPainter {
  const _TearDropPainter({required this.color, required this.isSelected});
  final Color color;
  final bool isSelected;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: isSelected ? 0.35 : 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final path = _buildPath(size);
    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);

    // White inner circle highlight
    final cx = size.width / 2;
    final cy = size.width / 2;
    canvas.drawCircle(
      Offset(cx, cy),
      size.width * 0.28,
      Paint()..color = Colors.white.withValues(alpha: 0.2),
    );
  }

  Path _buildPath(Size size) {
    final w = size.width;
    final h = size.height;
    final r = w / 2;
    final path = Path();
    // Circle top portion
    path.addArc(
      Rect.fromCircle(center: Offset(w / 2, r), radius: r),
      0,
      2 * 3.14159265,
    );
    // Triangle pointing down
    path.moveTo(0, r);
    path.lineTo(w / 2, h);
    path.lineTo(w, r);
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(_TearDropPainter old) =>
      old.color != color || old.isSelected != isSelected;
}