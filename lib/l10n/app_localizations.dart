import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'E-Wallet'**
  String get appTitle;

  /// No description provided for @profileAndSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile & Settings'**
  String get profileAndSettings;

  /// No description provided for @sectionWalletFinance.
  ///
  /// In en, this message translates to:
  /// **'Wallet & Finance'**
  String get sectionWalletFinance;

  /// No description provided for @sectionSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get sectionSecurity;

  /// No description provided for @sectionPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get sectionPreferences;

  /// No description provided for @preferencesCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get preferencesCurrency;

  /// No description provided for @preferencesAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get preferencesAppearance;

  /// No description provided for @appearanceDark.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get appearanceDark;

  /// No description provided for @appearanceLight.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get appearanceLight;

  /// No description provided for @preferencesNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get preferencesNotifications;

  /// No description provided for @preferencesNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Spending & budget alerts'**
  String get preferencesNotificationsSubtitle;

  /// No description provided for @preferencesLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get preferencesLanguage;

  /// No description provided for @securityPersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Info'**
  String get securityPersonalInfo;

  /// No description provided for @securityPersonalInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Name, phone, country/city'**
  String get securityPersonalInfoSubtitle;

  /// No description provided for @securityPasswordPin.
  ///
  /// In en, this message translates to:
  /// **'Password & PIN'**
  String get securityPasswordPin;

  /// No description provided for @securityPasswordPinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update app lock & transaction PIN'**
  String get securityPasswordPinSubtitle;

  /// No description provided for @securityBiometric.
  ///
  /// In en, this message translates to:
  /// **'Biometric Login'**
  String get securityBiometric;

  /// No description provided for @securityBiometricSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Face ID / Touch ID'**
  String get securityBiometricSubtitle;

  /// No description provided for @security2fa.
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication (2FA)'**
  String get security2fa;

  /// No description provided for @security2faSubtitle.
  ///
  /// In en, this message translates to:
  /// **'SMS or authenticator app'**
  String get security2faSubtitle;

  /// No description provided for @securityDailyLimits.
  ///
  /// In en, this message translates to:
  /// **'Daily Transaction Limits'**
  String get securityDailyLimits;

  /// No description provided for @securityDailyLimitsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set a maximum daily spend to trigger dynamic alerts'**
  String get securityDailyLimitsSubtitle;

  /// No description provided for @coreMyWallets.
  ///
  /// In en, this message translates to:
  /// **'My Wallets / Accounts'**
  String get coreMyWallets;

  /// No description provided for @coreMyWalletsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage cash, credit cards…'**
  String get coreMyWalletsSubtitle;

  /// No description provided for @coreAdjustBalance.
  ///
  /// In en, this message translates to:
  /// **'Adjust Balance'**
  String get coreAdjustBalance;

  /// No description provided for @coreBudget.
  ///
  /// In en, this message translates to:
  /// **'Monthly Budget Limit'**
  String get coreBudget;

  /// No description provided for @coreBudgetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set overall spending limits'**
  String get coreBudgetSubtitle;

  /// No description provided for @coreCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get coreCategories;

  /// No description provided for @coreCategoriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage income and expense categories'**
  String get coreCategoriesSubtitle;

  /// No description provided for @coreExport.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get coreExport;

  /// No description provided for @coreExportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Download history as CSV/PDF'**
  String get coreExportSubtitle;

  /// No description provided for @supportHelp.
  ///
  /// In en, this message translates to:
  /// **'Help Center & FAQ'**
  String get supportHelp;

  /// No description provided for @supportTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service & Privacy'**
  String get supportTerms;

  /// No description provided for @supportLogOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get supportLogOut;

  /// No description provided for @supportLogOutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get supportLogOutConfirmTitle;

  /// No description provided for @supportLogOutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get supportLogOutConfirmMessage;

  /// No description provided for @supportDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get supportDeleteAccount;

  /// No description provided for @supportDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get supportDeleteConfirmTitle;

  /// No description provided for @supportDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This action is permanent and cannot be undone. All your data will be erased.'**
  String get supportDeleteConfirmMessage;

  /// No description provided for @supportVersion.
  ///
  /// In en, this message translates to:
  /// **'v1.0.0 (Build 12)'**
  String get supportVersion;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @userVerifiedAccount.
  ///
  /// In en, this message translates to:
  /// **'Verified Account'**
  String get userVerifiedAccount;

  /// No description provided for @photoPickerSoon.
  ///
  /// In en, this message translates to:
  /// **'Photo picker coming soon'**
  String get photoPickerSoon;

  /// No description provided for @homeLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get homeLoading;

  /// No description provided for @greetingGoodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get greetingGoodMorning;

  /// No description provided for @greetingGoodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get greetingGoodAfternoon;

  /// No description provided for @greetingGoodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get greetingGoodEvening;

  /// No description provided for @greetingGoodNight.
  ///
  /// In en, this message translates to:
  /// **'Good Night'**
  String get greetingGoodNight;

  /// No description provided for @defaultUserFirstName.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get defaultUserFirstName;

  /// No description provided for @subscriptionsTab.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get subscriptionsTab;

  /// No description provided for @savingGoalsTab.
  ///
  /// In en, this message translates to:
  /// **'Saving Goals'**
  String get savingGoalsTab;

  /// No description provided for @subscriptionsTotalMonthlyCost.
  ///
  /// In en, this message translates to:
  /// **'Total Monthly Cost'**
  String get subscriptionsTotalMonthlyCost;

  /// No description provided for @savingGoalsCostTitle.
  ///
  /// In en, this message translates to:
  /// **'Saving Goals Cost'**
  String get savingGoalsCostTitle;

  /// No description provided for @addButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addButtonLabel;

  /// No description provided for @languagePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languagePickerTitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageTurkish.
  ///
  /// In en, this message translates to:
  /// **'Türkçe'**
  String get languageTurkish;

  /// No description provided for @comingSoonSnack.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoonSnack;

  /// No description provided for @walletComingSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get walletComingSoonTitle;

  /// No description provided for @walletScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get walletScreenTitle;

  /// No description provided for @authErrServerUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Unable to reach the server. Check your connection and try again.'**
  String get authErrServerUnreachable;

  /// No description provided for @authErrSomethingWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get authErrSomethingWrong;

  /// No description provided for @authErrRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Request failed. Please try again.'**
  String get authErrRequestFailed;

  /// No description provided for @authErrEmailAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered. Try signing in instead.'**
  String get authErrEmailAlreadyRegistered;

  /// No description provided for @authErrConfirmEmail.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your email address before continuing.'**
  String get authErrConfirmEmail;

  /// No description provided for @authErrPasswordRequirements.
  ///
  /// In en, this message translates to:
  /// **'Password does not meet the requirements.'**
  String get authErrPasswordRequirements;

  /// No description provided for @authErrEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get authErrEnterValidEmail;

  /// No description provided for @authErrRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a moment and try again.'**
  String get authErrRateLimited;

  /// No description provided for @authErrOtpExpired.
  ///
  /// In en, this message translates to:
  /// **'This code has expired. Request a new one.'**
  String get authErrOtpExpired;

  /// No description provided for @authErrInvalidOtp.
  ///
  /// In en, this message translates to:
  /// **'Invalid verification code. Please check and try again.'**
  String get authErrInvalidOtp;

  /// No description provided for @authErrSessionFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not establish a session. Please try again.'**
  String get authErrSessionFailed;

  /// No description provided for @authErrUnexpected.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get authErrUnexpected;

  /// No description provided for @authErrSignOutFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign out failed. Please try again.'**
  String get authErrSignOutFailed;

  /// No description provided for @authErrInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password. Please check and try again.'**
  String get authErrInvalidCredentials;

  /// No description provided for @loginWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get loginWelcomeTitle;

  /// No description provided for @loginBrandName.
  ///
  /// In en, this message translates to:
  /// **'E - Wallet'**
  String get loginBrandName;

  /// No description provided for @loginScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginScreenTitle;

  /// No description provided for @fieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get fieldEmail;

  /// No description provided for @fieldPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get fieldPassword;

  /// No description provided for @hintEmailExample.
  ///
  /// In en, this message translates to:
  /// **'example@gmail.com'**
  String get hintEmailExample;

  /// No description provided for @hintPasswordDots.
  ///
  /// In en, this message translates to:
  /// **'* * * * * * * * *'**
  String get hintPasswordDots;

  /// No description provided for @validationEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get validationEmailRequired;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get validationEmailInvalid;

  /// No description provided for @validationPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get validationPasswordRequired;

  /// No description provided for @validationPasswordMin.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get validationPasswordMin;

  /// No description provided for @loginOrDivider.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get loginOrDivider;

  /// No description provided for @loginNoAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get loginNoAccountPrompt;

  /// No description provided for @loginSignUpAction.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get loginSignUpAction;

  /// No description provided for @signUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpTitle;

  /// No description provided for @fieldFirstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get fieldFirstName;

  /// No description provided for @fieldLastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get fieldLastName;

  /// No description provided for @fieldConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get fieldConfirmPassword;

  /// No description provided for @hintFirstNameExample.
  ///
  /// In en, this message translates to:
  /// **'Jimmy'**
  String get hintFirstNameExample;

  /// No description provided for @hintLastNameExample.
  ///
  /// In en, this message translates to:
  /// **'Cook'**
  String get hintLastNameExample;

  /// No description provided for @validationFirstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your first name'**
  String get validationFirstNameRequired;

  /// No description provided for @validationLastNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your last name'**
  String get validationLastNameRequired;

  /// No description provided for @validationSignupPasswordEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get validationSignupPasswordEmpty;

  /// No description provided for @validationConfirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get validationConfirmPasswordRequired;

  /// No description provided for @validationPasswordsMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get validationPasswordsMismatch;

  /// No description provided for @signUpButton.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpButton;

  /// No description provided for @signUpAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get signUpAlreadyHaveAccount;

  /// No description provided for @signUpSignInAction.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signUpSignInAction;

  /// No description provided for @otpTitleEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Code'**
  String get otpTitleEnterCode;

  /// No description provided for @otpSubtitleSentTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to'**
  String get otpSubtitleSentTo;

  /// No description provided for @otpVerifyButton.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get otpVerifyButton;

  /// No description provided for @otpResendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get otpResendCode;

  /// No description provided for @otpResendAvailable.
  ///
  /// In en, this message translates to:
  /// **'You can resend the code now.'**
  String get otpResendAvailable;

  /// No description provided for @otpResendCountdown.
  ///
  /// In en, this message translates to:
  /// **'Resend available in {time}'**
  String otpResendCountdown(String time);

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get commonApply;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @myWalletsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Wallets'**
  String get myWalletsTitle;

  /// No description provided for @walletsAllAccountsSection.
  ///
  /// In en, this message translates to:
  /// **'All Accounts'**
  String get walletsAllAccountsSection;

  /// No description provided for @walletsAddWallet.
  ///
  /// In en, this message translates to:
  /// **'Add Wallet'**
  String get walletsAddWallet;

  /// No description provided for @fieldWalletName.
  ///
  /// In en, this message translates to:
  /// **'Wallet Name'**
  String get fieldWalletName;

  /// No description provided for @hintWalletNameExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. Vacation Savings'**
  String get hintWalletNameExample;

  /// No description provided for @fieldInitialBalance.
  ///
  /// In en, this message translates to:
  /// **'Initial Balance ({symbol})'**
  String fieldInitialBalance(String symbol);

  /// No description provided for @fieldAccountType.
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get fieldAccountType;

  /// No description provided for @walletTypeCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get walletTypeCash;

  /// No description provided for @walletTypeBank.
  ///
  /// In en, this message translates to:
  /// **'Bank Account'**
  String get walletTypeBank;

  /// No description provided for @walletTypeCreditCard.
  ///
  /// In en, this message translates to:
  /// **'Credit Card'**
  String get walletTypeCreditCard;

  /// No description provided for @walletActionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Wallet'**
  String get walletActionEdit;

  /// No description provided for @walletActionSetDefault.
  ///
  /// In en, this message translates to:
  /// **'Set as Default'**
  String get walletActionSetDefault;

  /// No description provided for @walletActionSetDefaultSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use for quick transactions'**
  String get walletActionSetDefaultSubtitle;

  /// No description provided for @walletActionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Wallet'**
  String get walletActionDelete;

  /// No description provided for @walletDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Wallet'**
  String get walletDeleteConfirmTitle;

  /// No description provided for @walletDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? This cannot be undone.'**
  String walletDeleteConfirmBody(String name);

  /// No description provided for @walletEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Wallet'**
  String get walletEditTitle;

  /// No description provided for @walletSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get walletSaveChanges;

  /// No description provided for @walletAdjustBalanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Adjust Balance'**
  String get walletAdjustBalanceTitle;

  /// No description provided for @fieldBalanceWithSymbol.
  ///
  /// In en, this message translates to:
  /// **'Balance ({symbol})'**
  String fieldBalanceWithSymbol(String symbol);

  /// No description provided for @hintAmountZero.
  ///
  /// In en, this message translates to:
  /// **'0.00'**
  String get hintAmountZero;

  /// No description provided for @walletUpdateBalance.
  ///
  /// In en, this message translates to:
  /// **'Update Balance'**
  String get walletUpdateBalance;

  /// No description provided for @accountsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accountsScreenTitle;

  /// No description provided for @accountsHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get accountsHistoryTitle;

  /// No description provided for @historyItemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String historyItemCount(int count);

  /// No description provided for @accountsActionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get accountsActionAdd;

  /// No description provided for @accountsActionTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get accountsActionTransfer;

  /// No description provided for @accountsActionPayDebt.
  ///
  /// In en, this message translates to:
  /// **'Pay Debt'**
  String get accountsActionPayDebt;

  /// No description provided for @accountsActionSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get accountsActionSettings;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get filterIncome;

  /// No description provided for @filterExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get filterExpense;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search…'**
  String get searchHint;

  /// No description provided for @walletBadgePrimary.
  ///
  /// In en, this message translates to:
  /// **'PRIMARY'**
  String get walletBadgePrimary;

  /// No description provided for @emptyNoWalletsTitle.
  ///
  /// In en, this message translates to:
  /// **'No wallets yet'**
  String get emptyNoWalletsTitle;

  /// No description provided for @emptyNoWalletsBody.
  ///
  /// In en, this message translates to:
  /// **'Add a wallet from the My Wallets tab to get started.'**
  String get emptyNoWalletsBody;

  /// No description provided for @emptyNoTransactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get emptyNoTransactionsTitle;

  /// No description provided for @emptyNoTransactionsBody.
  ///
  /// In en, this message translates to:
  /// **'Transactions for this wallet will appear here.'**
  String get emptyNoTransactionsBody;

  /// No description provided for @emptyNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get emptyNoResultsTitle;

  /// No description provided for @emptyNoResultsBody.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filters.'**
  String get emptyNoResultsBody;

  /// No description provided for @entryModeIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get entryModeIncome;

  /// No description provided for @entryModeTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get entryModeTransfer;

  /// No description provided for @entryModeExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get entryModeExpense;

  /// No description provided for @entrySelectDateTitle.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get entrySelectDateTitle;

  /// No description provided for @entryAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get entryAmountLabel;

  /// No description provided for @entryNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Add a note (optional)'**
  String get entryNoteHint;

  /// No description provided for @entryCategoryPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get entryCategoryPlaceholder;

  /// No description provided for @entrySelectWallet.
  ///
  /// In en, this message translates to:
  /// **'Select Wallet'**
  String get entrySelectWallet;

  /// No description provided for @entryWalletFromTitle.
  ///
  /// In en, this message translates to:
  /// **'From Wallet'**
  String get entryWalletFromTitle;

  /// No description provided for @entryWalletToTitle.
  ///
  /// In en, this message translates to:
  /// **'To Wallet'**
  String get entryWalletToTitle;

  /// No description provided for @entryTransferFromShort.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get entryTransferFromShort;

  /// No description provided for @entryTransferToShort.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get entryTransferToShort;

  /// No description provided for @entryAddTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get entryAddTransaction;

  /// No description provided for @entryAddTransfer.
  ///
  /// In en, this message translates to:
  /// **'Add Transfer'**
  String get entryAddTransfer;

  /// No description provided for @entrySelectCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get entrySelectCategoryTitle;

  /// No description provided for @entryBudgetAlertTitle.
  ///
  /// In en, this message translates to:
  /// **'Budget alert'**
  String get entryBudgetAlertTitle;

  /// No description provided for @entryBudgetAlertBody.
  ///
  /// In en, this message translates to:
  /// **'This exceeds your {percent}% budget limit!'**
  String entryBudgetAlertBody(int percent);

  /// No description provided for @transactionDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get transactionDefaultTitle;

  /// No description provided for @transferToWalletTitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer to {walletName}'**
  String transferToWalletTitle(String walletName);

  /// No description provided for @payCreditCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Pay Credit Card Debt'**
  String get payCreditCardTitle;

  /// No description provided for @payDebtFromLabel.
  ///
  /// In en, this message translates to:
  /// **'Pay from'**
  String get payDebtFromLabel;

  /// No description provided for @payDebtNoOtherWallets.
  ///
  /// In en, this message translates to:
  /// **'No other wallets available.'**
  String get payDebtNoOtherWallets;

  /// No description provided for @payDebtPaymentAmount.
  ///
  /// In en, this message translates to:
  /// **'Payment amount'**
  String get payDebtPaymentAmount;

  /// No description provided for @payDebtAmountField.
  ///
  /// In en, this message translates to:
  /// **'Amount ({symbol})'**
  String payDebtAmountField(String symbol);

  /// No description provided for @payDebtConfirmPayment.
  ///
  /// In en, this message translates to:
  /// **'Confirm Payment'**
  String get payDebtConfirmPayment;

  /// No description provided for @payDebtErrorInvalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount greater than 0.'**
  String get payDebtErrorInvalidAmount;

  /// No description provided for @payDebtErrorNoSourceWallet.
  ///
  /// In en, this message translates to:
  /// **'Please select a source wallet.'**
  String get payDebtErrorNoSourceWallet;

  /// No description provided for @payOffCardTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Pay off {cardName}'**
  String payOffCardTransactionTitle(String cardName);

  /// No description provided for @payDebtOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Outstanding debt: {amount}'**
  String payDebtOutstanding(String amount);

  /// No description provided for @budgetScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly Budget'**
  String get budgetScreenTitle;

  /// No description provided for @budgetMonthlyLimit.
  ///
  /// In en, this message translates to:
  /// **'Monthly Limit'**
  String get budgetMonthlyLimit;

  /// No description provided for @budgetPerMonth.
  ///
  /// In en, this message translates to:
  /// **'per month'**
  String get budgetPerMonth;

  /// No description provided for @budgetSpendingThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Spending This Month'**
  String get budgetSpendingThisMonth;

  /// No description provided for @budgetSpentFragment.
  ///
  /// In en, this message translates to:
  /// **'{amount} spent'**
  String budgetSpentFragment(String amount);

  /// No description provided for @budgetOfLimitFragment.
  ///
  /// In en, this message translates to:
  /// **'of {limit}'**
  String budgetOfLimitFragment(String limit);

  /// No description provided for @budgetOverBy.
  ///
  /// In en, this message translates to:
  /// **'Over by {amount}'**
  String budgetOverBy(String amount);

  /// No description provided for @budgetRemaining.
  ///
  /// In en, this message translates to:
  /// **'{amount} remaining'**
  String budgetRemaining(String amount);

  /// No description provided for @budgetAlertSettings.
  ///
  /// In en, this message translates to:
  /// **'Alert Settings'**
  String get budgetAlertSettings;

  /// No description provided for @budgetAlertsTitle.
  ///
  /// In en, this message translates to:
  /// **'Budget Alerts'**
  String get budgetAlertsTitle;

  /// No description provided for @budgetAlertsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Warn when a new expense crosses the threshold'**
  String get budgetAlertsSubtitle;

  /// No description provided for @budgetAlertThreshold.
  ///
  /// In en, this message translates to:
  /// **'Alert Threshold'**
  String get budgetAlertThreshold;

  /// No description provided for @budgetAlertFiresWhen.
  ///
  /// In en, this message translates to:
  /// **'Alert fires when spending + new expense ≥ {percent}% of limit'**
  String budgetAlertFiresWhen(int percent);

  /// No description provided for @categoriesScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesScreenTitle;

  /// No description provided for @categoriesAddCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get categoriesAddCategory;

  /// No description provided for @categoriesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No {type} categories yet'**
  String categoriesEmpty(String type);

  /// No description provided for @categoriesDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get categoriesDelete;

  /// No description provided for @categoriesEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get categoriesEditTitle;

  /// No description provided for @categoriesAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get categoriesAddTitle;

  /// No description provided for @categoriesFieldName.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoriesFieldName;

  /// No description provided for @categoriesTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get categoriesTypeLabel;

  /// No description provided for @categoriesIconLabel.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get categoriesIconLabel;

  /// No description provided for @categoriesColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get categoriesColorLabel;

  /// No description provided for @categoryTypeIncomeLower.
  ///
  /// In en, this message translates to:
  /// **'income'**
  String get categoryTypeIncomeLower;

  /// No description provided for @categoryTypeExpenseLower.
  ///
  /// In en, this message translates to:
  /// **'expense'**
  String get categoryTypeExpenseLower;

  /// No description provided for @subscriptionBillingWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get subscriptionBillingWeekly;

  /// No description provided for @subscriptionBillingMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get subscriptionBillingMonthly;

  /// No description provided for @subscriptionBillingYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get subscriptionBillingYearly;

  /// No description provided for @personalInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal Info'**
  String get personalInfoTitle;

  /// No description provided for @personalInfoSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved successfully'**
  String get personalInfoSaved;

  /// No description provided for @personalInfoDeletionRequested.
  ///
  /// In en, this message translates to:
  /// **'Account deletion requested'**
  String get personalInfoDeletionRequested;

  /// No description provided for @fieldFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fieldFullName;

  /// No description provided for @fieldEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get fieldEmailAddress;

  /// No description provided for @fieldPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get fieldPhoneNumber;

  /// No description provided for @fieldLocationAddress.
  ///
  /// In en, this message translates to:
  /// **'Location / Address'**
  String get fieldLocationAddress;

  /// No description provided for @passwordPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Password & PIN'**
  String get passwordPinTitle;

  /// No description provided for @passwordPinAppPin.
  ///
  /// In en, this message translates to:
  /// **'App PIN'**
  String get passwordPinAppPin;

  /// No description provided for @passwordPinChangeSoon.
  ///
  /// In en, this message translates to:
  /// **'PIN change coming soon'**
  String get passwordPinChangeSoon;

  /// No description provided for @twoFactorTitle.
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication'**
  String get twoFactorTitle;

  /// No description provided for @twoFactorSetupSoon.
  ///
  /// In en, this message translates to:
  /// **'{method} setup coming soon'**
  String twoFactorSetupSoon(String method);

  /// No description provided for @twoFactorAuthenticatorTitle.
  ///
  /// In en, this message translates to:
  /// **'Authenticator App'**
  String get twoFactorAuthenticatorTitle;

  /// No description provided for @twoFactorAuthenticatorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'e.g. Google Authenticator, Authy'**
  String get twoFactorAuthenticatorSubtitle;

  /// No description provided for @twoFactorSmsTitle.
  ///
  /// In en, this message translates to:
  /// **'SMS Verification'**
  String get twoFactorSmsTitle;

  /// No description provided for @twoFactorSmsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive a code via text message'**
  String get twoFactorSmsSubtitle;

  /// No description provided for @dailyLimitsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Daily limit updated'**
  String get dailyLimitsUpdated;

  /// No description provided for @goalsTabGoals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goalsTabGoals;

  /// No description provided for @goalsTabAchieved.
  ///
  /// In en, this message translates to:
  /// **'Achieved'**
  String get goalsTabAchieved;

  /// No description provided for @entryScanReceipt.
  ///
  /// In en, this message translates to:
  /// **'Scan Receipt'**
  String get entryScanReceipt;

  /// No description provided for @entryManualEntry.
  ///
  /// In en, this message translates to:
  /// **'Manual Entry'**
  String get entryManualEntry;

  /// No description provided for @recentTransactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent transactions'**
  String get recentTransactionsTitle;

  /// No description provided for @homeAiBotTitle.
  ///
  /// In en, this message translates to:
  /// **'AI assistant'**
  String get homeAiBotTitle;

  /// No description provided for @homeAiBotDescription.
  ///
  /// In en, this message translates to:
  /// **'Paying for YouTube and Spotify? Save money each month by consolidating your subscriptions on one platform.'**
  String get homeAiBotDescription;

  /// No description provided for @passwordChangePin.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get passwordChangePin;

  /// No description provided for @passwordChangePinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your 6-digit security PIN'**
  String get passwordChangePinSubtitle;

  /// No description provided for @passwordRequirePinOnLaunch.
  ///
  /// In en, this message translates to:
  /// **'Require PIN on App Launch'**
  String get passwordRequirePinOnLaunch;

  /// No description provided for @passwordRequirePinProtected.
  ///
  /// In en, this message translates to:
  /// **'App is protected — PIN required to open'**
  String get passwordRequirePinProtected;

  /// No description provided for @passwordRequirePinDisabled.
  ///
  /// In en, this message translates to:
  /// **'App lock is disabled'**
  String get passwordRequirePinDisabled;

  /// No description provided for @passwordSecurityTipTitle.
  ///
  /// In en, this message translates to:
  /// **'Security Tip'**
  String get passwordSecurityTipTitle;

  /// No description provided for @passwordSecurityTipBody.
  ///
  /// In en, this message translates to:
  /// **'We recommend keeping PIN protection enabled at all times to prevent unauthorized access to your wallet.'**
  String get passwordSecurityTipBody;

  /// No description provided for @passwordDisableLockDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Security Warning'**
  String get passwordDisableLockDialogTitle;

  /// No description provided for @passwordDisableLockDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Disabling the app lock makes your wallet vulnerable to unauthorized access. We highly recommend keeping this enabled.'**
  String get passwordDisableLockDialogBody;

  /// No description provided for @passwordDisableAnyway.
  ///
  /// In en, this message translates to:
  /// **'Disable Anyway'**
  String get passwordDisableAnyway;

  /// No description provided for @personalInfoDeleteQuestionTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get personalInfoDeleteQuestionTitle;

  /// No description provided for @personalInfoDeleteQuestionBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently removes your profile, transactions, and wallets. This cannot be undone.'**
  String get personalInfoDeleteQuestionBody;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get fieldRequired;

  /// No description provided for @validationEnterValidEmailShort.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get validationEnterValidEmailShort;

  /// No description provided for @hintFullNameExample.
  ///
  /// In en, this message translates to:
  /// **'John Doe'**
  String get hintFullNameExample;

  /// No description provided for @hintEmailPersonal.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get hintEmailPersonal;

  /// No description provided for @hintPhoneExample.
  ///
  /// In en, this message translates to:
  /// **'+1 555 000 0000'**
  String get hintPhoneExample;

  /// No description provided for @hintLocationExample.
  ///
  /// In en, this message translates to:
  /// **'Istanbul, Turkey'**
  String get hintLocationExample;

  /// No description provided for @personalInfoDeleteWarningFooter.
  ///
  /// In en, this message translates to:
  /// **'Once you delete your account, your data cannot be recovered.'**
  String get personalInfoDeleteWarningFooter;

  /// No description provided for @personalInfoDeleteAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get personalInfoDeleteAccountButton;

  /// No description provided for @walletDebtLabel.
  ///
  /// In en, this message translates to:
  /// **'Debt'**
  String get walletDebtLabel;

  /// No description provided for @twoFactorMarketingHeadline.
  ///
  /// In en, this message translates to:
  /// **'Add an Extra Layer of Security'**
  String get twoFactorMarketingHeadline;

  /// No description provided for @twoFactorMarketingBody.
  ///
  /// In en, this message translates to:
  /// **'Two-factor authentication (2FA) adds a second verification step when signing in. Even if your password is compromised, your account stays protected.'**
  String get twoFactorMarketingBody;

  /// No description provided for @twoFactorChooseMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Choose a Method'**
  String get twoFactorChooseMethodLabel;

  /// No description provided for @twoFactorNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Not Configured'**
  String get twoFactorNotConfigured;

  /// No description provided for @twoFactorInfoFooter.
  ///
  /// In en, this message translates to:
  /// **'Once enabled, you will be asked for a verification code every time you sign in from a new device.'**
  String get twoFactorInfoFooter;

  /// No description provided for @twoFactorRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get twoFactorRecommended;

  /// No description provided for @subscriptionAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add subscription'**
  String get subscriptionAddTitle;

  /// No description provided for @subscriptionFieldServiceName.
  ///
  /// In en, this message translates to:
  /// **'Service / platform name'**
  String get subscriptionFieldServiceName;

  /// No description provided for @subscriptionFieldAmountPerCycle.
  ///
  /// In en, this message translates to:
  /// **'Amount (per billing cycle, {currencySymbol})'**
  String subscriptionFieldAmountPerCycle(String currencySymbol);

  /// No description provided for @subscriptionBillingCycleLabel.
  ///
  /// In en, this message translates to:
  /// **'Billing cycle'**
  String get subscriptionBillingCycleLabel;

  /// No description provided for @subscriptionBillingDayOfMonth.
  ///
  /// In en, this message translates to:
  /// **'Billing day of month'**
  String get subscriptionBillingDayOfMonth;

  /// No description provided for @subscriptionBillingDayField.
  ///
  /// In en, this message translates to:
  /// **'Day (1–31)'**
  String get subscriptionBillingDayField;

  /// No description provided for @subscriptionRenewalWeekday.
  ///
  /// In en, this message translates to:
  /// **'Renewal weekday'**
  String get subscriptionRenewalWeekday;

  /// No description provided for @subscriptionNextBillingDate.
  ///
  /// In en, this message translates to:
  /// **'Next billing date'**
  String get subscriptionNextBillingDate;

  /// No description provided for @subscriptionErrorServiceNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Service name cannot be empty.'**
  String get subscriptionErrorServiceNameEmpty;

  /// No description provided for @subscriptionErrorAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount greater than 0.'**
  String get subscriptionErrorAmountInvalid;

  /// No description provided for @subscriptionErrorBillingDayRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a billing day (1–31).'**
  String get subscriptionErrorBillingDayRequired;

  /// No description provided for @subscriptionErrorDayOfMonthRange.
  ///
  /// In en, this message translates to:
  /// **'Please enter a day between 1 and 31.'**
  String get subscriptionErrorDayOfMonthRange;

  /// No description provided for @subscriptionErrorBillingDateAfterToday.
  ///
  /// In en, this message translates to:
  /// **'Please choose a billing date after today.'**
  String get subscriptionErrorBillingDateAfterToday;

  /// No description provided for @savingGoalAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add saving goal'**
  String get savingGoalAddTitle;

  /// No description provided for @savingGoalFieldName.
  ///
  /// In en, this message translates to:
  /// **'Goal name'**
  String get savingGoalFieldName;

  /// No description provided for @savingGoalFieldSavedAmount.
  ///
  /// In en, this message translates to:
  /// **'Currently saved amount ({currencySymbol})'**
  String savingGoalFieldSavedAmount(String currencySymbol);

  /// No description provided for @savingGoalFieldTargetAmount.
  ///
  /// In en, this message translates to:
  /// **'Target amount ({currencySymbol})'**
  String savingGoalFieldTargetAmount(String currencySymbol);

  /// No description provided for @savingGoalErrorEmptyName.
  ///
  /// In en, this message translates to:
  /// **'Goal name cannot be empty.'**
  String get savingGoalErrorEmptyName;

  /// No description provided for @savingGoalErrorSavedAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid saved amount (0 or more).'**
  String get savingGoalErrorSavedAmount;

  /// No description provided for @savingGoalErrorTargetAmount.
  ///
  /// In en, this message translates to:
  /// **'Target amount must be greater than 0.'**
  String get savingGoalErrorTargetAmount;

  /// No description provided for @savingGoalErrorTargetVsSaved.
  ///
  /// In en, this message translates to:
  /// **'Target must be at least the currently saved amount.'**
  String get savingGoalErrorTargetVsSaved;

  /// No description provided for @goalsErrorNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Unable to save: the app is not connected to the server yet.'**
  String get goalsErrorNotConnected;

  /// No description provided for @goalsErrorSignInRequired.
  ///
  /// In en, this message translates to:
  /// **'You must be signed in to add a saving goal.'**
  String get goalsErrorSignInRequired;

  /// No description provided for @goalsErrorSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the goal. Please try again.'**
  String get goalsErrorSaveFailed;

  /// No description provided for @dailyLimitsEnableTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable Daily Limit'**
  String get dailyLimitsEnableTitle;

  /// No description provided for @dailyLimitsSubtitleEnabled.
  ///
  /// In en, this message translates to:
  /// **'You will be alerted when spending exceeds the limit'**
  String get dailyLimitsSubtitleEnabled;

  /// No description provided for @dailyLimitsSubtitleDisabled.
  ///
  /// In en, this message translates to:
  /// **'No daily spending limit is enforced'**
  String get dailyLimitsSubtitleDisabled;

  /// No description provided for @dailyLimitsInfoBody.
  ///
  /// In en, this message translates to:
  /// **'When your total daily spending approaches or exceeds the limit, you will receive an in-app alert before confirming a transaction.'**
  String get dailyLimitsInfoBody;

  /// No description provided for @dailyLimitsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Spending Limit'**
  String get dailyLimitsSectionTitle;

  /// No description provided for @appPinCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create PIN'**
  String get appPinCreateTitle;

  /// No description provided for @appPinCreateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your 6-digit password to secure the app.'**
  String get appPinCreateSubtitle;

  /// No description provided for @appPinWarningSequential.
  ///
  /// In en, this message translates to:
  /// **'Avoid simple sequences (e.g. 123456 or 654321).'**
  String get appPinWarningSequential;

  /// No description provided for @appPinWarningRepeated.
  ///
  /// In en, this message translates to:
  /// **'Avoid using the same digit six times in a row.'**
  String get appPinWarningRepeated;

  /// No description provided for @appPinConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get appPinConfirmTitle;

  /// No description provided for @appPinEncryptedFooter.
  ///
  /// In en, this message translates to:
  /// **'Your password is encrypted and stored securely.'**
  String get appPinEncryptedFooter;

  /// No description provided for @appPinMismatch.
  ///
  /// In en, this message translates to:
  /// **'PIN codes do not match.'**
  String get appPinMismatch;

  /// No description provided for @appPinIncorrectPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password.'**
  String get appPinIncorrectPassword;

  /// No description provided for @appPinDailyBrand.
  ///
  /// In en, this message translates to:
  /// **'E - Wallet'**
  String get appPinDailyBrand;

  /// No description provided for @appPinDailyInstruction.
  ///
  /// In en, this message translates to:
  /// **'You must enter your password to continue.'**
  String get appPinDailyInstruction;

  /// No description provided for @appPinForgotPrefix.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password? '**
  String get appPinForgotPrefix;

  /// No description provided for @appPinForgotAction.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get appPinForgotAction;

  /// No description provided for @appPinResetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'A password reset link has been sent to {email}. (Demo — backend not connected.)'**
  String appPinResetEmailSent(String email);

  /// No description provided for @appPinSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your PIN has been saved.'**
  String get appPinSavedMessage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
