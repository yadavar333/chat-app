import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/db_helper.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _searching = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() => _searching = true);
    final rows = await DBHelper.searchMessages(query.trim());
    if (mounted) setState(() { _results = rows; _searching = false; });
  }

  String _formatTime(String iso) {
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return '';
    final now = DateTime.now();
    if (now.difference(dt).inDays == 0) return DateFormat.jm().format(dt);
    return DateFormat.MMMd().format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search messages…',
            border: InputBorder.none,
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      _search('');
                    },
                  )
                : null,
          ),
          onChanged: _search,
        ),
      ),
      body: _searching
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty
              ? Center(
                  child: Text(
                    _controller.text.isEmpty
                        ? 'Type to search messages'
                        : 'No results for "${_controller.text}"',
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                )
              : ListView.separated(
                  itemCount: _results.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 16),
                  itemBuilder: (context, index) {
                    final row = _results[index];
                    final isFromMe = (row['is_from_me'] as int) == 1;
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          (row['contact_name'] as String)[0].toUpperCase(),
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              row['contact_name'] as String,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          Text(
                            _formatTime(row['created_at'] as String),
                            style: TextStyle(
                                fontSize: 12,
                                color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                      subtitle: Row(
                        children: [
                          if (isFromMe)
                            Icon(Icons.done_all,
                                size: 14,
                                color: scheme.primary),
                          if (isFromMe) const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              row['text'] as String,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
