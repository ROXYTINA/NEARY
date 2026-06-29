import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class SalonImageCarousel extends StatefulWidget {
  final List<String> images;

  const SalonImageCarousel({
    super.key,
    required this.images,
  });

  @override
  State<SalonImageCarousel> createState() => _SalonImageCarouselState();
}

class _SalonImageCarouselState extends State<SalonImageCarousel> {
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (widget.images.isEmpty) return;

      setState(() {
        _index = (_index + 1) % widget.images.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images =
    widget.images.where((e) => e.trim().isNotEmpty).toList();

    if (images.isEmpty) {
      return Container(color: Colors.grey.shade300);
    }

    return Stack(
      children: [
        // IMAGE
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: CachedNetworkImage(
            key: ValueKey(images[_index]),
            imageUrl: images[_index],
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover, // keep cover but we fix UI with overlay
            placeholder: (_, __) =>
                Container(color: Colors.grey.shade200),
          ),
        ),

        // DARK OVERLAY (soft, not harsh)
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.15),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.35),
              ],
            ),
          ),
        ),

        // DOTS
        Positioned(
          bottom: 12,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (i) {
              final active = i == _index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 14 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: active ? Colors.white : Colors.white54,
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}