import 'package:flutter/material.dart';

import '../db/notes_dao.dart';
import '../l10n/app_strings.dart';
import '../models/chat_message.dart';
import '../utils/app_session.dart';
import 'chat_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late Future<List<ChatContact>> _contactsFuture;

  @override
  void initState() {
    super.initState();
    _contactsFuture = NotesDAO.getContacts(AppSession.instance.currentEmployeeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.t('chat_title'))),
      body: FutureBuilder<List<ChatContact>>(
        future: _contactsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final contacts = snapshot.data ?? [];
          if (contacts.isEmpty) {
            return Center(child: Text(S.t('no_other_employees')));
          }
          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(contact.name),
                trailing: const Icon(Icons.chevron_left),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ChatScreen(contact: contact)),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
