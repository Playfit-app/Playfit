///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsFr implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsFr({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.fr,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <fr>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key);

	late final TranslationsFr _root = this; // ignore: unused_field

	@override 
	TranslationsFr $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsFr(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsLoginFr login = _TranslationsLoginFr._(_root);
	@override late final _TranslationsRegisterFr register = _TranslationsRegisterFr._(_root);
}

// Path: login
class _TranslationsLoginFr implements TranslationsLoginEn {
	_TranslationsLoginFr._(this._root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Connexion';
	@override String get username => 'Nom d\'utilisateur';
	@override String get password => 'Mot de passe';
	@override String get login => 'Connexion';
	@override String get invalid_credentials => 'Nom d\'utilisateur ou mot de passe invalide.';
	@override String get empty_username => 'Veuillez entrer votre nom d\'utilisateur.';
	@override String get empty_password => 'Veuillez entrer votre mot de passe.';
	@override String get first_time_login => 'Première fois ? Créez un compte !';
}

// Path: register
class _TranslationsRegisterFr implements TranslationsRegisterEn {
	_TranslationsRegisterFr._(this._root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Créer un compte';
	@override String get previous => 'Précédent';
	@override String get next => 'Suivant';
	@override String get already_have_account => 'Déjà un compte ? Connectez-vous !';
	@override String get username => 'Nom d\'utilisateur';
	@override String get empty_username => 'Veuillez entrer un nom d\'utilisateur.';
	@override String get invalid_username => 'Le nom d\'utilisateur doit contenir au moins 4 caractères';
	@override String get email => 'Adresse e-mail';
	@override String get empty_email => 'Veuillez entrer une adresse e-mail.';
	@override String get invalid_email => 'Veuillez entrer une adresse e-mail valide.';
	@override String get password => 'Mot de passe';
	@override String get empty_password => 'Veuillez entrer un mot de passe.';
	@override String get invalid_password => 'Le mot de passe doit contenir au moins 8 caractères, une majuscule, une minuscule et un chiffre.';
	@override String get confirm_password => 'Confirmer le mot de passe';
	@override String get empty_confirm_password => 'Veuillez confirmer votre mot de passe.';
	@override String get passwords_do_not_match => 'Les mots de passe ne correspondent pas.';
	@override String get birthdate => 'Date de naissance';
	@override String get empty_birthdate => 'Veuillez entrer votre date de naissance.';
	@override String get invalid_birthdate => 'Vous devez avoir au moins 18 ans pour vous inscrire.';
	@override String get height => 'Taille (cm)';
	@override String get empty_height => 'Veuillez entrer votre taille.';
	@override String get invalid_height => 'Veuillez entrer une taille valide.';
	@override String get weight => 'Poids (kg)';
	@override String get empty_weight => 'Veuillez entrer votre poids.';
	@override String get invalid_weight => 'Veuillez entrer un poids valide.';
	@override String get gdpr_consent_title => 'Consentement RGPD';
	@override String get gdpr_consent => 'J\'accepte le formulaire de consentement RGPD et la Politique de Confidentialité (Obligatoire).';
	@override String get gdpr_consent_invalid => 'Vous devez accepter le formulaire de consentement RGPD et la Politique de Confidentialité.';
	@override String get marketing_consent => 'J\'accepte de recevoir des communications marketing (Facultatif).';
	@override String get avatar_choose => 'Choisir ton avatar';
	@override String get create_account => 'Créer un compte';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.
extension on TranslationsFr {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'login.title': return 'Connexion';
			case 'login.username': return 'Nom d\'utilisateur';
			case 'login.password': return 'Mot de passe';
			case 'login.login': return 'Connexion';
			case 'login.invalid_credentials': return 'Nom d\'utilisateur ou mot de passe invalide.';
			case 'login.empty_username': return 'Veuillez entrer votre nom d\'utilisateur.';
			case 'login.empty_password': return 'Veuillez entrer votre mot de passe.';
			case 'login.first_time_login': return 'Première fois ? Créez un compte !';
			case 'register.title': return 'Créer un compte';
			case 'register.previous': return 'Précédent';
			case 'register.next': return 'Suivant';
			case 'register.already_have_account': return 'Déjà un compte ? Connectez-vous !';
			case 'register.username': return 'Nom d\'utilisateur';
			case 'register.empty_username': return 'Veuillez entrer un nom d\'utilisateur.';
			case 'register.invalid_username': return 'Le nom d\'utilisateur doit contenir au moins 4 caractères';
			case 'register.email': return 'Adresse e-mail';
			case 'register.empty_email': return 'Veuillez entrer une adresse e-mail.';
			case 'register.invalid_email': return 'Veuillez entrer une adresse e-mail valide.';
			case 'register.password': return 'Mot de passe';
			case 'register.empty_password': return 'Veuillez entrer un mot de passe.';
			case 'register.invalid_password': return 'Le mot de passe doit contenir au moins 8 caractères, une majuscule, une minuscule et un chiffre.';
			case 'register.confirm_password': return 'Confirmer le mot de passe';
			case 'register.empty_confirm_password': return 'Veuillez confirmer votre mot de passe.';
			case 'register.passwords_do_not_match': return 'Les mots de passe ne correspondent pas.';
			case 'register.birthdate': return 'Date de naissance';
			case 'register.empty_birthdate': return 'Veuillez entrer votre date de naissance.';
			case 'register.invalid_birthdate': return 'Vous devez avoir au moins 18 ans pour vous inscrire.';
			case 'register.height': return 'Taille (cm)';
			case 'register.empty_height': return 'Veuillez entrer votre taille.';
			case 'register.invalid_height': return 'Veuillez entrer une taille valide.';
			case 'register.weight': return 'Poids (kg)';
			case 'register.empty_weight': return 'Veuillez entrer votre poids.';
			case 'register.invalid_weight': return 'Veuillez entrer un poids valide.';
			case 'register.gdpr_consent_title': return 'Consentement RGPD';
			case 'register.gdpr_consent': return 'J\'accepte le formulaire de consentement RGPD et la Politique de Confidentialité (Obligatoire).';
			case 'register.gdpr_consent_invalid': return 'Vous devez accepter le formulaire de consentement RGPD et la Politique de Confidentialité.';
			case 'register.marketing_consent': return 'J\'accepte de recevoir des communications marketing (Facultatif).';
			case 'register.avatar_choose': return 'Choisir ton avatar';
			case 'register.create_account': return 'Créer un compte';
			default: return null;
		}
	}
}

