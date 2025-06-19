import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:playfit/i18n/strings.g.dart';
import 'package:playfit/components/form/checkbox.dart';
import 'package:playfit/authentification/gdpr_consent_form.dart';

class RegistrationStep2 extends StatefulWidget {
  final TextEditingController birthDateController;
  final TextEditingController heightController;
  final TextEditingController weightController;
  final bool isConsentGiven;
  final bool isMarketingConsentGiven;
  final Function(bool?) onConsentChanged;
  final Function(bool?) onMarketingConsentChanged;
  // final TextEditingController _objectiveController;

  const RegistrationStep2({
    super.key,
    required this.birthDateController,
    required this.heightController,
    required this.weightController,
    required this.isConsentGiven,
    required this.isMarketingConsentGiven,
    required this.onConsentChanged,
    required this.onMarketingConsentChanged,
    // required this._objectiveController,
  });

  @override
  State<RegistrationStep2> createState() => _RegistrationStep2State();
}

class _RegistrationStep2State extends State<RegistrationStep2> {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.2),
          /// A [TextFormField] widget for selecting and displaying the user's birthdate.
          child: TextFormField(
            controller: widget.birthDateController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: t.register.birthdate,
              filled: true,
              fillColor: const Color.fromARGB(255, 255, 233, 202),
              prefixIcon: const Icon(Icons.calendar_today),
              suffixIcon: widget.birthDateController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => widget.birthDateController.clear(),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
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
                return t.register.empty_birthdate;
              }

              final DateTime birthDate = DateFormat('yyyy-MM-dd').parse(value);
              int age = DateTime.now().year - birthDate.year;
              if (birthDate.isAfter(
                  DateTime.now().subtract(Duration(days: age * 365)))) {
                age--;
              }
              if (age < 18) {
                return t.register.invalid_birthdate;
              }
              return null;
            },
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.2),
          /// A [TextFormField] widget for user height input in centimeters.
          child: TextFormField(
            controller: widget.heightController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: t.register.height,
              filled: true,
              fillColor: const Color.fromARGB(255, 255, 233, 202),
              prefixIcon: const Icon(Icons.height),
              suffixIcon: widget.heightController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => widget.heightController.clear(),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none,
              ),
            ),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return t.register.empty_height;
              }
              if (int.parse(value) < 100 || int.parse(value) > 250) {
                return t.register.invalid_height;
              }
              return null;
            },
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.2),
          /// A [TextFormField] widget for entering the user's weight during registration.
          child: TextFormField(
            controller: widget.weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: t.register.weight,
              filled: true,
              fillColor: const Color.fromARGB(255, 255, 233, 202),
              prefixIcon: const Icon(Icons.monitor_weight),
              suffixIcon: widget.weightController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => widget.weightController.clear(),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none,
              ),
            ),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return t.register.empty_weight;
              }
              if (double.parse(value) < 30 || double.parse(value) > 250) {
                return t.register.invalid_weight;
              }
              return null;
            },
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        // Consent form as dialog
        ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return GdprConsentForm(
                  isConsentGiven: widget.isConsentGiven,
                  isMarketingConsentGiven: widget.isMarketingConsentGiven,
                );
              },
            );
          },
          child: Text(t.register.gdpr_consent_title),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
          child: CheckboxFormField(
            title: Text(
              t.register.gdpr_consent,
              style: TextStyle(fontSize: 8),
            ),
            onChanged: widget.onConsentChanged,
            initialValue: widget.isConsentGiven,
            validator: (value) {
              if (value == false) {
                return t.register.gdpr_consent_invalid;
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
          child: CheckboxFormField(
            title: Text(
              t.register.marketing_consent,
              style: TextStyle(fontSize: 8),
            ),
            onChanged: widget.onMarketingConsentChanged,
            initialValue: widget.isMarketingConsentGiven,
          ),
        )
      ],
    );
  }
}
