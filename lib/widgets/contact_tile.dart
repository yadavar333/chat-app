import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/contact.dart';

class ContactTile extends StatelessWidget {
  final Contact contact;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const ContactTile({
    super.key,
    required this.contact,
    required this.onTap,
    this.onLongPress,
  });

  String _formatTime(String? isoString) {
    if (isoString == null) return '';
    final dt = DateTime.tryParse(isoString);
    if (dt == null) return '';
    final now = DateTime.now();
    if (now.difference(dt).inDays == 0) {
      return DateFormat.jm().format(dt.toLocal());
    } else if (now.difference(dt).inDays == 1) {
      return 'Yesterday';
    }
    return DateFormat.MMMd().format(dt.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasUnread = contact.unreadCount > 0;

    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
      leading: CircleAvatar(
        backgroundColor: Color(contact.avatarColor),
        child: Text(
          contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              contact.name,
              style: TextStyle(
                fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            _formatTime(contact.lastMessageAt),
            style: TextStyle(
              fontSize: 12,
              color: hasUnread ? scheme.primary : scheme.onSurfaceVariant,
              fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              contact.lastMessageText ?? 'No messages yet',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: hasUnread
                    ? scheme.onSurface
                    : scheme.onSurfaceVariant,
                fontWeight:
                    hasUnread ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
          if (hasUnread)
            Container(
              margin: const EdgeInsets.only(left: 6),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                contact.unreadCount > 99
                    ? '99+'
                    : contact.unreadCount.toString(),
                style: TextStyle(
                  color: scheme.onPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
