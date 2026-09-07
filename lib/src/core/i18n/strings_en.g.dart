///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	dynamic operator[](String key) => _meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final Translations$auth$en auth = Translations$auth$en._(_root);
	late final Translations$common$en common = Translations$common$en._(_root);
	late final Translations$failures$en failures = Translations$failures$en._(_root);
	late final Translations$fields$en fields = Translations$fields$en._(_root);
	late final Translations$navigation$en navigation = Translations$navigation$en._(_root);
	late final Translations$organizations$en organizations = Translations$organizations$en._(_root);
	late final Translations$sort$en sort = Translations$sort$en._(_root);
	late final Translations$validation$en validation = Translations$validation$en._(_root);
}

// Path: auth
class Translations$auth$en {
	Translations$auth$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Login'
	String get pageTitle => 'Login';

	/// en: 'Login'
	String get loginButton => 'Login';

	List<String> get loginAsAdminList => [
		'Not a user? ',
		'Login as Administrator',
	];
	List<String> get returnToLoginAsUser => [
		'Not an administrator? ',
		'Login as User',
	];

	/// en: 'Logged in successfully'
	String get loginSuccess => 'Logged in successfully';

	/// en: 'Logout'
	String get logoutButton => 'Logout';

	/// en: 'Are you sure you want to logout?'
	String get logoutConfirm => 'Are you sure you want to logout?';

	/// en: 'Forgot Password?'
	String get forgotPassword => 'Forgot Password?';

	/// en: 'Forgot Password'
	String get forgotPasswordTitle => 'Forgot Password';

	/// en: 'Enter your email address and we'll send you a link to reset your password.'
	String get forgotPasswordSubtitle => 'Enter your email address and we\'ll send you a link to reset your password.';

	/// en: 'Send Reset Link'
	String get sendResetLink => 'Send Reset Link';

	/// en: 'Back to Login'
	String get backToLogin => 'Back to Login';

	/// en: 'Check Your Email'
	String get checkEmail => 'Check Your Email';

	/// en: 'Password reset link has been sent to $email'
	String resetLinkSent({required Object email}) => 'Password reset link has been sent to ${email}';

	/// en: 'Sign in to continue'
	String get signInToContinue => 'Sign in to continue';

	/// en: 'Signing in...'
	String get signingIn => 'Signing in...';

	/// en: 'Verify your email'
	String get verifyEmailTitle => 'Verify your email';

	/// en: 'We sent a verification link to $email. Open the link, then tap Continue.'
	String verifyEmailSubtitle({required Object email}) => 'We sent a verification link to ${email}. Open the link, then tap Continue.';

	/// en: 'I've verified — Continue'
	String get verifyEmailContinue => 'I\'ve verified — Continue';

	/// en: 'Resend verification email'
	String get resendVerification => 'Resend verification email';

	/// en: 'Resend in ${seconds}s'
	String resendVerificationCooldown({required Object seconds}) => 'Resend in ${seconds}s';

	/// en: 'Verification email sent'
	String get verificationEmailSent => 'Verification email sent';

	/// en: 'Could not send verification email. Try again later.'
	String get verificationEmailFailed => 'Could not send verification email. Try again later.';

	/// en: 'Email is still unverified. Check your inbox and try again.'
	String get stillUnverified => 'Email is still unverified. Check your inbox and try again.';

	/// en: 'Confirming your email...'
	String get confirmingVerification => 'Confirming your email...';

	/// en: 'Email verified'
	String get verificationSuccess => 'Email verified';

	/// en: 'Verification link is invalid or expired.'
	String get verificationFailed => 'Verification link is invalid or expired.';

	/// en: 'Back to verify email'
	String get backToVerifyEmail => 'Back to verify email';
}

// Path: common
class Translations$common$en {
	Translations$common$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'HZN Gyms'
	String get appName => 'HZN Gyms';

	/// en: 'N/A'
	String get placeholderText => 'N/A';

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Delete'
	String get delete => 'Delete';

	/// en: 'Edit'
	String get edit => 'Edit';

	/// en: 'Add'
	String get add => 'Add';

	/// en: 'Close'
	String get close => 'Close';

	/// en: 'Confirm'
	String get confirm => 'Confirm';

	/// en: 'Submit'
	String get submit => 'Submit';

	/// en: 'Search'
	String get search => 'Search';

	/// en: 'Filter'
	String get filter => 'Filter';

	/// en: 'Refresh'
	String get refresh => 'Refresh';

	/// en: 'Loading...'
	String get loading => 'Loading...';

	/// en: 'Retry'
	String get retry => 'Retry';

	/// en: 'Yes'
	String get yes => 'Yes';

	/// en: 'No'
	String get no => 'No';

	/// en: 'OK'
	String get ok => 'OK';

	/// en: 'Done'
	String get done => 'Done';

	/// en: 'Reset'
	String get reset => 'Reset';

	/// en: 'Next'
	String get next => 'Next';

	/// en: 'Previous'
	String get previous => 'Previous';

	/// en: 'Back'
	String get back => 'Back';

	/// en: 'View All'
	String get viewAll => 'View All';

	/// en: 'See More'
	String get seeMore => 'See More';

	/// en: 'No results found'
	String get noResults => 'No results found';

	/// en: 'No items to display'
	String get emptyList => 'No items to display';

	/// en: 'Discard changes?'
	String get discardChanges => 'Discard changes?';

	/// en: 'You have unsaved changes. Are you sure you want to discard them?'
	String get discardChangesMessage => 'You have unsaved changes. Are you sure you want to discard them?';

	/// en: 'Discard'
	String get discard => 'Discard';

	/// en: 'Keep Editing'
	String get keepEditing => 'Keep Editing';

	/// en: 'Sort'
	String get sort => 'Sort';
}

// Path: failures
class Translations$failures$en {
	Translations$failures$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Something went wrong. Please try again.'
	String get generic => 'Something went wrong. Please try again.';

	/// en: 'Network error. Please check your connection.'
	String get networkError => 'Network error. Please check your connection.';

	/// en: 'Server error. Please try again later.'
	String get serverError => 'Server error. Please try again later.';

	/// en: 'You are not authorized to perform this action.'
	String get unauthorized => 'You are not authorized to perform this action.';

	/// en: 'Your session has expired. Please login again.'
	String get sessionExpired => 'Your session has expired. Please login again.';

	/// en: 'The requested resource was not found.'
	String get notFound => 'The requested resource was not found.';

	/// en: 'Invalid request. Please check your input.'
	String get badRequest => 'Invalid request. Please check your input.';

	/// en: 'A conflict occurred. The resource may already exist.'
	String get conflict => 'A conflict occurred. The resource may already exist.';

	/// en: 'Request timed out. Please try again.'
	String get timeout => 'Request timed out. Please try again.';

	/// en: 'No internet connection.'
	String get noInternet => 'No internet connection.';

	/// en: 'Invalid email or password.'
	String get invalidCredentials => 'Invalid email or password.';

	/// en: 'Your account has been disabled.'
	String get accountDisabled => 'Your account has been disabled.';

	/// en: 'Your account has not been verified.'
	String get accountNotVerified => 'Your account has not been verified.';

	/// en: 'Too many requests. Please wait a moment.'
	String get tooManyRequests => 'Too many requests. Please wait a moment.';
}

// Path: fields
class Translations$fields$en {
	Translations$fields$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Email'
	String get email => 'Email';

	/// en: 'Password'
	String get password => 'Password';

	/// en: 'Password confirmation'
	String get passwordConfirmation => 'Password confirmation';

	/// en: 'Name'
	String get name => 'Name';

	/// en: 'Contact Number'
	String get contactNumber => 'Contact Number';

	/// en: 'Address'
	String get address => 'Address';

	/// en: 'Search Fields'
	String get searchFields => 'Search Fields';

	/// en: 'Select which fields to include in your search'
	String get searchFieldsHint => 'Select which fields to include in your search';

	/// en: 'Required'
	String get requiredField => 'Required';

	/// en: 'At least one field required'
	String get atLeastOneRequired => 'At least one field required';

	/// en: 'Receipt Number'
	String get receiptNumber => 'Receipt Number';

	/// en: 'Description'
	String get descriptor => 'Description';

	/// en: 'Customer Name'
	String get customerName => 'Customer Name';

	/// en: 'Payment Reference'
	String get paymentRef => 'Payment Reference';

	/// en: 'Notes'
	String get notes => 'Notes';

	/// en: 'Description'
	String get description => 'Description';

	/// en: 'Category'
	String get category => 'Category';

	/// en: 'Status'
	String get statusFilters => 'Status';

	/// en: 'Show sales with these statuses'
	String get statusFiltersHint => 'Show sales with these statuses';

	/// en: 'Paid'
	String get statusPaid => 'Paid';

	/// en: 'Voided'
	String get statusVoided => 'Voided';

	/// en: 'Awaiting Payment'
	String get statusAwaitingPayment => 'Awaiting Payment';
}

// Path: navigation
class Translations$navigation$en {
	Translations$navigation$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Shortcuts'
	String get shortcuts => 'Shortcuts';

	/// en: 'Categories'
	String get categories => 'Categories';

	/// en: 'Show more'
	String get showMore => 'Show more';

	/// en: 'Show less'
	String get showLess => 'Show less';

	/// en: 'Operations'
	String get operations => 'Operations';

	/// en: 'People'
	String get people => 'People';

	/// en: 'Insights'
	String get insights => 'Insights';

	/// en: 'Administration'
	String get administration => 'Administration';

	/// en: 'Account'
	String get account => 'Account';

	/// en: 'Collapse navigation'
	String get collapseNav => 'Collapse navigation';

	/// en: 'Expand navigation'
	String get expandNav => 'Expand navigation';

	/// en: 'Dashboard'
	String get dashboard => 'Dashboard';

	/// en: 'Products'
	String get products => 'Products';

	/// en: 'Inventory'
	String get inventory => 'Inventory';

	/// en: 'Settings'
	String get settings => 'Settings';

	/// en: 'Profile'
	String get profile => 'Profile';

	/// en: 'Reports'
	String get reports => 'Reports';

	/// en: 'Users'
	String get users => 'Users';

	/// en: 'Roles'
	String get roles => 'Roles';

	/// en: 'Branches'
	String get branches => 'Branches';

	/// en: 'More'
	String get more => 'More';

	/// en: 'Cashier'
	String get sales => 'Cashier';

	/// en: 'Sales'
	String get salesHistory => 'Sales';

	/// en: 'Organization'
	String get organization => 'Organization';

	/// en: 'Organizations'
	String get organizations => 'Organizations';

	/// en: 'Check-In'
	String get checkIn => 'Check-In';

	/// en: 'Check-In Records'
	String get checkInRecords => 'Check-In Records';

	/// en: 'Members'
	String get members => 'Members';

	/// en: 'Memberships'
	String get memberships => 'Memberships';

	/// en: 'Outbox'
	String get outbox => 'Outbox';

	/// en: 'System'
	String get system => 'System';

	/// en: 'No Branch'
	String get noBranch => 'No Branch';

	/// en: 'All Branches'
	String get allBranches => 'All Branches';
}

// Path: organizations
class Translations$organizations$en {
	Translations$organizations$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Organizations'
	String get title => 'Organizations';

	/// en: 'Create Organization'
	String get create => 'Create Organization';

	/// en: 'Edit Organization'
	String get edit => 'Edit Organization';

	/// en: 'Name'
	String get name => 'Name';

	/// en: 'Slug'
	String get slug => 'Slug';

	/// en: 'Used for subdomain (e.g. slug.gyms.hznsystems.com)'
	String get slugHelper => 'Used for subdomain (e.g. slug.gyms.hznsystems.com)';

	/// en: 'Shown in app title/branding'
	String get displayNameHint => 'Shown in app title/branding';

	/// en: 'Lowercase letters, numbers, and hyphens only'
	String get slugValidationError => 'Lowercase letters, numbers, and hyphens only';

	/// en: 'Use hex format like #1E88E5'
	String get seedColorValidationError => 'Use hex format like #1E88E5';

	/// en: 'Theme accent color for this organization'
	String get seedColorHelper => 'Theme accent color for this organization';

	/// en: 'Custom color'
	String get seedColorCustom => 'Custom color';

	/// en: 'Pick color'
	String get seedColorPick => 'Pick color';

	/// en: 'Clear color'
	String get seedColorClear => 'Clear color';

	/// en: 'Preview'
	String get seedColorPreview => 'Preview';

	/// en: 'Sample'
	String get seedColorPreviewButton => 'Sample';

	/// en: 'Use hex format like #FFFFFF'
	String get splashColorValidationError => 'Use hex format like #FFFFFF';

	/// en: 'Display Name'
	String get displayName => 'Display Name';

	/// en: 'Seed Color'
	String get seedColor => 'Seed Color';

	/// en: 'Splash Background Color'
	String get splashBackgroundColor => 'Splash Background Color';

	/// en: 'Organization Logo'
	String get logo => 'Organization Logo';

	/// en: 'PNG or WebP with transparent background works best. Shown in the app sidebar and login screen.'
	String get logoHelper => 'PNG or WebP with transparent background works best. Shown in the app sidebar and login screen.';

	/// en: 'Upload logo'
	String get logoUpload => 'Upload logo';

	/// en: 'Replace logo'
	String get logoReplace => 'Replace logo';

	/// en: 'Remove'
	String get logoRemove => 'Remove';

	/// en: 'Subdomain'
	String get subdomain => 'Subdomain';

	/// en: 'DNS Status'
	String get dnsStatus => 'DNS Status';

	/// en: 'Retry DNS'
	String get retryDns => 'Retry DNS';

	/// en: 'DNS provisioning retried'
	String get retryDnsSuccess => 'DNS provisioning retried';

	/// en: 'Failed to retry DNS provisioning'
	String get retryDnsFailed => 'Failed to retry DNS provisioning';

	/// en: 'Organization created successfully'
	String get createSuccess => 'Organization created successfully';

	/// en: 'Organization updated successfully'
	String get updateSuccess => 'Organization updated successfully';

	/// en: 'Failed to save organization. Please try again.'
	String get saveFailed => 'Failed to save organization. Please try again.';

	/// en: 'No organizations found'
	String get emptyList => 'No organizations found';

	/// en: 'No Organization'
	String get noOrganization => 'No Organization';

	/// en: 'Switch Organization'
	String get switchOrganization => 'Switch Organization';

	/// en: 'Platform'
	String get platformTitle => 'Platform';

	/// en: 'Dashboard'
	String get platformDashboard => 'Dashboard';

	/// en: 'Enter tenant'
	String get enterTenant => 'Enter tenant';

	/// en: 'View all organizations'
	String get viewAllOrganizations => 'View all organizations';

	/// en: 'Recent organizations'
	String get recentOrganizations => 'Recent organizations';

	/// en: 'Total organizations'
	String get summaryTotal => 'Total organizations';

	/// en: 'Pending setup'
	String get summaryPendingSetup => 'Pending setup';

	/// en: 'DNS issues'
	String get summaryDnsIssues => 'DNS issues';

	/// en: 'Ready'
	String get summaryReady => 'Ready';

	/// en: 'Continue setup'
	String get continueSetup => 'Continue setup';

	/// en: 'Organization setup'
	String get setupTitle => 'Organization setup';

	/// en: 'Branding'
	String get setupStepBranding => 'Branding';

	/// en: 'DNS & subdomain'
	String get setupStepDns => 'DNS & subdomain';

	/// en: 'First branch'
	String get setupStepBranch => 'First branch';

	/// en: 'Org admin'
	String get setupStepAdminUser => 'Org admin';

	/// en: 'Membership plan'
	String get setupStepMembership => 'Membership plan';

	/// en: 'Product'
	String get setupStepProduct => 'Product';

	/// en: 'Review & complete'
	String get setupStepReview => 'Review & complete';

	/// en: 'Review organization name, slug, and branding colors.'
	String get setupBrandingHint => 'Review organization name, slug, and branding colors.';

	/// en: 'Continue'
	String get setupContinue => 'Continue';

	/// en: 'Create branch'
	String get setupCreateBranch => 'Create branch';

	/// en: 'Branch name'
	String get setupBranchName => 'Branch name';

	/// en: 'Branch code'
	String get setupBranchCode => 'Branch code';

	/// en: 'Failed to create branch'
	String get setupBranchFailed => 'Failed to create branch';

	/// en: 'Create a branch before adding an admin user.'
	String get setupBranchRequiredFirst => 'Create a branch before adding an admin user.';

	/// en: 'Admin name'
	String get setupAdminName => 'Admin name';

	/// en: 'Admin email (login)'
	String get setupAdminEmail => 'Admin email (login)';

	/// en: 'Password'
	String get setupAdminPassword => 'Password';

	/// en: 'Create admin user'
	String get setupCreateAdminUser => 'Create admin user';

	/// en: 'Failed to create admin user'
	String get setupAdminUserFailed => 'Failed to create admin user';

	/// en: 'No Admin role found. Seed roles in PocketBase first.'
	String get setupAdminRoleMissing => 'No Admin role found. Seed roles in PocketBase first.';

	/// en: 'Optional: create a membership plan for renewals and check-in.'
	String get setupMembershipHint => 'Optional: create a membership plan for renewals and check-in.';

	/// en: 'Create membership plan'
	String get setupCreateMembership => 'Create membership plan';

	/// en: 'Optional: create a product for the POS cashier.'
	String get setupProductHint => 'Optional: create a product for the POS cashier.';

	/// en: 'Create product'
	String get setupCreateProduct => 'Create product';

	/// en: 'Skip for now'
	String get setupSkipStep => 'Skip for now';

	/// en: 'Mark setup complete'
	String get setupMarkComplete => 'Mark setup complete';

	/// en: 'Staff login URL: $url'
	String setupLoginUrl({required Object url}) => 'Staff login URL: ${url}';

	/// en: 'Organization is ready'
	String get setupCompleteSuccess => 'Organization is ready';
}

// Path: sort
class Translations$sort$en {
	Translations$sort$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Sort By'
	String get sortBy => 'Sort By';

	/// en: 'Direction'
	String get direction => 'Direction';

	/// en: 'Ascending'
	String get ascending => 'Ascending';

	/// en: 'Descending'
	String get descending => 'Descending';

	/// en: 'Date Added'
	String get dateAdded => 'Date Added';

	/// en: 'Last Updated'
	String get lastUpdated => 'Last Updated';

	/// en: 'Date'
	String get date => 'Date';

	/// en: 'Amount'
	String get amount => 'Amount';

	/// en: 'Price'
	String get price => 'Price';

	/// en: 'Stock'
	String get stock => 'Stock';

	/// en: 'Expiration'
	String get expiration => 'Expiration';

	/// en: 'Status'
	String get status => 'Status';
}

// Path: validation
class Translations$validation$en {
	Translations$validation$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'This field is required'
	String get required => 'This field is required';

	/// en: 'Please enter a valid email address'
	String get invalidEmail => 'Please enter a valid email address';

	/// en: 'Please enter a valid phone number'
	String get invalidPhone => 'Please enter a valid phone number';

	/// en: 'Must be at least {min} characters'
	String get minLength => 'Must be at least {min} characters';

	/// en: 'Must be at most {max} characters'
	String get maxLength => 'Must be at most {max} characters';

	/// en: 'Passwords do not match'
	String get passwordMismatch => 'Passwords do not match';

	/// en: 'Please enter a valid number'
	String get invalidNumber => 'Please enter a valid number';

	/// en: 'Please enter a valid date'
	String get invalidDate => 'Please enter a valid date';

	/// en: 'Please enter a valid URL'
	String get invalidUrl => 'Please enter a valid URL';

	/// en: 'Value must be at least {min}'
	String get minValue => 'Value must be at least {min}';

	/// en: 'Value must be at most {max}'
	String get maxValue => 'Value must be at most {max}';

	/// en: 'Please enter a positive number'
	String get positiveNumber => 'Please enter a positive number';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'auth.pageTitle' => 'Login',
			'auth.loginButton' => 'Login',
			'auth.loginAsAdminList.0' => 'Not a user? ',
			'auth.loginAsAdminList.1' => 'Login as Administrator',
			'auth.returnToLoginAsUser.0' => 'Not an administrator? ',
			'auth.returnToLoginAsUser.1' => 'Login as User',
			'auth.loginSuccess' => 'Logged in successfully',
			'auth.logoutButton' => 'Logout',
			'auth.logoutConfirm' => 'Are you sure you want to logout?',
			'auth.forgotPassword' => 'Forgot Password?',
			'auth.forgotPasswordTitle' => 'Forgot Password',
			'auth.forgotPasswordSubtitle' => 'Enter your email address and we\'ll send you a link to reset your password.',
			'auth.sendResetLink' => 'Send Reset Link',
			'auth.backToLogin' => 'Back to Login',
			'auth.checkEmail' => 'Check Your Email',
			'auth.resetLinkSent' => ({required Object email}) => 'Password reset link has been sent to ${email}',
			'auth.signInToContinue' => 'Sign in to continue',
			'auth.signingIn' => 'Signing in...',
			'auth.verifyEmailTitle' => 'Verify your email',
			'auth.verifyEmailSubtitle' => ({required Object email}) => 'We sent a verification link to ${email}. Open the link, then tap Continue.',
			'auth.verifyEmailContinue' => 'I\'ve verified — Continue',
			'auth.resendVerification' => 'Resend verification email',
			'auth.resendVerificationCooldown' => ({required Object seconds}) => 'Resend in ${seconds}s',
			'auth.verificationEmailSent' => 'Verification email sent',
			'auth.verificationEmailFailed' => 'Could not send verification email. Try again later.',
			'auth.stillUnverified' => 'Email is still unverified. Check your inbox and try again.',
			'auth.confirmingVerification' => 'Confirming your email...',
			'auth.verificationSuccess' => 'Email verified',
			'auth.verificationFailed' => 'Verification link is invalid or expired.',
			'auth.backToVerifyEmail' => 'Back to verify email',
			'common.appName' => 'HZN Gyms',
			'common.placeholderText' => 'N/A',
			'common.save' => 'Save',
			'common.cancel' => 'Cancel',
			'common.delete' => 'Delete',
			'common.edit' => 'Edit',
			'common.add' => 'Add',
			'common.close' => 'Close',
			'common.confirm' => 'Confirm',
			'common.submit' => 'Submit',
			'common.search' => 'Search',
			'common.filter' => 'Filter',
			'common.refresh' => 'Refresh',
			'common.loading' => 'Loading...',
			'common.retry' => 'Retry',
			'common.yes' => 'Yes',
			'common.no' => 'No',
			'common.ok' => 'OK',
			'common.done' => 'Done',
			'common.reset' => 'Reset',
			'common.next' => 'Next',
			'common.previous' => 'Previous',
			'common.back' => 'Back',
			'common.viewAll' => 'View All',
			'common.seeMore' => 'See More',
			'common.noResults' => 'No results found',
			'common.emptyList' => 'No items to display',
			'common.discardChanges' => 'Discard changes?',
			'common.discardChangesMessage' => 'You have unsaved changes. Are you sure you want to discard them?',
			'common.discard' => 'Discard',
			'common.keepEditing' => 'Keep Editing',
			'common.sort' => 'Sort',
			'failures.generic' => 'Something went wrong. Please try again.',
			'failures.networkError' => 'Network error. Please check your connection.',
			'failures.serverError' => 'Server error. Please try again later.',
			'failures.unauthorized' => 'You are not authorized to perform this action.',
			'failures.sessionExpired' => 'Your session has expired. Please login again.',
			'failures.notFound' => 'The requested resource was not found.',
			'failures.badRequest' => 'Invalid request. Please check your input.',
			'failures.conflict' => 'A conflict occurred. The resource may already exist.',
			'failures.timeout' => 'Request timed out. Please try again.',
			'failures.noInternet' => 'No internet connection.',
			'failures.invalidCredentials' => 'Invalid email or password.',
			'failures.accountDisabled' => 'Your account has been disabled.',
			'failures.accountNotVerified' => 'Your account has not been verified.',
			'failures.tooManyRequests' => 'Too many requests. Please wait a moment.',
			'fields.email' => 'Email',
			'fields.password' => 'Password',
			'fields.passwordConfirmation' => 'Password confirmation',
			'fields.name' => 'Name',
			'fields.contactNumber' => 'Contact Number',
			'fields.address' => 'Address',
			'fields.searchFields' => 'Search Fields',
			'fields.searchFieldsHint' => 'Select which fields to include in your search',
			'fields.requiredField' => 'Required',
			'fields.atLeastOneRequired' => 'At least one field required',
			'fields.receiptNumber' => 'Receipt Number',
			'fields.descriptor' => 'Description',
			'fields.customerName' => 'Customer Name',
			'fields.paymentRef' => 'Payment Reference',
			'fields.notes' => 'Notes',
			'fields.description' => 'Description',
			'fields.category' => 'Category',
			'fields.statusFilters' => 'Status',
			'fields.statusFiltersHint' => 'Show sales with these statuses',
			'fields.statusPaid' => 'Paid',
			'fields.statusVoided' => 'Voided',
			'fields.statusAwaitingPayment' => 'Awaiting Payment',
			'navigation.shortcuts' => 'Shortcuts',
			'navigation.categories' => 'Categories',
			'navigation.showMore' => 'Show more',
			'navigation.showLess' => 'Show less',
			'navigation.operations' => 'Operations',
			'navigation.people' => 'People',
			'navigation.insights' => 'Insights',
			'navigation.administration' => 'Administration',
			'navigation.account' => 'Account',
			'navigation.collapseNav' => 'Collapse navigation',
			'navigation.expandNav' => 'Expand navigation',
			'navigation.dashboard' => 'Dashboard',
			'navigation.products' => 'Products',
			'navigation.inventory' => 'Inventory',
			'navigation.settings' => 'Settings',
			'navigation.profile' => 'Profile',
			'navigation.reports' => 'Reports',
			'navigation.users' => 'Users',
			'navigation.roles' => 'Roles',
			'navigation.branches' => 'Branches',
			'navigation.more' => 'More',
			'navigation.sales' => 'Cashier',
			'navigation.salesHistory' => 'Sales',
			'navigation.organization' => 'Organization',
			'navigation.organizations' => 'Organizations',
			'navigation.checkIn' => 'Check-In',
			'navigation.checkInRecords' => 'Check-In Records',
			'navigation.members' => 'Members',
			'navigation.memberships' => 'Memberships',
			'navigation.outbox' => 'Outbox',
			'navigation.system' => 'System',
			'navigation.noBranch' => 'No Branch',
			'navigation.allBranches' => 'All Branches',
			'organizations.title' => 'Organizations',
			'organizations.create' => 'Create Organization',
			'organizations.edit' => 'Edit Organization',
			'organizations.name' => 'Name',
			'organizations.slug' => 'Slug',
			'organizations.slugHelper' => 'Used for subdomain (e.g. slug.gyms.hznsystems.com)',
			'organizations.displayNameHint' => 'Shown in app title/branding',
			'organizations.slugValidationError' => 'Lowercase letters, numbers, and hyphens only',
			'organizations.seedColorValidationError' => 'Use hex format like #1E88E5',
			'organizations.seedColorHelper' => 'Theme accent color for this organization',
			'organizations.seedColorCustom' => 'Custom color',
			'organizations.seedColorPick' => 'Pick color',
			'organizations.seedColorClear' => 'Clear color',
			'organizations.seedColorPreview' => 'Preview',
			'organizations.seedColorPreviewButton' => 'Sample',
			'organizations.splashColorValidationError' => 'Use hex format like #FFFFFF',
			'organizations.displayName' => 'Display Name',
			'organizations.seedColor' => 'Seed Color',
			'organizations.splashBackgroundColor' => 'Splash Background Color',
			'organizations.logo' => 'Organization Logo',
			'organizations.logoHelper' => 'PNG or WebP with transparent background works best. Shown in the app sidebar and login screen.',
			'organizations.logoUpload' => 'Upload logo',
			'organizations.logoReplace' => 'Replace logo',
			'organizations.logoRemove' => 'Remove',
			'organizations.subdomain' => 'Subdomain',
			'organizations.dnsStatus' => 'DNS Status',
			'organizations.retryDns' => 'Retry DNS',
			'organizations.retryDnsSuccess' => 'DNS provisioning retried',
			'organizations.retryDnsFailed' => 'Failed to retry DNS provisioning',
			'organizations.createSuccess' => 'Organization created successfully',
			'organizations.updateSuccess' => 'Organization updated successfully',
			'organizations.saveFailed' => 'Failed to save organization. Please try again.',
			'organizations.emptyList' => 'No organizations found',
			'organizations.noOrganization' => 'No Organization',
			'organizations.switchOrganization' => 'Switch Organization',
			'organizations.platformTitle' => 'Platform',
			'organizations.platformDashboard' => 'Dashboard',
			'organizations.enterTenant' => 'Enter tenant',
			'organizations.viewAllOrganizations' => 'View all organizations',
			'organizations.recentOrganizations' => 'Recent organizations',
			'organizations.summaryTotal' => 'Total organizations',
			'organizations.summaryPendingSetup' => 'Pending setup',
			'organizations.summaryDnsIssues' => 'DNS issues',
			'organizations.summaryReady' => 'Ready',
			'organizations.continueSetup' => 'Continue setup',
			'organizations.setupTitle' => 'Organization setup',
			'organizations.setupStepBranding' => 'Branding',
			'organizations.setupStepDns' => 'DNS & subdomain',
			'organizations.setupStepBranch' => 'First branch',
			'organizations.setupStepAdminUser' => 'Org admin',
			'organizations.setupStepMembership' => 'Membership plan',
			'organizations.setupStepProduct' => 'Product',
			'organizations.setupStepReview' => 'Review & complete',
			'organizations.setupBrandingHint' => 'Review organization name, slug, and branding colors.',
			'organizations.setupContinue' => 'Continue',
			'organizations.setupCreateBranch' => 'Create branch',
			'organizations.setupBranchName' => 'Branch name',
			'organizations.setupBranchCode' => 'Branch code',
			'organizations.setupBranchFailed' => 'Failed to create branch',
			'organizations.setupBranchRequiredFirst' => 'Create a branch before adding an admin user.',
			'organizations.setupAdminName' => 'Admin name',
			'organizations.setupAdminEmail' => 'Admin email (login)',
			'organizations.setupAdminPassword' => 'Password',
			'organizations.setupCreateAdminUser' => 'Create admin user',
			'organizations.setupAdminUserFailed' => 'Failed to create admin user',
			'organizations.setupAdminRoleMissing' => 'No Admin role found. Seed roles in PocketBase first.',
			'organizations.setupMembershipHint' => 'Optional: create a membership plan for renewals and check-in.',
			'organizations.setupCreateMembership' => 'Create membership plan',
			'organizations.setupProductHint' => 'Optional: create a product for the POS cashier.',
			'organizations.setupCreateProduct' => 'Create product',
			'organizations.setupSkipStep' => 'Skip for now',
			'organizations.setupMarkComplete' => 'Mark setup complete',
			'organizations.setupLoginUrl' => ({required Object url}) => 'Staff login URL: ${url}',
			'organizations.setupCompleteSuccess' => 'Organization is ready',
			'sort.sortBy' => 'Sort By',
			'sort.direction' => 'Direction',
			'sort.ascending' => 'Ascending',
			'sort.descending' => 'Descending',
			'sort.dateAdded' => 'Date Added',
			'sort.lastUpdated' => 'Last Updated',
			'sort.date' => 'Date',
			'sort.amount' => 'Amount',
			'sort.price' => 'Price',
			'sort.stock' => 'Stock',
			'sort.expiration' => 'Expiration',
			'sort.status' => 'Status',
			'validation.required' => 'This field is required',
			'validation.invalidEmail' => 'Please enter a valid email address',
			'validation.invalidPhone' => 'Please enter a valid phone number',
			'validation.minLength' => 'Must be at least {min} characters',
			'validation.maxLength' => 'Must be at most {max} characters',
			'validation.passwordMismatch' => 'Passwords do not match',
			'validation.invalidNumber' => 'Please enter a valid number',
			'validation.invalidDate' => 'Please enter a valid date',
			'validation.invalidUrl' => 'Please enter a valid URL',
			'validation.minValue' => 'Value must be at least {min}',
			'validation.maxValue' => 'Value must be at most {max}',
			'validation.positiveNumber' => 'Please enter a positive number',
			_ => null,
		};
	}
}
