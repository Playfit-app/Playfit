import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:playfit/i18n/strings.g.dart';
import 'package:playfit/components/settings/dropdown_parameter.dart';
import 'package:playfit/services/language_service.dart';
import 'package:playfit/services/push_notification_service.dart';

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

class _Settings {
  final AppLocale locale;
  final bool notificationsEnabled;
  // final String overlayPosition;

  _Settings({
    required this.locale,
    required this.notificationsEnabled,
    // required this.overlayPosition,
  });
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final Color orange = const Color(0xFFE07C27);
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final _notificationService = NotificationService();
  late AppLocale _selectedLanguage;
  late bool _notificationsEnabled;
  late UserBoxType _selectedBoxType;
  bool _showAccountOptions = false;
  bool _showPrivacyPolicy = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<_Settings> _loadSettings() async {
    String? boxTypeStr = await storage.read(key: 'boxType');
    _selectedBoxType =
        boxTypeStr == 'bottom' ? UserBoxType.bottom : UserBoxType.left;
    return _Settings(
      locale:
          await LanguageService.loadLocale() ?? LocaleSettings.currentLocale,
      notificationsEnabled:
          await _notificationService.loadNotificationSettings(),
    );
  }

  void _showConfirmationDialog(
      String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(t.settings.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: Text(t.settings.confirm),
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
      () {
        // Logique de suppression ici
      },
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

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return FutureBuilder<_Settings>(
      future: _loadSettings(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final settings = snapshot.data!;
        _selectedLanguage = settings.locale;
        _notificationsEnabled = settings.notificationsEnabled;

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
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildSectionTitle(t.settings.title),
                          const SizedBox(height: 20),
                          Divider(color: orange, thickness: 1),
                          DropdownParameter(
                            title: t.settings.language,
                            currentValue: _selectedLanguage,
                            items: AppLocale.values,
                            onChanged: (value) {
                              setState(() async {
                                if (value != null) {
                                  _selectedLanguage = value;
                                  await LanguageService.saveLocale(value);
                                  await LocaleSettings.setLocale(value);
                                }
                              });
                            },
                            itemLabelBuilder: LanguageService.getLocaleName,
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
                                () => _showFieldSavedSnackBar(
                                    t.settings.username),
                              );
                            }),
                            const SizedBox(height: 8),
                            _buildEditableField(
                                t.settings.email, _emailController, () {
                              _showConfirmationDialog(
                                t.settings.edit_email_title,
                                t.settings.edit_email_confirmation,
                                () => _showFieldSavedSnackBar(t.settings.email),
                              );
                            }),
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
                            onTap: logout,
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

  Widget _buildDropdownTile(String title, String currentValue,
      List<String> options, ValueChanged<String?> onChanged) {
    return ListTile(
      leading: Icon(Icons.circle, size: 10, color: orange),
      title: _buildText(title),
      trailing: DropdownButton<String>(
        value: currentValue,
        underline: Container(),
        items: options
            .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildEditableField(
      String label, TextEditingController controller, VoidCallback onSave,
      {bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(fontFamily: 'family'),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: orange),
              borderRadius: BorderRadius.circular(10),
            ),
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
