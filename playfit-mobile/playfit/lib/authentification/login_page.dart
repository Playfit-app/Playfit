import 'dart:io';
import 'package:flutter/material.dart';
import 'package:playfit/auth_service.dart';
import 'package:playfit/home_page.dart';
import 'package:playfit/authentification/registration_page.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService authService = AuthService();
  String _errorMessage = '';
  bool _isGoogleSignInLoading = false;

  void _login() async {
    setState(() {
      _isGoogleSignInLoading = true;
    });
    try {
      var result = await authService.login(
        context,
        _loginController.text,
        _passwordController.text,
      );
      if (!mounted) return;
      if (result["status"] == 'success') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result["message"]!),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isGoogleSignInLoading = false;
      });
    }
  }

  Future<void> _handleGoogleSignIn() async {
    var result = await authService.loginWithGoogle(context);
    if (!mounted) return;
    if (result["status"] == 'success') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      setState(() {
        _errorMessage = result["message"]!;
      });
    }
  }

  void _navigateToCreateAccount(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const CreateAccountPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Image.asset(
              "assets/images/background_kickoff.png",
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
            Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                Image.asset(
                  "assets/images/mascot.png",
                  height: 200,
                ),
                Container(
                  // White background
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03),
                      Text(
                        'Connexion',
                        style: GoogleFonts.amaranth(
                          fontSize: 36,
                          color: Colors.black,
                          letterSpacing: 0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02),
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40.0, vertical: 10),
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.2),
                              child: TextFormField(
                                controller: _loginController,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor:
                                      const Color.fromARGB(255, 255, 233, 202),
                                  prefixIcon: const Icon(Icons.person),
                                  suffixIcon: _loginController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.close),
                                          onPressed: () =>
                                              _loginController.clear(),
                                        )
                                      : null,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide.none,
                                  ),
                                  labelText: "Nom d'utilisateur",
                                ),
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez entrer votre nom d\'utilisateur';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.025),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.2),
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor:
                                      const Color.fromARGB(255, 255, 233, 202),
                                  prefixIcon: const Icon(Icons.lock),
                                  suffixIcon:
                                      _passwordController.text.isNotEmpty
                                          ? IconButton(
                                              icon: const Icon(Icons.close),
                                              onPressed: () =>
                                                  _passwordController.clear(),
                                            )
                                          : null,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide.none,
                                  ),
                                  labelText: "Mot de passe",
                                ),
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez entrer votre mot de passe';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.04),
                            ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _login();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 248, 135, 31),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100.0),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.06,
                                    vertical: 10),
                              ),
                              child: const Text(
                                'Connexion',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.03),
                            TextButton(
                              onPressed: () =>
                                  _navigateToCreateAccount(context),
                              child: const Text(
                                'Première fois ? Créez un compte !',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 30, 144, 255),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.02),
                            Divider(
                              indent: MediaQuery.of(context).size.width * 0.15,
                              endIndent:
                                  MediaQuery.of(context).size.width * 0.15,
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.02),
                            Platform.isAndroid
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0),
                                    child: GestureDetector(
                                      onTap: _isGoogleSignInLoading
                                          ? null
                                          : () async {
                                              await _handleGoogleSignIn();
                                            },
                                      child: _isGoogleSignInLoading
                                          ? const CircularProgressIndicator()
                                          : Image.asset(
                                              'assets/images/google.png',
                                              height: 50,
                                            ),
                                    ),
                                  )
                                : Container(),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.06),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
