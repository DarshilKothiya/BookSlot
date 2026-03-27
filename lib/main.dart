import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/admin_dashboard.dart';
import 'providers/auth_provider.dart';
import 'providers/booking_provider.dart';
import 'models/user.dart';
import 'utils/minimal_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Firebase initialization failed, using local storage: $e');
  }
  runApp(const BookSlotApp());
}

class BookSlotApp extends StatelessWidget {
  const BookSlotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
      ],
      child: MaterialApp(
        title: 'BookSlot',
        theme: MinimalTheme.lightTheme,
        home: const AuthWrapper(),
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/admin': (context) => const AdminDashboard(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show splash screen on first load
        if (authProvider.isLoading) {
          return const SplashScreen();
        }

        if (authProvider.currentUser != null) {
          if (authProvider.currentUser!.isAdmin) {
            return const AdminDashboard();
          } else {
            return const HomeScreen();
          }
        }

        return const LoginScreen();
      },
    );
  }
}
