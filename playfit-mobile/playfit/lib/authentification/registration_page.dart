import 'package:flutter/material.dart';
import 'package:playfit/services/auth_service.dart';
import 'package:playfit/authentification/registration_step1.dart';
import 'package:playfit/authentification/registration_step2.dart';
import 'package:playfit/home_page.dart';
import 'package:playfit/authentification/login_page.dart';
import 'package:playfit/styles/styles.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  CreateAccountPageState createState() => CreateAccountPageState();
}

class CreateAccountPageState extends State<CreateAccountPage> {
  final GlobalKey<FormState> _step1FormKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _step2FormKey = GlobalKey<FormState>();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  bool isConsentGiven = false;
  bool isMarketingConsentGiven = false;
  // final TextEditingController _objectiveController = TextEditingController();
  final AuthService authService = AuthService();
  bool _isGoogleSignInLoading = false;

  int _currentStep = 0;
  bool _isStep1Valid = false;
  bool _isStep2Valid = false;

  void _validateStep(GlobalKey<FormState> formKey) {
    setState(() {
      if (formKey == _step1FormKey) {
        _isStep1Valid = _step1FormKey.currentState!.validate();
      } else {
        _isStep2Valid = _step2FormKey.currentState!.validate();
      }
    });
  }

  void _createAccount() async {
    var result = await authService.register(
      context,
      _emailController.text,
      _usernameController.text,
      _passwordController.text,
      _birthDateController.text,
      double.parse(_heightController.text),
      double.parse(_weightController.text),
      isConsentGiven,
      isMarketingConsentGiven,
      // _objectiveController.text,
    );
    if (!mounted) return;
    if (result["status"] == 'success') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const HomePage(firstLogin: true)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result["message"]!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _nextStep() {
    setState(() {
      if (_currentStep < 1) {
        _currentStep++;
      } else {
        // Handle registration completion here
      }
    });
  }

  void _previousStep() {
    setState(() {
      if (_currentStep > 0) {
        _currentStep--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                child: LinearProgressIndicator(
                  value: (_currentStep) / 2,
                  backgroundColor: Colors.grey[300],
                  color: const Color(0xFF8B0000),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Image.asset(
                  'assets/images/mascot.png',
                  height: 150,
                ),
              ),
              const Text(
                'Créer un compte',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              if (_currentStep == 0)
                Form(
                  key: _step1FormKey,
                  child: RegistrationStep1(
                    usernameController: _usernameController,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    confirmPasswordController: _confirmPasswordController,
                  ),
                  onChanged: () => _validateStep(_step1FormKey),
                ),
              if (_currentStep == 1)
                Form(
                  key: _step2FormKey,
                  child: RegistrationStep2(
                    birthDateController: _birthDateController,
                    heightController: _heightController,
                    weightController: _weightController,
                    isConsentGiven: isConsentGiven,
                    isMarketingConsentGiven: isMarketingConsentGiven,
                    onConsentChanged: (value) {
                      setState(() {
                        isConsentGiven = value!;
                      });
                    },
                    onMarketingConsentChanged: (value) {
                      setState(() {
                        isMarketingConsentGiven = value!;
                      });
                    },
                    // _objectiveController: _objectiveController,
                  ),
                  onChanged: () => _validateStep(_step2FormKey),
                ),
              const SizedBox(height: 20),
              if (_currentStep < 1)
                ElevatedButton(
                  onPressed: _isStep1Valid ? _nextStep : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B0000),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                  ),
                  child: const Text(
                    'Suivant',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                )
              else
                ElevatedButton(
                  onPressed: _isStep2Valid ? _createAccount : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B0000),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                  ),
                  child: const Text(
                    'Créer mon compte',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              const SizedBox(height: 15),
              if (_currentStep > 0)
                TextButton(
                  onPressed: _previousStep,
                  child: const Text(
                    'Précédent',
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              if (_currentStep == 0)
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                    );
                  },
                  child: const Text(
                    'Déjà un compte ? Connectez-vous !',
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              if (_currentStep == 0) const Divider(),
              if (_currentStep == 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: GestureDetector(
                    onTap: _isGoogleSignInLoading
                        ? null
                        : () async {
                            setState(() {
                              _isGoogleSignInLoading = true;
                            });
                            var result =
                                await authService.loginWithGoogle(context);
                            if (!mounted) return;
                            if (result["status"] == 'success') {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const HomePage()),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result["message"]!),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                    child: Image.asset(
                      'assets/images/google.png',
                      height: 50,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
