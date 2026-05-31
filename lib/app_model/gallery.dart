class GalleryItem {
  final String id;
  final String salonId;
  final String url;
  final bool isVideo;
  final String caption;
  final String category;

  const GalleryItem({
    required this.id,
    required this.salonId,
    required this.url,
    required this.isVideo,
    required this.caption,
    required this.category,
  });

  factory GalleryItem.fromJson(Map<String, dynamic> j) => GalleryItem(
    id: j['id'],
    salonId: j['salonId'] ?? '',
    url: j['url'],
    isVideo: j['isVideo'] ?? false,
    caption: j['caption'] ?? '',
    category: j['category'] ?? 'All',
  );
}
