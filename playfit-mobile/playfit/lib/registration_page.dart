import 'package:flutter/material.dart';
import 'package:playfit/auth_service.dart';
import 'package:playfit/home_page.dart';
import 'package:playfit/login_page.dart';
import 'package:playfit/styles/styles.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  CreateAccountPageState createState() => CreateAccountPageState();
}

class CreateAccountPageState extends State<CreateAccountPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _objectiveController = TextEditingController();
  final AuthService authService = AuthService();

  int _currentStep = 0;

  void _createAccount() {
    authService.register(
      context,
      _usernameController.text,
      _passwordController.text,
      _confirmPasswordController.text,
      _firstNameController.text,
      _lastNameController.text,
      _birthDateController.text,
      _heightController.text,
      _weightController.text,
      // _objectiveController.text,
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  void _nextStep() {
    setState(() {
      if (_currentStep < 2) {
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

  void _navigateToLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor, // Use the background color from styles
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Progress Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: LinearProgressIndicator(
                  value: (_currentStep ) / 3, // Progress value between 0 and 1
                  backgroundColor: Colors.grey[300],
                  color: const Color(0xFF8B0000), // Dark red color
                ),
              ),
              // Mascot Image at the top
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
              // Dynamic content based on the current step
              if (_currentStep == 0) _buildStep1(),
              if (_currentStep == 1) _buildStep2(),
              if (_currentStep == 2) _buildStep3(),
              const SizedBox(height: 20),
              // Navigation Buttons
              if (_currentStep < 2)
                ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B0000), // Dark red color
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
                  onPressed: () => _createAccount(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B0000), // Dark red color
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
              // Back button if not on the first step
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

  // Step 1: Username, Password, and Confirm Password
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

  // Step 2: First Name, Last Name, and Birth Date
  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        children: [
          TextField(
            controller: _firstNameController,
            decoration: InputDecoration(
              hintText: 'Prénom',
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.person),
              suffixIcon: _firstNameController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _firstNameController.clear(),
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
            controller: _lastNameController,
            decoration: InputDecoration(
              hintText: 'Nom',
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.person_outline),
              suffixIcon: _lastNameController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _lastNameController.clear(),
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
            controller: _birthDateController,
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
          ),
        ],
      ),
    );
  }

  // Step 3: Height, Weight, and Objective
  Widget _buildStep3() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        children: [
          TextField(
            controller: _heightController,
            decoration: InputDecoration(
              hintText: 'Taille',
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
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _weightController,
            decoration: InputDecoration(
              hintText: 'Poids',
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
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _objectiveController,
            decoration: InputDecoration(
              hintText: 'Objectif',
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.flag),
              suffixIcon: _objectiveController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _objectiveController.clear(),
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
}
