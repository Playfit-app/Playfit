import 'package:flutter/material.dart';
import 'package:playfit/i18n/strings.g.dart';

class RegistrationStep1 extends StatefulWidget {
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  const RegistrationStep1({
    super.key,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
  });

  @override
  State<RegistrationStep1> createState() => _RegistrationStep1State();
}

class _RegistrationStep1State extends State<RegistrationStep1> {
  late final List<TextEditingController> _watchedControllers;

  @override
  void initState() {
    super.initState();
    _watchedControllers = [
      widget.usernameController,
      widget.emailController,
      widget.passwordController,
      widget.confirmPasswordController,
    ];

    for (final controller in _watchedControllers) {
      controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    for (final controller in _watchedControllers) {
      controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  /// Builds the registration step 1 form UI, which includes input fields for username,
  /// email, password, and password confirmation. Each field uses a [TextFormField]
  /// with custom styling, validation logic, and clear buttons for user convenience.
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset > 0 ? bottomInset * 0.4 : 0),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.2),
            child: TextFormField(
              controller: widget.usernameController,
              decoration: InputDecoration(
                labelText: t.register.username,
                filled: true,
                fillColor: const Color.fromARGB(255, 255, 233, 202),
                prefixIcon: const Icon(Icons.person),
                suffixIcon: widget.usernameController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => widget.usernameController.clear(),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
              ),
              scrollPadding: EdgeInsets.only(bottom: bottomInset + 80),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return t.register.empty_username;
                }
                if (value.length < 4) {
                  return t.register.invalid_username;
                }
                return null;
              },
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.2),
            child: TextFormField(
              controller: widget.emailController,
              decoration: InputDecoration(
                labelText: t.register.email,
                filled: true,
                fillColor: const Color.fromARGB(255, 255, 233, 202),
                prefixIcon: const Icon(Icons.email),
                suffixIcon: widget.emailController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => widget.emailController.clear(),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              scrollPadding: EdgeInsets.only(bottom: bottomInset + 80),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return t.register.empty_email;
                }
                if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                    .hasMatch(value)) {
                  return t.register.invalid_email;
                }
                return null;
              },
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.2),
            child: TextFormField(
              controller: widget.passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: t.register.password,
                filled: true,
                fillColor: const Color.fromARGB(255, 255, 233, 202),
                // Allow the validation error text to wrap to multiple lines so it's fully visible
                errorMaxLines: 3,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: widget.passwordController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => widget.passwordController.clear(),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
              ),
              scrollPadding: EdgeInsets.only(bottom: bottomInset + 80),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return t.register.empty_password;
                }
                if (value.length < 8) {
                  return t.register.invalid_password;
                }
                // Password requirements:
                // - At least 8 characters
                // - At least one lowercase letter
                // - At least one uppercase letter
                // - At least one digit
                // - At least one special character from [@$!%*?&]
                if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$')
                    .hasMatch(value)) {
                  return t.register.invalid_password;
                }
                return null;
              },
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.2),
            child: TextFormField(
              controller: widget.confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: t.register.confirm_password,
                filled: true,
                fillColor: const Color.fromARGB(255, 255, 233, 202),
                // Allow the validation error text to wrap to multiple lines so it's fully visible
                errorMaxLines: 3,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: widget.confirmPasswordController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => widget.confirmPasswordController.clear(),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
              ),
              scrollPadding: EdgeInsets.only(bottom: bottomInset + 80),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return t.register.empty_confirm_password;
                }
                if (value != widget.passwordController.text) {
                  return t.register.passwords_do_not_match;
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}
