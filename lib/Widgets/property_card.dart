import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gnbtask/Screens/Property_detail_screen.dart';
import 'package:gnbtask/Screens/image_upload_screen.dart';
import 'package:gnbtask/Services/analytics_service.dart';
import 'package:gnbtask/models/property_model.dart';
import 'package:intl/intl.dart';

class PropertyCard extends StatelessWidget {
  final Property property;

  const PropertyCard({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.simpleCurrency(decimalDigits: 0);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        AnalyticsService().logInteraction(
          elementId: 'property_card',
          action: 'tap_view_details',
          metadata: {'property_id': property.id, 'title': property.title},
        );

        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) =>
                PropertyDetailScreen(property: property),
            transitionsBuilder: (_, a, __, c) =>
                FadeTransition(opacity: a, child: c),
          ),
        );
      },
      child: Card(
        elevation: 2,
        color: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // --------------------
            // IMAGE WITH UPLOAD BUTTON
            // --------------------
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  Hero(
                    tag: property.id,
                    child: CachedNetworkImage(
                      imageUrl: property.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (context, url) => Container(
                        color: isDark ? Colors.grey[800] : Colors.grey[200],
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.error,
                        color: isDark ? Colors.red[300] : Colors.red,
                      ),
                    ),
                  ),
                  // Upload Icon Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.black87,
                            size: 20,
                          ),
                          onPressed: () {
                            AnalyticsService().logInteraction(
                              elementId: 'upload_photo_btn',
                              action: 'tap',
                              metadata: {'property_id': property.id},
                            );

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImageUploadScreen(
                                  propertyId: property.id,
                                  propertyTitle: property.title,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --------------------
            // SCROLLABLE CONTENT
            // --------------------
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // STATUS BADGE
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(property.status),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          property.status.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // PRICE
                      Text(
                        currencyFormatter.format(property.price),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // TITLE
                      Text(
                        property.title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // LOCATION
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "${property.address}, ${property.city}",
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[700],
                                fontSize: 13,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // FEATURES
                      Row(
                        children: [
                          _buildFeature(
                            Icons.bed,
                            "${property.bedrooms} Beds",
                            isDark,
                          ),
                          const SizedBox(width: 12),
                          _buildFeature(
                            Icons.bathtub,
                            "${property.bathrooms} Baths",
                            isDark,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'sold':
        return Colors.red;
      case 'upcoming':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
