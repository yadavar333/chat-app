import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/contacts_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/contact_tile.dart';
import 'chat_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showAddContactSheet(BuildContext context) {
    final nameController = TextEditingController();
    final colors = [
      0xFF6366F1, 0xFFEC4899, 0xFF10B981,
      0xFFF59E0B, 0xFF3B82F6, 0xFFEF4444,
    ];
    int selectedColor = colors.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.fromLTRB(
            24, 24, 24,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('New Contact',
                  style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              const Text('Avatar colour'),
              const SizedBox(height: 8),
              Row(
                children: colors
                    .map((c) => GestureDetector(
                          onTap: () => setState(() => selectedColor = c),
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Color(c),
                              shape: BoxShape.circle,
                              border: selectedColor == c
                                  ? Border.all(
                                      color: Theme.of(ctx).colorScheme.primary,
                                      width: 3,
                                    )
                                  : null,
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;
                    context.read<ContactsProvider>().addContact(name, selectedColor);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Add Contact'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int contactId, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete contact?'),
        content: Text('This will delete "$name" and all messages.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              context.read<ContactsProvider>().deleteContact(contactId);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search messages',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Consumer<ContactsProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.contacts.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline,
                      size: 72,
                      color: Theme.of(context).colorScheme.outlineVariant),
                  const SizedBox(height: 16),
                  Text('No contacts yet',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  const Text('Tap + to add someone'),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: provider.refresh,
            child: ListView.separated(
              itemCount: provider.contacts.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 72),
              itemBuilder: (context, index) {
                final contact = provider.contacts[index];
                return ContactTile(
                  contact: contact,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(contact: contact),
                      ),
                    );
                    // Refresh unread counts on return
                    provider.refresh();
                  },
                  onLongPress: () => _confirmDelete(
                      context, contact.id!, contact.name),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddContactSheet(context),
        tooltip: 'New contact',
        child: const Icon(Icons.edit),
      ),
    );
  }
}
