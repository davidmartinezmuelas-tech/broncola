import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/home_screen.dart';
import 'services/user_access_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await UserAccessService.instance.load();
  // TODO: quitar antes de lanzar a producción
  await UserAccessService.instance.debugUnlockAll();
  runApp(const BroncolaApp());
}

class BroncolaApp extends StatelessWidget {
  const BroncolaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Broncola',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A1A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF7A45),
          secondary: Color(0xFF26A69A),
          surface: Color(0xFF1A1D28),
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
