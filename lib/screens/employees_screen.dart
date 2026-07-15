import 'package:flutter/material.dart';

import '../db/employee_dao.dart';
import '../l10n/app_strings.dart';
import '../models/employee.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  final _nameController = TextEditingController();
  final _salaryController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  int? _editingEmployeeId;
  late Future<List<Employee>> _employeesFuture;

  @override
  void initState() {
    super.initState();
    _employeesFuture = EmployeeDAO.getAll();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _salaryController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() => _employeesFuture = EmployeeDAO.getAll());
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _resetForm() {
    _nameController.clear();
    _salaryController.clear();
    _usernameController.clear();
    _passwordController.clear();
    setState(() => _editingEmployeeId = null);
  }

  void _startEdit(Employee employee) {
    _nameController.text = employee.name;
    _salaryController.text = employee.salary.toString();
    _usernameController.text = employee.username;
    _passwordController.text = employee.password;
    setState(() => _editingEmployeeId = employee.id);
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final salaryText = _salaryController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || salaryText.isEmpty || username.isEmpty || password.isEmpty) {
      _showMessage(S.t('err_all_fields_required'));
      return;
    }

    final salary = double.tryParse(salaryText);
    if (salary == null) {
      _showMessage(S.t('err_salary_must_be_number'));
      return;
    }

    try {
      if (_editingEmployeeId == null) {
        await EmployeeDAO.insert(name: name, salary: salary, username: username, password: password);
        _showMessage('${S.t('employee_hired_prefix')} $name');
      } else {
        await EmployeeDAO.update(
          id: _editingEmployeeId!,
          name: name,
          salary: salary,
          username: username,
          password: password,
        );
        _showMessage(S.t('employee_updated'));
      }
      _resetForm();
      _refresh();
    } catch (e) {
      _showMessage('${S.t('err_operation_prefix')} $e');
    }
  }

  Future<void> _toggleActive(Employee employee) async {
    await EmployeeDAO.setActive(employee.id, !employee.active);
    _refresh();
  }

  Future<void> _confirmDelete(Employee employee) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.t('confirm_delete')),
        content: Text('${S.t('confirm_delete_item_prefix')} "${employee.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(S.t('cancel'))),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(S.t('delete'), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await EmployeeDAO.delete(employee.id);
      if (_editingEmployeeId == employee.id) _resetForm();
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _editingEmployeeId != null;

    return Scaffold(
      appBar: AppBar(title: Text(S.t('employees_title'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: S.t('worker_name'), border: const OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _salaryController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: S.t('salary'), border: const OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(labelText: S.t('username'), border: const OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: S.t('password'), border: const OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6D4C41),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _submit,
                        icon: Icon(isEditing ? Icons.save : Icons.person_add),
                        label: Text(isEditing ? S.t('save_edit') : S.t('hire')),
                      ),
                    ),
                    if (isEditing) ...[
                      const SizedBox(width: 10),
                      OutlinedButton(onPressed: _resetForm, child: Text(S.t('cancel'))),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: FutureBuilder<List<Employee>>(
              future: _employeesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final employees = snapshot.data ?? [];
                if (employees.isEmpty) {
                  return Center(child: Text(S.t('no_employees_yet')));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: employees.length,
                  itemBuilder: (context, index) {
                    final employee = employees[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    employee.name,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Chip(
                                  label: Text(employee.active ? S.t('active') : S.t('inactive')),
                                  backgroundColor: employee.active
                                      ? Colors.green.shade100
                                      : Colors.red.shade100,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 16,
                              runSpacing: 4,
                              children: [
                                Text('${S.t('salary_label')}: ${employee.salary.toStringAsFixed(2)}'),
                                Text('${S.t('username_label')}: ${employee.username}'),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => _toggleActive(employee),
                                  child: Text(S.t('toggle_active')),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Color(0xFF6D4C41)),
                                  onPressed: () => _startEdit(employee),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _confirmDelete(employee),
                                ),
                              ],
                            ),
                          ],
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
