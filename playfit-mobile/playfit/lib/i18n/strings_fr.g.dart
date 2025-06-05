///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsFr = Translations; // ignore: unused_element
class Translations implements BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
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
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final TranslationsLoginFr login = TranslationsLoginFr.internal(_root);
	late final TranslationsRegisterFr register = TranslationsRegisterFr.internal(_root);
	late final TranslationsHomeFr home = TranslationsHomeFr.internal(_root);
	late final TranslationsCameraFr camera = TranslationsCameraFr.internal(_root);
	late final TranslationsNotificationsFr notifications = TranslationsNotificationsFr.internal(_root);
	late final TranslationsProfileFr profile = TranslationsProfileFr.internal(_root);
	late final TranslationsSocialFr social = TranslationsSocialFr.internal(_root);
	late final TranslationsGdprConsentFormFr gdpr_consent_form = TranslationsGdprConsentFormFr.internal(_root);
	late final TranslationsWorkoutSessionDialogFr workout_session_dialog = TranslationsWorkoutSessionDialogFr.internal(_root);
	late final TranslationsCustomizationFr customization = TranslationsCustomizationFr.internal(_root);
	late final TranslationsIntroductionFr introduction = TranslationsIntroductionFr.internal(_root);
}

// Path: login
class TranslationsLoginFr {
	TranslationsLoginFr.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Connexion';
	String get username => 'Nom d\'utilisateur';
	String get password => 'Mot de passe';
	String get login => 'Connexion';
	String get invalid_credentials => 'Nom d\'utilisateur ou mot de passe invalide.';
	String get empty_username => 'Veuillez entrer votre nom d\'utilisateur.';
	String get empty_password => 'Veuillez entrer votre mot de passe.';
	String get first_time_login => 'Première fois ? Créez un compte !';
}

// Path: register
class TranslationsRegisterFr {
	TranslationsRegisterFr.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Créer un compte';
	String get previous => 'Précédent';
	String get next => 'Suivant';
	String get already_have_account => 'Déjà un compte ? Connectez-vous !';
	String get username => 'Nom d\'utilisateur';
	String get empty_username => 'Veuillez entrer un nom d\'utilisateur.';
	String get invalid_username => 'Le nom d\'utilisateur doit contenir au moins 4 caractères';
	String get email => 'Adresse e-mail';
	String get empty_email => 'Veuillez entrer une adresse e-mail.';
	String get invalid_email => 'Veuillez entrer une adresse e-mail valide.';
	String get password => 'Mot de passe';
	String get empty_password => 'Veuillez entrer un mot de passe.';
	String get invalid_password => 'Le mot de passe doit contenir au moins 8 caractères, une majuscule, une minuscule et un chiffre.';
	String get confirm_password => 'Confirmer le mot de passe';
	String get empty_confirm_password => 'Veuillez confirmer votre mot de passe.';
	String get passwords_do_not_match => 'Les mots de passe ne correspondent pas.';
	String get birthdate => 'Date de naissance';
	String get empty_birthdate => 'Veuillez entrer votre date de naissance.';
	String get invalid_birthdate => 'Vous devez avoir au moins 18 ans pour vous inscrire.';
	String get height => 'Taille (cm)';
	String get empty_height => 'Veuillez entrer votre taille.';
	String get invalid_height => 'Veuillez entrer une taille valide.';
	String get weight => 'Poids (kg)';
	String get empty_weight => 'Veuillez entrer votre poids.';
	String get invalid_weight => 'Veuillez entrer un poids valide.';
	String get gdpr_consent_title => 'Consentement RGPD';
	String get gdpr_consent => 'J\'accepte le formulaire de consentement RGPD et la Politique de Confidentialité (Obligatoire).';
	String get gdpr_consent_invalid => 'Vous devez accepter le formulaire de consentement RGPD et la Politique de Confidentialité.';
	String get marketing_consent => 'J\'accepte de recevoir des communications marketing (Facultatif).';
	String get avatar_choose => 'Choisir ton avatar';
	String get create_account => 'Créer un compte';
}

// Path: home
class TranslationsHomeFr {
	TranslationsHomeFr.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get error_loading => 'Erreur lors du chargement des données.';
}

// Path: camera
class TranslationsCameraFr {
	TranslationsCameraFr.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String next_step_countdown({required Object seconds}) => 'Prochaine étape dans ${seconds} secondes...';
	String get start_workout => 'Démarrer';
}

// Path: notifications
class TranslationsNotificationsFr {
	TranslationsNotificationsFr.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Notifications';
	String get read_all => 'Tout lire';
	String get empty => 'Aucune notification pour le moment.';
	String get no_title => 'Aucun titre';
	String get no_body => 'Aucun contenu';
}

// Path: profile
class TranslationsProfileFr {
	TranslationsProfileFr.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get follow => 'Suivre';
	String get unfollow => 'Ne plus suivre';
	String member_since({required Object date}) => 'Membre depuis ${date}';
	String get followers => 'abonnés';
	String get following => 'abonnements';
	String get cities_finished => 'Villes finies';
	String get nb_exercises_done_title => 'Nombre d\'exercices faits';
	String get bpm_title => 'BPM (Battements par minute)';
	String get achievements => 'Succès';
}

// Path: social
class TranslationsSocialFr {
	TranslationsSocialFr.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Social';
}

// Path: gdpr_consent_form
class TranslationsGdprConsentFormFr {
	TranslationsGdprConsentFormFr.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Consentement RGPD';
	String get description => 'Conformément au Règlement Général sur la Protection des Données (RGPD), nous sommes tenus de vous informer sur la collecte, l\'utilisation et le stockage de vos données personnelles.';
	late final TranslationsGdprConsentFormDataCollectionFr data_collection = TranslationsGdprConsentFormDataCollectionFr.internal(_root);
	late final TranslationsGdprConsentFormDataUsageFr data_usage = TranslationsGdprConsentFormDataUsageFr.internal(_root);
	late final TranslationsGdprConsentFormDataStorageFr data_storage = TranslationsGdprConsentFormDataStorageFr.internal(_root);
	late final TranslationsGdprConsentFormMarketingUsageFr marketing_usage = TranslationsGdprConsentFormMarketingUsageFr.internal(_root);
	String get accept_button => 'Continuer';
}

// Path: workout_session_dialog
class TranslationsWorkoutSessionDialogFr {
	TranslationsWorkoutSessionDialogFr.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String session_title({required Object session_number}) => 'Session n°${session_number}';
	String get start_button => 'Démarrer';
}

// Path: customization
class TranslationsCustomizationFr {
	TranslationsCustomizationFr.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Quel look pour ce voyage ?';
	String get next_button => 'Suivant';
	String get confirm_button => 'Terminer';
}

// Path: introduction
class TranslationsIntroductionFr {
	TranslationsIntroductionFr.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get text_1 => 'Tout a commencé par une simple envie : se remettre au sport.';
	String get text_2 => 'Pour cela, le joueur choisit une petite randonnée en forêt, sans se douter qu\'elle marquerait le début d\'un long périple.';
	String get text_3 => 'Originaire de Rome, il marche, marche… jusqu\'à se perdre complètement.';
	String get text_4 => 'Alors qu\'il fait une pause pour reprendre son souffle, un hamster surgit devant lui.';
	String get text_5 => 'Pas un hamster ordinaire : celui-ci parle ! Intrigués, ils engagent la conversation.';
	String get text_6 => 'Attends une minute… Tu viens de Rome, c\'est ça ? Eh bien mon pote… t\'es plus près de Paris que de ton lit !';
	String get text_7 => 'Oh, tu fais cette tête-là. Je sais, ça surprend. Mais bon, faut dire que t\'as sacrément marché ! T\'as un bon pas, je te le reconnais.';
	String get text_8 => 'Écoute, t\'as de la chance de m\'être tombé dessus. Je suis un grand explorateur, moi ! L\'Europe ? Je la connais comme mes poches. Bon, j\'ai pas de poches, mais tu vois l\'idée.';
	String get text_9 => 'Si tu veux, je peux te ramener à Rome. Et tant qu\'à faire, on en profitera pour te cultiver un peu. T\'aimes les anecdotes historiques, non ?';
}

// Path: gdpr_consent_form.data_collection
class TranslationsGdprConsentFormDataCollectionFr {
	TranslationsGdprConsentFormDataCollectionFr.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => '1. Données Collectées\n';
	String get description => 'Nous collectons les données suivantes lors de l\'inscription :\n';
	String get essential_data => ' - Données essentielles : nom d\'utilisateur, adresse e-mail, mot de passe, date de naissance pour accéder à l\'application.\n';
	String get optional_data => ' - Données facultatives : taille, poids, objectifs, niveau de forme physique, particularités physiques pour personnaliser votre expérience utilisateur.\n';
}

// Path: gdpr_consent_form.data_usage
class TranslationsGdprConsentFormDataUsageFr {
	TranslationsGdprConsentFormDataUsageFr.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => '2. Utilisation des Données\n';
	String get description => 'Nous utilisons vos données pour les finalités suivantes :\n';
	String get purposes_1 => ' - Vous permettre d\'accéder à l\'application et de profiter de ses fonctionnalités.\n';
	String get purposes_2 => ' - Personnaliser votre expérience utilisateur en fonction de vos objectifs et de votre niveau de forme physique.\n';
	String get purposes_3 => ' - Pour respecter nos obligations légales et réglementaires.\n';
}

// Path: gdpr_consent_form.data_storage
class TranslationsGdprConsentFormDataStorageFr {
	TranslationsGdprConsentFormDataStorageFr.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => '3. Stockage des Données\n';
	String get description => 'Vos données sont stockées de manière sécurisée sur nos serveurs et ne sont pas partagées avec des tiers sans votre consentement.\n';
}

// Path: gdpr_consent_form.marketing_usage
class TranslationsGdprConsentFormMarketingUsageFr {
	TranslationsGdprConsentFormMarketingUsageFr.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => '4. Utilisation Marketing\n';
	String get description => 'Nous utilisons vos données pour vous envoyer des e-mails marketing concernant des promotions, événements ou rappels liés à l\'application.\n';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.
extension on Translations {
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
			default: return null;
		}
	}
}

