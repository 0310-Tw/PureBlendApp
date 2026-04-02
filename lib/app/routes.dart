import 'package:flutter/material.dart';
import 'package:frontend/features/orders/order_screen.dart';

import '../features/admin/admin_dashboard_screen.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/reset_password_screen.dart';
import '../features/auth/splash_screen.dart';
import '../features/auth/welcome_screen.dart';
import '../features/cart/cart_screen.dart';
import '../features/checkout/checkout_screen.dart';
import '../features/checkout/order_success_screen.dart';
import '../features/favorites/favorites_screen.dart';
import '../features/home/home_screen.dart';
import '../features/orders/order_details_screen.dart';
import '../features/product/smoothie_details_screen.dart';
import '../features/profile/add_edit_address_screen.dart';
import '../features/profile/addresses_screen.dart';
import '../features/profile/edit_profile_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/profile/settings_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String home = '/home';
  static const String smoothieDetails = '/smoothie-details';
  static const String favorites = '/favorites';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderSuccess = '/order-success';
  static const String orders = '/orders';
  static const String orderDetails = '/order-details';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String addresses = '/addresses';
  static const String addEditAddress = '/add-edit-address';
  static const String settings = '/settings';
  static const String admin = '/admin';

  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashScreen(),
        welcome: (_) => const WelcomeScreen(),
        login: (_) => const LoginScreen(),
        register: (_) => const RegisterScreen(),
        forgotPassword: (_) => const ForgotPasswordScreen(),
        resetPassword: (_) => const ResetPasswordScreen(),
        home: (_) => const HomeScreen(),
        smoothieDetails: (_) => const SmoothieDetailsScreen(),
        favorites: (_) => const FavoritesScreen(),
        cart: (_) => const CartScreen(),
        checkout: (_) => const CheckoutScreen(),
        orderSuccess: (_) => const OrderSuccessScreen(),
        orders: (_) => const OrdersScreen(),
        orderDetails: (_) => const OrderDetailsScreen(),
        profile: (_) => const ProfileScreen(),
        editProfile: (_) => const EditProfileScreen(),
        addresses: (_) => const AddressesScreen(),
        addEditAddress: (_) => const AddEditAddressScreen(),
        settings: (_) => const SettingsScreen(),
        admin: (_) => const AdminDashboardScreen(),
      };
}