import '../models/chat_message.dart';
import 'db_helper.dart';

class NotesDAO {
  static Future<List<ChatContact>> getContacts(int excludeId) async {
    final db = await DBHelper.instance.database;
    final rows = await db.query(
      'employees',
      columns: ['id', 'name'],
      where: 'id != ?',
      whereArgs: [excludeId],
    );
    return rows.map((r) => ChatContact(id: r['id'] as int, name: r['name'] as String)).toList();
  }

  static Future<List<ChatMessage>> getMessages(int myId, int otherId) async {
    final db = await DBHelper.instance.database;
    final rows = await db.rawQuery('''
      SELECT sender_id, message, created_at
      FROM notes
      WHERE (sender_id = ? AND receiver_id = ?)
         OR (sender_id = ? AND receiver_id = ?)
      ORDER BY created_at ASC
    ''', [myId, otherId, otherId, myId]);
    return rows.map(ChatMessage.fromMap).toList();
  }

  static Future<void> sendMessage({required int senderId, required int receiverId, required String message}) async {
    final db = await DBHelper.instance.database;
    await db.insert('notes', {
      'sender_id': senderId,
      'receiver_id': receiverId,
      'message': message,
    });
  }
}
