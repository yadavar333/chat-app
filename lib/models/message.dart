class Message {
  final int? id;
  final int contactId;
  final String text;
  final bool isFromMe;
  final bool isRead;
  final String createdAt;

  const Message({
    this.id,
    required this.contactId,
    required this.text,
    required this.isFromMe,
    this.isRead = false,
    required this.createdAt,
  });

  Message copyWith({bool? isRead}) => Message(
        id: id,
        contactId: contactId,
        text: text,
        isFromMe: isFromMe,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'contact_id': contactId,
        'text': text,
        'is_from_me': isFromMe ? 1 : 0,
        'is_read': isRead ? 1 : 0,
        'created_at': createdAt,
      };

  factory Message.fromMap(Map<String, dynamic> m) => Message(
        id: m['id'] as int?,
        contactId: m['contact_id'] as int,
        text: m['text'] as String,
        isFromMe: (m['is_from_me'] as int) == 1,
        isRead: (m['is_read'] as int) == 1,
        createdAt: m['created_at'] as String,
      );
}
