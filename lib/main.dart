import 'package:flutter/material.dart';
import 'package:sample/screen/splash.dart';
import 'package:sample/utils/cart_manager.dart';
import 'package:sample/utils/favorites_manager.dart';
import 'package:sample/utils/session_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SessionManager.init();
  await FavoritesManager.init();
  await CartManager.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Namaste Grocer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}