import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('id'),
  ];

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageFollowDevice.
  ///
  /// In en, this message translates to:
  /// **'Follow device'**
  String get languageFollowDevice;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageIndonesian.
  ///
  /// In en, this message translates to:
  /// **'Bahasa Indonesia'**
  String get languageIndonesian;

  /// No description provided for @languageStoriesNote.
  ///
  /// In en, this message translates to:
  /// **'Stories are always written in simple English.'**
  String get languageStoriesNote;

  /// No description provided for @landingTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your own story'**
  String get landingTitle;

  /// No description provided for @landingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Help your child learn English through stories they love'**
  String get landingSubtitle;

  /// No description provided for @landingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Let’s go'**
  String get landingGetStarted;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @signUpWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign Up with Google'**
  String get signUpWithGoogle;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember Me'**
  String get rememberMe;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @newUser.
  ///
  /// In en, this message translates to:
  /// **'New User? '**
  String get newUser;

  /// No description provided for @acceptTermsPrefix.
  ///
  /// In en, this message translates to:
  /// **'I accept the '**
  String get acceptTermsPrefix;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'terms of service'**
  String get termsOfService;

  /// No description provided for @acceptTermsAnd.
  ///
  /// In en, this message translates to:
  /// **' & '**
  String get acceptTermsAnd;

  /// No description provided for @privacyPolicyLink.
  ///
  /// In en, this message translates to:
  /// **'privacy policy'**
  String get privacyPolicyLink;

  /// No description provided for @childInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Child’s Information'**
  String get childInfoTitle;

  /// No description provided for @basicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Info'**
  String get basicInfo;

  /// No description provided for @childName.
  ///
  /// In en, this message translates to:
  /// **'Child’s Name'**
  String get childName;

  /// No description provided for @enterChildName.
  ///
  /// In en, this message translates to:
  /// **'Enter the name of your child'**
  String get enterChildName;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @enterAgeOptional.
  ///
  /// In en, this message translates to:
  /// **'Enter age (optional)'**
  String get enterAgeOptional;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @genderNotSpecified.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get genderNotSpecified;

  /// No description provided for @interest.
  ///
  /// In en, this message translates to:
  /// **'Interest'**
  String get interest;

  /// No description provided for @interestSlotsRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No slots left} =1{1 slot remaining} other{{count} slots remaining}}'**
  String interestSlotsRemaining(int count);

  /// No description provided for @interestSports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get interestSports;

  /// No description provided for @interestMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get interestMusic;

  /// No description provided for @interestArt.
  ///
  /// In en, this message translates to:
  /// **'Art'**
  String get interestArt;

  /// No description provided for @interestScience.
  ///
  /// In en, this message translates to:
  /// **'Science'**
  String get interestScience;

  /// No description provided for @interestNature.
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get interestNature;

  /// No description provided for @interestSpace.
  ///
  /// In en, this message translates to:
  /// **'Space'**
  String get interestSpace;

  /// No description provided for @interestMagic.
  ///
  /// In en, this message translates to:
  /// **'Magic'**
  String get interestMagic;

  /// No description provided for @interestReading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get interestReading;

  /// No description provided for @interestDancing.
  ///
  /// In en, this message translates to:
  /// **'Dancing'**
  String get interestDancing;

  /// No description provided for @interestGames.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get interestGames;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saveAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Save & Continue'**
  String get saveAndContinue;

  /// No description provided for @useDifferentAccount.
  ///
  /// In en, this message translates to:
  /// **'Use a different account'**
  String get useDifferentAccount;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @changeServerAddress.
  ///
  /// In en, this message translates to:
  /// **'Change server address'**
  String get changeServerAddress;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @mascot.
  ///
  /// In en, this message translates to:
  /// **'Mascot'**
  String get mascot;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// No description provided for @volumeLimit.
  ///
  /// In en, this message translates to:
  /// **'Volume Limit'**
  String get volumeLimit;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @serverAddress.
  ///
  /// In en, this message translates to:
  /// **'Server Address'**
  String get serverAddress;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get sendFeedback;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsAndConditions;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @msgCredentialsRequired.
  ///
  /// In en, this message translates to:
  /// **'Email and Password are required!'**
  String get msgCredentialsRequired;

  /// No description provided for @msgEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required!'**
  String get msgEmailRequired;

  /// No description provided for @msgEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format, please check again!'**
  String get msgEmailInvalid;

  /// No description provided for @msgPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required!'**
  String get msgPasswordRequired;

  /// No description provided for @msgPasswordRules.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least {minLength} characters with letters and numbers!'**
  String msgPasswordRules(int minLength);

  /// No description provided for @msgTermsNotAccepted.
  ///
  /// In en, this message translates to:
  /// **'Please accept our Terms and Conditions to continue.'**
  String get msgTermsNotAccepted;

  /// No description provided for @msgChildInfoMissing.
  ///
  /// In en, this message translates to:
  /// **'Please fill child\'s information first'**
  String get msgChildInfoMissing;

  /// No description provided for @msgFillMandatory.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all mandatory fields!'**
  String get msgFillMandatory;

  /// No description provided for @msgAgeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid age.'**
  String get msgAgeInvalid;

  /// No description provided for @msgChildNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Child\'s name is required!'**
  String get msgChildNameRequired;

  /// No description provided for @msgChildNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Name must be at most {maxLength} characters.'**
  String msgChildNameTooLong(int maxLength);

  /// No description provided for @msgChildNameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Use letters only (spaces, \' and - are allowed), starting with a letter.'**
  String get msgChildNameInvalid;

  /// No description provided for @msgSessionRejected.
  ///
  /// In en, this message translates to:
  /// **'The server rejected your session. Please login again.'**
  String get msgSessionRejected;

  /// No description provided for @msgServerUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach the server. Make sure the backend is running and you\'re on the same network.'**
  String get msgServerUnreachable;

  /// No description provided for @msgProfileSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Your account was created, but we could not save the profile. Check your connection and try again.'**
  String get msgProfileSyncFailed;

  /// No description provided for @msgGoogleAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'This Google account is already registered. Please login instead.'**
  String get msgGoogleAlreadyRegistered;

  /// No description provided for @msgEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered. Please login.'**
  String get msgEmailInUse;

  /// No description provided for @msgInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password. Please try again.'**
  String get msgInvalidCredentials;

  /// No description provided for @msgUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'No account found for this email. Please sign up first.'**
  String get msgUserNotFound;

  /// No description provided for @msgWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'This password is too weak. Please choose a stronger one.'**
  String get msgWeakPassword;

  /// No description provided for @msgTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again later.'**
  String get msgTooManyRequests;

  /// No description provided for @msgNoConnection.
  ///
  /// In en, this message translates to:
  /// **'No connection. Check your internet and try again.'**
  String get msgNoConnection;

  /// No description provided for @msgSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please login again.'**
  String get msgSessionExpired;

  /// No description provided for @msgGoogleSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed. If this is a new build, make sure its SHA-1 is registered in Firebase.'**
  String get msgGoogleSignInFailed;

  /// No description provided for @msgGenericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get msgGenericError;

  /// No description provided for @msgReloginRequired.
  ///
  /// In en, this message translates to:
  /// **'For security, please log out and login again, then try once more.'**
  String get msgReloginRequired;

  /// No description provided for @msgBackendOutdated.
  ///
  /// In en, this message translates to:
  /// **'The server doesn’t support this action yet. Please restart the backend so it runs the latest version.'**
  String get msgBackendOutdated;

  /// No description provided for @msgRequestRejected.
  ///
  /// In en, this message translates to:
  /// **'The server didn’t accept this request.'**
  String get msgRequestRejected;

  /// No description provided for @msgRequestNotUnderstood.
  ///
  /// In en, this message translates to:
  /// **'The server didn’t understand this request. Please try again.'**
  String get msgRequestNotUnderstood;

  /// No description provided for @msgUnreadableResponse.
  ///
  /// In en, this message translates to:
  /// **'The server sent something we could not read. Please try again.'**
  String get msgUnreadableResponse;

  /// No description provided for @msgManagedByGoogle.
  ///
  /// In en, this message translates to:
  /// **'This account signs in with Google, so its email and password are managed by Google.'**
  String get msgManagedByGoogle;

  /// No description provided for @msgChildDataNotLoaded.
  ///
  /// In en, this message translates to:
  /// **'Child’s data has not been loaded yet. Please try again in a moment.'**
  String get msgChildDataNotLoaded;

  /// No description provided for @msgChildProfileNotFound.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t find this child’s profile. Please log out and login again.'**
  String get msgChildProfileNotFound;

  /// No description provided for @msgChildNameRejected.
  ///
  /// In en, this message translates to:
  /// **'The server didn’t accept this name. Use letters only, up to {maxLength} characters.'**
  String msgChildNameRejected(int maxLength);

  /// No description provided for @msgNameUpdated.
  ///
  /// In en, this message translates to:
  /// **'Name updated successfully!'**
  String get msgNameUpdated;

  /// No description provided for @msgMascotInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please choose one of the mascots.'**
  String get msgMascotInvalid;

  /// No description provided for @msgMascotRejected.
  ///
  /// In en, this message translates to:
  /// **'The server didn’t accept this mascot. Please choose another one.'**
  String get msgMascotRejected;

  /// No description provided for @msgMascotUpdated.
  ///
  /// In en, this message translates to:
  /// **'Mascot updated!'**
  String get msgMascotUpdated;

  /// No description provided for @msgCurrentPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Current password is required!'**
  String get msgCurrentPasswordRequired;

  /// No description provided for @msgCurrentPasswordIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Current password is incorrect.'**
  String get msgCurrentPasswordIncorrect;

  /// No description provided for @msgPasswordsMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match!'**
  String get msgPasswordsMismatch;

  /// No description provided for @msgPasswordSameAsCurrent.
  ///
  /// In en, this message translates to:
  /// **'New password must be different from the current one.'**
  String get msgPasswordSameAsCurrent;

  /// No description provided for @msgPasswordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully!'**
  String get msgPasswordUpdated;

  /// No description provided for @msgSameEmail.
  ///
  /// In en, this message translates to:
  /// **'This is already your email address.'**
  String get msgSameEmail;

  /// No description provided for @msgVerificationSent.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification link to {email}. Your email changes after you open the link.'**
  String msgVerificationSent(String email);

  /// No description provided for @msgFeedbackCategoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Please choose a category.'**
  String get msgFeedbackCategoryRequired;

  /// No description provided for @msgFeedbackEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please write your feedback first.'**
  String get msgFeedbackEmpty;

  /// No description provided for @msgFeedbackTooShort.
  ///
  /// In en, this message translates to:
  /// **'Your message is too short. Please add a little more detail.'**
  String get msgFeedbackTooShort;

  /// No description provided for @msgFeedbackTooLong.
  ///
  /// In en, this message translates to:
  /// **'Your message is too long. Please keep it under {maxLength} characters.'**
  String msgFeedbackTooLong(int maxLength);

  /// No description provided for @msgFeedbackRejected.
  ///
  /// In en, this message translates to:
  /// **'The server didn’t accept this message. Please check it and try again.'**
  String get msgFeedbackRejected;

  /// No description provided for @msgAccountNotFound.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t find your account. Please log out and login again.'**
  String get msgAccountNotFound;

  /// No description provided for @msgFeedbackRateLimited.
  ///
  /// In en, this message translates to:
  /// **'You have sent a lot of feedback recently. Please try again later.'**
  String get msgFeedbackRateLimited;

  /// No description provided for @msgFeedbackSent.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback!'**
  String get msgFeedbackSent;

  /// No description provided for @msgPhotoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile photo updated!'**
  String get msgPhotoUpdated;

  /// No description provided for @msgPhotoRemoved.
  ///
  /// In en, this message translates to:
  /// **'Profile photo removed.'**
  String get msgPhotoRemoved;

  /// No description provided for @msgPhotoUnsupported.
  ///
  /// In en, this message translates to:
  /// **'That file isn’t a supported photo. Please use a JPG, PNG or WebP image.'**
  String get msgPhotoUnsupported;

  /// No description provided for @msgPhotoTooLarge.
  ///
  /// In en, this message translates to:
  /// **'That photo is too large. Please choose one under 5 MB.'**
  String get msgPhotoTooLarge;

  /// No description provided for @msgPhotoUnreadable.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t read that photo. Please choose another one.'**
  String get msgPhotoUnreadable;

  /// No description provided for @msgPhotoPickerFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t open the photo picker. Please try again.'**
  String get msgPhotoPickerFailed;

  /// No description provided for @msgFavoriteAdded.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites.'**
  String get msgFavoriteAdded;

  /// No description provided for @msgFavoriteRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites.'**
  String get msgFavoriteRemoved;

  /// No description provided for @msgStoryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Story deleted.'**
  String get msgStoryDeleted;

  /// No description provided for @msgStoryNotFound.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t find that story. It may have been removed.'**
  String get msgStoryNotFound;

  /// No description provided for @msgAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the address of your computer, like 192.168.1.5:8080.'**
  String get msgAddressRequired;

  /// No description provided for @msgAddressInvalid.
  ///
  /// In en, this message translates to:
  /// **'That doesn’t look like an address. Try something like 192.168.1.5:8080.'**
  String get msgAddressInvalid;

  /// No description provided for @msgAddressBadScheme.
  ///
  /// In en, this message translates to:
  /// **'The address must start with http:// or https://.'**
  String get msgAddressBadScheme;

  /// No description provided for @msgAddressExtraParts.
  ///
  /// In en, this message translates to:
  /// **'Enter only the address and port, like 192.168.1.5:8080.'**
  String get msgAddressExtraParts;

  /// No description provided for @msgAddressNotLocal.
  ///
  /// In en, this message translates to:
  /// **'Use your computer’s address on the same Wi-Fi (like 192.168.1.5), not an internet address.'**
  String get msgAddressNotLocal;

  /// No description provided for @msgAddressNotTalepuff.
  ///
  /// In en, this message translates to:
  /// **'We reached a server there, but it is not the TalePuff backend, or it needs a restart.'**
  String get msgAddressNotTalepuff;

  /// No description provided for @msgAddressUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Can’t reach that address. Check that the backend is running and your phone is on the same Wi-Fi.'**
  String get msgAddressUnreachable;

  /// No description provided for @updateName.
  ///
  /// In en, this message translates to:
  /// **'Update Name'**
  String get updateName;

  /// No description provided for @newEmail.
  ///
  /// In en, this message translates to:
  /// **'New email'**
  String get newEmail;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @enterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password'**
  String get enterCurrentPassword;

  /// No description provided for @updateEmail.
  ///
  /// In en, this message translates to:
  /// **'Update Email'**
  String get updateEmail;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @newPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'At least {minLength} characters, letters and numbers'**
  String newPasswordHint(int minLength);

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm your new password'**
  String get confirmNewPassword;

  /// No description provided for @mascotIntro.
  ///
  /// In en, this message translates to:
  /// **'Choose the friend who greets your child on the home screen.'**
  String get mascotIntro;

  /// No description provided for @updateMascot.
  ///
  /// In en, this message translates to:
  /// **'Update Mascot'**
  String get updateMascot;

  /// No description provided for @mascotHarimau.
  ///
  /// In en, this message translates to:
  /// **'Sumatran Tiger'**
  String get mascotHarimau;

  /// No description provided for @mascotOrangUtan.
  ///
  /// In en, this message translates to:
  /// **'Orangutan'**
  String get mascotOrangUtan;

  /// No description provided for @mascotBadak.
  ///
  /// In en, this message translates to:
  /// **'Javan Rhino'**
  String get mascotBadak;

  /// No description provided for @mascotBurung.
  ///
  /// In en, this message translates to:
  /// **'Bird of Paradise'**
  String get mascotBurung;

  /// No description provided for @feedbackIntro.
  ///
  /// In en, this message translates to:
  /// **'Tell us what is not working or what you would like to see.'**
  String get feedbackIntro;

  /// No description provided for @feedbackBug.
  ///
  /// In en, this message translates to:
  /// **'Bug'**
  String get feedbackBug;

  /// No description provided for @feedbackIdea.
  ///
  /// In en, this message translates to:
  /// **'Idea'**
  String get feedbackIdea;

  /// No description provided for @feedbackOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get feedbackOther;

  /// No description provided for @feedbackHint.
  ///
  /// In en, this message translates to:
  /// **'Write your message here...'**
  String get feedbackHint;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @serverConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected to the server'**
  String get serverConnected;

  /// No description provided for @serverSaved.
  ///
  /// In en, this message translates to:
  /// **'Server address saved'**
  String get serverSaved;

  /// No description provided for @serverBackToDefault.
  ///
  /// In en, this message translates to:
  /// **'Back to the built-in address'**
  String get serverBackToDefault;

  /// No description provided for @serverAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Server address'**
  String get serverAddressLabel;

  /// No description provided for @serverAddressHelp.
  ///
  /// In en, this message translates to:
  /// **'Use your computer’s address on the same Wi-Fi. On the computer, run ipconfig and look for the IPv4 address.'**
  String get serverAddressHelp;

  /// No description provided for @testConnection.
  ///
  /// In en, this message translates to:
  /// **'Test connection'**
  String get testConnection;

  /// No description provided for @useBuiltInAddress.
  ///
  /// In en, this message translates to:
  /// **'Use the built-in address'**
  String get useBuiltInAddress;

  /// No description provided for @legalLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'This document could not be loaded.'**
  String get legalLoadFailed;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get greetingEvening;

  /// No description provided for @homePrompt.
  ///
  /// In en, this message translates to:
  /// **'What story do you want to hear today?'**
  String get homePrompt;

  /// No description provided for @searchStory.
  ///
  /// In en, this message translates to:
  /// **'Search your story'**
  String get searchStory;

  /// No description provided for @createNewStory.
  ///
  /// In en, this message translates to:
  /// **'Create New Story'**
  String get createNewStory;

  /// No description provided for @playLastStory.
  ///
  /// In en, this message translates to:
  /// **'Play Last Story'**
  String get playLastStory;

  /// No description provided for @playLastStoryComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Play Last Story is coming soon!'**
  String get playLastStoryComingSoon;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navStory.
  ///
  /// In en, this message translates to:
  /// **'Story'**
  String get navStory;

  /// No description provided for @navCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get navCreate;

  /// No description provided for @navParents.
  ///
  /// In en, this message translates to:
  /// **'Parents'**
  String get navParents;

  /// No description provided for @ageYears.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 year old} other{{count} years old}}'**
  String ageYears(int count);

  /// No description provided for @profileIntro.
  ///
  /// In en, this message translates to:
  /// **'Hi, I’m {name}'**
  String profileIntro(String name);

  /// No description provided for @profileLikes1.
  ///
  /// In en, this message translates to:
  /// **'I like {a}!'**
  String profileLikes1(String a);

  /// No description provided for @profileLikes2.
  ///
  /// In en, this message translates to:
  /// **'I like {a} and {b}!'**
  String profileLikes2(String a, String b);

  /// No description provided for @profileLikesMany.
  ///
  /// In en, this message translates to:
  /// **'I like {rest}, and {last}!'**
  String profileLikesMany(String rest, String last);

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'{name}’s listening week overview'**
  String statsTitle(String name);

  /// No description provided for @statsMood.
  ///
  /// In en, this message translates to:
  /// **'{count} Mood'**
  String statsMood(int count);

  /// No description provided for @statsStories.
  ///
  /// In en, this message translates to:
  /// **'{count} Stories'**
  String statsStories(int count);

  /// No description provided for @statsMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} Minutes'**
  String statsMinutes(int count);

  /// No description provided for @bedtimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto Bedtime Story'**
  String get bedtimeTitle;

  /// No description provided for @bedtimeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'automatically play last stories at certain times'**
  String get bedtimeSubtitle;

  /// No description provided for @enterTime.
  ///
  /// In en, this message translates to:
  /// **'Enter time'**
  String get enterTime;

  /// No description provided for @photoTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile Picture'**
  String get photoTitle;

  /// No description provided for @photoCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get photoCamera;

  /// No description provided for @photoLibrary.
  ///
  /// In en, this message translates to:
  /// **'Choose from library'**
  String get photoLibrary;

  /// No description provided for @photoRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get photoRemove;

  /// No description provided for @photoCropTitle.
  ///
  /// In en, this message translates to:
  /// **'Adjust Profile Photo'**
  String get photoCropTitle;

  /// No description provided for @msgConnectionLost.
  ///
  /// In en, this message translates to:
  /// **'We lost the connection to the server. Your story may still be finishing, so check the Story page in a moment.'**
  String get msgConnectionLost;

  /// No description provided for @msgNoticeNameReplaced.
  ///
  /// In en, this message translates to:
  /// **'That character name can’t be used in stories, so we called them Pip instead.'**
  String get msgNoticeNameReplaced;

  /// No description provided for @msgNoticeBothReplaced.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t use that character name or part of your idea, so we wrote a gentle story about Pip instead.'**
  String get msgNoticeBothReplaced;

  /// No description provided for @msgNoticeIdeaDropped.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t use part of your idea, so we wrote a gentle story instead.'**
  String get msgNoticeIdeaDropped;

  /// No description provided for @msgJobAiUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The story service isn’t running right now. Please try again in a moment.'**
  String get msgJobAiUnavailable;

  /// No description provided for @msgJobAiFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t write the story this time. Please try again.'**
  String get msgJobAiFailed;

  /// No description provided for @msgJobVoiceFailed.
  ///
  /// In en, this message translates to:
  /// **'Your story was saved, but we couldn’t create its voice.'**
  String get msgJobVoiceFailed;

  /// No description provided for @msgJobSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t save the story. Please try again.'**
  String get msgJobSaveFailed;

  /// No description provided for @msgJobInterrupted.
  ///
  /// In en, this message translates to:
  /// **'The story was interrupted. Please try again.'**
  String get msgJobInterrupted;

  /// No description provided for @msgJobFailed.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while creating the story. Please try again.'**
  String get msgJobFailed;

  /// No description provided for @msgCharacterNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a character name.'**
  String get msgCharacterNameRequired;

  /// No description provided for @msgChildProfileMissing.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t find the child profile. Please log out and log in again.'**
  String get msgChildProfileMissing;

  /// No description provided for @msgChooseMissing.
  ///
  /// In en, this message translates to:
  /// **'Please choose {items}.'**
  String msgChooseMissing(String items);

  /// No description provided for @fieldCategory.
  ///
  /// In en, this message translates to:
  /// **'a category'**
  String get fieldCategory;

  /// No description provided for @fieldLength.
  ///
  /// In en, this message translates to:
  /// **'a story length'**
  String get fieldLength;

  /// No description provided for @fieldVoice.
  ///
  /// In en, this message translates to:
  /// **'a voice'**
  String get fieldVoice;

  /// No description provided for @createHeader.
  ///
  /// In en, this message translates to:
  /// **'I want a story about...'**
  String get createHeader;

  /// No description provided for @createCharacterName.
  ///
  /// In en, this message translates to:
  /// **'Character Name'**
  String get createCharacterName;

  /// No description provided for @createNicknameHint.
  ///
  /// In en, this message translates to:
  /// **'Custom Your Nickname'**
  String get createNicknameHint;

  /// No description provided for @createStoryLength.
  ///
  /// In en, this message translates to:
  /// **'Story Length'**
  String get createStoryLength;

  /// No description provided for @createMood.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get createMood;

  /// No description provided for @createVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get createVoice;

  /// No description provided for @createDescribe.
  ///
  /// In en, this message translates to:
  /// **'Describe Your Story'**
  String get createDescribe;

  /// No description provided for @createDescribeHint.
  ///
  /// In en, this message translates to:
  /// **'Optional, max 30 words. English or Indonesian is fine.'**
  String get createDescribeHint;

  /// No description provided for @generateStory.
  ///
  /// In en, this message translates to:
  /// **'Generate Story'**
  String get generateStory;

  /// No description provided for @regenerate.
  ///
  /// In en, this message translates to:
  /// **'Re-Generate'**
  String get regenerate;

  /// No description provided for @lengthMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} Minutes'**
  String lengthMinutes(int count);

  /// No description provided for @themeDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get themeDaily;

  /// No description provided for @themeFriendship.
  ///
  /// In en, this message translates to:
  /// **'Friendship'**
  String get themeFriendship;

  /// No description provided for @themeAdventure.
  ///
  /// In en, this message translates to:
  /// **'Adventure'**
  String get themeAdventure;

  /// No description provided for @themeFeeling.
  ///
  /// In en, this message translates to:
  /// **'Feeling'**
  String get themeFeeling;

  /// No description provided for @moodCalm.
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get moodCalm;

  /// No description provided for @moodCurious.
  ///
  /// In en, this message translates to:
  /// **'Curious'**
  String get moodCurious;

  /// No description provided for @moodWarm.
  ///
  /// In en, this message translates to:
  /// **'Warm'**
  String get moodWarm;

  /// No description provided for @moodJoyful.
  ///
  /// In en, this message translates to:
  /// **'Joyful'**
  String get moodJoyful;

  /// No description provided for @moodFantasy.
  ///
  /// In en, this message translates to:
  /// **'Fantasy'**
  String get moodFantasy;

  /// No description provided for @moodCozy.
  ///
  /// In en, this message translates to:
  /// **'Cozy'**
  String get moodCozy;

  /// No description provided for @moodBrave.
  ///
  /// In en, this message translates to:
  /// **'Brave'**
  String get moodBrave;

  /// No description provided for @moodNature.
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get moodNature;

  /// No description provided for @voiceWarm.
  ///
  /// In en, this message translates to:
  /// **'Warm'**
  String get voiceWarm;

  /// No description provided for @voiceBrave.
  ///
  /// In en, this message translates to:
  /// **'Brave'**
  String get voiceBrave;

  /// No description provided for @voiceGentle.
  ///
  /// In en, this message translates to:
  /// **'Gentle'**
  String get voiceGentle;

  /// No description provided for @voiceCharacter.
  ///
  /// In en, this message translates to:
  /// **'Character'**
  String get voiceCharacter;

  /// No description provided for @voiceFriendly.
  ///
  /// In en, this message translates to:
  /// **'Friendly'**
  String get voiceFriendly;

  /// No description provided for @voiceNeutral.
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get voiceNeutral;

  /// No description provided for @loadingStarting.
  ///
  /// In en, this message translates to:
  /// **'Getting ready...'**
  String get loadingStarting;

  /// No description provided for @loadingWriting.
  ///
  /// In en, this message translates to:
  /// **'Writing your story...'**
  String get loadingWriting;

  /// No description provided for @loadingVoice.
  ///
  /// In en, this message translates to:
  /// **'Creating the voice...'**
  String get loadingVoice;

  /// No description provided for @loadingDone.
  ///
  /// In en, this message translates to:
  /// **'Your story is ready'**
  String get loadingDone;

  /// No description provided for @loadingFailed.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get loadingFailed;

  /// No description provided for @loadingStartingUp.
  ///
  /// In en, this message translates to:
  /// **'Starting up'**
  String get loadingStartingUp;

  /// No description provided for @loadingStep.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of 2'**
  String loadingStep(int step);

  /// No description provided for @loadingTakesMinute.
  ///
  /// In en, this message translates to:
  /// **'This can take up to a minute'**
  String get loadingTakesMinute;

  /// No description provided for @loadingKeepWorking.
  ///
  /// In en, this message translates to:
  /// **'We’ll keep working on it. Your story will appear in Story when it’s ready.'**
  String get loadingKeepWorking;

  /// No description provided for @openStory.
  ///
  /// In en, this message translates to:
  /// **'Open story'**
  String get openStory;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @storyTabRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get storyTabRecent;

  /// No description provided for @storyTabFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get storyTabFavorites;

  /// No description provided for @storyTabPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get storyTabPopular;

  /// No description provided for @storiesOf.
  ///
  /// In en, this message translates to:
  /// **'{name}’s stories'**
  String storiesOf(String name);

  /// No description provided for @searchStories.
  ///
  /// In en, this message translates to:
  /// **'Search stories...'**
  String get searchStories;

  /// No description provided for @untitledStory.
  ///
  /// In en, this message translates to:
  /// **'Untitled story'**
  String get untitledStory;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String minutesShort(int count);

  /// No description provided for @storyCreated.
  ///
  /// In en, this message translates to:
  /// **'Created {when}'**
  String storyCreated(String when);

  /// No description provided for @timeJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get timeJustNow;

  /// No description provided for @timeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String timeMinutesAgo(int count);

  /// No description provided for @timeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} h ago'**
  String timeHoursAgo(int count);

  /// No description provided for @timeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} d ago'**
  String timeDaysAgo(int count);

  /// No description provided for @timeDate.
  ///
  /// In en, this message translates to:
  /// **'{date}'**
  String timeDate(DateTime date);

  /// No description provided for @timeDateYear.
  ///
  /// In en, this message translates to:
  /// **'{date}'**
  String timeDateYear(DateTime date);

  /// No description provided for @deleteStoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this story?'**
  String get deleteStoryTitle;

  /// No description provided for @deleteStoryBody.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" and its voice will be removed. This can’t be undone.'**
  String deleteStoryBody(String title);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @noStoriesMatch.
  ///
  /// In en, this message translates to:
  /// **'No stories match \"{query}\".'**
  String noStoriesMatch(String query);

  /// No description provided for @noFavorites.
  ///
  /// In en, this message translates to:
  /// **'No favorite stories yet.\nTap the heart on a story to keep it here.'**
  String get noFavorites;

  /// No description provided for @noPopular.
  ///
  /// In en, this message translates to:
  /// **'Stories you play the most will show up here.'**
  String get noPopular;

  /// No description provided for @noStories.
  ///
  /// In en, this message translates to:
  /// **'No story has been created.'**
  String get noStories;

  /// No description provided for @createFirstStory.
  ///
  /// In en, this message translates to:
  /// **'Let’s create a story'**
  String get createFirstStory;

  /// No description provided for @storyLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'This story could not be loaded.'**
  String get storyLoadFailed;

  /// No description provided for @playOnTotem.
  ///
  /// In en, this message translates to:
  /// **'Play on totem'**
  String get playOnTotem;

  /// No description provided for @playOnTotemSoon.
  ///
  /// In en, this message translates to:
  /// **'Playing on the totem is coming soon!'**
  String get playOnTotemSoon;

  /// No description provided for @msgTotemInvalidId.
  ///
  /// In en, this message translates to:
  /// **'That doesn’t look like a totem ID. Use letters, numbers and dashes, like totem-001.'**
  String get msgTotemInvalidId;

  /// No description provided for @msgTotemNotVisible.
  ///
  /// In en, this message translates to:
  /// **'We can’t see this totem. Make sure it is on and connected to Wi-Fi.'**
  String get msgTotemNotVisible;

  /// No description provided for @msgTotemTaken.
  ///
  /// In en, this message translates to:
  /// **'This totem is already linked to another account.'**
  String get msgTotemTaken;

  /// No description provided for @msgTotemNotPaired.
  ///
  /// In en, this message translates to:
  /// **'Link a totem first in Settings.'**
  String get msgTotemNotPaired;

  /// No description provided for @msgTotemOffline.
  ///
  /// In en, this message translates to:
  /// **'Your totem is offline. Turn it on and try again.'**
  String get msgTotemOffline;

  /// No description provided for @msgTotemUnreachable.
  ///
  /// In en, this message translates to:
  /// **'We can’t reach the totem right now. Please try again.'**
  String get msgTotemUnreachable;

  /// No description provided for @msgTotemUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The totem feature isn’t set up on the server yet.'**
  String get msgTotemUnavailable;

  /// No description provided for @msgStoryNoVoice.
  ///
  /// In en, this message translates to:
  /// **'This story has no voice yet, so the totem can’t play it.'**
  String get msgStoryNoVoice;

  /// No description provided for @msgTotemLinked.
  ///
  /// In en, this message translates to:
  /// **'Totem linked!'**
  String get msgTotemLinked;

  /// No description provided for @msgTotemUnlinked.
  ///
  /// In en, this message translates to:
  /// **'Totem unlinked.'**
  String get msgTotemUnlinked;

  /// No description provided for @msgTotemSent.
  ///
  /// In en, this message translates to:
  /// **'Sent to the totem.'**
  String get msgTotemSent;

  /// No description provided for @totem.
  ///
  /// In en, this message translates to:
  /// **'Totem'**
  String get totem;

  /// No description provided for @totemNotLinked.
  ///
  /// In en, this message translates to:
  /// **'Not linked'**
  String get totemNotLinked;

  /// No description provided for @totemLinkedTo.
  ///
  /// In en, this message translates to:
  /// **'Linked to {id}'**
  String totemLinkedTo(String id);

  /// No description provided for @totemId.
  ///
  /// In en, this message translates to:
  /// **'Totem ID'**
  String get totemId;

  /// No description provided for @totemLinkIntro.
  ///
  /// In en, this message translates to:
  /// **'Enter the ID printed on your totem. It must be turned on and connected to Wi-Fi.'**
  String get totemLinkIntro;

  /// No description provided for @totemLink.
  ///
  /// In en, this message translates to:
  /// **'Link totem'**
  String get totemLink;

  /// No description provided for @totemUnlink.
  ///
  /// In en, this message translates to:
  /// **'Unlink totem'**
  String get totemUnlink;

  /// No description provided for @totemOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get totemOnline;

  /// No description provided for @totemOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get totemOffline;

  /// No description provided for @totemStateIdle.
  ///
  /// In en, this message translates to:
  /// **'Idle'**
  String get totemStateIdle;

  /// No description provided for @totemStateLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get totemStateLoading;

  /// No description provided for @totemStatePlaying.
  ///
  /// In en, this message translates to:
  /// **'Playing'**
  String get totemStatePlaying;

  /// No description provided for @totemStatePaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get totemStatePaused;

  /// No description provided for @totemStateError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get totemStateError;

  /// No description provided for @totemStateUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get totemStateUnknown;

  /// No description provided for @totemNowPlaying.
  ///
  /// In en, this message translates to:
  /// **'Now playing on the totem'**
  String get totemNowPlaying;

  /// No description provided for @totemVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get totemVolume;
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
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
