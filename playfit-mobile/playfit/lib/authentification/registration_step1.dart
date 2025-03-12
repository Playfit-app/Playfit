import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.2),
          child: TextFormField(
            controller: widget.usernameController,
            decoration: InputDecoration(
              labelText: 'Nom d\'utilisateur',
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer un nom d\'utilisateur';
              }
              if (value.length < 4) {
                return 'Le nom d\'utilisateur doit contenir au moins 4 caractères';
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
              labelText: 'Adresse e-mail',
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer une adresse e-mail';
              }
              if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                  .hasMatch(value)) {
                return 'Veuillez entrer une adresse e-mail valide';
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
              labelText: 'Mot de passe',
              filled: true,
              fillColor: const Color.fromARGB(255, 255, 233, 202),
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer un mot de passe';
              }
              if (value.length < 8) {
                return 'Le mot de passe doit contenir au moins 8 caractères';
              }
              if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]+$')
                  .hasMatch(value)) {
                return 'Le mot de passe doit contenir au moins une lettre et un chiffre';
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
              labelText: 'Confirmez le mot de passe',
              filled: true,
              fillColor: const Color.fromARGB(255, 255, 233, 202),
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez confirmer votre mot de passe';
              }
              if (value != widget.passwordController.text) {
                return 'Les mots de passe ne correspondent pas';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
