import 'package:flutter/material.dart';
import 'package:gnbtask/Services/analytics_service.dart';
import 'package:gnbtask/provider/property_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class FilterSheet extends StatelessWidget {
  const FilterSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PropertyProvider>(context);
    final currencyFormat = NumberFormat.compactSimpleCurrency();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 40),
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Filters",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              TextButton(
                onPressed: () {
                  AnalyticsService().logInteraction(
                    elementId: 'filter_clear_all',
                    action: 'tap',
                  );
                  provider.clearFilters();
                  Navigator.pop(context);
                },
                child: Text(
                  "Clear All",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Divider(color: isDark ? Colors.grey[700] : Colors.grey),

          Expanded(
            child: ListView(
              children: [
                // Location
                Text(
                  "Location",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: provider.selectedLocation,
                  hint: Text(
                    "Select City",
                    style: TextStyle(
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.grey[800] : Colors.grey[200],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  dropdownColor: isDark ? Colors.grey[800] : Colors.white,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  items: provider.locations.map((loc) {
                    return DropdownMenuItem(value: loc, child: Text(loc));
                  }).toList(),
                  onChanged: (val) => provider.setLocation(val),
                ),
                const SizedBox(height: 20),

                // Price Range
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Price Range",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      "${currencyFormat.format(provider.priceRange.start)} - ${currencyFormat.format(provider.priceRange.end)}",
                      style: TextStyle(
                        color: isDark ? Colors.grey[300] : Colors.blueGrey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                RangeSlider(
                  values: provider.priceRange,
                  min: 0,
                  max: 1000000,
                  divisions: 20,
                  activeColor: Colors.blueAccent,
                  inactiveColor: isDark ? Colors.grey[700] : Colors.grey[300],
                  labels: RangeLabels(
                    currencyFormat.format(provider.priceRange.start),
                    currencyFormat.format(provider.priceRange.end),
                  ),
                  onChanged: (RangeValues values) {
                    provider.setPriceRange(values);
                  },
                ),
                const SizedBox(height: 20),

                // Status
                Text(
                  "Status",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: provider.statuses.map((status) {
                    final isSelected = provider.selectedStatus == status;
                    return ChoiceChip(
                      label: Text(
                        status,
                        style: TextStyle(
                          color: isSelected
                              ? (isDark ? Colors.black : Colors.white)
                              : (isDark ? Colors.white : Colors.black),
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: isDark
                          ? Colors.blueAccent.withOpacity(0.3)
                          : Colors.blueAccent.withOpacity(0.2),
                      backgroundColor: isDark
                          ? Colors.grey[800]
                          : Colors.grey[200],
                      onSelected: (bool selected) {
                        provider.setStatus(selected ? status : null);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Tags
                Text(
                  "Amenities & Tags",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: provider.availableTags.map((tag) {
                    final isSelected = provider.selectedTags.contains(tag);

                    return FilterChip(
                      label: Text(tag),
                      selected: isSelected,
                      checkmarkColor: isDark ? Colors.black : Colors.white,
                      selectedColor: isDark ? Colors.greenAccent : Colors.green,
                      backgroundColor: isDark
                          ? Colors.grey[800]
                          : Colors.grey[200],
                      labelStyle: TextStyle(
                        color: isSelected
                            ? (isDark ? Colors.black : Colors.white)
                            : (isDark ? Colors.white : Colors.black),
                      ),
                      onSelected: (bool selected) {
                        provider.toggleTag(tag);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // --- APPLY BUTTON WITH ANALYTICS ---
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey[900],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                AnalyticsService().logInteraction(
                  elementId: 'filter_apply_btn',
                  action: 'filter_applied',
                  metadata: {
                    'location': provider.selectedLocation ?? 'All',
                    'price_min': provider.priceRange.start.round(),
                    'price_max': provider.priceRange.end.round(),
                    'status': provider.selectedStatus ?? 'All',
                    'tags': provider.selectedTags.isNotEmpty
                        ? provider.selectedTags.join(',')
                        : 'None',
                  },
                );

                provider.applyFilters();
                Navigator.pop(context);
              },
              child: const Text(
                "Apply Filters",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
