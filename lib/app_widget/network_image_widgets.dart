import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NetworkAvatar extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final IconData icon;

  const NetworkAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 24.0,
    this.icon = Icons.person,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey[200],
        child: Icon(icon, color: Colors.grey[500], size: radius),
      );
    }
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: radius,
        backgroundImage: imageProvider,
      ),
      placeholder: (context, url) => CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey[200],
        child: const CircularProgressIndicator(),
      ),
      errorWidget: (context, url, error) => CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey[200],
        child: Icon(icon, color: Colors.grey[500], size: radius),
      ),
    );
  }
}

class SafeNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;

  const SafeNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Center(child: Icon(Icons.image, color: Colors.grey)),
      );
    }
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      placeholder: (context, url) => Container(
        color: Colors.grey[200],
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[200],
        child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
      ),
    );
  }
}
