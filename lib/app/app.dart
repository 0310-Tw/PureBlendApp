import 'package:flutter/material.dart';

import 'routes.dart';
import 'theme.dart';

class PureBlendApp extends StatelessWidget {
  const PureBlendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pure Blend Smoothie App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}