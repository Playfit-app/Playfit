import 'package:flutter/material.dart';

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

class _GdprConsentFormState extends State<GdprConsentForm> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Formulaire de Consentement RGPD'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Conformément au Règlement Général sur la Protection des Données (RGPD), nous sommes tenus de vous informer sur la collecte, l’utilisation et le stockage de vos données personnelles.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              '1. Données Collectées\n'
              "Nous collectons les données suivantes lors de l'inscription :\n"
              " - Données essentielles : nom d'utilisateur, adresse e-mail, mot de passe, date de naissance pour accéder à l'application.\n"
              " - Données facultatives : taille, poids, objectifs, niveau de forme physique, particularités physiques pour personnaliser votre expérience utilisateur.\n",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              "2. Utilisation des Données\n"
              "Nous utilisons vos données pour les finalités suivantes :\n"
              " - Vous permettre d'accéder à l'application et de profiter de ses fonctionnalités.\n"
              " - Personnaliser votre expérience utilisateur en fonction de vos objectifs et de votre niveau de forme physique.\n"
              " - Pour respecter nos obligations légales et réglementaires.\n",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              "3. Stockage des Données\n"
              "Vos données sont stockées de manière sécurisée sur nos serveurs et ne sont pas partagées avec des tiers sans votre consentement.\n",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              "4. Utilisation Marketing\n"
              "Nous utilisons vos données pour vous envoyer des e-mails marketing concernant des promotions, événements ou rappels liés à l'application.\n",
              style: TextStyle(fontSize: 14),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Continuer'),
            ),
          ],
        ),
      ),
    );
  }
}
