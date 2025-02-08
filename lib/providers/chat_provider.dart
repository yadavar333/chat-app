import 'package:flutter/foundation.dart';
import '../db/db_helper.dart';
import '../models/message.dart';

class ChatProvider extends ChangeNotifier {
  List<Message> _messages = [];
  int? _currentContactId;

  List<Message> get messages => List.unmodifiable(_messages);

  Future<void> loadMessages(int contactId) async {
    _currentContactId = contactId;
    _messages = await DBHelper.getMessages(contactId);
    notifyListeners();
    await DBHelper.markMessagesAsRead(contactId);
    // Update read status in-memory
    _messages = _messages
        .map((m) => m.isFromMe ? m : m.copyWith(isRead: true))
        .toList();
    notifyListeners();
  }

  Future<void> sendMessage(int contactId, String text) async {
    final msg = Message(
      contactId: contactId,
      text: text.trim(),
      isFromMe: true,
      isRead: true,
      createdAt: DateTime.now().toIso8601String(),
    );
    final id = await DBHelper.insertMessage(msg);
    _messages.add(Message(
      id: id,
      contactId: msg.contactId,
      text: msg.text,
      isFromMe: msg.isFromMe,
      isRead: msg.isRead,
      createdAt: msg.createdAt,
    ));
    notifyListeners();
  }

  /// Simulate an incoming reply (demo purposes).
  Future<void> simulateReply(int contactId, String replyText) async {
    final msg = Message(
      contactId: contactId,
      text: replyText,
      isFromMe: false,
      isRead: false,
      createdAt: DateTime.now().toIso8601String(),
    );
    final id = await DBHelper.insertMessage(msg);
    _messages.add(msg.copyWith(isRead: true));
    notifyListeners();
  }

  void clear() {
    _messages = [];
    _currentContactId = null;
    notifyListeners();
  }
}
