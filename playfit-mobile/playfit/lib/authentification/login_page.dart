import 'dart:io';
import 'package:flutter/material.dart';
import 'package:playfit/i18n/strings.g.dart';
import 'package:playfit/services/auth_service.dart';
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
  bool _isKeyboardVisible = false;

  /// Initializes the state of the widget and sets up a post-frame callback to determine
  /// if the keyboard is visible by checking the bottom inset of the current MediaQuery.
  /// This is useful for adjusting the UI based on keyboard visibility.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    });
  }

  /// Hides the on-screen keyboard by removing focus from the current input field,
  /// and updates the state to indicate that the keyboard is no longer visible.
  void _hideKeyboard() {
    FocusScope.of(context).unfocus();

    setState(() {
      _isKeyboardVisible = false;
    });
  }

  /// Handles the login process for the user.
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
          MaterialPageRoute(builder: (context) => HomePage()),
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
        MaterialPageRoute(builder: (context) => HomePage()),
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

  /// Builds the login page UI with a mascot image, background, and an animated login form.
  ///
  /// The layout consists of:
  /// - A background image with a mascot aligned near the top.
  /// - An animated form container that shifts position based on keyboard visibility.
  /// - The form includes fields for username and password, with validation and clear buttons.
  /// - Displays error messages if login fails.
  /// - Provides a login button, a navigation button to the account creation page,
  ///   and a Google sign-in option (Android only).
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: screenWidth,
              height: 682,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/background_kickoff.png"),
                  fit: BoxFit.fill,
                ),
              ),
              child: Align(
                alignment: const Alignment(0, -0.7),
                child: Image.asset("assets/images/mascot.png"),
              ),
            ),
          ),
          AnimatedPositioned(
            top: _isKeyboardVisible ? screenHeight * 0.15 : screenHeight * 0.35,
            left: 0,
            bottom: 0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Container(
              width: screenWidth,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.03),
                    Text(
                      t.login.title,
                      style: GoogleFonts.amaranth(
                        fontSize: 36,
                        color: Colors.black,
                        letterSpacing: 0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
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
                    SizedBox(height: screenHeight * 0.01),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.2),
                            child: TextFormField(
                              onTap: () {
                                setState(() {
                                  _isKeyboardVisible = true;
                                });
                              },
                              onEditingComplete: _hideKeyboard,
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
                                labelText: t.login.username,
                              ),
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return t.login.empty_username;
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.025),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.2),
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              onTap: () {
                                setState(() {
                                  _isKeyboardVisible = true;
                                });
                              },
                              onEditingComplete: _hideKeyboard,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor:
                                    const Color.fromARGB(255, 255, 233, 202),
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: _passwordController.text.isNotEmpty
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
                                labelText: t.login.password,
                              ),
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return t.login.empty_password;
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.04),
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
                                  horizontal: screenWidth * 0.06, vertical: 10),
                            ),
                            child: Text(
                              t.login.login,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          TextButton(
                            onPressed: () => _navigateToCreateAccount(context),
                            child: Text(
                              t.login.first_time_login,
                              style: TextStyle(
                                color: Color.fromARGB(255, 30, 144, 255),
                                fontSize: 12,
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Divider(
                            indent: screenWidth * 0.15,
                            endIndent: screenWidth * 0.15,
                          ),
                          SizedBox(height: screenHeight * 0.02),
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
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
