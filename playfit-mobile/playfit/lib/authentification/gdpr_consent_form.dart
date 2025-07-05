import 'package:flutter/material.dart';
import 'package:playfit/i18n/strings.g.dart';

class GdprConsentForm extends StatefulWidget {
  final bool isConsentGiven;
  final bool isMarketingConsentGiven;

  const GdprConsentForm({
    super.key,
    required this.isConsentGiven,
    required this.isMarketingConsentGiven,
  });

  @override
  _GdprConsentFormState createState() => _GdprConsentFormState();
}

/// State class for the GDPR Consent Form dialog.
///
/// This widget displays an [AlertDialog] containing detailed information about GDPR consent,
/// including sections on data collection, data usage, data storage, and marketing usage.
class _GdprConsentFormState extends State<GdprConsentForm> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(t.gdpr_consent_form.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.gdpr_consent_form.description,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              "${t.gdpr_consent_form.data_collection.title}"
              "${t.gdpr_consent_form.data_collection.description}"
              "${t.gdpr_consent_form.data_collection.essential_data}"
              "${t.gdpr_consent_form.data_collection.optional_data}",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              "${t.gdpr_consent_form.data_usage.title}"
              "${t.gdpr_consent_form.data_usage.description}"
              "${t.gdpr_consent_form.data_usage.purposes_1}"
              "${t.gdpr_consent_form.data_usage.purposes_2}"
              "${t.gdpr_consent_form.data_usage.purposes_3}",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              "${t.gdpr_consent_form.data_storage.title}"
              "${t.gdpr_consent_form.data_storage.description}",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              "${t.gdpr_consent_form.marketing_usage.title}"
              "${t.gdpr_consent_form.marketing_usage.description}",
              style: TextStyle(fontSize: 14),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(t.gdpr_consent_form.accept_button),
            ),
          ],
        ),
      ),
    );
  }
}
