import 'package:flutter/material.dart';
import 'package:playfit/services/auth_service.dart';
import 'package:playfit/authentification/registration_step1.dart';
import 'package:playfit/authentification/registration_step2.dart';
import 'package:playfit/authentification/registration_step3.dart';
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
  final GlobalKey<FormState> _step3FormKey = GlobalKey<FormState>();
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
  bool _isStep3Valid = false;
  bool _isKeyboardVisible = false;

  void _validateStep(GlobalKey<FormState> formKey) {
    setState(() {
      if (formKey == _step1FormKey) {
        _isStep1Valid = _step1FormKey.currentState!.validate();
      } else if (formKey == _step2FormKey) {
        _isStep2Valid = _step2FormKey.currentState!.validate();
      } else {
        _isStep3Valid = _step3FormKey.currentState!.validate();
      }
    });
  }

  void _nextStep() {
    setState(() {
      if (_currentStep < 2) {
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    });
  }

  void _hideKeyboard() {
    FocusScope.of(context).unfocus();

    setState(() {
      _isKeyboardVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // resizeToAvoidBottomInset: true, // Add this line
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
                padding: const EdgeInsets.only(top: 15),
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
                    SizedBox(height: screenHeight * 0.02),
                    LinearProgressIndicator(
                      value: (_currentStep) / 3,
                      backgroundColor: Colors.grey[300],
                      color: const Color(0xFF8B0000),
                    ),
                    SizedBox(height: screenHeight * 0.02),
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
                        ),
                        onChanged: () => _validateStep(_step2FormKey),
                      ),
                    if (_currentStep == 2)
                      Form(
                        key: _step3FormKey,
                        child: const RegistrationStep3(),
                        onChanged: () => _validateStep(_step3FormKey),
                      ),
                    SizedBox(height: screenHeight * 0.02),
                    ElevatedButton(
                      onPressed: () {
                        if (_currentStep == 0 && _isStep1Valid) {
                          _nextStep();
                        } else if (_currentStep == 1 && _isStep2Valid) {
                          _nextStep(); // Move to Step 3 instead of creating an account
                        } else if (_currentStep == 2) {
                          _createAccount(); // Create account on Step 3 submission
                        }
                      },
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
                        _currentStep < 2 ? 'Suivant' : 'Créer mon compte',
                        style:
                            const TextStyle(fontSize: 14, color: Colors.white),
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
          ),
        ],
      ),
    );
  }
}
