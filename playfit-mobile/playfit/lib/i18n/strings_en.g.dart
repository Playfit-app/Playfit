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
			default: return null;
		}
	}
}

