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
	late final TranslationsLoginEn login = TranslationsLoginEn._(_root);
	late final TranslationsRegisterEn register = TranslationsRegisterEn._(_root);
}

// Path: login
class TranslationsLoginEn {
	TranslationsLoginEn._(this._root);

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
	TranslationsRegisterEn._(this._root);

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
			default: return null;
		}
	}
}

