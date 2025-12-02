import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gnbtask/models/property_model.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class PropertyProvider extends ChangeNotifier {
  final String _baseUrl = 'http://147.182.207.192:8003/properties';

  List<Property> _properties = [];
  bool _isLoading = false;
  bool _isFirstLoad = true;
  String? _error;
  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMoreData = true;

  // --- Filter State ---
  RangeValues _priceRange = const RangeValues(0, 1000000); // Default range
  String? _selectedLocation;
  String? _selectedStatus;
  List<String> _selectedTags = [];

  bool _isUploading = false;
  bool get isUploading => _isUploading;
  // --- Filter Options (In a real app, fetch these from API) ---
  final List<String> locations = [
    'Cityville',
    'Metrocity',
    'Hillview',
    'Beachside',
    'Townsburg',
  ];
  final List<String> statuses = ['Available', 'Sold', 'Upcoming'];
  final List<String> availableTags = [
    'New',
    'Furnished',
    'Luxury',
    'Pet Friendly',
  ];

  // --- Getters ---
  List<Property> get properties => _properties;
  bool get isLoading => _isLoading;
  bool get isFirstLoad => _isFirstLoad;
  String? get error => _error;
  bool get hasMoreData => _hasMoreData;

  // Filter Getters
  RangeValues get priceRange => _priceRange;
  String? get selectedLocation => _selectedLocation;
  String? get selectedStatus => _selectedStatus;
  List<String> get selectedTags => _selectedTags;

  PropertyProvider() {
    fetchProperties();
  }

  // --- Filter Setters ---
  void setPriceRange(RangeValues range) {
    _priceRange = range;
    notifyListeners();
  }

  void setLocation(String? loc) {
    _selectedLocation = loc;
    notifyListeners();
  }

  void setStatus(String? status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void toggleTag(String tag) {
    if (_selectedTags.contains(tag)) {
      _selectedTags.remove(tag);
    } else {
      _selectedTags.add(tag);
    }
    notifyListeners();
  }

  void clearFilters() {
    _priceRange = const RangeValues(0, 1000000);
    _selectedLocation = null;
    _selectedStatus = null;
    _selectedTags = [];
    notifyListeners();
    fetchProperties(refresh: true); // Reload data immediately
  }

  void applyFilters() {
    fetchProperties(refresh: true); // Reset page to 1 and reload
  }

  Future<Property?> fetchPropertyById(String id) async {
    try {
      return _properties.firstWhere((p) => p.id == id);
    } catch (e) {
      return null; // ID not found in list
    }
  }

  Future<bool> uploadPropertyImage(String propertyId, XFile imageFile) async {
    _isUploading = true;
    notifyListeners();

    try {
      final uri = Uri.parse(
        '$_baseUrl/$propertyId/images',
      ); // Assumed API Endpoint

      // 1. Create Multipart Request
      var request = http.MultipartRequest('POST', uri);

      // 2. Read bytes (Cross-platform way: works on Web & Mobile)
      final imageBytes = await imageFile.readAsBytes();

      // 3. Create Multipart File
      var multipartFile = http.MultipartFile.fromBytes(
        'image', // The key expected by your backend (e.g., 'file', 'image')
        imageBytes,
        filename: imageFile.name,
      );

      request.files.add(multipartFile);

      // 4. Send
      var response = await request.send();

      _isUploading = false;
      notifyListeners();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true; // Success
      } else {
        _error = "Upload failed: ${response.statusCode}";
        return false;
      }
    } catch (e) {
      _isUploading = false;
      _error = "Connection Error during upload";
      notifyListeners();
      return false;
    }
  }

  // --- Main Fetch Logic ---
  Future<void> fetchProperties({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _properties.clear();
      _hasMoreData = true;
      _isFirstLoad = true;
      _error = null;
      notifyListeners();
    }

    if (_isLoading || !_hasMoreData) return;

    _isLoading = true;
    notifyListeners();

    try {
      // 1. Base URL
      StringBuffer query = StringBuffer(
        '$_baseUrl?page=$_currentPage&page_size=$_pageSize',
      );

      // 2. Dynamic Query Construction (Minimal Payload)
      // Only add parameters if they are set/modified

      // Price
      if (_priceRange.start > 0) {
        query.write('&min_price=${_priceRange.start.round()}');
      }
      if (_priceRange.end < 1000000) {
        query.write('&max_price=${_priceRange.end.round()}');
      }

      // Location
      if (_selectedLocation != null) {
        query.write('&location=$_selectedLocation');
      }

      // Status
      if (_selectedStatus != null) {
        query.write('&status=$_selectedStatus');
      }

      // Tags (Handling multiple values: ?tags=New&tags=Furnished)
      for (String tag in _selectedTags) {
        query.write('&tags=$tag');
      }

      print("Requesting: ${query.toString()}"); 

      final response = await http
          .get(Uri.parse(query.toString()))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> propList = data['properties'] ?? [];

        final List<Property> newProperties = propList
            .map((item) => Property.fromJson(item))
            .toList();

        _properties.addAll(newProperties);

        final int totalPages = data['totalPages'] ?? 0;
        if (_currentPage >= totalPages) {
          _hasMoreData = false;
        } else {
          _currentPage++;
        }
      } else {
        _error = 'Server Error: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Connection failed. Check internet.';
    } finally {
      _isLoading = false;
      _isFirstLoad = false;
      notifyListeners();
    }
  }
}
