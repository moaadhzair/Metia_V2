import 'package:flutter/material.dart';
import 'package:metia/models/log_entry.dart';
import 'package:metia/models/logger.dart';

class LoggingPage extends StatefulWidget {
  const LoggingPage({super.key});

  @override
  State<LoggingPage> createState() => _LoggingPageState();
}

class _LoggingPageState extends State<LoggingPage> {
  late Future<List<LogEntry>> _logsFuture;

  @override
  void initState() {
    super.initState();
    _logsFuture = Logger.getLogs(limit: 99999999);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Logs')),
      body: FutureBuilder<List<LogEntry>>(
        future: _logsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}'));
          }
          final logs = snapshot.data ?? [];
          if (logs.isEmpty) {
            return const Center(child: Text('No logs found.'));
          }
          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return ListTile(
                title: Text(log.message),
                subtitle: Text(
                  'Level: ${log.level}\nTime: ${log.timestamp}\nDetails: ${log.details ?? "Empty"}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
