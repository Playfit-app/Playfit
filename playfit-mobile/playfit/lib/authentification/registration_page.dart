import 'package:flutter/material.dart';
import 'package:playfit/auth_service.dart';
import 'package:playfit/authentification/registration_step1.dart';
import 'package:playfit/authentification/registration_step2.dart';
import 'package:playfit/home_page.dart';
import 'package:playfit/authentification/login_page.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  CreateAccountPageState createState() => CreateAccountPageState();
}

class CreateAccountPageState extends State<CreateAccountPage> {
  final GlobalKey<FormState> _step1FormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _step2FormKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  bool isConsentGiven = false;
  bool isMarketingConsentGiven = false;
  final AuthService authService = AuthService();
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

  void _nextStep() {
    setState(() {
      if (_currentStep < 1) {
        _currentStep++;
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Add this line
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
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(
                          'Créer un compte',
                          style: GoogleFonts.amaranth(
                            fontSize: 36,
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 20),
                        LinearProgressIndicator(
                          value: (_currentStep) / 2,
                          backgroundColor: Colors.grey[300],
                          color: const Color(0xFF8B0000),
                        ),
                        const SizedBox(height: 20),
                        if (_currentStep == 0)
                          Form(
                            key: _step1FormKey,
                            child: RegistrationStep1(
                              usernameController: _usernameController,
                              emailController: _emailController,
                              passwordController: _passwordController,
                              confirmPasswordController:
                                  _confirmPasswordController,
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
                            ),
                            onChanged: () => _validateStep(_step2FormKey),
                          ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _currentStep == 0
                              ? (_isStep1Valid ? _nextStep : null)
                              : (_isStep2Valid ? _createAccount : null),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 248, 135, 31),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                          ),
                          child: Text(
                            _currentStep == 0 ? 'Suivant' : 'Créer mon compte',
                            style: const TextStyle(
                                fontSize: 18, color: Colors.white),
                          ),
                        ),
                        if (_currentStep > 0)
                          TextButton(
                            onPressed: _previousStep,
                            child: const Text(
                              'Précédent',
                              style: TextStyle(color: Colors.blueAccent),
                            ),
                          ),
                        TextButton(
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                          ),
                          child: const Text(
                            'Déjà un compte ? Connectez-vous !',
                            style: TextStyle(color: Colors.blueAccent),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
