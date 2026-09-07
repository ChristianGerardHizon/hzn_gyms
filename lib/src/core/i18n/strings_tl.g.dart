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
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.tl,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <tl>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key);

	late final TranslationsTl _root = this; // ignore: unused_field

	@override 
	TranslationsTl $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsTl(meta: meta ?? this.$meta);

	// Translations
	@override late final _Translations$auth$tl auth = _Translations$auth$tl._(_root);
	@override late final _Translations$common$tl common = _Translations$common$tl._(_root);
	@override late final _Translations$failures$tl failures = _Translations$failures$tl._(_root);
	@override late final _Translations$fields$tl fields = _Translations$fields$tl._(_root);
	@override late final _Translations$navigation$tl navigation = _Translations$navigation$tl._(_root);
	@override late final _Translations$organizations$tl organizations = _Translations$organizations$tl._(_root);
	@override late final _Translations$sort$tl sort = _Translations$sort$tl._(_root);
	@override late final _Translations$validation$tl validation = _Translations$validation$tl._(_root);
}

// Path: auth
class _Translations$auth$tl implements Translations$auth$en {
	_Translations$auth$tl._(this._root);

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
class _Translations$common$tl implements Translations$common$en {
	_Translations$common$tl._(this._root);

	final TranslationsTl _root; // ignore: unused_field

	// Translations
	@override String get appName => 'HZN Gyms';
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
class _Translations$failures$tl implements Translations$failures$en {
	_Translations$failures$tl._(this._root);

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
	@override String get invalidCredentials => 'Di-wastong email o password.';
	@override String get accountDisabled => 'Ang iyong account ay na-disable.';
	@override String get accountNotVerified => 'Hindi pa na-verify ang iyong account.';
	@override String get tooManyRequests => 'Masyadong maraming request. Maghintay ng ilang sandali.';
}

// Path: fields
class _Translations$fields$tl implements Translations$fields$en {
	_Translations$fields$tl._(this._root);

	final TranslationsTl _root; // ignore: unused_field

	// Translations
	@override String get email => 'Email';
	@override String get username => 'Username';
	@override String get password => 'Password';
	@override String get passwordConfirmation => 'Password confirmation';
	@override String get name => 'Pangalan';
	@override String get contactNumber => 'Contact Number';
	@override String get address => 'Address';
	@override String get searchFields => 'Mga Field na Hahanapin';
	@override String get searchFieldsHint => 'Piliin kung aling mga field ang isasama sa iyong paghahanap';
	@override String get requiredField => 'Kinakailangan';
	@override String get atLeastOneRequired => 'Kailangan ng kahit isang field';
	@override String get receiptNumber => 'Numero ng Resibo';
	@override String get descriptor => 'Paglalarawan';
	@override String get customerName => 'Pangalan ng Customer';
	@override String get paymentRef => 'Reference ng Bayad';
	@override String get notes => 'Mga Tala';
	@override String get description => 'Paglalarawan';
	@override String get category => 'Kategorya';
	@override String get statusFilters => 'Status';
	@override String get statusFiltersHint => 'Ipakita ang mga benta na may mga status na ito';
	@override String get statusPaid => 'Bayad';
	@override String get statusVoided => 'Voided';
	@override String get statusAwaitingPayment => 'Naghihintay ng Bayad';
}

// Path: navigation
class _Translations$navigation$tl implements Translations$navigation$en {
	_Translations$navigation$tl._(this._root);

	final TranslationsTl _root; // ignore: unused_field

	// Translations
	@override String get shortcuts => 'Mga Shortcut';
	@override String get categories => 'Mga Kategorya';
	@override String get showMore => 'Magpakita pa';
	@override String get showLess => 'Magpakita ng mas kaunti';
	@override String get operations => 'Operasyon';
	@override String get people => 'Mga Tao';
	@override String get insights => 'Mga Insight';
	@override String get administration => 'Administrasyon';
	@override String get account => 'Account';
	@override String get collapseNav => 'I-collapse ang navigation';
	@override String get expandNav => 'I-expand ang navigation';
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
	@override String get organizations => 'Mga Organisasyon';
	@override String get checkIn => 'Check-In';
	@override String get checkInRecords => 'Kasaysayan ng Check-In';
	@override String get members => 'Mga Miyembro';
	@override String get memberships => 'Mga Membership';
	@override String get outbox => 'Outbox';
	@override String get system => 'Sistema';
	@override String get noBranch => 'Walang Sangay';
	@override String get allBranches => 'Lahat ng Sangay';
}

// Path: organizations
class _Translations$organizations$tl implements Translations$organizations$en {
	_Translations$organizations$tl._(this._root);

	final TranslationsTl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Mga Organisasyon';
	@override String get create => 'Gumawa ng Organisasyon';
	@override String get edit => 'I-edit ang Organisasyon';
	@override String get name => 'Pangalan';
	@override String get slug => 'Slug';
	@override String get slugHelper => 'URL-safe na identifier (lowercase letters, numbers, hyphens)';
	@override String get displayNameHint => 'Ipinapakita sa app title/branding';
	@override String get slugValidationError => 'Lowercase letters, numbers, and hyphens lamang';
	@override String get seedColorValidationError => 'Gumamit ng hex format tulad ng #1E88E5';
	@override String get seedColorHelper => 'Theme accent color para sa organisasyong ito';
	@override String get seedColorCustom => 'Custom na kulay';
	@override String get seedColorPick => 'Pumili ng kulay';
	@override String get seedColorClear => 'Alisin ang kulay';
	@override String get seedColorPreview => 'Preview';
	@override String get seedColorPreviewButton => 'Sample';
	@override String get splashColorValidationError => 'Gumamit ng hex format tulad ng #FFFFFF';
	@override String get displayName => 'Display Name';
	@override String get seedColor => 'Seed Color';
	@override String get splashBackgroundColor => 'Splash Background Color';
	@override String get logo => 'Organization Logo';
	@override String get logoHelper => 'Pinakamabuti ang PNG o WebP na may transparent background. Ipapakita sa sidebar at login screen.';
	@override String get logoUpload => 'Mag-upload ng logo';
	@override String get logoReplace => 'Palitan ang logo';
	@override String get logoRemove => 'Alisin';
	@override String get createSuccess => 'Matagumpay na nagawa ang organisasyon';
	@override String get updateSuccess => 'Matagumpay na na-update ang organisasyon';
	@override String get saveFailed => 'Hindi na-save ang organisasyon. Pakisubukang muli.';
	@override String get emptyList => 'Walang nahanap na organisasyon';
	@override String get noOrganization => 'Walang Organisasyon';
	@override String get switchOrganization => 'Palitan ang Organisasyon';
	@override String get platformTitle => 'Platform';
	@override String get platformDashboard => 'Dashboard';
	@override String get enterTenant => 'Pumasok sa tenant';
	@override String get viewAllOrganizations => 'Tingnan lahat ng organisasyon';
	@override String get recentOrganizations => 'Kamakailang organisasyon';
	@override String get summaryTotal => 'Kabuuang organisasyon';
	@override String get summaryPendingSetup => 'Nakabinbing setup';
	@override String get summaryReady => 'Handa na';
	@override String get continueSetup => 'Ipagpatuloy ang setup';
	@override String get setupTitle => 'Setup ng organisasyon';
	@override String get setupStepBranding => 'Branding';
	@override String get setupStepBranch => 'Unang branch';
	@override String get setupStepAdminUser => 'Org admin';
	@override String get setupStepMembership => 'Membership plan';
	@override String get setupStepProduct => 'Produkto';
	@override String get setupStepReview => 'Review at kumpletuhin';
	@override String get setupBrandingHint => 'Suriin ang pangalan, slug, at branding colors.';
	@override String get setupContinue => 'Magpatuloy';
	@override String get setupCreateBranch => 'Gumawa ng branch';
	@override String get setupBranchName => 'Pangalan ng branch';
	@override String get setupBranchCode => 'Code ng branch';
	@override String get setupBranchFailed => 'Hindi nagawa ang branch';
	@override String get setupBranchRequiredFirst => 'Gumawa muna ng branch bago magdagdag ng admin user.';
	@override String get setupAdminName => 'Pangalan ng admin';
	@override String get setupAdminEmail => 'Email ng admin (login)';
	@override String get setupAdminUsername => 'Username';
	@override String get setupAdminPassword => 'Password';
	@override String get setupCreateAdminUser => 'Gumawa ng admin user';
	@override String get setupAdminUserFailed => 'Hindi nagawa ang admin user';
	@override String get setupAdminRoleMissing => 'Walang Admin role. I-seed muna ang roles sa PocketBase.';
	@override String get setupMembershipHint => 'Opsyonal: gumawa ng membership plan.';
	@override String get setupCreateMembership => 'Gumawa ng membership plan';
	@override String get setupProductHint => 'Opsyonal: gumawa ng produkto para sa POS.';
	@override String get setupCreateProduct => 'Gumawa ng produkto';
	@override String get setupSkipStep => 'Laktawan muna';
	@override String get setupMarkComplete => 'Markahan bilang kumpleto';
	@override String get setupCompleteSuccess => 'Handa na ang organisasyon';
}

// Path: sort
class _Translations$sort$tl implements Translations$sort$en {
	_Translations$sort$tl._(this._root);

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
class _Translations$validation$tl implements Translations$validation$en {
	_Translations$validation$tl._(this._root);

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
			'common.appName' => 'HZN Gyms',
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
			'failures.invalidCredentials' => 'Di-wastong email o password.',
			'failures.accountDisabled' => 'Ang iyong account ay na-disable.',
			'failures.accountNotVerified' => 'Hindi pa na-verify ang iyong account.',
			'failures.tooManyRequests' => 'Masyadong maraming request. Maghintay ng ilang sandali.',
			'fields.email' => 'Email',
			'fields.username' => 'Username',
			'fields.password' => 'Password',
			'fields.passwordConfirmation' => 'Password confirmation',
			'fields.name' => 'Pangalan',
			'fields.contactNumber' => 'Contact Number',
			'fields.address' => 'Address',
			'fields.searchFields' => 'Mga Field na Hahanapin',
			'fields.searchFieldsHint' => 'Piliin kung aling mga field ang isasama sa iyong paghahanap',
			'fields.requiredField' => 'Kinakailangan',
			'fields.atLeastOneRequired' => 'Kailangan ng kahit isang field',
			'fields.receiptNumber' => 'Numero ng Resibo',
			'fields.descriptor' => 'Paglalarawan',
			'fields.customerName' => 'Pangalan ng Customer',
			'fields.paymentRef' => 'Reference ng Bayad',
			'fields.notes' => 'Mga Tala',
			'fields.description' => 'Paglalarawan',
			'fields.category' => 'Kategorya',
			'fields.statusFilters' => 'Status',
			'fields.statusFiltersHint' => 'Ipakita ang mga benta na may mga status na ito',
			'fields.statusPaid' => 'Bayad',
			'fields.statusVoided' => 'Voided',
			'fields.statusAwaitingPayment' => 'Naghihintay ng Bayad',
			'navigation.shortcuts' => 'Mga Shortcut',
			'navigation.categories' => 'Mga Kategorya',
			'navigation.showMore' => 'Magpakita pa',
			'navigation.showLess' => 'Magpakita ng mas kaunti',
			'navigation.operations' => 'Operasyon',
			'navigation.people' => 'Mga Tao',
			'navigation.insights' => 'Mga Insight',
			'navigation.administration' => 'Administrasyon',
			'navigation.account' => 'Account',
			'navigation.collapseNav' => 'I-collapse ang navigation',
			'navigation.expandNav' => 'I-expand ang navigation',
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
			'navigation.organizations' => 'Mga Organisasyon',
			'navigation.checkIn' => 'Check-In',
			'navigation.checkInRecords' => 'Kasaysayan ng Check-In',
			'navigation.members' => 'Mga Miyembro',
			'navigation.memberships' => 'Mga Membership',
			'navigation.outbox' => 'Outbox',
			'navigation.system' => 'Sistema',
			'navigation.noBranch' => 'Walang Sangay',
			'navigation.allBranches' => 'Lahat ng Sangay',
			'organizations.title' => 'Mga Organisasyon',
			'organizations.create' => 'Gumawa ng Organisasyon',
			'organizations.edit' => 'I-edit ang Organisasyon',
			'organizations.name' => 'Pangalan',
			'organizations.slug' => 'Slug',
			'organizations.slugHelper' => 'URL-safe na identifier (lowercase letters, numbers, hyphens)',
			'organizations.displayNameHint' => 'Ipinapakita sa app title/branding',
			'organizations.slugValidationError' => 'Lowercase letters, numbers, and hyphens lamang',
			'organizations.seedColorValidationError' => 'Gumamit ng hex format tulad ng #1E88E5',
			'organizations.seedColorHelper' => 'Theme accent color para sa organisasyong ito',
			'organizations.seedColorCustom' => 'Custom na kulay',
			'organizations.seedColorPick' => 'Pumili ng kulay',
			'organizations.seedColorClear' => 'Alisin ang kulay',
			'organizations.seedColorPreview' => 'Preview',
			'organizations.seedColorPreviewButton' => 'Sample',
			'organizations.splashColorValidationError' => 'Gumamit ng hex format tulad ng #FFFFFF',
			'organizations.displayName' => 'Display Name',
			'organizations.seedColor' => 'Seed Color',
			'organizations.splashBackgroundColor' => 'Splash Background Color',
			'organizations.logo' => 'Organization Logo',
			'organizations.logoHelper' => 'Pinakamabuti ang PNG o WebP na may transparent background. Ipapakita sa sidebar at login screen.',
			'organizations.logoUpload' => 'Mag-upload ng logo',
			'organizations.logoReplace' => 'Palitan ang logo',
			'organizations.logoRemove' => 'Alisin',
			'organizations.createSuccess' => 'Matagumpay na nagawa ang organisasyon',
			'organizations.updateSuccess' => 'Matagumpay na na-update ang organisasyon',
			'organizations.saveFailed' => 'Hindi na-save ang organisasyon. Pakisubukang muli.',
			'organizations.emptyList' => 'Walang nahanap na organisasyon',
			'organizations.noOrganization' => 'Walang Organisasyon',
			'organizations.switchOrganization' => 'Palitan ang Organisasyon',
			'organizations.platformTitle' => 'Platform',
			'organizations.platformDashboard' => 'Dashboard',
			'organizations.enterTenant' => 'Pumasok sa tenant',
			'organizations.viewAllOrganizations' => 'Tingnan lahat ng organisasyon',
			'organizations.recentOrganizations' => 'Kamakailang organisasyon',
			'organizations.summaryTotal' => 'Kabuuang organisasyon',
			'organizations.summaryPendingSetup' => 'Nakabinbing setup',
			'organizations.summaryReady' => 'Handa na',
			'organizations.continueSetup' => 'Ipagpatuloy ang setup',
			'organizations.setupTitle' => 'Setup ng organisasyon',
			'organizations.setupStepBranding' => 'Branding',
			'organizations.setupStepBranch' => 'Unang branch',
			'organizations.setupStepAdminUser' => 'Org admin',
			'organizations.setupStepMembership' => 'Membership plan',
			'organizations.setupStepProduct' => 'Produkto',
			'organizations.setupStepReview' => 'Review at kumpletuhin',
			'organizations.setupBrandingHint' => 'Suriin ang pangalan, slug, at branding colors.',
			'organizations.setupContinue' => 'Magpatuloy',
			'organizations.setupCreateBranch' => 'Gumawa ng branch',
			'organizations.setupBranchName' => 'Pangalan ng branch',
			'organizations.setupBranchCode' => 'Code ng branch',
			'organizations.setupBranchFailed' => 'Hindi nagawa ang branch',
			'organizations.setupBranchRequiredFirst' => 'Gumawa muna ng branch bago magdagdag ng admin user.',
			'organizations.setupAdminName' => 'Pangalan ng admin',
			'organizations.setupAdminEmail' => 'Email ng admin (login)',
			'organizations.setupAdminUsername' => 'Username',
			'organizations.setupAdminPassword' => 'Password',
			'organizations.setupCreateAdminUser' => 'Gumawa ng admin user',
			'organizations.setupAdminUserFailed' => 'Hindi nagawa ang admin user',
			'organizations.setupAdminRoleMissing' => 'Walang Admin role. I-seed muna ang roles sa PocketBase.',
			'organizations.setupMembershipHint' => 'Opsyonal: gumawa ng membership plan.',
			'organizations.setupCreateMembership' => 'Gumawa ng membership plan',
			'organizations.setupProductHint' => 'Opsyonal: gumawa ng produkto para sa POS.',
			'organizations.setupCreateProduct' => 'Gumawa ng produkto',
			'organizations.setupSkipStep' => 'Laktawan muna',
			'organizations.setupMarkComplete' => 'Markahan bilang kumpleto',
			'organizations.setupCompleteSuccess' => 'Handa na ang organisasyon',
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
