import 'package:flutter/material.dart';
import 'package:metia/colors/material_theme.dart';
import 'package:metia/models/login_provider.dart';
import 'package:metia/models/profile_provider.dart';
import 'package:metia/screens/home_page.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LoginProvider()),
        ChangeNotifierProvider(create: (context) => ProfileProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(colorScheme: MaterialTheme.darkHighContrastScheme()),
        home: const HomePage(),
      ),
    );
  }
}
