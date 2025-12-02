import 'package:gnbtask/models/agent_model.dart';

class Property {
  final String id;
  final String title;
  final double price;
  final String address;
  final String city;
  final String imageUrl;
  final String status;
  final int bedrooms;
  final int bathrooms;
  final Agent agent;

  Property({
    required this.id,
    required this.title,
    required this.price,
    required this.address,
    required this.city,
    required this.imageUrl,
    required this.status,
    required this.bedrooms,
    required this.bathrooms,
    required this.agent,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>?;

    final List<dynamic> images = json['images'] ?? [];
    final String firstImage = images.isNotEmpty
        ? images[0]
        : 'https://via.placeholder.com/600x400';

    return Property(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'No Title',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      address: location?['address'] ?? '',
      city: location?['city'] ?? 'Unknown',
      imageUrl: firstImage,
      status: json['status'] ?? 'Unknown',
      bedrooms: json['bedrooms'] ?? 0,
      bathrooms: json['bathrooms'] ?? 0,
      agent: json['agent'] != null
          ? Agent.fromJson(json['agent'])
          : Agent(name: '', email: '', contact: ''),
    );
  }
}
