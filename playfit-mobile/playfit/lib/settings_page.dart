import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:playfit/i18n/strings.g.dart';
import 'package:playfit/components/settings/dropdown_parameter.dart';
import 'package:playfit/providers/language_provider.dart';
import 'package:playfit/services/push_notification_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

enum UserBoxType { left, bottom }

extension UserBoxTypeExtension on UserBoxType {
  String get label {
    switch (this) {
      case UserBoxType.left:
        return t.settings.left;
      case UserBoxType.bottom:
        return t.settings.bottom;
    }
  }
}

class SettingsPage extends StatefulWidget {
  final Map<String, dynamic>? initialUserData;
  
  const SettingsPage({Key? key, this.initialUserData}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final Color orange = const Color(0xFFE07C27);
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final _notificationService = NotificationService();
  bool _notificationsEnabled = false;
  UserBoxType _selectedBoxType = UserBoxType.left;
  bool _showAccountOptions = false;
  bool _showPrivacyPolicy = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  Map<String, dynamic>? _userData;
  bool _userDataChanged = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    String? boxTypeStr = await storage.read(key: 'boxType');
    _selectedBoxType =
        boxTypeStr == 'bottom' ? UserBoxType.bottom : UserBoxType.left;
    _notificationsEnabled =
        await _notificationService.loadNotificationSettings();
    
    // Use passed user data if available and complete, otherwise load from API
    if (widget.initialUserData != null && 
        widget.initialUserData!.containsKey('username')) {
      _userData = widget.initialUserData;
      _usernameController.text = _userData?['username'] ?? '';
      await _loadEmailData();
    }
    setState(() {});
  }

  Future<void> _loadEmailData() async {
    try {
      final token = await storage.read(key: 'token');
      if (token == null) return;

      final response = await http.get(
        Uri.parse('${dotenv.env['SERVER_BASE_URL']}/api/auth/get_my_data/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _emailController.text = data['email'] ?? '';
        if (_userData != null) {
          _userData!['email'] = data['email'];
        }
      }
    } catch (e) {
      print('Error loading email data: $e');
    }
  }

  void _showConfirmationDialog(
    String title, String content, VoidCallback onConfirm) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: orange, width: 2),
        ),
        title: Row(
          children: [
            Container(width: 4, height: 24, color: orange),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Amaranth',
                ),
              ),
            ),
          ],
        ),
        content: Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'family',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
            ),
            child: Text(
              t.settings.cancel,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'family',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              t.settings.confirm,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'family',
              ),
            ),
          ),
        ],
      );
    },
  );
}

  
void _showDeleteConfirmationDialog() {
  _showConfirmationDialog(
    t.settings.delete_confirm_title,
    t.settings.delete_account_confirmation,
    () async {
      final token = await storage.read(key: 'token');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Token non trouvé")),
        );
        return;
      }

      try {
        final response = await http.delete(
          Uri.parse('${dotenv.env['SERVER_BASE_URL']}/api/auth/delete_my_data/'),
          headers: {
            'Authorization': 'Token $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({"confirm": true}),
        );

        if (response.statusCode == 200 || response.statusCode == 204) {
          await storage.delete(key: 'token');
          await storage.delete(key: 'userId');

          if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        } else {
          print("Error deleting account: ${response.body}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.settings.delete_account_fail)),
          );
        }
      } catch (e) {
        print("Error exception: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.settings.delete_account_error)),
        );
      }
    },
  );
}

  void _showLogoutConfirmationDialog() {
    _showConfirmationDialog(
      t.settings.logout,
      t.settings.logout_confirmation,
      () => logout(),
    );
  }

  void logout() async {
    final token = await storage.read(key: 'token');

    if (token != null) {
      await storage.delete(key: 'token');
      await storage.delete(key: 'userId');

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  void _showFieldSavedSnackBar(String field) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$field mis à jour'),
        backgroundColor: orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Validates email format for TextFormField
  String? _validateEmailField(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email cannot be empty';
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    
    return null; // Valid email
  }

  /// Validates username format for TextFormField
  String? _validateUsernameField(String? username) {
    if (username == null || username.isEmpty) {
      return 'Username cannot be empty';
    }
    
    if (username.length < 3) {
      return 'Username must be at least 3 characters long';
    }
    
    if (username.length > 30) {
      return 'Username must be less than 30 characters';
    }
    
    // Check for valid characters (letters, numbers, underscores, hyphens)
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_-]+$');
    if (!usernameRegex.hasMatch(username)) {
      return 'Username can only contain letters, numbers, underscores, and hyphens';
    }
    
    return null; // Valid username
  }

  /// Validates email format
  String? _validateEmail(String? email) {
    return _validateEmailField(email);
  }

  /// Validates username format
  String? _validateUsername(String? username) {
    return _validateUsernameField(username);
  }

  /// Generic method to update user field data
  Future<void> _updateUserField(String fieldName, String value, String displayName) async {
    try {
      final token = await storage.read(key: 'token');
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Token not found")),
        );
        return;
      }

      // Construire le body dynamiquement avec la clé variable
      final Map<String, dynamic> requestBody = {};
      requestBody[fieldName] = value;

      final response = await http.patch(
        Uri.parse('${dotenv.env['SERVER_BASE_URL']}/api/auth/update_my_data/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        _showFieldSavedSnackBar(displayName);
        _userDataChanged = true;
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error while updating $displayName")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _updateUsername() async {
    // Validate username before making API call
    final validationError = _validateUsername(_usernameController.text);
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    await _updateUserField('username', _usernameController.text, t.settings.username);
  }

  Future<void> _updateEmail() async {
    // Validate email before making API call
    final validationError = _validateEmail(_emailController.text);
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    await _updateUserField('email', _emailController.text, t.settings.email);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: IconButton(
                              icon: const Icon(Icons.close, size: 28),
                              onPressed: () => Navigator.pop(context, _userDataChanged),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildSectionTitle(t.settings.title),
                          const SizedBox(height: 20),
                          Divider(color: orange, thickness: 1),
                          DropdownParameter(
                            title: t.settings.language,
                            currentValue: languageProvider.currentLocale,
                            items: AppLocale.values,
                            onChanged: (value) async {
                              if (value != null) {
                                await languageProvider.changeLanguage(value);
                              }
                            },
                            itemLabelBuilder: languageProvider.getLanguageName,
                          ),
                          Divider(color: orange, thickness: 1),
                          SwitchListTile(
                            activeColor: orange,
                            title: _buildText(t.settings.notifications),
                            value: _notificationsEnabled,
                            onChanged: (value) async {
                              if (value) {
                                await _notificationService
                                    .handleNotificationPermissionFromSettings();
                              } else {
                                // User wants to disable notifications (manually)
                                // On Android: You can disable locally (but not system level)
                                // On iOS: You can't programmatically disable, just inform the user
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      context.t.settings
                                          .disable_notifications_info,
                                    ),
                                  ),
                                );
                              }
                              setState(() {
                                _notificationsEnabled = value;
                                _notificationService
                                    .saveNotificationSettings(value);
                              });
                            },
                          ),
                          Divider(color: orange, thickness: 1),
                          DropdownParameter(
                            title: t.settings.overlay_title,
                            currentValue: _selectedBoxType,
                            items: UserBoxType.values,
                            onChanged: (value) async {
                              if (value != null) {
                                setState(() {
                                  _selectedBoxType = value;
                                });
                                await storage.write(
                                    key: 'boxType',
                                    value: value == UserBoxType.left ? 'left' : 'bottom');
                              }
                            },
                            itemLabelBuilder: (type) => (type).label,
                          ),
                          Divider(color: orange, thickness: 1),
                          ListTile(
                            leading:
                                Icon(Icons.person, color: Colors.brown[200]),
                            title: _buildText(t.settings.account),
                            onTap: () => setState(() =>
                                _showAccountOptions = !_showAccountOptions),
                          ),
                          if (_showAccountOptions) ...[
                            const SizedBox(height: 8),
                            _buildEditableField(
                                t.settings.username, _usernameController, () {
                              _showConfirmationDialog(
                                t.settings.edit_username_title,
                                t.settings.edit_username_confirmation,
                                () => _updateUsername(),
                              );
                            }, validator: _validateUsernameField),
                            const SizedBox(height: 8),
                            _buildEditableField(
                                t.settings.email, _emailController, () {
                              _showConfirmationDialog(
                                t.settings.edit_email_title,
                                t.settings.edit_email_confirmation,
                                () => _updateEmail(),
                              );
                            }, validator: _validateEmailField),
                            const SizedBox(height: 8),
                            // _buildEditableField(
                            //     'Mot de passe', _passwordController, () {
                            //   _showConfirmationDialog(
                            //     'Modifier le mot de passe',
                            //     'Voulez-vous vraiment modifier votre mot de passe ?',
                            //     () => _showFieldSavedSnackBar('Mot de passe'),
                            //   );
                            // }, obscureText: true),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                              onPressed: _showDeleteConfirmationDialog,
                              child: Text(t.settings.delete_account,
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                          Divider(color: orange, thickness: 1),
                          const SizedBox(height: 24),
                          _buildSectionTitle(t.settings.others),
                          Divider(color: orange, thickness: 1),
                          ListTile(
                            leading: Icon(Icons.logout, color: orange),
                            title: _buildText(t.settings.logout),
                            onTap: _showLogoutConfirmationDialog,
                          ),
                          Divider(color: orange, thickness: 1),
                          ExpansionTile(
                            leading: Icon(Icons.privacy_tip, color: orange),
                            title: _buildText(t.settings.privacy_policy),
                            initiallyExpanded: _showPrivacyPolicy,
                            onExpansionChanged: (expanded) =>
                                setState(() => _showPrivacyPolicy = expanded),
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 10, left: 8, right: 8, bottom: 16),
                                child: _buildText(
                                  t.settings.privacy_policy_description,
                                  size: 14,
                                ),
                              ),
                            ],
                          ),
                          Divider(color: orange, thickness: 1),
                          const SizedBox(height: 12),
                          Center(
                            child: Text(
                              'Version 1.0.0',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(width: 5, height: 30, color: orange),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            fontFamily: 'Amaranth',
          ),
        ),
      ],
    );
  }

  Widget _buildText(String text, {double size = 16}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: size,
        fontFamily: 'family',
      ),
    );
  }

  Widget _buildEditableField(
      String label, TextEditingController controller, VoidCallback onSave,
      {bool obscureText = false, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(fontFamily: 'family'),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: orange),
              borderRadius: BorderRadius.circular(10),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            // Display an indicator if data is not yet loaded
            suffixIcon: _userData == null 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : null,
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: orange,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(t.settings.save, style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}