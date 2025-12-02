import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gnbtask/Screens/Property_list_screen.dart';
import 'package:gnbtask/firebase_options.dart';
import 'package:gnbtask/provider/theme_provider.dart';
import 'package:provider/provider.dart';
import 'Services/notification_service.dart';
import 'provider/property_provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize notifications with error handling
  try {
    await NotificationService().init();
    // Subscribe all users to receive notifications
    await NotificationService().subscribeToAllProperties();
    print('✅ Notification service initialized successfully');
  } catch (e) {
    print('⚠️  Notification service failed to initialize: $e');
    print('📱 App will continue without push notifications');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => PropertyProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final themeProvider = Provider.of<ThemeProvider>(context);

        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Real Estate App',

          // 🔥 FIX FONT SCALING ISSUE
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaleFactor: 1.0, // ← lock font scaling globally
              ),
              child: child!,
            );
          },

          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.grey[100],
            cardColor: Colors.white,
            // 📌 DEFAULT FONT SIZES FOR CONSISTENT UI
            textTheme: const TextTheme(
              bodyLarge: TextStyle(fontSize: 15),
              bodyMedium: TextStyle(fontSize: 13),
              bodySmall: TextStyle(fontSize: 12),
              titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              titleMedium: TextStyle(fontSize: 18),
              titleSmall: TextStyle(fontSize: 16),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
          ),

          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212),
            cardColor: const Color(0xFF1E1E1E),

            // 📌 DEFAULT DARK MODE FONT SIZES
            textTheme: const TextTheme(
              bodyLarge: TextStyle(fontSize: 15),
              bodyMedium: TextStyle(fontSize: 13),
              bodySmall: TextStyle(fontSize: 12),
              titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              titleMedium: TextStyle(fontSize: 18),
              titleSmall: TextStyle(fontSize: 16),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blueGrey,
              brightness: Brightness.dark,
            ),
          ),
          themeMode: themeProvider.themeMode,
          home: const PropertyListScreen(),
        );
      },
    );
  }
}
