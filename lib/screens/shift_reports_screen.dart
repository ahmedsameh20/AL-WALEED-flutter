import 'package:flutter/material.dart';

import '../db/shift_dao.dart';
import '../l10n/app_strings.dart';
import '../models/shift.dart';

class ShiftReportsScreen extends StatefulWidget {
  const ShiftReportsScreen({super.key});

  @override
  State<ShiftReportsScreen> createState() => _ShiftReportsScreenState();
}

class _ShiftReportsScreenState extends State<ShiftReportsScreen> {
  late final Future<List<EmployeeShiftSummary>> _summariesFuture = ShiftDAO.getAllSummaries();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.t('shift_reports_title'))),
      body: FutureBuilder<List<EmployeeShiftSummary>>(
        future: _summariesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final summaries = snapshot.data ?? [];
          if (summaries.isEmpty) {
            return Center(child: Text(S.t('no_shift_data_yet')));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: summaries.length,
            itemBuilder: (context, index) {
              final summary = summaries[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(summary.employeeName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    '${S.t('total_hours_label')}: ${summary.totalHours.toStringAsFixed(1)}h  ·  '
                    '${S.t('shifts_count_label')}: ${summary.shiftCount}',
                  ),
                  trailing: summary.isActive
                      ? Chip(
                          label: Text(S.t('currently_active_label'), style: const TextStyle(fontSize: 11)),
                          backgroundColor: Colors.green.shade100,
                          visualDensity: VisualDensity.compact,
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
