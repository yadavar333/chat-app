import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _keyDisplayName = 'display_name';

  final _nameController = TextEditingController();
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_keyDisplayName) ?? '';
    if (mounted) setState(() => _nameController.text = name);
  }

  Future<void> _saveName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDisplayName, name);
    if (!mounted) return;
    setState(() => _saved = true);
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Display name saved'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _saved = false);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Profile section ─────────────────────────────────────────────
          Text('Profile', style: Theme.of(context).textTheme.labelLarge
              ?.copyWith(color: scheme.primary)),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Display name',
              hintText: 'Your name in outgoing messages',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.badge_outlined),
            ),
            textCapitalization: TextCapitalization.words,
            onSubmitted: (_) => _saveName(),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _saveName,
            icon: Icon(_saved ? Icons.check : Icons.save_outlined),
            label: Text(_saved ? 'Saved!' : 'Save name'),
          ),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),

          // ── About section ────────────────────────────────────────────────
          Text('About', style: Theme.of(context).textTheme.labelLarge
              ?.copyWith(color: scheme.primary)),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.info_outline),
            title: const Text('Chat App'),
            subtitle: const Text('Local-only messaging — no servers, no data shared.'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.storage_outlined),
            title: const Text('Storage'),
            subtitle: const Text('All messages are stored on-device in SQLite.'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.lock_outline),
            title: const Text('Privacy'),
            subtitle: const Text('No network calls. No analytics. No cloud sync.'),
          ),
        ],
      ),
    );
  }
}
