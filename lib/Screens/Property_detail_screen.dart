import 'package:flutter/material.dart';
import 'package:gnbtask/models/property_model.dart';
import 'package:gnbtask/provider/property_provider.dart';
import 'package:gnbtask/Services/analytics_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PropertyDetailScreen extends StatefulWidget {
  final Property? property;
  final String? propertyId;

  const PropertyDetailScreen({super.key, this.property, this.propertyId})
    : assert(
        property != null || propertyId != null,
        'You must provide either a property object or an ID',
      );

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  final AnalyticsService _analytics = AnalyticsService();
  Property? _currentProperty;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.property != null) {
      _currentProperty = widget.property;
      _startAnalytics();
    } else if (widget.propertyId != null) {
      _fetchDataFromId(widget.propertyId!);
    }
  }

  Future<void> _fetchDataFromId(String id) async {
    setState(() => _isLoading = true);
    final foundProperty = await Provider.of<PropertyProvider>(
      context,
      listen: false,
    ).fetchPropertyById(id);

    if (mounted) {
      setState(() {
        _currentProperty = foundProperty;
        _isLoading = false;
      });
      if (_currentProperty != null) _startAnalytics();
    }
  }

  void _startAnalytics() {
    if (_currentProperty == null) return;
    _analytics.logPageView(
      pageName: 'property_detail',
      propertyId: _currentProperty!.id,
    );
    _analytics.startPageTimer(_currentProperty!.id);
  }

  Future<void> _callAgent(String phoneNumber) async {
    final uri = Uri(scheme: "tel", path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Cannot open dialer")));
    }
  }

  @override
  void dispose() {
    if (_currentProperty != null) {
      _analytics.endPageTimer(_currentProperty!.id);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentProperty == null) {
      return Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
        body: Center(
          child: Text(
            "Property not found",
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: CustomScrollView(
        slivers: [
          // Collapsing App Bar
          SliverAppBar(
            leading: Builder(
              builder: (context) {
                double circleSize = MediaQuery.of(context).size.width * 0.08;
                circleSize = circleSize.clamp(40, 60); // clamp for web/desktop
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: circleSize,
                      height: circleSize,
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                        size: circleSize * 0.6,
                      ),
                    ),
                  ),
                );
              },
            ),

            expandedHeight: 300.0,
            pinned: true,
            backgroundColor: isDark ? Colors.grey[900] : Colors.blueGrey[900],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _currentProperty!.title,
                style: const TextStyle(
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                ),
              ),
              background: Hero(
                tag: _currentProperty!.id,
                child: Image.network(
                  _currentProperty!.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, _, __) => Container(
                    color: isDark ? Colors.grey[800] : Colors.grey[300],
                  ),
                ),
              ),
            ),
          ),

          // Property Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Price",
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        "\$${_currentProperty!.price}",
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Location Row
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: isDark ? Colors.grey[400] : Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          "${_currentProperty!.address}, ${_currentProperty!.city}",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Divider(color: isDark ? Colors.grey[700] : Colors.grey[300]),
                  const SizedBox(height: 20),

                  // Description
                  Text(
                    "Property Description",
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "This is a beautiful property located in the heart of ${_currentProperty!.city}. "
                    "It features ${_currentProperty!.bedrooms} bedrooms and ${_currentProperty!.bathrooms} bathrooms. "
                    "Perfect for families or investment.",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.grey[300] : Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Contact Agent Button
                  Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.phone),
                      label: const Text("Contact Agent"),
                      onPressed: () {
                        final phone = _currentProperty!.agent.contact;

                        _analytics.logInteraction(
                          elementId: 'contact_agent_btn',
                          action: 'tap',
                          metadata: {
                            'property_id': _currentProperty!.id,
                            'agent_phone': phone,
                            'agent_email': _currentProperty!.agent.email,
                            'agent_name': _currentProperty!.agent.name,
                          },
                        );

                        _callAgent(phone);
                      },
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
