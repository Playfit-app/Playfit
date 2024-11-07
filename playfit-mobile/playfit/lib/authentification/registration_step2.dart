import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class RegistrationStep2 extends StatefulWidget {
  final TextEditingController birthDateController;
  final TextEditingController heightController;
  final TextEditingController weightController;
  // final TextEditingController _objectiveController;

  const RegistrationStep2({
    super.key,
    required this.birthDateController,
    required this.heightController,
    required this.weightController,
    // required this._objectiveController,
  });

  @override
  State<RegistrationStep2> createState() => _RegistrationStep2State();
}

class _RegistrationStep2State extends State<RegistrationStep2> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        children: [
          TextFormField(
            controller: widget.birthDateController,
            readOnly: true,
            decoration: InputDecoration(
              hintText: 'Date de naissance',
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.calendar_today),
              suffixIcon: widget.birthDateController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => widget.birthDateController.clear(),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100.0),
                borderSide: BorderSide.none,
              ),
            ),
            onTap: () async {
              DateTime currentDate = DateTime.now();
              DateTime minDate = DateTime(currentDate.year - 100);

              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: currentDate,
                firstDate: minDate,
                lastDate: currentDate,
              );

              if (pickedDate != null) {
                String formattedDate =
                    DateFormat('yyyy-MM-dd').format(pickedDate);
                widget.birthDateController.text = formattedDate;
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre date de naissance';
              }

              final DateTime birthDate = DateFormat('yyyy-MM-dd').parse(value);
              int age = DateTime.now().year - birthDate.year;
              if (birthDate.isAfter(
                  DateTime.now().subtract(Duration(days: age * 365)))) {
                age--;
              }
              if (age < 14) {
                return 'Vous devez avoir au moins 14 ans';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: widget.heightController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Taille (cm)',
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.height),
              suffixIcon: widget.heightController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => widget.heightController.clear(),
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre taille';
              }
              if (int.parse(value) < 100 || int.parse(value) > 250) {
                return 'Veuillez entrer une taille valide';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: widget.weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: 'Poids (kg)',
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.monitor_weight),
              suffixIcon: widget.weightController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => widget.weightController.clear(),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100.0),
                borderSide: BorderSide.none,
              ),
            ),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre poids';
              }
              if (double.parse(value) < 30 || double.parse(value) > 250) {
                return 'Veuillez entrer un poids valide';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
