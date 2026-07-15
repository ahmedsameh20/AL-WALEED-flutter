import 'package:flutter/material.dart';

import '../db/log_dao.dart';
import '../l10n/app_strings.dart';
import '../models/log_entry.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  late Future<List<LogEntry>> _logsFuture;

  @override
  void initState() {
    super.initState();
    _logsFuture = LogDAO.getAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.t('logs_title'))),
      body: FutureBuilder<List<LogEntry>>(
        future: _logsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final logs = snapshot.data ?? [];
          if (logs.isEmpty) {
            return Center(child: Text(S.t('no_logs_yet')));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(log.action),
                  subtitle: Text(log.employeeName),
                  trailing: Text(log.timestamp, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
