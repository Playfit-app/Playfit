///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
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
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final TranslationsLoginEn login = TranslationsLoginEn.internal(_root);
	late final TranslationsRegisterEn register = TranslationsRegisterEn.internal(_root);
	late final TranslationsHomeEn home = TranslationsHomeEn.internal(_root);
	late final TranslationsCameraEn camera = TranslationsCameraEn.internal(_root);
	late final TranslationsNotificationsEn notifications = TranslationsNotificationsEn.internal(_root);
	late final TranslationsProfileEn profile = TranslationsProfileEn.internal(_root);
	late final TranslationsSocialEn social = TranslationsSocialEn.internal(_root);
	late final TranslationsGdprConsentFormEn gdpr_consent_form = TranslationsGdprConsentFormEn.internal(_root);
	late final TranslationsWorkoutSessionDialogEn workout_session_dialog = TranslationsWorkoutSessionDialogEn.internal(_root);
	late final TranslationsSettingsEn settings = TranslationsSettingsEn.internal(_root);
	late final TranslationsCustomizationEn customization = TranslationsCustomizationEn.internal(_root);
	late final TranslationsIntroductionEn introduction = TranslationsIntroductionEn.internal(_root);
	Map<String, String> get anecdotes => {
		'sacre_coeur': 'Ah, the Panthéon in Paris! Nothing to do with Roman gods — this one\'s for great humans. Voltaire, Rousseau, Marie Curie… they\'re all chilling in the crypt. A real roommate setup of geniuses.',
		'notre_dame': 'Ah, Notre-Dame de Paris! Started in 1163, finished 200 years later. Here, Napoleon was crowned, the Revolution damaged it badly, and Victor Hugo made it famous with his Quasimodo. Even the 2019 fire didn\'t bring it down. This cathedral\'s a true survivor!',
		'louvre': 'The Louvre! Originally a 12th-century fortress to protect Paris. Then the kings turned it into a palace, especially François I and Louis XIV — until the latter preferred Versailles. Since the Revolution, it\'s been a museum, and not just any: the biggest in the world!',
		'obelisk': 'The Obelisk at Place de la Concorde! A true piece of Egypt planted right in Paris. Gifted by the viceroy of Egypt in 1830, it\'s over 3,000 years old and comes from the Luxor Temple. It even has hieroglyphs telling the feats of Ramses II.',
		'opera_paris': 'The Opéra Garnier, no less! Built under Napoleon III, inaugurated in 1875… A real gem of the Second Empire style. Marble staircases, painted ceilings, gold everywhere — you feel like you\'re stepping into a luxury cake.',
		'triumph_arc': 'The Arc de Triomphe! Commissioned by Napoleon in 1806 to celebrate his victories… but he didn\'t live to see it finished. It stands in the middle of Paris\' biggest roundabout, like a final boss of traffic.',
		'eiffel_tower': 'The Eiffel Tower! Built for the 1889 World\'s Fair, and originally… it was supposed to be dismantled after 20 years! In the end, it became the symbol of Paris. Back then, some thought it was ugly — now, everyone wants a photo with it.',
		'la_serre_du_parc_de_la_tete_d\'or': 'Parc de la Tête d\'Or is a true nature escape right in the city! Opened in 1857, it\'s one of the biggest urban parks in France. And the greenhouse? A real tropical jungle in the heart of Lyon! Built in 1890, it houses rare and exotic plants. Perfect for feeling elsewhere without leaving town.',
		'opera_lyon': 'The Lyon Opera is a blend of classical and modern! The main building dates back to 1831, but the grand hall was renovated in the \'90s with a super contemporary design.',
		'cathedrale_st_jean': 'Saint-Jean Cathedral is the star of Old Lyon! Built between the 12th and 15th centuries, it mixes many styles: Romanesque, Gothic. And check out that 14th-century astronomical clock — a real marvel! It doesn\'t just show time, but also moon phases, religious feasts… a medieval high-tech gadget.',
		'statue_équestre_de_louis_XIV': 'Place Bellecour is the heart of Lyon, the second largest pedestrian square in Europe! It\'s been there since the 17th century — a true meeting spot for the people of Lyon.',
		'fontaine_bartholdi': 'The Bartholdi Fountain is an incredible piece of art in the heart of Lyon! Created by Frédéric Bartholdi — yes, the guy behind the Statue of Liberty. It represents the city of Lyon carried by four powerful horses. Each horse symbolizes a major regional river.',
		'theatre_antique': 'The Ancient Theatre of Lyon is a heavyweight! Built in the 1st century, it\'s one of the oldest Roman theatres still standing. It could seat up to 10,000 spectators — theatre was a big deal!',
		'basilique_notre-dame_de_fourviere': 'The Basilica of Fourvière is the symbol of Lyon perched on its hill. Built between 1872 and 1884, it was erected after the Franco-Prussian War. Its architecture mixes Romanesque and Byzantine styles, with magnificent mosaics and colorful stained glass windows.',
		'galerie_victor_emmanuel_2': 'The Galleria Vittorio Emanuele II? It\'s Milan\'s grand salon! Inaugurated in 1877, it\'s named after the first king of a unified Italy. A real source of national pride.',
		'chateau_des_sforza': 'The Sforza Castle is solid stuff! Built in the 15th century by the powerful Sforza family, it was a fortress, a palace… and a symbol of power in Milan. Leonardo da Vinci even worked there! Today, it\'s packed with museums, including works by Michelangelo, among others. It\'s basically a treasure castle.',
		'plazza_del_duomo': 'The Piazza del Duomo is Milan\'s beating heart! For centuries, everything has started here. The Duomo? Begun in 1386, it took nearly 500 years to complete. 135 spires, thousands of statues, and the golden Madonnina at the top watching over the city. It\'s not just a square — it\'s a history lesson in the open air!',
		'santa_maria_delle_grazie': 'Santa Maria delle Grazie isn\'t just a classy Gothic church — it\'s a UNESCO treasure! Built between 1463 and 1497, it was entrusted to the Dominican order, and it was Duke Ludovico Sforza who commissioned the renovation of its cloister. And most importantly… in the refectory, there\'s *The Last Supper* by Leonardo da Vinci, painted right on the wall between 1495 and 1498.',
		'arco_della_pace': 'The Arco della Pace is Milan\'s grand gate to peace. Built in the early 19th century, it celebrates the end of the Napoleonic wars and the return of peace in Europe.',
		'basilique_saint_pierre': 'Saint Peter\'s Basilica is THE heart of the Vatican and one of the largest churches in the world. Built over the tomb of Saint Peter, one of Jesus\' apostles, it was constructed between the 16th and 17th centuries.',
		'pantheon_rome': 'The Pantheon in Rome is an ancient masterpiece that has survived the ages. Built nearly 2,000 years ago under Emperor Hadrian, it was a temple dedicated to all Roman gods. Its massive dome, with that famous oculus in the center, is an architectural feat — the largest unreinforced concrete dome in the world!',
		'chateau_saint_ange': 'Castel Sant\'Angelo is a fortress that has seen a lot! Originally, it was a mausoleum built for Emperor Hadrian nearly 2,000 years ago. Over the centuries, it became a fortress, a papal residence, and even a prison.',
		'collisee': 'The Colosseum is the ultimate ancient stadium! Built between 70 and 80 AD, it could hold up to 50,000 spectators ready to cheer for gladiator fights and other spectacles. This thing was a real thrill machine: chariot races, wild animal hunts, epic reenactments...',
		'fontaine_de_trevi': 'The Trevi Fountain is Rome\'s fountain superstar! Built in the 18th century, it marks the end of the aqueduct that brought water to the city since Antiquity. Tradition says if you toss a coin over your shoulder into the fountain, you\'re guaranteed to return to Rome.',
	};
}

// Path: login
class TranslationsLoginEn {
	TranslationsLoginEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Login';
	String get username => 'Username';
	String get password => 'Password';
	String get login => 'Login';
	String get invalid_credentials => 'Invalid username or password.';
	String get empty_username => 'Please enter your username.';
	String get empty_password => 'Please enter your password.';
	String get first_time_login => 'First time? Create an account!';
}

// Path: register
class TranslationsRegisterEn {
	TranslationsRegisterEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Create an account';
	String get previous => 'Previous';
	String get next => 'Next';
	String get already_have_account => 'Already have an account? Log in!';
	String get username => 'Username';
	String get empty_username => 'Please enter a username.';
	String get invalid_username => 'Username must be at least 4 characters long.';
	String get email => 'Email address';
	String get empty_email => 'Please enter an email address.';
	String get invalid_email => 'Please enter a valid email address.';
	String get password => 'Password';
	String get empty_password => 'Please enter a password.';
	String get invalid_password => 'Password must be at least 8 characters long, contain an uppercase letter, a lowercase letter, and a number.';
	String get confirm_password => 'Confirm password';
	String get empty_confirm_password => 'Please confirm your password.';
	String get passwords_do_not_match => 'Passwords do not match.';
	String get birthdate => 'Birthdate';
	String get empty_birthdate => 'Please enter your birthdate.';
	String get invalid_birthdate => 'You must be at least 18 years old to register.';
	String get height => 'Height (cm)';
	String get empty_height => 'Please enter your height.';
	String get invalid_height => 'Please enter a valid height.';
	String get weight => 'Weight (kg)';
	String get empty_weight => 'Please enter your weight.';
	String get invalid_weight => 'Please enter a valid weight.';
	String get gdpr_consent_title => 'GDPR Consent';
	String get gdpr_consent => 'I accept the GDPR consent form and the Privacy Policy (Required).';
	String get gdpr_consent_invalid => 'You must accept the GDPR consent form and the Privacy Policy.';
	String get marketing_consent => 'I agree to receive marketing communications (Optional).';
	String get avatar_choose => 'Choose your avatar';
	String get create_account => 'Create an account';
}

// Path: home
class TranslationsHomeEn {
	TranslationsHomeEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get error_loading => 'Error loading data.';
}

// Path: camera
class TranslationsCameraEn {
	TranslationsCameraEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String next_step_countdown({required Object seconds}) => 'Next step in ${seconds} seconds...';
	String get start_workout => 'Start';
}

// Path: notifications
class TranslationsNotificationsEn {
	TranslationsNotificationsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Notifications';
	String get read_all => 'Read all';
	String get empty => 'No notifications at the moment.';
	String get no_title => 'No title';
	String get no_body => 'No content';
}

// Path: profile
class TranslationsProfileEn {
	TranslationsProfileEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get follow => 'Follow';
	String get unfollow => 'Unfollow';
	String member_since({required Object date}) => 'Member since ${date}';
	String get followers => 'followers';
	String get following => 'following';
	String get cities_finished => 'Cities finished';
	String get nb_exercises_done_title => 'Number of exercises done';
	String get bpm_title => 'BPM (Beats per minute)';
	String get achievements => 'Achievements';
}

// Path: social
class TranslationsSocialEn {
	TranslationsSocialEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Social';
}

// Path: gdpr_consent_form
class TranslationsGdprConsentFormEn {
	TranslationsGdprConsentFormEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'GDPR Consent';
	String get description => 'In accordance with the General Data Protection Regulation (GDPR), we are required to inform you about the collection, use, and storage of your personal data.';
	late final TranslationsGdprConsentFormDataCollectionEn data_collection = TranslationsGdprConsentFormDataCollectionEn.internal(_root);
	late final TranslationsGdprConsentFormDataUsageEn data_usage = TranslationsGdprConsentFormDataUsageEn.internal(_root);
	late final TranslationsGdprConsentFormDataStorageEn data_storage = TranslationsGdprConsentFormDataStorageEn.internal(_root);
	late final TranslationsGdprConsentFormMarketingUsageEn marketing_usage = TranslationsGdprConsentFormMarketingUsageEn.internal(_root);
	String get accept_button => 'Continue';
}

// Path: workout_session_dialog
class TranslationsWorkoutSessionDialogEn {
	TranslationsWorkoutSessionDialogEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String session_title({required Object session_number}) => 'Session n°${session_number}';
	String get start_button => 'Start';
}

// Path: settings
class TranslationsSettingsEn {
	TranslationsSettingsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Settings';
	String get language => 'Language';
	String get notifications => 'Notifications';
	String get disable_notifications_info => 'Notifications have been disabled. You can re-enable them later in your device settings if needed.';
	String get account => 'Account';
	String get username => 'Username';
	String get edit_username_title => 'Edit username';
	String get edit_username_confirmation => 'Do you really want to change your username?';
	String get email => 'Email';
	String get edit_email_title => 'Edit email';
	String get edit_email_confirmation => 'Do you really want to change your email address?';
	String get change_password => 'Change password';
	String get delete_account => 'Delete account';
	String get delete_account_fail => 'Delete account fail';
	String get delete_account_error => 'Delete account error';
	String get others => 'Others';
	String get delete_account_confirmation => 'Are you sure you want to delete your account? This action cannot be undone.';
	String get logout => 'Logout';
	Map<String, String> get languages => {
		'fr': 'French',
		'en': 'English',
	};
	String get cancel => 'Cancel';
	String get confirm => 'Confirm';
	String get delete_confirm_title => 'Confirm Deletion';
	String get privacy_policy => 'Privacy Policy';
	String get privacy_policy_description => 'We are committed to protecting your privacy. All your data is confidential and will never be shared without your consent.';
	String get save => 'Save';
	String get overlay_title => 'Overlay Position';
	String get left => 'Left';
	String get bottom => 'Bottom';
}

// Path: customization
class TranslationsCustomizationEn {
	TranslationsCustomizationEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'What look for this trip?';
	String get next_button => 'Next';
	String get confirm_button => 'Finish';
}

// Path: introduction
class TranslationsIntroductionEn {
	TranslationsIntroductionEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get text_1 => 'It all started with a simple desire: to get back into sports.';
	String get text_2 => 'To do that, the player chose a short hike in the forest, not suspecting it would mark the beginning of a long journey.';
	String get text_3 => 'Originally from Rome, he walks and walks… until he gets completely lost.';
	String get text_4 => 'While taking a break to catch his breath, a hamster suddenly appears in front of him.';
	String get text_5 => 'Not an ordinary hamster: this one talks! Intrigued, they strike up a conversation.';
	String get text_6 => 'Wait a minute… You\'re from Rome, right? Well buddy… you\'re closer to Paris than to your bed!';
	String get text_7 => 'Oh, that face you\'re making. I know, it\'s surprising. But hey, you\'ve walked a lot! Gotta say, you\'ve got a good stride.';
	String get text_8 => 'Listen, you\'re lucky you ran into me. I\'m a great explorer! Europe? I know it like the back of my paw. Well, I don\'t have paws—pockets, I mean—but you get the idea.';
	String get text_9 => 'If you want, I can take you back to Rome. And while we\'re at it, we might as well teach you a few things. You like historical fun facts, right?';
}

// Path: gdpr_consent_form.data_collection
class TranslationsGdprConsentFormDataCollectionEn {
	TranslationsGdprConsentFormDataCollectionEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => '1. Data Collected\n';
	String get description => 'We collect the following data during registration:\n';
	String get essential_data => ' - Essential data: username, email address, password, date of birth to access the application.\n';
	String get optional_data => ' - Optional data: height, weight, goals, fitness level, physical characteristics to personalize your user experience.\n';
}

// Path: gdpr_consent_form.data_usage
class TranslationsGdprConsentFormDataUsageEn {
	TranslationsGdprConsentFormDataUsageEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => '2. Data Usage\n';
	String get description => 'We use your data for the following purposes:\n';
	String get purposes_1 => ' - To allow you to access the application and enjoy its features.\n';
	String get purposes_2 => ' - To personalize your user experience based on your goals and fitness level.\n';
	String get purposes_3 => ' - To comply with our legal and regulatory obligations.\n';
}

// Path: gdpr_consent_form.data_storage
class TranslationsGdprConsentFormDataStorageEn {
	TranslationsGdprConsentFormDataStorageEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => '3. Data Storage\n';
	String get description => 'Your data is securely stored on our servers and is not shared with third parties without your consent.\n';
}

// Path: gdpr_consent_form.marketing_usage
class TranslationsGdprConsentFormMarketingUsageEn {
	TranslationsGdprConsentFormMarketingUsageEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => '4. Marketing Usage\n';
	String get description => 'We use your data to send you marketing emails regarding promotions, events, or reminders related to the application.\n';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.
extension on Translations {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'login.title': return 'Login';
			case 'login.username': return 'Username';
			case 'login.password': return 'Password';
			case 'login.login': return 'Login';
			case 'login.invalid_credentials': return 'Invalid username or password.';
			case 'login.empty_username': return 'Please enter your username.';
			case 'login.empty_password': return 'Please enter your password.';
			case 'login.first_time_login': return 'First time? Create an account!';
			case 'register.title': return 'Create an account';
			case 'register.previous': return 'Previous';
			case 'register.next': return 'Next';
			case 'register.already_have_account': return 'Already have an account? Log in!';
			case 'register.username': return 'Username';
			case 'register.empty_username': return 'Please enter a username.';
			case 'register.invalid_username': return 'Username must be at least 4 characters long.';
			case 'register.email': return 'Email address';
			case 'register.empty_email': return 'Please enter an email address.';
			case 'register.invalid_email': return 'Please enter a valid email address.';
			case 'register.password': return 'Password';
			case 'register.empty_password': return 'Please enter a password.';
			case 'register.invalid_password': return 'Password must be at least 8 characters long, contain an uppercase letter, a lowercase letter, and a number.';
			case 'register.confirm_password': return 'Confirm password';
			case 'register.empty_confirm_password': return 'Please confirm your password.';
			case 'register.passwords_do_not_match': return 'Passwords do not match.';
			case 'register.birthdate': return 'Birthdate';
			case 'register.empty_birthdate': return 'Please enter your birthdate.';
			case 'register.invalid_birthdate': return 'You must be at least 18 years old to register.';
			case 'register.height': return 'Height (cm)';
			case 'register.empty_height': return 'Please enter your height.';
			case 'register.invalid_height': return 'Please enter a valid height.';
			case 'register.weight': return 'Weight (kg)';
			case 'register.empty_weight': return 'Please enter your weight.';
			case 'register.invalid_weight': return 'Please enter a valid weight.';
			case 'register.gdpr_consent_title': return 'GDPR Consent';
			case 'register.gdpr_consent': return 'I accept the GDPR consent form and the Privacy Policy (Required).';
			case 'register.gdpr_consent_invalid': return 'You must accept the GDPR consent form and the Privacy Policy.';
			case 'register.marketing_consent': return 'I agree to receive marketing communications (Optional).';
			case 'register.avatar_choose': return 'Choose your avatar';
			case 'register.create_account': return 'Create an account';
			case 'home.error_loading': return 'Error loading data.';
			case 'camera.next_step_countdown': return ({required Object seconds}) => 'Next step in ${seconds} seconds...';
			case 'camera.start_workout': return 'Start';
			case 'notifications.title': return 'Notifications';
			case 'notifications.read_all': return 'Read all';
			case 'notifications.empty': return 'No notifications at the moment.';
			case 'notifications.no_title': return 'No title';
			case 'notifications.no_body': return 'No content';
			case 'profile.follow': return 'Follow';
			case 'profile.unfollow': return 'Unfollow';
			case 'profile.member_since': return ({required Object date}) => 'Member since ${date}';
			case 'profile.followers': return 'followers';
			case 'profile.following': return 'following';
			case 'profile.cities_finished': return 'Cities finished';
			case 'profile.nb_exercises_done_title': return 'Number of exercises done';
			case 'profile.bpm_title': return 'BPM (Beats per minute)';
			case 'profile.achievements': return 'Achievements';
			case 'social.title': return 'Social';
			case 'gdpr_consent_form.title': return 'GDPR Consent';
			case 'gdpr_consent_form.description': return 'In accordance with the General Data Protection Regulation (GDPR), we are required to inform you about the collection, use, and storage of your personal data.';
			case 'gdpr_consent_form.data_collection.title': return '1. Data Collected\n';
			case 'gdpr_consent_form.data_collection.description': return 'We collect the following data during registration:\n';
			case 'gdpr_consent_form.data_collection.essential_data': return ' - Essential data: username, email address, password, date of birth to access the application.\n';
			case 'gdpr_consent_form.data_collection.optional_data': return ' - Optional data: height, weight, goals, fitness level, physical characteristics to personalize your user experience.\n';
			case 'gdpr_consent_form.data_usage.title': return '2. Data Usage\n';
			case 'gdpr_consent_form.data_usage.description': return 'We use your data for the following purposes:\n';
			case 'gdpr_consent_form.data_usage.purposes_1': return ' - To allow you to access the application and enjoy its features.\n';
			case 'gdpr_consent_form.data_usage.purposes_2': return ' - To personalize your user experience based on your goals and fitness level.\n';
			case 'gdpr_consent_form.data_usage.purposes_3': return ' - To comply with our legal and regulatory obligations.\n';
			case 'gdpr_consent_form.data_storage.title': return '3. Data Storage\n';
			case 'gdpr_consent_form.data_storage.description': return 'Your data is securely stored on our servers and is not shared with third parties without your consent.\n';
			case 'gdpr_consent_form.marketing_usage.title': return '4. Marketing Usage\n';
			case 'gdpr_consent_form.marketing_usage.description': return 'We use your data to send you marketing emails regarding promotions, events, or reminders related to the application.\n';
			case 'gdpr_consent_form.accept_button': return 'Continue';
			case 'workout_session_dialog.session_title': return ({required Object session_number}) => 'Session n°${session_number}';
			case 'workout_session_dialog.start_button': return 'Start';
			case 'settings.title': return 'Settings';
			case 'settings.language': return 'Language';
			case 'settings.notifications': return 'Notifications';
			case 'settings.disable_notifications_info': return 'Notifications have been disabled. You can re-enable them later in your device settings if needed.';
			case 'settings.account': return 'Account';
			case 'settings.username': return 'Username';
			case 'settings.edit_username_title': return 'Edit username';
			case 'settings.edit_username_confirmation': return 'Do you really want to change your username?';
			case 'settings.email': return 'Email';
			case 'settings.edit_email_title': return 'Edit email';
			case 'settings.edit_email_confirmation': return 'Do you really want to change your email address?';
			case 'settings.change_password': return 'Change password';
			case 'settings.delete_account': return 'Delete account';
			case 'settings.delete_account_fail': return 'Delete account fail';
			case 'settings.delete_account_error': return 'Delete account error';
			case 'settings.others': return 'Others';
			case 'settings.delete_account_confirmation': return 'Are you sure you want to delete your account? This action cannot be undone.';
			case 'settings.logout': return 'Logout';
			case 'settings.languages.fr': return 'French';
			case 'settings.languages.en': return 'English';
			case 'settings.cancel': return 'Cancel';
			case 'settings.confirm': return 'Confirm';
			case 'settings.delete_confirm_title': return 'Confirm Deletion';
			case 'settings.privacy_policy': return 'Privacy Policy';
			case 'settings.privacy_policy_description': return 'We are committed to protecting your privacy. All your data is confidential and will never be shared without your consent.';
			case 'settings.save': return 'Save';
			case 'settings.overlay_title': return 'Overlay Position';
			case 'settings.left': return 'Left';
			case 'settings.bottom': return 'Bottom';
			case 'customization.title': return 'What look for this trip?';
			case 'customization.next_button': return 'Next';
			case 'customization.confirm_button': return 'Finish';
			case 'introduction.text_1': return 'It all started with a simple desire: to get back into sports.';
			case 'introduction.text_2': return 'To do that, the player chose a short hike in the forest, not suspecting it would mark the beginning of a long journey.';
			case 'introduction.text_3': return 'Originally from Rome, he walks and walks… until he gets completely lost.';
			case 'introduction.text_4': return 'While taking a break to catch his breath, a hamster suddenly appears in front of him.';
			case 'introduction.text_5': return 'Not an ordinary hamster: this one talks! Intrigued, they strike up a conversation.';
			case 'introduction.text_6': return 'Wait a minute… You\'re from Rome, right? Well buddy… you\'re closer to Paris than to your bed!';
			case 'introduction.text_7': return 'Oh, that face you\'re making. I know, it\'s surprising. But hey, you\'ve walked a lot! Gotta say, you\'ve got a good stride.';
			case 'introduction.text_8': return 'Listen, you\'re lucky you ran into me. I\'m a great explorer! Europe? I know it like the back of my paw. Well, I don\'t have paws—pockets, I mean—but you get the idea.';
			case 'introduction.text_9': return 'If you want, I can take you back to Rome. And while we\'re at it, we might as well teach you a few things. You like historical fun facts, right?';
			case 'anecdotes.sacre_coeur': return 'Ah, the Panthéon in Paris! Nothing to do with Roman gods — this one\'s for great humans. Voltaire, Rousseau, Marie Curie… they\'re all chilling in the crypt. A real roommate setup of geniuses.';
			case 'anecdotes.notre_dame': return 'Ah, Notre-Dame de Paris! Started in 1163, finished 200 years later. Here, Napoleon was crowned, the Revolution damaged it badly, and Victor Hugo made it famous with his Quasimodo. Even the 2019 fire didn\'t bring it down. This cathedral\'s a true survivor!';
			case 'anecdotes.louvre': return 'The Louvre! Originally a 12th-century fortress to protect Paris. Then the kings turned it into a palace, especially François I and Louis XIV — until the latter preferred Versailles. Since the Revolution, it\'s been a museum, and not just any: the biggest in the world!';
			case 'anecdotes.obelisk': return 'The Obelisk at Place de la Concorde! A true piece of Egypt planted right in Paris. Gifted by the viceroy of Egypt in 1830, it\'s over 3,000 years old and comes from the Luxor Temple. It even has hieroglyphs telling the feats of Ramses II.';
			case 'anecdotes.opera_paris': return 'The Opéra Garnier, no less! Built under Napoleon III, inaugurated in 1875… A real gem of the Second Empire style. Marble staircases, painted ceilings, gold everywhere — you feel like you\'re stepping into a luxury cake.';
			case 'anecdotes.triumph_arc': return 'The Arc de Triomphe! Commissioned by Napoleon in 1806 to celebrate his victories… but he didn\'t live to see it finished. It stands in the middle of Paris\' biggest roundabout, like a final boss of traffic.';
			case 'anecdotes.eiffel_tower': return 'The Eiffel Tower! Built for the 1889 World\'s Fair, and originally… it was supposed to be dismantled after 20 years! In the end, it became the symbol of Paris. Back then, some thought it was ugly — now, everyone wants a photo with it.';
			case 'anecdotes.la_serre_du_parc_de_la_tete_d\'or': return 'Parc de la Tête d\'Or is a true nature escape right in the city! Opened in 1857, it\'s one of the biggest urban parks in France. And the greenhouse? A real tropical jungle in the heart of Lyon! Built in 1890, it houses rare and exotic plants. Perfect for feeling elsewhere without leaving town.';
			case 'anecdotes.opera_lyon': return 'The Lyon Opera is a blend of classical and modern! The main building dates back to 1831, but the grand hall was renovated in the \'90s with a super contemporary design.';
			case 'anecdotes.cathedrale_st_jean': return 'Saint-Jean Cathedral is the star of Old Lyon! Built between the 12th and 15th centuries, it mixes many styles: Romanesque, Gothic. And check out that 14th-century astronomical clock — a real marvel! It doesn\'t just show time, but also moon phases, religious feasts… a medieval high-tech gadget.';
			case 'anecdotes.statue_équestre_de_louis_XIV': return 'Place Bellecour is the heart of Lyon, the second largest pedestrian square in Europe! It\'s been there since the 17th century — a true meeting spot for the people of Lyon.';
			case 'anecdotes.fontaine_bartholdi': return 'The Bartholdi Fountain is an incredible piece of art in the heart of Lyon! Created by Frédéric Bartholdi — yes, the guy behind the Statue of Liberty. It represents the city of Lyon carried by four powerful horses. Each horse symbolizes a major regional river.';
			case 'anecdotes.theatre_antique': return 'The Ancient Theatre of Lyon is a heavyweight! Built in the 1st century, it\'s one of the oldest Roman theatres still standing. It could seat up to 10,000 spectators — theatre was a big deal!';
			case 'anecdotes.basilique_notre-dame_de_fourviere': return 'The Basilica of Fourvière is the symbol of Lyon perched on its hill. Built between 1872 and 1884, it was erected after the Franco-Prussian War. Its architecture mixes Romanesque and Byzantine styles, with magnificent mosaics and colorful stained glass windows.';
			case 'anecdotes.galerie_victor_emmanuel_2': return 'The Galleria Vittorio Emanuele II? It\'s Milan\'s grand salon! Inaugurated in 1877, it\'s named after the first king of a unified Italy. A real source of national pride.';
			case 'anecdotes.chateau_des_sforza': return 'The Sforza Castle is solid stuff! Built in the 15th century by the powerful Sforza family, it was a fortress, a palace… and a symbol of power in Milan. Leonardo da Vinci even worked there! Today, it\'s packed with museums, including works by Michelangelo, among others. It\'s basically a treasure castle.';
			case 'anecdotes.plazza_del_duomo': return 'The Piazza del Duomo is Milan\'s beating heart! For centuries, everything has started here. The Duomo? Begun in 1386, it took nearly 500 years to complete. 135 spires, thousands of statues, and the golden Madonnina at the top watching over the city. It\'s not just a square — it\'s a history lesson in the open air!';
			case 'anecdotes.santa_maria_delle_grazie': return 'Santa Maria delle Grazie isn\'t just a classy Gothic church — it\'s a UNESCO treasure! Built between 1463 and 1497, it was entrusted to the Dominican order, and it was Duke Ludovico Sforza who commissioned the renovation of its cloister. And most importantly… in the refectory, there\'s *The Last Supper* by Leonardo da Vinci, painted right on the wall between 1495 and 1498.';
			case 'anecdotes.arco_della_pace': return 'The Arco della Pace is Milan\'s grand gate to peace. Built in the early 19th century, it celebrates the end of the Napoleonic wars and the return of peace in Europe.';
			case 'anecdotes.basilique_saint_pierre': return 'Saint Peter\'s Basilica is THE heart of the Vatican and one of the largest churches in the world. Built over the tomb of Saint Peter, one of Jesus\' apostles, it was constructed between the 16th and 17th centuries.';
			case 'anecdotes.pantheon_rome': return 'The Pantheon in Rome is an ancient masterpiece that has survived the ages. Built nearly 2,000 years ago under Emperor Hadrian, it was a temple dedicated to all Roman gods. Its massive dome, with that famous oculus in the center, is an architectural feat — the largest unreinforced concrete dome in the world!';
			case 'anecdotes.chateau_saint_ange': return 'Castel Sant\'Angelo is a fortress that has seen a lot! Originally, it was a mausoleum built for Emperor Hadrian nearly 2,000 years ago. Over the centuries, it became a fortress, a papal residence, and even a prison.';
			case 'anecdotes.collisee': return 'The Colosseum is the ultimate ancient stadium! Built between 70 and 80 AD, it could hold up to 50,000 spectators ready to cheer for gladiator fights and other spectacles. This thing was a real thrill machine: chariot races, wild animal hunts, epic reenactments...';
			case 'anecdotes.fontaine_de_trevi': return 'The Trevi Fountain is Rome\'s fountain superstar! Built in the 18th century, it marks the end of the aqueduct that brought water to the city since Antiquity. Tradition says if you toss a coin over your shoulder into the fountain, you\'re guaranteed to return to Rome.';
			default: return null;
		}
	}
}

