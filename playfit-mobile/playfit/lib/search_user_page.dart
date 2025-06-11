import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:playfit/components/profile_icon.dart';

class SearchUsersPage extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onUserSelected;

  const SearchUsersPage({super.key, required this.onUserSelected});

  @override
  State<SearchUsersPage> createState() => _SearchUsersPageState();
}

class _SearchUsersPageState extends State<SearchUsersPage> {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;

  Future<void> _searchUsers(String query) async {
    setState(() => _loading = true);
    final token = await storage.read(key: 'token');
    final url = Uri.parse(
        "${dotenv.env['SERVER_BASE_URL']}/api/social/search-users/?search=$query");

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Token $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _results = List<Map<String, dynamic>>.from(data['results']);
        // _nextPageUrl = data['next'];
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
        // _nextPageUrl = null;
        _results.clear();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final query = _controller.text.trim();
      if (query.isNotEmpty) {
        _searchUsers(query);
      } else {
        setState(() => _results = []);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Users')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_results.isEmpty && _controller.text.isNotEmpty)
              const Center(child: Text('No users found.'))
            else
              Expanded(
                child: ListView.separated(
                  itemCount: _results.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: ProfileIcon(imageUrl: _results[index]['customizations']['base_character']['image'], size: 40),
                      title: Text(_results[index]['username']),
                      onTap: () {
                        widget.onUserSelected(_results[index]);
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
