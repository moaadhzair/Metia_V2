import 'package:flutter/material.dart';
import 'package:metia/colors/material_theme.dart';
import 'package:metia/data/user/user_data.dart';
import 'package:metia/models/login_provider.dart';
import 'package:metia/screens/home_page.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserData.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      child: MaterialApp(
        //showPerformanceOverlay: true,
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(colorScheme: MaterialTheme.darkHighContrastScheme()),
        home: const HomePage(),
      ),
    );
  }
}
