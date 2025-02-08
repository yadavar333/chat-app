class Contact {
  final int? id;
  final String name;
  final int avatarColor;
  final String createdAt;

  // Populated by queries — not stored in DB
  final String? lastMessageText;
  final String? lastMessageAt;
  final int unreadCount;

  const Contact({
    this.id,
    required this.name,
    required this.avatarColor,
    required this.createdAt,
    this.lastMessageText,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  Contact copyWith({
    int? id,
    String? name,
    int? avatarColor,
    String? createdAt,
    String? lastMessageText,
    String? lastMessageAt,
    int? unreadCount,
  }) =>
      Contact(
        id: id ?? this.id,
        name: name ?? this.name,
        avatarColor: avatarColor ?? this.avatarColor,
        createdAt: createdAt ?? this.createdAt,
        lastMessageText: lastMessageText ?? this.lastMessageText,
        lastMessageAt: lastMessageAt ?? this.lastMessageAt,
        unreadCount: unreadCount ?? this.unreadCount,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'avatar_color': avatarColor,
        'created_at': createdAt,
      };

  factory Contact.fromMap(Map<String, dynamic> m) => Contact(
        id: m['id'] as int?,
        name: m['name'] as String,
        avatarColor: m['avatar_color'] as int,
        createdAt: m['created_at'] as String,
        lastMessageText: m['last_message_text'] as String?,
        lastMessageAt: m['last_message_at'] as String?,
        unreadCount: (m['unread_count'] as int?) ?? 0,
      );
}
