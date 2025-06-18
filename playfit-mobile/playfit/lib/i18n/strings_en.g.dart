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
class TranslationsEn extends Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsEn({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsEn _root = this; // ignore: unused_field

	@override 
	TranslationsEn $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsEn(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsLoginEn login = _TranslationsLoginEn._(_root);
	@override late final _TranslationsRegisterEn register = _TranslationsRegisterEn._(_root);
	@override late final _TranslationsHomeEn home = _TranslationsHomeEn._(_root);
	@override late final _TranslationsCameraEn camera = _TranslationsCameraEn._(_root);
	@override late final _TranslationsNotificationsEn notifications = _TranslationsNotificationsEn._(_root);
	@override late final _TranslationsProfileEn profile = _TranslationsProfileEn._(_root);
	@override late final _TranslationsSocialEn social = _TranslationsSocialEn._(_root);
	@override late final _TranslationsGdprConsentFormEn gdpr_consent_form = _TranslationsGdprConsentFormEn._(_root);
	@override late final _TranslationsWorkoutSessionDialogEn workout_session_dialog = _TranslationsWorkoutSessionDialogEn._(_root);
	@override late final _TranslationsCustomizationEn customization = _TranslationsCustomizationEn._(_root);
	@override late final _TranslationsIntroductionEn introduction = _TranslationsIntroductionEn._(_root);
	@override late final _TranslationsMissionEn mission = _TranslationsMissionEn._(_root);
	@override late final _TranslationsShopEn shop = _TranslationsShopEn._(_root);
	@override late final _TranslationsWorkoutEn workout = _TranslationsWorkoutEn._(_root);
}

// Path: login
class _TranslationsLoginEn extends TranslationsLoginFr {
	_TranslationsLoginEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Login';
	@override String get username => 'Username';
	@override String get password => 'Password';
	@override String get login => 'Login';
	@override String get invalid_credentials => 'Invalid username or password.';
	@override String get empty_username => 'Please enter your username.';
	@override String get empty_password => 'Please enter your password.';
	@override String get first_time_login => 'First time? Create an account!';
}

// Path: register
class _TranslationsRegisterEn extends TranslationsRegisterFr {
	_TranslationsRegisterEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Create an account';
	@override String get previous => 'Previous';
	@override String get next => 'Next';
	@override String get already_have_account => 'Already have an account? Log in!';
	@override String get username => 'Username';
	@override String get empty_username => 'Please enter a username.';
	@override String get invalid_username => 'Username must be at least 4 characters long.';
	@override String get email => 'Email address';
	@override String get empty_email => 'Please enter an email address.';
	@override String get invalid_email => 'Please enter a valid email address.';
	@override String get password => 'Password';
	@override String get empty_password => 'Please enter a password.';
	@override String get invalid_password => 'Password must be at least 8 characters long, contain an uppercase letter, a lowercase letter, and a number.';
	@override String get confirm_password => 'Confirm password';
	@override String get empty_confirm_password => 'Please confirm your password.';
	@override String get passwords_do_not_match => 'Passwords do not match.';
	@override String get birthdate => 'Birthdate';
	@override String get empty_birthdate => 'Please enter your birthdate.';
	@override String get invalid_birthdate => 'You must be at least 18 years old to register.';
	@override String get height => 'Height (cm)';
	@override String get empty_height => 'Please enter your height.';
	@override String get invalid_height => 'Please enter a valid height.';
	@override String get weight => 'Weight (kg)';
	@override String get empty_weight => 'Please enter your weight.';
	@override String get invalid_weight => 'Please enter a valid weight.';
	@override String get gdpr_consent_title => 'GDPR Consent';
	@override String get gdpr_consent => 'I accept the GDPR consent form and the Privacy Policy (Required).';
	@override String get gdpr_consent_invalid => 'You must accept the GDPR consent form and the Privacy Policy.';
	@override String get marketing_consent => 'I agree to receive marketing communications (Optional).';
	@override String get avatar_choose => 'Choose your avatar';
	@override String get create_account => 'Create an account';
}

// Path: home
class _TranslationsHomeEn extends TranslationsHomeFr {
	_TranslationsHomeEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get error_loading => 'Error loading data.';
}

// Path: camera
class _TranslationsCameraEn extends TranslationsCameraFr {
	_TranslationsCameraEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String next_step_countdown({required Object seconds}) => 'Next step in ${seconds} seconds...';
	@override String get start_workout => 'Start';
}

// Path: notifications
class _TranslationsNotificationsEn extends TranslationsNotificationsFr {
	_TranslationsNotificationsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Notifications';
	@override String get read_all => 'Read all';
	@override String get empty => 'No notifications at the moment.';
	@override String get no_title => 'No title';
	@override String get no_body => 'No content';
}

// Path: profile
class _TranslationsProfileEn extends TranslationsProfileFr {
	_TranslationsProfileEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get follow => 'Follow';
	@override String get unfollow => 'Unfollow';
	@override String member_since({required Object date}) => 'Member since ${date}';
	@override String get followers => 'followers';
	@override String get following => 'following';
	@override String get cities_finished => 'Cities finished';
	@override String get nb_exercises_done_title => 'Number of exercises done';
	@override String get bpm_title => 'BPM (Beats per minute)';
	@override String get achievements => 'Achievements';
}

// Path: social
class _TranslationsSocialEn extends TranslationsSocialFr {
	_TranslationsSocialEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Social';
	@override String get no_posts_available => 'No posts available.';
	@override String get post_delete => 'Delete';
	@override String get post_report => 'Report';
}

// Path: gdpr_consent_form
class _TranslationsGdprConsentFormEn extends TranslationsGdprConsentFormFr {
	_TranslationsGdprConsentFormEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'GDPR Consent';
	@override String get description => 'In accordance with the General Data Protection Regulation (GDPR), we are required to inform you about the collection, use, and storage of your personal data.';
	@override late final _TranslationsGdprConsentFormDataCollectionEn data_collection = _TranslationsGdprConsentFormDataCollectionEn._(_root);
	@override late final _TranslationsGdprConsentFormDataUsageEn data_usage = _TranslationsGdprConsentFormDataUsageEn._(_root);
	@override late final _TranslationsGdprConsentFormDataStorageEn data_storage = _TranslationsGdprConsentFormDataStorageEn._(_root);
	@override late final _TranslationsGdprConsentFormMarketingUsageEn marketing_usage = _TranslationsGdprConsentFormMarketingUsageEn._(_root);
	@override String get accept_button => 'Continue';
}

// Path: workout_session_dialog
class _TranslationsWorkoutSessionDialogEn extends TranslationsWorkoutSessionDialogFr {
	_TranslationsWorkoutSessionDialogEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String session_title({required Object session_number}) => 'Session n°${session_number}';
	@override String get start_button => 'Start';
}

// Path: customization
class _TranslationsCustomizationEn extends TranslationsCustomizationFr {
	_TranslationsCustomizationEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'What look for this trip?';
	@override String get next_button => 'Next';
	@override String get confirm_button => 'Finish';
}

// Path: introduction
class _TranslationsIntroductionEn extends TranslationsIntroductionFr {
	_TranslationsIntroductionEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get text_1 => 'It all started with a simple desire: to get back into sports.';
	@override String get text_2 => 'To do that, the player chose a short hike in the forest, not suspecting it would mark the beginning of a long journey.';
	@override String get text_3 => 'Originally from Rome, he walks and walks… until he gets completely lost.';
	@override String get text_4 => 'While taking a break to catch his breath, a hamster suddenly appears in front of him.';
	@override String get text_5 => 'Not an ordinary hamster: this one talks! Intrigued, they strike up a conversation.';
	@override String get text_6 => 'Wait a minute… You\'re from Rome, right? Well buddy… you\'re closer to Paris than to your bed!';
	@override String get text_7 => 'Oh, that face you\'re making. I know, it\'s surprising. But hey, you’ve walked a lot! Gotta say, you’ve got a good stride.';
	@override String get text_8 => 'Listen, you\'re lucky you ran into me. I\'m a great explorer! Europe? I know it like the back of my paw. Well, I don’t have paws—pockets, I mean—but you get the idea.';
	@override String get text_9 => 'If you want, I can take you back to Rome. And while we\'re at it, we might as well teach you a few things. You like historical fun facts, right?';
}

// Path: mission
class _TranslationsMissionEn extends TranslationsMissionFr {
	_TranslationsMissionEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Mission';
}

// Path: shop
class _TranslationsShopEn extends TranslationsShopFr {
	_TranslationsShopEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Shop';
}

// Path: workout
class _TranslationsWorkoutEn extends TranslationsWorkoutFr {
	_TranslationsWorkoutEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get difficulty => 'Difficulty:';
	@override String get easy => 'Easy';
	@override String get medium => 'Medium';
	@override String get hard => 'Hard';
	@override String get stage_1_level_1 => 'Stage 1 - Level 1';
	@override String get stage_1_level_2 => 'Stage 1 - Level 2';
}

// Path: gdpr_consent_form.data_collection
class _TranslationsGdprConsentFormDataCollectionEn extends TranslationsGdprConsentFormDataCollectionFr {
	_TranslationsGdprConsentFormDataCollectionEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => '1. Data Collected\n';
	@override String get description => 'We collect the following data during registration:\n';
	@override String get essential_data => ' - Essential data: username, email address, password, date of birth to access the application.\n';
	@override String get optional_data => ' - Optional data: height, weight, goals, fitness level, physical characteristics to personalize your user experience.\n';
}

// Path: gdpr_consent_form.data_usage
class _TranslationsGdprConsentFormDataUsageEn extends TranslationsGdprConsentFormDataUsageFr {
	_TranslationsGdprConsentFormDataUsageEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => '2. Data Usage\n';
	@override String get description => 'We use your data for the following purposes:\n';
	@override String get purposes_1 => ' - To allow you to access the application and enjoy its features.\n';
	@override String get purposes_2 => ' - To personalize your user experience based on your goals and fitness level.\n';
	@override String get purposes_3 => ' - To comply with our legal and regulatory obligations.\n';
}

// Path: gdpr_consent_form.data_storage
class _TranslationsGdprConsentFormDataStorageEn extends TranslationsGdprConsentFormDataStorageFr {
	_TranslationsGdprConsentFormDataStorageEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => '3. Data Storage\n';
	@override String get description => 'Your data is securely stored on our servers and is not shared with third parties without your consent.\n';
}

// Path: gdpr_consent_form.marketing_usage
class _TranslationsGdprConsentFormMarketingUsageEn extends TranslationsGdprConsentFormMarketingUsageFr {
	_TranslationsGdprConsentFormMarketingUsageEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => '4. Marketing Usage\n';
	@override String get description => 'We use your data to send you marketing emails regarding promotions, events, or reminders related to the application.\n';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.
extension on TranslationsEn {
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
			case 'social.no_posts_available': return 'No posts available.';
			case 'social.post_delete': return 'Delete';
			case 'social.post_report': return 'Report';
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
			case 'customization.title': return 'What look for this trip?';
			case 'customization.next_button': return 'Next';
			case 'customization.confirm_button': return 'Finish';
			case 'introduction.text_1': return 'It all started with a simple desire: to get back into sports.';
			case 'introduction.text_2': return 'To do that, the player chose a short hike in the forest, not suspecting it would mark the beginning of a long journey.';
			case 'introduction.text_3': return 'Originally from Rome, he walks and walks… until he gets completely lost.';
			case 'introduction.text_4': return 'While taking a break to catch his breath, a hamster suddenly appears in front of him.';
			case 'introduction.text_5': return 'Not an ordinary hamster: this one talks! Intrigued, they strike up a conversation.';
			case 'introduction.text_6': return 'Wait a minute… You\'re from Rome, right? Well buddy… you\'re closer to Paris than to your bed!';
			case 'introduction.text_7': return 'Oh, that face you\'re making. I know, it\'s surprising. But hey, you’ve walked a lot! Gotta say, you’ve got a good stride.';
			case 'introduction.text_8': return 'Listen, you\'re lucky you ran into me. I\'m a great explorer! Europe? I know it like the back of my paw. Well, I don’t have paws—pockets, I mean—but you get the idea.';
			case 'introduction.text_9': return 'If you want, I can take you back to Rome. And while we\'re at it, we might as well teach you a few things. You like historical fun facts, right?';
			case 'mission.title': return 'Mission';
			case 'shop.title': return 'Shop';
			case 'workout.difficulty': return 'Difficulty:';
			case 'workout.easy': return 'Easy';
			case 'workout.medium': return 'Medium';
			case 'workout.hard': return 'Hard';
			case 'workout.stage_1_level_1': return 'Stage 1 - Level 1';
			case 'workout.stage_1_level_2': return 'Stage 1 - Level 2';
			default: return null;
		}
	}
}

