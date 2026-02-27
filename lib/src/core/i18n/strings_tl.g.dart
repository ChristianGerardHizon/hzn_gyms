///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsTl with BaseTranslations<AppLocale, Translations> implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsTl({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.tl,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <tl>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key);

	late final TranslationsTl _root = this; // ignore: unused_field

	@override 
	TranslationsTl $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsTl(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsAuthTl auth = _TranslationsAuthTl._(_root);
	@override late final _TranslationsCommonTl common = _TranslationsCommonTl._(_root);
	@override late final _TranslationsFailuresTl failures = _TranslationsFailuresTl._(_root);
	@override late final _TranslationsFieldsTl fields = _TranslationsFieldsTl._(_root);
	@override late final _TranslationsNavigationTl navigation = _TranslationsNavigationTl._(_root);
	@override late final _TranslationsSortTl sort = _TranslationsSortTl._(_root);
	@override late final _TranslationsValidationTl validation = _TranslationsValidationTl._(_root);
}

// Path: auth
class _TranslationsAuthTl implements TranslationsAuthEn {
	_TranslationsAuthTl._(this._root);

	final TranslationsTl _root; // ignore: unused_field

	// Translations
	@override String get pageTitle => 'Mag-log in';
	@override String get loginButton => 'Mag-log in';
	@override List<String> get loginAsAdminList => [
		'Hindi ka user?',
		'Mag-log in bilang Tagapamahala',
	];
	@override List<String> get returnToLoginAsUser => [
		'Hindi ka tagapamahala? ',
		'Mag-log in bilang User',
	];
	@override String get loginSuccess => 'Nagtagumpay sa pag-log in';
	@override String get logoutButton => 'Mag-logout';
	@override String get logoutConfirm => 'Sigurado ka bang gusto mong mag-logout?';
	@override String get forgotPassword => 'Nakalimutan ang Password?';
	@override String get forgotPasswordTitle => 'Nakalimutan ang Password';
	@override String get forgotPasswordSubtitle => 'Ilagay ang iyong email address at magpapadala kami ng link para i-reset ang iyong password.';
	@override String get sendResetLink => 'Ipadala ang Reset Link';
	@override String get backToLogin => 'Bumalik sa Login';
	@override String get checkEmail => 'Tingnan ang Iyong Email';
	@override String resetLinkSent({required Object email}) => 'Naipadala na ang password reset link sa ${email}';
	@override String get signInToContinue => 'Mag-sign in upang magpatuloy';
	@override String get signingIn => 'Nagsa-sign in...';
}

// Path: common
class _TranslationsCommonTl implements TranslationsCommonEn {
	_TranslationsCommonTl._(this._root);

	final TranslationsTl _root; // ignore: unused_field

	// Translations
	@override String get appName => 'Ebe Gym';
	@override String get placeholderText => 'N/A';
	@override String get save => 'I-save';
	@override String get cancel => 'Kanselahin';
	@override String get delete => 'Burahin';
	@override String get edit => 'I-edit';
	@override String get add => 'Dagdagan';
	@override String get close => 'Isara';
	@override String get confirm => 'Kumpirmahin';
	@override String get submit => 'Isumite';
	@override String get search => 'Maghanap';
	@override String get filter => 'I-filter';
	@override String get refresh => 'I-refresh';
	@override String get loading => 'Naglo-load...';
	@override String get retry => 'Subukang muli';
	@override String get yes => 'Oo';
	@override String get no => 'Hindi';
	@override String get ok => 'OK';
	@override String get done => 'Tapos na';
	@override String get reset => 'I-reset';
	@override String get next => 'Susunod';
	@override String get previous => 'Nakaraan';
	@override String get back => 'Bumalik';
	@override String get viewAll => 'Tingnan Lahat';
	@override String get seeMore => 'Tingnan ang Higit Pa';
	@override String get noResults => 'Walang nakitang resulta';
	@override String get emptyList => 'Walang ipapakita';
	@override String get discardChanges => 'I-discard ang mga pagbabago?';
	@override String get discardChangesMessage => 'Mayroon kang mga hindi pa nase-save na pagbabago. Sigurado ka bang gusto mong i-discard ang mga ito?';
	@override String get discard => 'I-discard';
	@override String get keepEditing => 'Magpatuloy sa Pag-edit';
	@override String get sort => 'Ayusin';
}

// Path: failures
class _TranslationsFailuresTl implements TranslationsFailuresEn {
	_TranslationsFailuresTl._(this._root);

	final TranslationsTl _root; // ignore: unused_field

	// Translations
	@override String get generic => 'May nangyaring mali. Pakisubukang muli.';
	@override String get networkError => 'Error sa network. Pakitingnan ang iyong koneksyon.';
	@override String get serverError => 'Error sa server. Pakisubukang muli mamaya.';
	@override String get unauthorized => 'Hindi ka awtorisadong gawin ang aksyong ito.';
	@override String get sessionExpired => 'Ang iyong session ay nag-expire na. Mag-login muli.';
	@override String get notFound => 'Hindi nahanap ang hiniling na resource.';
	@override String get badRequest => 'Di-wastong request. Pakitingnan ang iyong input.';
	@override String get conflict => 'May nangyaring conflict. Maaaring umiiral na ang resource.';
	@override String get timeout => 'Nag-timeout ang request. Pakisubukang muli.';
	@override String get noInternet => 'Walang koneksyon sa internet.';
	@override String get invalidCredentials => 'Di-wastong username o password.';
	@override String get accountDisabled => 'Ang iyong account ay na-disable.';
	@override String get accountNotVerified => 'Hindi pa na-verify ang iyong account.';
	@override String get tooManyRequests => 'Masyadong maraming request. Maghintay ng ilang sandali.';
}

// Path: fields
class _TranslationsFieldsTl implements TranslationsFieldsEn {
	_TranslationsFieldsTl._(this._root);

	final TranslationsTl _root; // ignore: unused_field

	// Translations
	@override String get email => 'Email';
	@override String get username => 'Username';
	@override String get password => 'Password';
	@override String get passwordConfirmation => 'Password confirmation';
	@override String get name => 'Pangalan';
	@override String get owner => 'May-ari';
	@override String get species => 'Uri ng Hayop';
	@override String get breed => 'Lahi';
	@override String get contactNumber => 'Contact Number';
	@override String get address => 'Address';
	@override String get searchFields => 'Mga Field na Hahanapin';
	@override String get searchFieldsHint => 'Piliin kung aling mga field ang isasama sa iyong paghahanap';
	@override String get requiredField => 'Kinakailangan';
	@override String get atLeastOneRequired => 'Kailangan ng kahit isang field';
	@override String get receiptNumber => 'Numero ng Resibo';
	@override String get customerName => 'Pangalan ng Customer';
	@override String get paymentRef => 'Reference ng Bayad';
	@override String get notes => 'Mga Tala';
	@override String get description => 'Paglalarawan';
	@override String get category => 'Kategorya';
}

// Path: navigation
class _TranslationsNavigationTl implements TranslationsNavigationEn {
	_TranslationsNavigationTl._(this._root);

	final TranslationsTl _root; // ignore: unused_field

	// Translations
	@override String get dashboard => 'Dashboard';
	@override String get products => 'Mga Produkto';
	@override String get inventory => 'Imbentaryo';
	@override String get settings => 'Mga Setting';
	@override String get profile => 'Profile';
	@override String get reports => 'Mga Ulat';
	@override String get users => 'Mga User';
	@override String get roles => 'Mga Tungkulin';
	@override String get branches => 'Mga Sangay';
	@override String get more => 'Iba Pa';
	@override String get sales => 'Cashier';
	@override String get salesHistory => 'Mga Benta';
	@override String get organization => 'Organisasyon';
	@override String get services => 'Mga Serbisyo';
	@override String get checkIn => 'Check-In';
	@override String get members => 'Mga Miyembro';
	@override String get memberships => 'Mga Membership';
	@override String get system => 'Sistema';
	@override String get account => 'Account';
	@override String get noBranch => 'Walang Sangay';
}

// Path: sort
class _TranslationsSortTl implements TranslationsSortEn {
	_TranslationsSortTl._(this._root);

	final TranslationsTl _root; // ignore: unused_field

	// Translations
	@override String get sortBy => 'Ayusin Ayon Sa';
	@override String get direction => 'Direksyon';
	@override String get ascending => 'Pataas';
	@override String get descending => 'Pababa';
	@override String get dateAdded => 'Petsa ng Pagdagdag';
	@override String get lastUpdated => 'Huling Na-update';
	@override String get date => 'Petsa';
	@override String get amount => 'Halaga';
	@override String get price => 'Presyo';
	@override String get stock => 'Stock';
	@override String get expiration => 'Expiration';
	@override String get status => 'Katayuan';
}

// Path: validation
class _TranslationsValidationTl implements TranslationsValidationEn {
	_TranslationsValidationTl._(this._root);

	final TranslationsTl _root; // ignore: unused_field

	// Translations
	@override String get required => 'Kinakailangan ang field na ito';
	@override String get invalidEmail => 'Maglagay ng valid na email address';
	@override String get invalidPhone => 'Maglagay ng valid na numero ng telepono';
	@override String get minLength => 'Dapat ay hindi bababa sa {min} na karakter';
	@override String get maxLength => 'Dapat ay hindi hihigit sa {max} na karakter';
	@override String get passwordMismatch => 'Hindi magkatugma ang mga password';
	@override String get invalidNumber => 'Maglagay ng valid na numero';
	@override String get invalidDate => 'Maglagay ng valid na petsa';
	@override String get invalidUrl => 'Maglagay ng valid na URL';
	@override String get minValue => 'Ang halaga ay dapat hindi bababa sa {min}';
	@override String get maxValue => 'Ang halaga ay dapat hindi hihigit sa {max}';
	@override String get positiveNumber => 'Maglagay ng positibong numero';
}

/// The flat map containing all translations for locale <tl>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsTl {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'auth.pageTitle' => 'Mag-log in',
			'auth.loginButton' => 'Mag-log in',
			'auth.loginAsAdminList.0' => 'Hindi ka user?',
			'auth.loginAsAdminList.1' => 'Mag-log in bilang Tagapamahala',
			'auth.returnToLoginAsUser.0' => 'Hindi ka tagapamahala? ',
			'auth.returnToLoginAsUser.1' => 'Mag-log in bilang User',
			'auth.loginSuccess' => 'Nagtagumpay sa pag-log in',
			'auth.logoutButton' => 'Mag-logout',
			'auth.logoutConfirm' => 'Sigurado ka bang gusto mong mag-logout?',
			'auth.forgotPassword' => 'Nakalimutan ang Password?',
			'auth.forgotPasswordTitle' => 'Nakalimutan ang Password',
			'auth.forgotPasswordSubtitle' => 'Ilagay ang iyong email address at magpapadala kami ng link para i-reset ang iyong password.',
			'auth.sendResetLink' => 'Ipadala ang Reset Link',
			'auth.backToLogin' => 'Bumalik sa Login',
			'auth.checkEmail' => 'Tingnan ang Iyong Email',
			'auth.resetLinkSent' => ({required Object email}) => 'Naipadala na ang password reset link sa ${email}',
			'auth.signInToContinue' => 'Mag-sign in upang magpatuloy',
			'auth.signingIn' => 'Nagsa-sign in...',
			'common.appName' => 'Ebe Gym',
			'common.placeholderText' => 'N/A',
			'common.save' => 'I-save',
			'common.cancel' => 'Kanselahin',
			'common.delete' => 'Burahin',
			'common.edit' => 'I-edit',
			'common.add' => 'Dagdagan',
			'common.close' => 'Isara',
			'common.confirm' => 'Kumpirmahin',
			'common.submit' => 'Isumite',
			'common.search' => 'Maghanap',
			'common.filter' => 'I-filter',
			'common.refresh' => 'I-refresh',
			'common.loading' => 'Naglo-load...',
			'common.retry' => 'Subukang muli',
			'common.yes' => 'Oo',
			'common.no' => 'Hindi',
			'common.ok' => 'OK',
			'common.done' => 'Tapos na',
			'common.reset' => 'I-reset',
			'common.next' => 'Susunod',
			'common.previous' => 'Nakaraan',
			'common.back' => 'Bumalik',
			'common.viewAll' => 'Tingnan Lahat',
			'common.seeMore' => 'Tingnan ang Higit Pa',
			'common.noResults' => 'Walang nakitang resulta',
			'common.emptyList' => 'Walang ipapakita',
			'common.discardChanges' => 'I-discard ang mga pagbabago?',
			'common.discardChangesMessage' => 'Mayroon kang mga hindi pa nase-save na pagbabago. Sigurado ka bang gusto mong i-discard ang mga ito?',
			'common.discard' => 'I-discard',
			'common.keepEditing' => 'Magpatuloy sa Pag-edit',
			'common.sort' => 'Ayusin',
			'failures.generic' => 'May nangyaring mali. Pakisubukang muli.',
			'failures.networkError' => 'Error sa network. Pakitingnan ang iyong koneksyon.',
			'failures.serverError' => 'Error sa server. Pakisubukang muli mamaya.',
			'failures.unauthorized' => 'Hindi ka awtorisadong gawin ang aksyong ito.',
			'failures.sessionExpired' => 'Ang iyong session ay nag-expire na. Mag-login muli.',
			'failures.notFound' => 'Hindi nahanap ang hiniling na resource.',
			'failures.badRequest' => 'Di-wastong request. Pakitingnan ang iyong input.',
			'failures.conflict' => 'May nangyaring conflict. Maaaring umiiral na ang resource.',
			'failures.timeout' => 'Nag-timeout ang request. Pakisubukang muli.',
			'failures.noInternet' => 'Walang koneksyon sa internet.',
			'failures.invalidCredentials' => 'Di-wastong username o password.',
			'failures.accountDisabled' => 'Ang iyong account ay na-disable.',
			'failures.accountNotVerified' => 'Hindi pa na-verify ang iyong account.',
			'failures.tooManyRequests' => 'Masyadong maraming request. Maghintay ng ilang sandali.',
			'fields.email' => 'Email',
			'fields.username' => 'Username',
			'fields.password' => 'Password',
			'fields.passwordConfirmation' => 'Password confirmation',
			'fields.name' => 'Pangalan',
			'fields.owner' => 'May-ari',
			'fields.species' => 'Uri ng Hayop',
			'fields.breed' => 'Lahi',
			'fields.contactNumber' => 'Contact Number',
			'fields.address' => 'Address',
			'fields.searchFields' => 'Mga Field na Hahanapin',
			'fields.searchFieldsHint' => 'Piliin kung aling mga field ang isasama sa iyong paghahanap',
			'fields.requiredField' => 'Kinakailangan',
			'fields.atLeastOneRequired' => 'Kailangan ng kahit isang field',
			'fields.receiptNumber' => 'Numero ng Resibo',
			'fields.customerName' => 'Pangalan ng Customer',
			'fields.paymentRef' => 'Reference ng Bayad',
			'fields.notes' => 'Mga Tala',
			'fields.description' => 'Paglalarawan',
			'fields.category' => 'Kategorya',
			'navigation.dashboard' => 'Dashboard',
			'navigation.products' => 'Mga Produkto',
			'navigation.inventory' => 'Imbentaryo',
			'navigation.settings' => 'Mga Setting',
			'navigation.profile' => 'Profile',
			'navigation.reports' => 'Mga Ulat',
			'navigation.users' => 'Mga User',
			'navigation.roles' => 'Mga Tungkulin',
			'navigation.branches' => 'Mga Sangay',
			'navigation.more' => 'Iba Pa',
			'navigation.sales' => 'Cashier',
			'navigation.salesHistory' => 'Mga Benta',
			'navigation.organization' => 'Organisasyon',
			'navigation.services' => 'Mga Serbisyo',
			'navigation.checkIn' => 'Check-In',
			'navigation.members' => 'Mga Miyembro',
			'navigation.memberships' => 'Mga Membership',
			'navigation.system' => 'Sistema',
			'navigation.account' => 'Account',
			'navigation.noBranch' => 'Walang Sangay',
			'sort.sortBy' => 'Ayusin Ayon Sa',
			'sort.direction' => 'Direksyon',
			'sort.ascending' => 'Pataas',
			'sort.descending' => 'Pababa',
			'sort.dateAdded' => 'Petsa ng Pagdagdag',
			'sort.lastUpdated' => 'Huling Na-update',
			'sort.date' => 'Petsa',
			'sort.amount' => 'Halaga',
			'sort.price' => 'Presyo',
			'sort.stock' => 'Stock',
			'sort.expiration' => 'Expiration',
			'sort.status' => 'Katayuan',
			'validation.required' => 'Kinakailangan ang field na ito',
			'validation.invalidEmail' => 'Maglagay ng valid na email address',
			'validation.invalidPhone' => 'Maglagay ng valid na numero ng telepono',
			'validation.minLength' => 'Dapat ay hindi bababa sa {min} na karakter',
			'validation.maxLength' => 'Dapat ay hindi hihigit sa {max} na karakter',
			'validation.passwordMismatch' => 'Hindi magkatugma ang mga password',
			'validation.invalidNumber' => 'Maglagay ng valid na numero',
			'validation.invalidDate' => 'Maglagay ng valid na petsa',
			'validation.invalidUrl' => 'Maglagay ng valid na URL',
			'validation.minValue' => 'Ang halaga ay dapat hindi bababa sa {min}',
			'validation.maxValue' => 'Ang halaga ay dapat hindi hihigit sa {max}',
			'validation.positiveNumber' => 'Maglagay ng positibong numero',
			_ => null,
		};
	}
}
