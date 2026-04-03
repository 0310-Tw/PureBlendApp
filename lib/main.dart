import 'package:flutter/material.dart';
import 'package:frontend/app/routes.dart';
import 'package:frontend/core/providers/address_provider.dart';
import 'package:frontend/core/providers/order_provider.dart';
import 'package:provider/provider.dart';

import 'core/providers/auth_provider.dart';
import 'core/providers/cart_provider.dart';
import 'core/providers/favorite_provider.dart';
import 'core/providers/profile_provider.dart';
import 'core/providers/smoothie_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
  providers: [
    ChangeNotifierProvider<AuthProvider>(
      create: (_) => AuthProvider(),
    ),
    ChangeNotifierProvider<SmoothieProvider>(
      create: (_) => SmoothieProvider(),
    ),
    ChangeNotifierProvider<CartProvider>(
      create: (_) => CartProvider(),
    ),
    ChangeNotifierProvider<FavoriteProvider>(
      create: (_) => FavoriteProvider(),
    ),
    ChangeNotifierProvider<ProfileProvider>(
      create: (_) => ProfileProvider(),
    ),
    ChangeNotifierProvider<OrderProvider>(
      create: (_) => OrderProvider(),
    ),
    ChangeNotifierProvider<AddressProvider>(   
      create: (_) => AddressProvider(),
    ),
  ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Pure Blend Smoothies',
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
      ),
    );
  }
}