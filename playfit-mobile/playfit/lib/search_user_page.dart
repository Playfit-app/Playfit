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

  /// Searches for users based on the query entered in the text field.
  /// It sends a GET request to the server with the search query and updates the state with the results.
  /// If the response is successful, it updates the results list.
  /// If the response fails, it clears the results list and stops the loading indicator.
  ///
  /// `query` is the search term entered by the user.
  ///
  /// Returns a [Future] that completes when the search is done.
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
    // Initialize the text controller and add a listener to it
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
            // TextField for searching users
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
            // If loading, show a progress indicator
            // If no results, show a message
            // If results are found, display them in a ListView
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_results.isEmpty && _controller.text.isNotEmpty)
              const Center(child: Text('No users found.'))
            else
              // ListView to display search results
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
