import 'package:flutter/material.dart';
import 'package:gnbtask/Widgets/property_card.dart';
import 'package:gnbtask/Screens/filter_dialog.dart';
import 'package:gnbtask/provider/property_provider.dart';
import 'package:gnbtask/provider/theme_provider.dart';
import 'package:provider/provider.dart';

class PropertyListScreen extends StatefulWidget {
  const PropertyListScreen({super.key});

  @override
  State<PropertyListScreen> createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<PropertyProvider>().fetchProperties();
    }
  }

  void _openFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const FilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Properties"),
        actions: [
          // Theme Switcher
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) =>
                      RotationTransition(turns: anim, child: child),
                  child: Icon(
                    themeProvider.isDarkMode
                        ? Icons.light_mode
                        : Icons.dark_mode,
                    key: ValueKey(themeProvider.isDarkMode),
                  ),
                ),
                onPressed: themeProvider.toggleTheme,
              );
            },
          ),

          // Filter Button with Badge
          Consumer<PropertyProvider>(
            builder: (context, provider, _) {
              bool isFiltered =
                  provider.selectedLocation != null ||
                  provider.selectedStatus != null ||
                  provider.selectedTags.isNotEmpty ||
                  provider.priceRange.start > 0 ||
                  provider.priceRange.end < 1000000;

              return IconButton(
                icon: Badge(
                  isLabelVisible: isFiltered,
                  label: const Text("!", style: TextStyle(color: Colors.white)),
                  child: const Icon(Icons.tune),
                ),
                onPressed: () => _openFilters(context),
              );
            },
          ),
        ],
      ),
      body: Consumer<PropertyProvider>(
        builder: (context, provider, child) {
          if (provider.isFirstLoad && provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.properties.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: isDark ? Colors.red[300] : Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.error!,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  TextButton(
                    onPressed: () => provider.fetchProperties(refresh: true),
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          if (provider.properties.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 60,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  const SizedBox(height: 20),
                  const Text("No properties match your filters."),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: provider.clearFilters,
                    child: const Text("Clear Filters"),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => provider.fetchProperties(refresh: true),
            child: LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount;
                double spacing = 12;

                // Breakpoints
                if (constraints.maxWidth >= 1200) {
                  crossAxisCount = 4;
                } else if (constraints.maxWidth >= 900) {
                  crossAxisCount = 3;
                } else if (constraints.maxWidth >= 600) {
                  crossAxisCount = 2;
                } else {
                  crossAxisCount = 1;
                }

                double cardWidth =
                    (constraints.maxWidth - (crossAxisCount - 1) * spacing) /
                    crossAxisCount;

                double childAspectRatio;

                // Mobile
                if (constraints.maxWidth < 600) {
                  childAspectRatio = 1.14;
                }
                // Tablet
                else if (constraints.maxWidth < 900) {
                  childAspectRatio = 1;
                }
                // Desktop
                else if (constraints.maxWidth < 1200) {
                  childAspectRatio = 1.05;
                }
                // Wide Desktop
                else {
                  childAspectRatio = 1.05;
                }

                // Center padding for wide screens
                double horizontalPadding =
                    (constraints.maxWidth -
                        crossAxisCount * cardWidth -
                        (crossAxisCount - 1) * spacing) /
                    2;
                horizontalPadding = horizontalPadding < spacing
                    ? spacing
                    : horizontalPadding;

                return CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: spacing,
                      ),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => FadeInUp(
                            delay: index > 10 ? 0 : index * 50,
                            child: PropertyCard(
                              property: provider.properties[index],
                            ),
                          ),
                          childCount: provider.properties.length,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: spacing,
                          mainAxisSpacing: spacing,
                          childAspectRatio: childAspectRatio,
                        ),
                      ),
                    ),
                    if (provider.isLoading)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// FadeInUp Animation
class FadeInUp extends StatelessWidget {
  final int delay;
  final Widget child;

  const FadeInUp({super.key, required this.delay, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
