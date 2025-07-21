import 'package:flutter/material.dart';
import 'package:metia/models/login_provider.dart';
import 'package:provider/provider.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = Provider.of<UserProvider>(context).isLoggedIn;
    
    return Scaffold(
      appBar: AppBar(title: const Text('Library')),
      body: isLoggedIn
          ? const Center(child: Text('Your Library'))
          : const Center(child: Text('Please log in to view your library')),
    );
  }
}
