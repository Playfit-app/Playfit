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
class TranslationsFr extends Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsFr({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.fr,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <fr>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsFr _root = this; // ignore: unused_field

	@override 
	TranslationsFr $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsFr(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsLoginFr login = _TranslationsLoginFr._(_root);
	@override late final _TranslationsRegisterFr register = _TranslationsRegisterFr._(_root);
	@override late final _TranslationsHomeFr home = _TranslationsHomeFr._(_root);
	@override late final _TranslationsCameraFr camera = _TranslationsCameraFr._(_root);
	@override late final _TranslationsNotificationsFr notifications = _TranslationsNotificationsFr._(_root);
	@override late final _TranslationsProfileFr profile = _TranslationsProfileFr._(_root);
	@override late final _TranslationsSocialFr social = _TranslationsSocialFr._(_root);
	@override late final _TranslationsGdprConsentFormFr gdpr_consent_form = _TranslationsGdprConsentFormFr._(_root);
	@override late final _TranslationsWorkoutSessionDialogFr workout_session_dialog = _TranslationsWorkoutSessionDialogFr._(_root);
	@override late final _TranslationsSettingsFr settings = _TranslationsSettingsFr._(_root);
	@override late final _TranslationsCustomizationFr customization = _TranslationsCustomizationFr._(_root);
	@override late final _TranslationsIntroductionFr introduction = _TranslationsIntroductionFr._(_root);
}

// Path: login
class _TranslationsLoginFr extends TranslationsLoginEn {
	_TranslationsLoginFr._(TranslationsFr root) : this._root = root, super.internal(root);

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
class _TranslationsRegisterFr extends TranslationsRegisterEn {
	_TranslationsRegisterFr._(TranslationsFr root) : this._root = root, super.internal(root);

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

// Path: home
class _TranslationsHomeFr extends TranslationsHomeEn {
	_TranslationsHomeFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get error_loading => 'Erreur lors du chargement des données.';
}

// Path: camera
class _TranslationsCameraFr extends TranslationsCameraEn {
	_TranslationsCameraFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String next_step_countdown({required Object seconds}) => 'Prochaine étape dans ${seconds} secondes...';
	@override String get start_workout => 'Démarrer';
}

// Path: notifications
class _TranslationsNotificationsFr extends TranslationsNotificationsEn {
	_TranslationsNotificationsFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Notifications';
	@override String get read_all => 'Tout lire';
	@override String get empty => 'Aucune notification pour le moment.';
	@override String get no_title => 'Aucun titre';
	@override String get no_body => 'Aucun contenu';
}

// Path: profile
class _TranslationsProfileFr extends TranslationsProfileEn {
	_TranslationsProfileFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get follow => 'Suivre';
	@override String get unfollow => 'Ne plus suivre';
	@override String member_since({required Object date}) => 'Membre depuis ${date}';
	@override String get followers => 'abonnés';
	@override String get following => 'abonnements';
	@override String get cities_finished => 'Villes finies';
	@override String get nb_exercises_done_title => 'Nombre d\'exercices faits';
	@override String get bpm_title => 'BPM (Battements par minute)';
	@override String get achievements => 'Succès';
}

// Path: social
class _TranslationsSocialFr extends TranslationsSocialEn {
	_TranslationsSocialFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Social';
}

// Path: gdpr_consent_form
class _TranslationsGdprConsentFormFr extends TranslationsGdprConsentFormEn {
	_TranslationsGdprConsentFormFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Consentement RGPD';
	@override String get description => 'Conformément au Règlement Général sur la Protection des Données (RGPD), nous sommes tenus de vous informer sur la collecte, l\'utilisation et le stockage de vos données personnelles.';
	@override late final _TranslationsGdprConsentFormDataCollectionFr data_collection = _TranslationsGdprConsentFormDataCollectionFr._(_root);
	@override late final _TranslationsGdprConsentFormDataUsageFr data_usage = _TranslationsGdprConsentFormDataUsageFr._(_root);
	@override late final _TranslationsGdprConsentFormDataStorageFr data_storage = _TranslationsGdprConsentFormDataStorageFr._(_root);
	@override late final _TranslationsGdprConsentFormMarketingUsageFr marketing_usage = _TranslationsGdprConsentFormMarketingUsageFr._(_root);
	@override String get accept_button => 'Continuer';
}

// Path: workout_session_dialog
class _TranslationsWorkoutSessionDialogFr extends TranslationsWorkoutSessionDialogEn {
	_TranslationsWorkoutSessionDialogFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String session_title({required Object session_number}) => 'Session n°${session_number}';
	@override String get start_button => 'Démarrer';
}

// Path: settings
class _TranslationsSettingsFr extends TranslationsSettingsEn {
	_TranslationsSettingsFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Paramètres';
	@override String get language => 'Langue';
	@override String get notifications => 'Notifications';
	@override String get disable_notifications_info => 'Les notifications ont été désactivées. Vous pouvez les réactiver plus tard dans les paramètres de votre appareil si nécessaire.';
	@override String get account => 'Compte';
	@override String get username => 'Nom d\'utilisateur';
	@override String get edit_username_title => 'Modifier le nom d\'utilisateur';
	@override String get edit_username_confirmation => 'Voulez-vous vraiment modifier votre pseudo ?';
	@override String get email => 'E-mail';
	@override String get edit_email_title => 'Modifier l\'e-mail';
	@override String get edit_email_confirmation => 'Voulez-vous vraiment modifier votre adresse e-mail ?';
	@override String get change_password => 'Changer le mot de passe';
	@override String get delete_account => 'Supprimer le compte';
	@override String get delete_account_fail => 'Échec de la suppression du compte';
	@override String get delete_account_error => 'Erreur lors de la suppression';
	@override String get others => 'Autres';
	@override String get delete_account_confirmation => 'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.';
	@override String get logout => 'Se déconnecter';
	@override Map<String, String> get languages => {
		'fr': 'Français',
		'en': 'Anglais',
	};
	@override String get cancel => 'Annuler';
	@override String get confirm => 'Confirmer';
	@override String get delete_confirm_title => 'Confirmer la suppression';
	@override String get privacy_policy => 'Avis sur la confidentialité';
	@override String get privacy_policy_description => 'Nous nous engageons à protéger votre vie privée. Toutes vos données sont confidentielles et ne seront jamais partagées sans votre consentement.';
	@override String get save => 'Sauvegarder';
	@override String get overlay_title => 'Position du compteur';
	@override String get left => 'Gauche';
	@override String get bottom => 'Bas';
}

// Path: customization
class _TranslationsCustomizationFr extends TranslationsCustomizationEn {
	_TranslationsCustomizationFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Quel look pour ce voyage ?';
	@override String get next_button => 'Suivant';
	@override String get confirm_button => 'Terminer';
}

// Path: introduction
class _TranslationsIntroductionFr extends TranslationsIntroductionEn {
	_TranslationsIntroductionFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get text_1 => 'Tout a commencé par une simple envie : se remettre au sport.';
	@override String get text_2 => 'Pour cela, le joueur choisit une petite randonnée en forêt, sans se douter qu\'elle marquerait le début d\'un long périple.';
	@override String get text_3 => 'Originaire de Rome, il marche, marche… jusqu\'à se perdre complètement.';
	@override String get text_4 => 'Alors qu\'il fait une pause pour reprendre son souffle, un hamster surgit devant lui.';
	@override String get text_5 => 'Pas un hamster ordinaire : celui-ci parle ! Intrigués, ils engagent la conversation.';
	@override String get text_6 => 'Attends une minute… Tu viens de Rome, c\'est ça ? Eh bien mon pote… t\'es plus près de Paris que de ton lit !';
	@override String get text_7 => 'Oh, tu fais cette tête-là. Je sais, ça surprend. Mais bon, faut dire que t\'as sacrément marché ! T\'as un bon pas, je te le reconnais.';
	@override String get text_8 => 'Écoute, t\'as de la chance de m\'être tombé dessus. Je suis un grand explorateur, moi ! L\'Europe ? Je la connais comme mes poches. Bon, j\'ai pas de poches, mais tu vois l\'idée.';
	@override String get text_9 => 'Si tu veux, je peux te ramener à Rome. Et tant qu\'à faire, on en profitera pour te cultiver un peu. T\'aimes les anecdotes historiques, non ?';
}

// Path: mission
class TranslationsMissionFr {
	TranslationsMissionFr.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Mission';
}

// Path: shop
class TranslationsShopFr {
	TranslationsShopFr.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Boutique';
}

// Path: workout
class TranslationsWorkoutFr {
	TranslationsWorkoutFr.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get difficulty => 'Difficulté :';
	String get easy => 'Facile';
	String get medium => 'Moyen';
	String get hard => 'Difficile';
	String get stage_1_level_1 => 'Étape 1 - Niveau 1';
	String get stage_1_level_2 => 'Étape 1 - Niveau 2';
}

// Path: gdpr_consent_form.data_collection
class _TranslationsGdprConsentFormDataCollectionFr extends TranslationsGdprConsentFormDataCollectionEn {
	_TranslationsGdprConsentFormDataCollectionFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => '1. Données Collectées\n';
	@override String get description => 'Nous collectons les données suivantes lors de l\'inscription :\n';
	@override String get essential_data => ' - Données essentielles : nom d\'utilisateur, adresse e-mail, mot de passe, date de naissance pour accéder à l\'application.\n';
	@override String get optional_data => ' - Données facultatives : taille, poids, objectifs, niveau de forme physique, particularités physiques pour personnaliser votre expérience utilisateur.\n';
}

// Path: gdpr_consent_form.data_usage
class _TranslationsGdprConsentFormDataUsageFr extends TranslationsGdprConsentFormDataUsageEn {
	_TranslationsGdprConsentFormDataUsageFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => '2. Utilisation des Données\n';
	@override String get description => 'Nous utilisons vos données pour les finalités suivantes :\n';
	@override String get purposes_1 => ' - Vous permettre d\'accéder à l\'application et de profiter de ses fonctionnalités.\n';
	@override String get purposes_2 => ' - Personnaliser votre expérience utilisateur en fonction de vos objectifs et de votre niveau de forme physique.\n';
	@override String get purposes_3 => ' - Pour respecter nos obligations légales et réglementaires.\n';
}

// Path: gdpr_consent_form.data_storage
class _TranslationsGdprConsentFormDataStorageFr extends TranslationsGdprConsentFormDataStorageEn {
	_TranslationsGdprConsentFormDataStorageFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => '3. Stockage des Données\n';
	@override String get description => 'Vos données sont stockées de manière sécurisée sur nos serveurs et ne sont pas partagées avec des tiers sans votre consentement.\n';
}

// Path: gdpr_consent_form.marketing_usage
class _TranslationsGdprConsentFormMarketingUsageFr extends TranslationsGdprConsentFormMarketingUsageEn {
	_TranslationsGdprConsentFormMarketingUsageFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => '4. Utilisation Marketing\n';
	@override String get description => 'Nous utilisons vos données pour vous envoyer des e-mails marketing concernant des promotions, événements ou rappels liés à l\'application.\n';
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
			case 'home.error_loading': return 'Erreur lors du chargement des données.';
			case 'camera.next_step_countdown': return ({required Object seconds}) => 'Prochaine étape dans ${seconds} secondes...';
			case 'camera.start_workout': return 'Démarrer';
			case 'notifications.title': return 'Notifications';
			case 'notifications.read_all': return 'Tout lire';
			case 'notifications.empty': return 'Aucune notification pour le moment.';
			case 'notifications.no_title': return 'Aucun titre';
			case 'notifications.no_body': return 'Aucun contenu';
			case 'profile.follow': return 'Suivre';
			case 'profile.unfollow': return 'Ne plus suivre';
			case 'profile.member_since': return ({required Object date}) => 'Membre depuis ${date}';
			case 'profile.followers': return 'abonnés';
			case 'profile.following': return 'abonnements';
			case 'profile.cities_finished': return 'Villes finies';
			case 'profile.nb_exercises_done_title': return 'Nombre d\'exercices faits';
			case 'profile.bpm_title': return 'BPM (Battements par minute)';
			case 'profile.achievements': return 'Succès';
			case 'social.title': return 'Social';
			case 'social.no_posts_available': return 'Aucun post disponible.';
			case 'social.post_delete': return 'Supprimer';
			case 'social.post_report': return 'Signaler';
			case 'gdpr_consent_form.title': return 'Consentement RGPD';
			case 'gdpr_consent_form.description': return 'Conformément au Règlement Général sur la Protection des Données (RGPD), nous sommes tenus de vous informer sur la collecte, l\'utilisation et le stockage de vos données personnelles.';
			case 'gdpr_consent_form.data_collection.title': return '1. Données Collectées\n';
			case 'gdpr_consent_form.data_collection.description': return 'Nous collectons les données suivantes lors de l\'inscription :\n';
			case 'gdpr_consent_form.data_collection.essential_data': return ' - Données essentielles : nom d\'utilisateur, adresse e-mail, mot de passe, date de naissance pour accéder à l\'application.\n';
			case 'gdpr_consent_form.data_collection.optional_data': return ' - Données facultatives : taille, poids, objectifs, niveau de forme physique, particularités physiques pour personnaliser votre expérience utilisateur.\n';
			case 'gdpr_consent_form.data_usage.title': return '2. Utilisation des Données\n';
			case 'gdpr_consent_form.data_usage.description': return 'Nous utilisons vos données pour les finalités suivantes :\n';
			case 'gdpr_consent_form.data_usage.purposes_1': return ' - Vous permettre d\'accéder à l\'application et de profiter de ses fonctionnalités.\n';
			case 'gdpr_consent_form.data_usage.purposes_2': return ' - Personnaliser votre expérience utilisateur en fonction de vos objectifs et de votre niveau de forme physique.\n';
			case 'gdpr_consent_form.data_usage.purposes_3': return ' - Pour respecter nos obligations légales et réglementaires.\n';
			case 'gdpr_consent_form.data_storage.title': return '3. Stockage des Données\n';
			case 'gdpr_consent_form.data_storage.description': return 'Vos données sont stockées de manière sécurisée sur nos serveurs et ne sont pas partagées avec des tiers sans votre consentement.\n';
			case 'gdpr_consent_form.marketing_usage.title': return '4. Utilisation Marketing\n';
			case 'gdpr_consent_form.marketing_usage.description': return 'Nous utilisons vos données pour vous envoyer des e-mails marketing concernant des promotions, événements ou rappels liés à l\'application.\n';
			case 'gdpr_consent_form.accept_button': return 'Continuer';
			case 'workout_session_dialog.session_title': return ({required Object session_number}) => 'Session n°${session_number}';
			case 'workout_session_dialog.start_button': return 'Démarrer';
			case 'settings.title': return 'Paramètres';
			case 'settings.language': return 'Langue';
			case 'settings.notifications': return 'Notifications';
			case 'settings.disable_notifications_info': return 'Les notifications ont été désactivées. Vous pouvez les réactiver plus tard dans les paramètres de votre appareil si nécessaire.';
			case 'settings.account': return 'Compte';
			case 'settings.username': return 'Nom d\'utilisateur';
			case 'settings.edit_username_title': return 'Modifier le nom d\'utilisateur';
			case 'settings.edit_username_confirmation': return 'Voulez-vous vraiment modifier votre pseudo ?';
			case 'settings.email': return 'E-mail';
			case 'settings.edit_email_title': return 'Modifier l\'e-mail';
			case 'settings.edit_email_confirmation': return 'Voulez-vous vraiment modifier votre adresse e-mail ?';
			case 'settings.change_password': return 'Changer le mot de passe';
			case 'settings.delete_account': return 'Supprimer le compte';
			case 'settings.delete_account_fail': return 'Échec de la suppression du compte';
			case 'settings.delete_account_error': return 'Erreur lors de la suppression';
			case 'settings.others': return 'Autres';
			case 'settings.delete_account_confirmation': return 'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.';
			case 'settings.logout': return 'Se déconnecter';
			case 'settings.languages.fr': return 'Français';
			case 'settings.languages.en': return 'Anglais';
			case 'settings.cancel': return 'Annuler';
			case 'settings.confirm': return 'Confirmer';
			case 'settings.delete_confirm_title': return 'Confirmer la suppression';
			case 'settings.privacy_policy': return 'Avis sur la confidentialité';
			case 'settings.privacy_policy_description': return 'Nous nous engageons à protéger votre vie privée. Toutes vos données sont confidentielles et ne seront jamais partagées sans votre consentement.';
			case 'settings.save': return 'Sauvegarder';
			case 'settings.overlay_title': return 'Position du compteur';
			case 'settings.left': return 'Gauche';
			case 'settings.bottom': return 'Bas';
			case 'customization.title': return 'Quel look pour ce voyage ?';
			case 'customization.next_button': return 'Suivant';
			case 'customization.confirm_button': return 'Terminer';
			case 'introduction.text_1': return 'Tout a commencé par une simple envie : se remettre au sport.';
			case 'introduction.text_2': return 'Pour cela, le joueur choisit une petite randonnée en forêt, sans se douter qu\'elle marquerait le début d\'un long périple.';
			case 'introduction.text_3': return 'Originaire de Rome, il marche, marche… jusqu\'à se perdre complètement.';
			case 'introduction.text_4': return 'Alors qu\'il fait une pause pour reprendre son souffle, un hamster surgit devant lui.';
			case 'introduction.text_5': return 'Pas un hamster ordinaire : celui-ci parle ! Intrigués, ils engagent la conversation.';
			case 'introduction.text_6': return 'Attends une minute… Tu viens de Rome, c\'est ça ? Eh bien mon pote… t\'es plus près de Paris que de ton lit !';
			case 'introduction.text_7': return 'Oh, tu fais cette tête-là. Je sais, ça surprend. Mais bon, faut dire que t\'as sacrément marché ! T\'as un bon pas, je te le reconnais.';
			case 'introduction.text_8': return 'Écoute, t\'as de la chance de m\'être tombé dessus. Je suis un grand explorateur, moi ! L\'Europe ? Je la connais comme mes poches. Bon, j\'ai pas de poches, mais tu vois l\'idée.';
			case 'introduction.text_9': return 'Si tu veux, je peux te ramener à Rome. Et tant qu\'à faire, on en profitera pour te cultiver un peu. T\'aimes les anecdotes historiques, non ?';
			case 'mission.title': return 'Mission';
			case 'shop.title': return 'Boutique';
			case 'workout.difficulty': return 'Difficulté :';
			case 'workout.easy': return 'Facile';
			case 'workout.medium': return 'Moyen';
			case 'workout.hard': return 'Difficile';
			case 'workout.stage_1_level_1': return 'Étape 1 - Niveau 1';
			case 'workout.stage_1_level_2': return 'Étape 1 - Niveau 2';
			default: return null;
		}
	}
}

