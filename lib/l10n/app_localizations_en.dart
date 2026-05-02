// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'E-Wallet';

  @override
  String get profileAndSettings => 'Profile & Settings';

  @override
  String get sectionWalletFinance => 'Wallet & Finance';

  @override
  String get sectionSecurity => 'Security';

  @override
  String get sectionPreferences => 'Preferences';

  @override
  String get preferencesCurrency => 'Currency';

  @override
  String get preferencesAppearance => 'Appearance';

  @override
  String get appearanceDark => 'Dark Mode';

  @override
  String get appearanceLight => 'Light Mode';

  @override
  String get preferencesNotifications => 'Notifications';

  @override
  String get preferencesNotificationsSubtitle => 'Spending & budget alerts';

  @override
  String get preferencesLanguage => 'Language';

  @override
  String get securityPersonalInfo => 'Personal Info';

  @override
  String get securityPersonalInfoSubtitle => 'Name, phone, country/city';

  @override
  String get securityPasswordPin => 'Password & PIN';

  @override
  String get securityPasswordPinSubtitle => 'Update app lock & transaction PIN';

  @override
  String get securityBiometric => 'Biometric Login';

  @override
  String get securityBiometricSubtitle => 'Face ID / Touch ID';

  @override
  String get security2fa => 'Two-Factor Authentication (2FA)';

  @override
  String get security2faSubtitle => 'SMS or authenticator app';

  @override
  String get securityDailyLimits => 'Daily Transaction Limits';

  @override
  String get securityDailyLimitsSubtitle =>
      'Set a maximum daily spend to trigger dynamic alerts';

  @override
  String get coreMyWallets => 'My Wallets / Accounts';

  @override
  String get coreMyWalletsSubtitle => 'Manage cash, credit cards…';

  @override
  String get coreAdjustBalance => 'Adjust Balance';

  @override
  String get coreBudget => 'Monthly Budget Limit';

  @override
  String get coreBudgetSubtitle => 'Set overall spending limits';

  @override
  String get coreCategories => 'Categories';

  @override
  String get coreCategoriesSubtitle => 'Manage income and expense categories';

  @override
  String get coreExport => 'Export Data';

  @override
  String get coreExportSubtitle => 'Download history as CSV/PDF';

  @override
  String get supportHelp => 'Help Center & FAQ';

  @override
  String get supportTerms => 'Terms of Service & Privacy';

  @override
  String get supportLogOut => 'Log Out';

  @override
  String get supportLogOutConfirmTitle => 'Log Out';

  @override
  String get supportLogOutConfirmMessage => 'Are you sure you want to log out?';

  @override
  String get supportDeleteAccount => 'Delete Account';

  @override
  String get supportDeleteConfirmTitle => 'Delete Account';

  @override
  String get supportDeleteConfirmMessage =>
      'This action is permanent and cannot be undone. All your data will be erased.';

  @override
  String get supportVersion => 'v1.0.0 (Build 12)';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonDone => 'Done';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get userVerifiedAccount => 'Verified Account';

  @override
  String get photoPickerSoon => 'Photo picker coming soon';

  @override
  String get homeLoading => 'Loading…';

  @override
  String get greetingGoodMorning => 'Good Morning';

  @override
  String get greetingGoodAfternoon => 'Good Afternoon';

  @override
  String get greetingGoodEvening => 'Good Evening';

  @override
  String get greetingGoodNight => 'Good Night';

  @override
  String get defaultUserFirstName => 'User';

  @override
  String get subscriptionsTab => 'Subscriptions';

  @override
  String get savingGoalsTab => 'Saving Goals';

  @override
  String get subscriptionsTotalMonthlyCost => 'Total Monthly Cost';

  @override
  String get savingGoalsCostTitle => 'Saving Goals Cost';

  @override
  String get addButtonLabel => 'Add';

  @override
  String get languagePickerTitle => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get comingSoonSnack => 'Coming soon';

  @override
  String get walletComingSoonTitle => 'Coming Soon';

  @override
  String get walletScreenTitle => 'Wallet';

  @override
  String get authErrServerUnreachable =>
      'Unable to reach the server. Check your connection and try again.';

  @override
  String get authErrSomethingWrong => 'Something went wrong. Please try again.';

  @override
  String get authErrRequestFailed => 'Request failed. Please try again.';

  @override
  String get authErrEmailAlreadyRegistered =>
      'This email is already registered. Try signing in instead.';

  @override
  String get authErrConfirmEmail =>
      'Please confirm your email address before continuing.';

  @override
  String get authErrPasswordRequirements =>
      'Password does not meet the requirements.';

  @override
  String get authErrEnterValidEmail => 'Please enter a valid email address.';

  @override
  String get authErrRateLimited =>
      'Too many attempts. Please wait a moment and try again.';

  @override
  String get authErrOtpExpired => 'This code has expired. Request a new one.';

  @override
  String get authErrInvalidOtp =>
      'Invalid verification code. Please check and try again.';

  @override
  String get authErrSessionFailed =>
      'Could not establish a session. Please try again.';

  @override
  String get authErrUnexpected =>
      'An unexpected error occurred. Please try again.';

  @override
  String get authErrSignOutFailed => 'Sign out failed. Please try again.';

  @override
  String get authErrInvalidCredentials =>
      'Invalid email or password. Please check and try again.';

  @override
  String get loginWelcomeTitle => 'Welcome';

  @override
  String get loginBrandName => 'E - Wallet';

  @override
  String get loginScreenTitle => 'Login';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldPassword => 'Password';

  @override
  String get hintEmailExample => 'example@gmail.com';

  @override
  String get hintPasswordDots => '* * * * * * * * *';

  @override
  String get validationEmailRequired => 'Please enter your email';

  @override
  String get validationEmailInvalid => 'Please enter a valid email';

  @override
  String get validationPasswordRequired => 'Please enter your password';

  @override
  String get validationPasswordMin => 'Password must be at least 6 characters';

  @override
  String get loginOrDivider => 'or';

  @override
  String get loginNoAccountPrompt => 'Don\'t have an account? ';

  @override
  String get loginSignUpAction => 'Sign Up';

  @override
  String get signUpTitle => 'Sign Up';

  @override
  String get fieldFirstName => 'First Name';

  @override
  String get fieldLastName => 'Last Name';

  @override
  String get fieldConfirmPassword => 'Confirm Password';

  @override
  String get hintFirstNameExample => 'Jimmy';

  @override
  String get hintLastNameExample => 'Cook';

  @override
  String get validationFirstNameRequired => 'Please enter your first name';

  @override
  String get validationLastNameRequired => 'Please enter your last name';

  @override
  String get validationSignupPasswordEmpty => 'Please enter a password';

  @override
  String get validationConfirmPasswordRequired =>
      'Please confirm your password';

  @override
  String get validationPasswordsMismatch => 'Passwords do not match';

  @override
  String get signUpButton => 'Sign Up';

  @override
  String get signUpAlreadyHaveAccount => 'Already have an account? ';

  @override
  String get signUpSignInAction => 'Sign In';

  @override
  String get otpTitleEnterCode => 'Enter Code';

  @override
  String get otpSubtitleSentTo => 'We sent a 6-digit code to';

  @override
  String get otpVerifyButton => 'Verify';

  @override
  String get otpResendCode => 'Resend Code';

  @override
  String get otpResendAvailable => 'You can resend the code now.';

  @override
  String otpResendCountdown(String time) {
    return 'Resend available in $time';
  }

  @override
  String get commonSave => 'Save';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonApply => 'Apply';

  @override
  String get commonAdd => 'Add';

  @override
  String get myWalletsTitle => 'My Wallets';

  @override
  String get walletsAllAccountsSection => 'All Accounts';

  @override
  String get walletsAddWallet => 'Add Wallet';

  @override
  String get fieldWalletName => 'Wallet Name';

  @override
  String get hintWalletNameExample => 'e.g. Vacation Savings';

  @override
  String fieldInitialBalance(String symbol) {
    return 'Initial Balance ($symbol)';
  }

  @override
  String get fieldAccountType => 'Account Type';

  @override
  String get walletTypeCash => 'Cash';

  @override
  String get walletTypeBank => 'Bank Account';

  @override
  String get walletTypeCreditCard => 'Credit Card';

  @override
  String get walletActionEdit => 'Edit Wallet';

  @override
  String get walletActionSetDefault => 'Set as Default';

  @override
  String get walletActionSetDefaultSubtitle => 'Use for quick transactions';

  @override
  String get walletActionDelete => 'Delete Wallet';

  @override
  String get walletDeleteConfirmTitle => 'Delete Wallet';

  @override
  String walletDeleteConfirmBody(String name) {
    return 'Delete \"$name\"? This cannot be undone.';
  }

  @override
  String get walletEditTitle => 'Edit Wallet';

  @override
  String get walletSaveChanges => 'Save Changes';

  @override
  String get walletAdjustBalanceTitle => 'Adjust Balance';

  @override
  String fieldBalanceWithSymbol(String symbol) {
    return 'Balance ($symbol)';
  }

  @override
  String get hintAmountZero => '0.00';

  @override
  String get walletUpdateBalance => 'Update Balance';

  @override
  String get accountsScreenTitle => 'Accounts';

  @override
  String get accountsHistoryTitle => 'History';

  @override
  String historyItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get accountsActionAdd => 'Add';

  @override
  String get accountsActionTransfer => 'Transfer';

  @override
  String get accountsActionPayDebt => 'Pay Debt';

  @override
  String get accountsActionSettings => 'Settings';

  @override
  String get filterAll => 'All';

  @override
  String get filterIncome => 'Income';

  @override
  String get filterExpense => 'Expense';

  @override
  String get searchHint => 'Search…';

  @override
  String get walletBadgePrimary => 'PRIMARY';

  @override
  String get emptyNoWalletsTitle => 'No wallets yet';

  @override
  String get emptyNoWalletsBody =>
      'Add a wallet from the My Wallets tab to get started.';

  @override
  String get emptyNoTransactionsTitle => 'No transactions yet';

  @override
  String get emptyNoTransactionsBody =>
      'Transactions for this wallet will appear here.';

  @override
  String get emptyNoResultsTitle => 'No results';

  @override
  String get emptyNoResultsBody => 'Try adjusting your search or filters.';

  @override
  String get entryModeIncome => 'Income';

  @override
  String get entryModeTransfer => 'Transfer';

  @override
  String get entryModeExpense => 'Expense';

  @override
  String get entrySelectDateTitle => 'Select date';

  @override
  String get entryAmountLabel => 'Amount';

  @override
  String get entryNoteHint => 'Add a note (optional)';

  @override
  String get entryCategoryPlaceholder => 'Category';

  @override
  String get entrySelectWallet => 'Select Wallet';

  @override
  String get entryWalletFromTitle => 'From Wallet';

  @override
  String get entryWalletToTitle => 'To Wallet';

  @override
  String get entryTransferFromShort => 'From';

  @override
  String get entryTransferToShort => 'To';

  @override
  String get entryAddTransaction => 'Add Transaction';

  @override
  String get entryAddTransfer => 'Add Transfer';

  @override
  String get entrySelectCategoryTitle => 'Select Category';

  @override
  String get entryBudgetAlertTitle => 'Budget alert';

  @override
  String entryBudgetAlertBody(int percent) {
    return 'This exceeds your $percent% budget limit!';
  }

  @override
  String get transactionDefaultTitle => 'Transaction';

  @override
  String transferToWalletTitle(String walletName) {
    return 'Transfer to $walletName';
  }

  @override
  String get payCreditCardTitle => 'Pay Credit Card Debt';

  @override
  String get payDebtFromLabel => 'Pay from';

  @override
  String get payDebtNoOtherWallets => 'No other wallets available.';

  @override
  String get payDebtPaymentAmount => 'Payment amount';

  @override
  String payDebtAmountField(String symbol) {
    return 'Amount ($symbol)';
  }

  @override
  String get payDebtConfirmPayment => 'Confirm Payment';

  @override
  String get payDebtErrorInvalidAmount =>
      'Please enter a valid amount greater than 0.';

  @override
  String get payDebtErrorNoSourceWallet => 'Please select a source wallet.';

  @override
  String payOffCardTransactionTitle(String cardName) {
    return 'Pay off $cardName';
  }

  @override
  String payDebtOutstanding(String amount) {
    return 'Outstanding debt: $amount';
  }

  @override
  String get budgetScreenTitle => 'Monthly Budget';

  @override
  String get budgetMonthlyLimit => 'Monthly Limit';

  @override
  String get budgetPerMonth => 'per month';

  @override
  String get budgetSpendingThisMonth => 'Spending This Month';

  @override
  String budgetSpentFragment(String amount) {
    return '$amount spent';
  }

  @override
  String budgetOfLimitFragment(String limit) {
    return 'of $limit';
  }

  @override
  String budgetOverBy(String amount) {
    return 'Over by $amount';
  }

  @override
  String budgetRemaining(String amount) {
    return '$amount remaining';
  }

  @override
  String get budgetAlertSettings => 'Alert Settings';

  @override
  String get budgetAlertsTitle => 'Budget Alerts';

  @override
  String get budgetAlertsSubtitle =>
      'Warn when a new expense crosses the threshold';

  @override
  String get budgetAlertThreshold => 'Alert Threshold';

  @override
  String budgetAlertFiresWhen(int percent) {
    return 'Alert fires when spending + new expense ≥ $percent% of limit';
  }

  @override
  String get categoriesScreenTitle => 'Categories';

  @override
  String get categoriesAddCategory => 'Add Category';

  @override
  String categoriesEmpty(String type) {
    return 'No $type categories yet';
  }

  @override
  String get categoriesDelete => 'Delete';

  @override
  String get categoriesEditTitle => 'Edit Category';

  @override
  String get categoriesAddTitle => 'Add Category';

  @override
  String get categoriesFieldName => 'Category Name';

  @override
  String get categoriesTypeLabel => 'Type';

  @override
  String get categoriesIconLabel => 'Icon';

  @override
  String get categoriesColorLabel => 'Color';

  @override
  String get categoryTypeIncomeLower => 'income';

  @override
  String get categoryTypeExpenseLower => 'expense';

  @override
  String get subscriptionBillingWeekly => 'Weekly';

  @override
  String get subscriptionBillingMonthly => 'Monthly';

  @override
  String get subscriptionBillingYearly => 'Yearly';

  @override
  String get personalInfoTitle => 'Personal Info';

  @override
  String get personalInfoSaved => 'Changes saved successfully';

  @override
  String get personalInfoDeletionRequested => 'Account deletion requested';

  @override
  String get fieldFullName => 'Full Name';

  @override
  String get fieldEmailAddress => 'Email Address';

  @override
  String get fieldPhoneNumber => 'Phone Number';

  @override
  String get fieldLocationAddress => 'Location / Address';

  @override
  String get passwordPinTitle => 'Password & PIN';

  @override
  String get passwordPinAppPin => 'App PIN';

  @override
  String get passwordPinChangeSoon => 'PIN change coming soon';

  @override
  String get twoFactorTitle => 'Two-Factor Authentication';

  @override
  String twoFactorSetupSoon(String method) {
    return '$method setup coming soon';
  }

  @override
  String get twoFactorAuthenticatorTitle => 'Authenticator App';

  @override
  String get twoFactorAuthenticatorSubtitle =>
      'e.g. Google Authenticator, Authy';

  @override
  String get twoFactorSmsTitle => 'SMS Verification';

  @override
  String get twoFactorSmsSubtitle => 'Receive a code via text message';

  @override
  String get dailyLimitsUpdated => 'Daily limit updated';

  @override
  String get goalsTabGoals => 'Goals';

  @override
  String get goalsTabAchieved => 'Achieved';

  @override
  String get entryScanReceipt => 'Scan Receipt';

  @override
  String get entryManualEntry => 'Manual Entry';

  @override
  String get recentTransactionsTitle => 'Recent transactions';

  @override
  String get homeAiBotTitle => 'AI assistant';

  @override
  String get homeAiBotDescription =>
      'Paying for YouTube and Spotify? Save money each month by consolidating your subscriptions on one platform.';

  @override
  String get passwordChangePin => 'Change PIN';

  @override
  String get passwordChangePinSubtitle => 'Update your 6-digit security PIN';

  @override
  String get passwordRequirePinOnLaunch => 'Require PIN on App Launch';

  @override
  String get passwordRequirePinProtected =>
      'App is protected — PIN required to open';

  @override
  String get passwordRequirePinDisabled => 'App lock is disabled';

  @override
  String get passwordSecurityTipTitle => 'Security Tip';

  @override
  String get passwordSecurityTipBody =>
      'We recommend keeping PIN protection enabled at all times to prevent unauthorized access to your wallet.';

  @override
  String get passwordDisableLockDialogTitle => 'Security Warning';

  @override
  String get passwordDisableLockDialogBody =>
      'Disabling the app lock makes your wallet vulnerable to unauthorized access. We highly recommend keeping this enabled.';

  @override
  String get passwordDisableAnyway => 'Disable Anyway';

  @override
  String get personalInfoDeleteQuestionTitle => 'Delete account?';

  @override
  String get personalInfoDeleteQuestionBody =>
      'This permanently removes your profile, transactions, and wallets. This cannot be undone.';

  @override
  String get fieldRequired => 'Required';

  @override
  String get validationEnterValidEmailShort => 'Enter a valid email';

  @override
  String get hintFullNameExample => 'John Doe';

  @override
  String get hintEmailPersonal => 'you@example.com';

  @override
  String get hintPhoneExample => '+1 555 000 0000';

  @override
  String get hintLocationExample => 'Istanbul, Turkey';

  @override
  String get personalInfoDeleteWarningFooter =>
      'Once you delete your account, your data cannot be recovered.';

  @override
  String get personalInfoDeleteAccountButton => 'Delete account';

  @override
  String get walletDebtLabel => 'Debt';

  @override
  String get twoFactorMarketingHeadline => 'Add an Extra Layer of Security';

  @override
  String get twoFactorMarketingBody =>
      'Two-factor authentication (2FA) adds a second verification step when signing in. Even if your password is compromised, your account stays protected.';

  @override
  String get twoFactorChooseMethodLabel => 'Choose a Method';

  @override
  String get twoFactorNotConfigured => 'Not Configured';

  @override
  String get twoFactorInfoFooter =>
      'Once enabled, you will be asked for a verification code every time you sign in from a new device.';

  @override
  String get twoFactorRecommended => 'Recommended';

  @override
  String get subscriptionAddTitle => 'Add subscription';

  @override
  String get subscriptionFieldServiceName => 'Service / platform name';

  @override
  String subscriptionFieldAmountPerCycle(String currencySymbol) {
    return 'Amount (per billing cycle, $currencySymbol)';
  }

  @override
  String get subscriptionBillingCycleLabel => 'Billing cycle';

  @override
  String get subscriptionBillingDayOfMonth => 'Billing day of month';

  @override
  String get subscriptionBillingDayField => 'Day (1–31)';

  @override
  String get subscriptionRenewalWeekday => 'Renewal weekday';

  @override
  String get subscriptionNextBillingDate => 'Next billing date';

  @override
  String get subscriptionErrorServiceNameEmpty =>
      'Service name cannot be empty.';

  @override
  String get subscriptionErrorAmountInvalid =>
      'Please enter a valid amount greater than 0.';

  @override
  String get subscriptionErrorBillingDayRequired =>
      'Please enter a billing day (1–31).';

  @override
  String get subscriptionErrorDayOfMonthRange =>
      'Please enter a day between 1 and 31.';

  @override
  String get subscriptionErrorBillingDateAfterToday =>
      'Please choose a billing date after today.';

  @override
  String get savingGoalAddTitle => 'Add saving goal';

  @override
  String get savingGoalFieldName => 'Goal name';

  @override
  String savingGoalFieldSavedAmount(String currencySymbol) {
    return 'Currently saved amount ($currencySymbol)';
  }

  @override
  String savingGoalFieldTargetAmount(String currencySymbol) {
    return 'Target amount ($currencySymbol)';
  }

  @override
  String get savingGoalErrorEmptyName => 'Goal name cannot be empty.';

  @override
  String get savingGoalErrorSavedAmount =>
      'Please enter a valid saved amount (0 or more).';

  @override
  String get savingGoalErrorTargetAmount =>
      'Target amount must be greater than 0.';

  @override
  String get savingGoalErrorTargetVsSaved =>
      'Target must be at least the currently saved amount.';

  @override
  String get goalsErrorNotConnected =>
      'Unable to save: the app is not connected to the server yet.';

  @override
  String get goalsErrorSignInRequired =>
      'You must be signed in to add a saving goal.';

  @override
  String get goalsErrorSaveFailed =>
      'Could not save the goal. Please try again.';

  @override
  String get dailyLimitsEnableTitle => 'Enable Daily Limit';

  @override
  String get dailyLimitsSubtitleEnabled =>
      'You will be alerted when spending exceeds the limit';

  @override
  String get dailyLimitsSubtitleDisabled =>
      'No daily spending limit is enforced';

  @override
  String get dailyLimitsInfoBody =>
      'When your total daily spending approaches or exceeds the limit, you will receive an in-app alert before confirming a transaction.';

  @override
  String get dailyLimitsSectionTitle => 'Daily Spending Limit';
}
