import 'package:flutter/material.dart';

import '../db/shift_dao.dart';
import '../l10n/app_strings.dart';
import '../models/shift.dart';
import '../utils/app_session.dart';

class ShiftsScreen extends StatefulWidget {
  const ShiftsScreen({super.key});

  @override
  State<ShiftsScreen> createState() => _ShiftsScreenState();
}

class _ShiftsScreenState extends State<ShiftsScreen> {
  late Future<Shift?> _activeShiftFuture;
  late Future<List<Shift>> _historyFuture;
  bool _busy = false;

  int get _employeeId => AppSession.instance.currentEmployeeId;
  String get _employeeName => AppSession.instance.currentEmployeeName ?? '';

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _activeShiftFuture = ShiftDAO.getActiveShift(_employeeId);
    _historyFuture = ShiftDAO.getHistory(_employeeId);
  }

  Future<void> _clockIn() async {
    setState(() => _busy = true);
    await ShiftDAO.clockIn(_employeeId, _employeeName);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _refresh();
    });
  }

  Future<void> _clockOut(Shift active) async {
    setState(() => _busy = true);
    await ShiftDAO.clockOut(active.id);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _refresh();
    });
  }

  String _fmtTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  String _fmtDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  String _fmtDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.t('shifts_title'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: FutureBuilder<Shift?>(
              future: _activeShiftFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()));
                }
                final active = snapshot.data;
                return Column(
                  children: [
                    Text(
                      active != null
                          ? '${S.t('clocked_in_since')} ${_fmtTime(active.clockIn)}'
                          : S.t('not_clocked_in'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: active != null ? Colors.red.shade600 : const Color(0xFF6D4C41),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: _busy ? null : () => active != null ? _clockOut(active) : _clockIn(),
                        icon: Icon(active != null ? Icons.logout : Icons.login),
                        label: Text(active != null ? S.t('clock_out_button') : S.t('clock_in_button')),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(S.t('shift_history_title'), style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Shift>>(
              future: _historyFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final shifts = snapshot.data ?? [];
                if (shifts.isEmpty) {
                  return Center(child: Text(S.t('no_shifts_yet')));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: shifts.length,
                  itemBuilder: (context, index) {
                    final shift = shifts[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(_fmtDate(shift.clockIn)),
                        subtitle: Text(
                          '${_fmtTime(shift.clockIn)} → ${shift.clockOut != null ? _fmtTime(shift.clockOut!) : S.t('ongoing_label')}',
                        ),
                        trailing: Text(
                          shift.isActive ? S.t('ongoing_label') : _fmtDuration(shift.duration),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: shift.isActive ? Colors.green.shade700 : null,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
