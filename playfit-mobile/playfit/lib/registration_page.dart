import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:playfit/auth_service.dart';
import 'package:playfit/home_page.dart';
import 'package:playfit/login_page.dart';
import 'package:playfit/styles/styles.dart';
import 'package:intl/intl.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  CreateAccountPageState createState() => CreateAccountPageState();
}

class CreateAccountPageState extends State<CreateAccountPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  // final TextEditingController _objectiveController = TextEditingController();
  final AuthService authService = AuthService();

  int _currentStep = 0;
  bool _isStep1Valid = false;
  bool _isStep2Valid = false;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_validateStep1);
    _passwordController.addListener(_validateStep1);
    _confirmPasswordController.addListener(_validateStep1);
    _emailController.addListener(_validateStep1);
    _birthDateController.addListener(_validateStep2);
    _heightController.addListener(_validateStep2);
    _weightController.addListener(_validateStep2);
    // _objectiveController.addListener(_validateStep2);
  }

  void _validateStep1() {
    setState(() {
      _isStep1Valid = _usernameController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty &&
          _emailController.text.isNotEmpty;
    });
  }

  void _validateStep2() {
    setState(() {
      _isStep2Valid = _birthDateController.text.isNotEmpty &&
          _heightController.text.isNotEmpty &&
          _weightController.text.isNotEmpty;
          // _objectiveController.text.isNotEmpty;
    });
  }

  void _createAccount() async {
    var result = await authService.register(
      context,
      _usernameController.text,
      _passwordController.text,
      _confirmPasswordController.text,
      _birthDateController.text,
      _heightController.text,
      _weightController.text,
      // _objectiveController.text,
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
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
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
              if (_currentStep == 0) _buildStep1(),
              if (_currentStep == 1) _buildStep2(),
              const SizedBox(height: 20),
              if (_currentStep < 1)
                ElevatedButton(
                  onPressed: _isStep1Valid ? _nextStep : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B0000),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
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
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
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
                      MaterialPageRoute(builder: (context) => const LoginPage()),
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
                    onTap: () {
                      // Handle Google registration logic here
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

  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        children: [
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              hintText: 'Nom d\'utilisateur',
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.person),
              suffixIcon: _usernameController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _usernameController.clear(),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100.0),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              hintText: 'Adresse e-mail',
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.email),
              suffixIcon: _emailController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _emailController.clear(),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100.0),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Mot de passe',
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: _passwordController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _passwordController.clear(),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100.0),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Confirmez le mot de passe',
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: _confirmPasswordController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _confirmPasswordController.clear(),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100.0),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        children: [
          TextField(
            controller: _birthDateController,
            readOnly: true,
            decoration: InputDecoration(
              hintText: 'Date de naissance',
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.calendar_today),
              suffixIcon: _birthDateController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _birthDateController.clear(),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100.0),
                borderSide: BorderSide.none,
              ),
            ),
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2101),
              );

              if (pickedDate != null) {
                String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                _birthDateController.text = formattedDate;
              }
            },
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _heightController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Taille (cm)',
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.height),
              suffixIcon: _heightController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _heightController.clear(),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100.0),
                borderSide: BorderSide.none,
              ),
            ),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: 'Poids (kg)',
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.monitor_weight),
              suffixIcon: _weightController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _weightController.clear(),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100.0),
                borderSide: BorderSide.none,
              ),
            ),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
            ],
          ),
          // const SizedBox(height: 10),
          // TextField(
          //   controller: _objectiveController,
          //   decoration: InputDecoration(
          //     hintText: 'Objectif',
          //     filled: true,
          //     fillColor: Colors.white,
          //     prefixIcon: const Icon(Icons.flag),
          //     suffixIcon: _objectiveController.text.isNotEmpty
          //         ? IconButton(
          //             icon: const Icon(Icons.close),
          //             onPressed: () => _objectiveController.clear(),
          //           )
          //         : null,
          //     border: OutlineInputBorder(
          //       borderRadius: BorderRadius.circular(100.0),
          //       borderSide: BorderSide.none,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
