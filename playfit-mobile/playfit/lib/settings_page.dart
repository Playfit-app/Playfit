import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final Color orange = const Color(0xFFE07C27);
  String _selectedLanguage = 'Français';
  bool _notificationsEnabled = true;
  String _overlayPosition = 'Droite';
  bool _showAccountOptions = false;
  bool _showPrivacyPolicy = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _showConfirmationDialog(String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog() {
    _showConfirmationDialog(
      'Confirmer la suppression',
      'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.',
      () {
        // Logique de suppression ici
      },
    );
  }

  void _showLogoutConfirmationDialog() {
    _showConfirmationDialog(
      'Se déconnecter',
      'Êtes-vous sûr de vouloir vous déconnecter ?',
      () {
        // Logique de déconnexion ici
      },
    );
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
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
                      _buildSectionTitle('Paramètres'),
                      const SizedBox(height: 20),
                      Divider(color: orange, thickness: 1),
                      _buildDropdownTile('Langue', _selectedLanguage, ['Français', 'Anglais'], (value) {
                        setState(() {
                          _selectedLanguage = value!;
                        });
                      }),
                      Divider(color: orange, thickness: 1),
                      SwitchListTile(
                        activeColor: orange,
                        title: _buildText('Notifications'),
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                        },
                      ),
                      Divider(color: orange, thickness: 1),
                      _buildDropdownTile('Overlay', _overlayPosition, ['Droite', 'Gauche', 'Bas'], (value) {
                        setState(() {
                          _overlayPosition = value!;
                        });
                      }),
                      Divider(color: orange, thickness: 1),
                      ListTile(
                        leading: Icon(Icons.person, color: Colors.brown[200]),
                        title: _buildText('Compte'),
                        onTap: () => setState(() => _showAccountOptions = !_showAccountOptions),
                      ),
                      if (_showAccountOptions) ...[
                        const SizedBox(height: 8),
                        _buildEditableField('Pseudo', _usernameController, () {
                          _showConfirmationDialog(
                            'Modifier le pseudo',
                            'Voulez-vous vraiment modifier votre pseudo ?',
                            () => _showFieldSavedSnackBar('Pseudo'),
                          );
                        }),
                        const SizedBox(height: 8),
                        _buildEditableField('Email', _emailController, () {
                          _showConfirmationDialog(
                            'Modifier l\'email',
                            'Voulez-vous vraiment modifier votre email ?',
                            () => _showFieldSavedSnackBar('Email'),
                          );
                        }),
                        const SizedBox(height: 8),
                        _buildEditableField('Mot de passe', _passwordController, () {
                          _showConfirmationDialog(
                            'Modifier le mot de passe',
                            'Voulez-vous vraiment modifier votre mot de passe ?',
                            () => _showFieldSavedSnackBar('Mot de passe'),
                          );
                        }, obscureText: true),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: _showDeleteConfirmationDialog,
                          child: const Text('Supprimer le compte', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                      Divider(color: orange, thickness: 1),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Autres'),
                      Divider(color: orange, thickness: 1),
                      ListTile(
                        leading: Icon(Icons.logout, color: orange),
                        title: _buildText('Se déconnecter'),
                        onTap: _showLogoutConfirmationDialog,
                      ),
                      Divider(color: orange, thickness: 1),
                      ExpansionTile(
                        leading: Icon(Icons.privacy_tip, color: orange),
                        title: _buildText('Avis sur la confidentialité'),
                        initiallyExpanded: _showPrivacyPolicy,
                        onExpansionChanged: (expanded) => setState(() => _showPrivacyPolicy = expanded),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 10, left: 8, right: 8, bottom: 16),
                            child: _buildText(
                              'Nous nous engageons à protéger votre vie privée. Toutes vos données sont confidentielles et ne seront jamais partagées sans votre consentement.',
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
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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

  Widget _buildDropdownTile(String title, String currentValue, List<String> options, ValueChanged<String?> onChanged) {
    return ListTile(
      leading: Icon(Icons.circle, size: 10, color: orange),
      title: _buildText(title),
      trailing: DropdownButton<String>(
        value: currentValue,
        underline: Container(),
        items: options.map((lang) => DropdownMenuItem(value: lang, child: Text(lang))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, VoidCallback onSave, {bool obscureText = false}) {
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
            child: const Text('Sauvegarder', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
