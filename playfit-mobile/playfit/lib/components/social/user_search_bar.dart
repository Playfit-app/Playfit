import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserSearchBar extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onUserSelected;
  const UserSearchBar({
    super.key,
    required this.onUserSelected,
  });

  @override
  State<UserSearchBar> createState() => _UserSearchBarState();
}

/// State for [UserSearchBar] widget, handling user search with debounced input,
/// paginated results, and overlay display for user selection.
class _UserSearchBarState extends State<UserSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final LayerLink _layerLink = LayerLink();
  final FocusNode _focusNode = FocusNode();
  final FlutterSecureStorage storage = FlutterSecureStorage();
  final ScrollController _scrollController = ScrollController();

  OverlayEntry? _overlayEntry;
  List<Map<String, dynamic>> _results = [];
  String? _nextPageUrl;
  Timer? _debounce;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  /// Called when the scroll position changes.
  /// If the user has scrolled within 50 pixels of the bottom of the scrollable area,
  /// this method triggers the fetching of the next page of data by calling [_fetchNextPage()].
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50) {
      _fetchNextPage();
    }
  }

  /// Handles changes to the search bar input with debounce logic.
  ///
  /// Cancels any existing debounce timer and starts a new one with a 300ms delay.
  /// If the input [value] is not empty after the delay, it triggers a user search
  /// by calling `_searchUsers(value)`. If the input is empty, it clears the search
  /// results and removes the overlay.
  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (value.isNotEmpty) {
        _searchUsers(value);
      } else {
        _results.clear();
        _removeOverlay();
      }
    });
  }

  /// Fetches the next page of user search results from the server.
  ///
  /// This method checks if there is a next page URL and if a loading operation is not already in progress.
  /// It appends the new results to the existing list and updates the next page URL.
  /// If the request fails, the loading state is reset without updating the results.
  Future<void> _fetchNextPage() async {
    if (_nextPageUrl == null || _loading) return;
    setState(() => _loading = true);

    final token = await storage.read(key: 'token');
    final response = await http.get(
      Uri.parse(_nextPageUrl!),
      headers: {
        "Authorization": "Token $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _results.addAll(List<Map<String, dynamic>>.from(data['results']));
        _nextPageUrl = data['next'];
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

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
        _nextPageUrl = data['next'];
        _loading = false;
      });
      _showOverlay();
    } else {
      setState(() {
        _loading = false;
        _nextPageUrl = null;
        _results.clear();
      });
      _removeOverlay();
    }
  }

  /// Displays an overlay dropdown below the search bar, showing user search results.
  void _showOverlay() {
    _removeOverlay();
    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 32,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 56),
          child: Material(
            elevation: 4,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(16.0)),
              child: SizedBox(
                height: 200,
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount:
                            _results.length + (_nextPageUrl != null ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _results.length) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          final user = _results[index];
                          return ListTile(
                            title: Text(user['username']),
                            onTap: () {
                              _controller.text = user['username'];
                              widget.onUserSelected(user);
                              _removeOverlay();
                              FocusScope.of(context).unfocus();
                            },
                          );
                        },
                      ),
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: 'Search users',
          prefixIcon: const Icon(Icons.search),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
            borderSide: BorderSide(color: Colors.grey),
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _controller.clear();
              _nextPageUrl = null;
              _results.clear();
              _removeOverlay();
              FocusScope.of(context).unfocus();
            },
          ),
        ),
        onChanged: _onChanged,
      ),
    );
  }
}
