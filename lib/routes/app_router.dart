import 'package:flutter/material.dart';
import '../features/receipt/presentation/pages/home_page.dart';

class AppRouter {
  static Route generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
        );
    }
  }
}
