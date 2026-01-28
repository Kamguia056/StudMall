class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final int stock;
  final String condition;
  final String university;
  final String sellerId;
  final String sellerName;
  final String sellerEmail;
  final String sellerAvatar;
  final bool isAvailable;
  final bool isFeatured;
  final double rating;
  final int reviewCount;
  final int viewCount;
  final int soldCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> location;
  final List<String> tags;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.stock,
    required this.condition,
    required this.university,
    required this.sellerId,
    required this.sellerName,
    required this.sellerEmail,
    required this.sellerAvatar,
    required this.isAvailable,
    required this.isFeatured,
    required this.rating,
    required this.reviewCount,
    required this.viewCount,
    required this.soldCount,
    required this.createdAt,
    required this.updatedAt,
    required this.location,
    required this.tags,
  });
}
