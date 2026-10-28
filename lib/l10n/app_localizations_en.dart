// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get language => 'Language';

  @override
  String get languageFollowDevice => 'Follow device';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageIndonesian => 'Bahasa Indonesia';

  @override
  String get languageStoriesNote =>
      'Stories are always written in simple English.';

  @override
  String get landingTitle => 'Create your own story';

  @override
  String get landingSubtitle =>
      'Help your child learn English through stories they love';

  @override
  String get landingGetStarted => 'Let’s go';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get login => 'Login';

  @override
  String get signUp => 'Sign Up';

  @override
  String get signUpWithGoogle => 'Sign Up with Google';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get rememberMe => 'Remember Me';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get newUser => 'New User? ';

  @override
  String get acceptTermsPrefix => 'I accept the ';

  @override
  String get termsOfService => 'terms of service';

  @override
  String get acceptTermsAnd => ' & ';

  @override
  String get privacyPolicyLink => 'privacy policy';

  @override
  String get childInfoTitle => 'Child’s Information';

  @override
  String get basicInfo => 'Basic Info';

  @override
  String get childName => 'Child’s Name';

  @override
  String get enterChildName => 'Enter the name of your child';

  @override
  String get age => 'Age';

  @override
  String get enterAgeOptional => 'Enter age (optional)';

  @override
  String get gender => 'Gender';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get genderNotSpecified => 'N/A';

  @override
  String get interest => 'Interest';

  @override
  String interestSlotsRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count slots remaining',
      one: '1 slot remaining',
      zero: 'No slots left',
    );
    return '$_temp0';
  }

  @override
  String get interestSports => 'Sports';

  @override
  String get interestMusic => 'Music';

  @override
  String get interestArt => 'Art';

  @override
  String get interestScience => 'Science';

  @override
  String get interestNature => 'Nature';

  @override
  String get interestSpace => 'Space';

  @override
  String get interestMagic => 'Magic';

  @override
  String get interestReading => 'Reading';

  @override
  String get interestDancing => 'Dancing';

  @override
  String get interestGames => 'Games';

  @override
  String get save => 'Save';

  @override
  String get saveAndContinue => 'Save & Continue';

  @override
  String get useDifferentAccount => 'Use a different account';

  @override
  String get tryAgain => 'Try again';

  @override
  String get changeServerAddress => 'Change server address';

  @override
  String get settings => 'Settings';

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get mascot => 'Mascot';

  @override
  String get updatePassword => 'Update Password';

  @override
  String get volumeLimit => 'Volume Limit';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get serverAddress => 'Server Address';

  @override
  String get sendFeedback => 'Send Feedback';

  @override
  String get termsAndConditions => 'Terms and Conditions';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get logout => 'Logout';

  @override
  String get msgCredentialsRequired => 'Email and Password are required!';

  @override
  String get msgEmailRequired => 'Email is required!';

  @override
  String get msgEmailInvalid => 'Invalid email format, please check again!';

  @override
  String get msgPasswordRequired => 'Password is required!';

  @override
  String msgPasswordRules(int minLength) {
    return 'Password must be at least $minLength characters with letters and numbers!';
  }

  @override
  String get msgTermsNotAccepted =>
      'Please accept our Terms and Conditions to continue.';

  @override
  String get msgChildInfoMissing => 'Please fill child\'s information first';

  @override
  String get msgFillMandatory => 'Please fill in all mandatory fields!';

  @override
  String get msgAgeInvalid => 'Please enter a valid age.';

  @override
  String get msgChildNameRequired => 'Child\'s name is required!';

  @override
  String msgChildNameTooLong(int maxLength) {
    return 'Name must be at most $maxLength characters.';
  }

  @override
  String get msgChildNameInvalid =>
      'Use letters only (spaces, \' and - are allowed), starting with a letter.';

  @override
  String get msgSessionRejected =>
      'The server rejected your session. Please login again.';

  @override
  String get msgServerUnreachable =>
      'Can\'t reach the server. Make sure the backend is running and you\'re on the same network.';

  @override
  String get msgProfileSyncFailed =>
      'Your account was created, but we could not save the profile. Check your connection and try again.';

  @override
  String get msgGoogleAlreadyRegistered =>
      'This Google account is already registered. Please login instead.';

  @override
  String get msgEmailInUse => 'This email is already registered. Please login.';

  @override
  String get msgInvalidCredentials =>
      'Incorrect email or password. Please try again.';

  @override
  String get msgUserNotFound =>
      'No account found for this email. Please sign up first.';

  @override
  String get msgWeakPassword =>
      'This password is too weak. Please choose a stronger one.';

  @override
  String get msgTooManyRequests => 'Too many attempts. Please try again later.';

  @override
  String get msgNoConnection =>
      'No connection. Check your internet and try again.';

  @override
  String get msgSessionExpired =>
      'Your session has expired. Please login again.';

  @override
  String get msgGoogleSignInFailed =>
      'Google sign-in failed. If this is a new build, make sure its SHA-1 is registered in Firebase.';

  @override
  String get msgGenericError => 'Something went wrong. Please try again.';

  @override
  String get msgReloginRequired =>
      'For security, please log out and login again, then try once more.';

  @override
  String get msgBackendOutdated =>
      'The server doesn’t support this action yet. Please restart the backend so it runs the latest version.';

  @override
  String get msgRequestRejected => 'The server didn’t accept this request.';

  @override
  String get msgRequestNotUnderstood =>
      'The server didn’t understand this request. Please try again.';

  @override
  String get msgUnreadableResponse =>
      'The server sent something we could not read. Please try again.';

  @override
  String get msgManagedByGoogle =>
      'This account signs in with Google, so its email and password are managed by Google.';

  @override
  String get msgChildDataNotLoaded =>
      'Child’s data has not been loaded yet. Please try again in a moment.';

  @override
  String get msgChildProfileNotFound =>
      'We couldn’t find this child’s profile. Please log out and login again.';

  @override
  String msgChildNameRejected(int maxLength) {
    return 'The server didn’t accept this name. Use letters only, up to $maxLength characters.';
  }

  @override
  String get msgNameUpdated => 'Name updated successfully!';

  @override
  String get msgMascotInvalid => 'Please choose one of the mascots.';

  @override
  String get msgMascotRejected =>
      'The server didn’t accept this mascot. Please choose another one.';

  @override
  String get msgMascotUpdated => 'Mascot updated!';

  @override
  String get msgCurrentPasswordRequired => 'Current password is required!';

  @override
  String get msgCurrentPasswordIncorrect => 'Current password is incorrect.';

  @override
  String get msgPasswordsMismatch => 'Passwords do not match!';

  @override
  String get msgPasswordSameAsCurrent =>
      'New password must be different from the current one.';

  @override
  String get msgPasswordUpdated => 'Password updated successfully!';

  @override
  String get msgSameEmail => 'This is already your email address.';

  @override
  String msgVerificationSent(String email) {
    return 'We sent a verification link to $email. Your email changes after you open the link.';
  }

  @override
  String get msgFeedbackCategoryRequired => 'Please choose a category.';

  @override
  String get msgFeedbackEmpty => 'Please write your feedback first.';

  @override
  String get msgFeedbackTooShort =>
      'Your message is too short. Please add a little more detail.';

  @override
  String msgFeedbackTooLong(int maxLength) {
    return 'Your message is too long. Please keep it under $maxLength characters.';
  }

  @override
  String get msgFeedbackRejected =>
      'The server didn’t accept this message. Please check it and try again.';

  @override
  String get msgAccountNotFound =>
      'We couldn’t find your account. Please log out and login again.';

  @override
  String get msgFeedbackRateLimited =>
      'You have sent a lot of feedback recently. Please try again later.';

  @override
  String get msgFeedbackSent => 'Thank you for your feedback!';

  @override
  String get msgPhotoUpdated => 'Profile photo updated!';

  @override
  String get msgPhotoRemoved => 'Profile photo removed.';

  @override
  String get msgPhotoUnsupported =>
      'That file isn’t a supported photo. Please use a JPG, PNG or WebP image.';

  @override
  String get msgPhotoTooLarge =>
      'That photo is too large. Please choose one under 5 MB.';

  @override
  String get msgPhotoUnreadable =>
      'We couldn’t read that photo. Please choose another one.';

  @override
  String get msgPhotoPickerFailed =>
      'We couldn’t open the photo picker. Please try again.';

  @override
  String get msgFavoriteAdded => 'Added to favorites.';

  @override
  String get msgFavoriteRemoved => 'Removed from favorites.';

  @override
  String get msgStoryDeleted => 'Story deleted.';

  @override
  String get msgStoryNotFound =>
      'We couldn’t find that story. It may have been removed.';

  @override
  String get msgAddressRequired =>
      'Enter the address of your computer, like 192.168.1.5:8080.';

  @override
  String get msgAddressInvalid =>
      'That doesn’t look like an address. Try something like 192.168.1.5:8080.';

  @override
  String get msgAddressBadScheme =>
      'The address must start with http:// or https://.';

  @override
  String get msgAddressExtraParts =>
      'Enter only the address and port, like 192.168.1.5:8080.';

  @override
  String get msgAddressNotLocal =>
      'Use your computer’s address on the same Wi-Fi (like 192.168.1.5), not an internet address.';

  @override
  String get msgAddressNotTalepuff =>
      'We reached a server there, but it is not the TalePuff backend, or it needs a restart.';

  @override
  String get msgAddressUnreachable =>
      'Can’t reach that address. Check that the backend is running and your phone is on the same Wi-Fi.';

  @override
  String get updateName => 'Update Name';

  @override
  String get newEmail => 'New email';

  @override
  String get currentPassword => 'Current password';

  @override
  String get enterCurrentPassword => 'Enter your current password';

  @override
  String get updateEmail => 'Update Email';

  @override
  String get newPassword => 'New password';

  @override
  String newPasswordHint(int minLength) {
    return 'At least $minLength characters, letters and numbers';
  }

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get confirmNewPassword => 'Confirm your new password';

  @override
  String get mascotIntro =>
      'Choose the friend who greets your child on the home screen.';

  @override
  String get updateMascot => 'Update Mascot';

  @override
  String get mascotHarimau => 'Sumatran Tiger';

  @override
  String get mascotOrangUtan => 'Orangutan';

  @override
  String get mascotBadak => 'Javan Rhino';

  @override
  String get mascotBurung => 'Bird of Paradise';

  @override
  String get feedbackIntro =>
      'Tell us what is not working or what you would like to see.';

  @override
  String get feedbackBug => 'Bug';

  @override
  String get feedbackIdea => 'Idea';

  @override
  String get feedbackOther => 'Other';

  @override
  String get feedbackHint => 'Write your message here...';

  @override
  String get send => 'Send';

  @override
  String get serverConnected => 'Connected to the server';

  @override
  String get serverSaved => 'Server address saved';

  @override
  String get serverBackToDefault => 'Back to the built-in address';

  @override
  String get serverAddressLabel => 'Server address';

  @override
  String get serverAddressHelp =>
      'Use your computer’s address on the same Wi-Fi. On the computer, run ipconfig and look for the IPv4 address.';

  @override
  String get testConnection => 'Test connection';

  @override
  String get useBuiltInAddress => 'Use the built-in address';

  @override
  String get legalLoadFailed => 'This document could not be loaded.';

  @override
  String get greetingMorning => 'Good Morning';

  @override
  String get greetingAfternoon => 'Good Afternoon';

  @override
  String get greetingEvening => 'Good Evening';

  @override
  String get homePrompt => 'What story do you want to hear today?';

  @override
  String get searchStory => 'Search your story';

  @override
  String get createNewStory => 'Create New Story';

  @override
  String get playLastStory => 'Play Last Story';

  @override
  String get playLastStoryComingSoon => 'Play Last Story is coming soon!';

  @override
  String get navHome => 'Home';

  @override
  String get navStory => 'Story';

  @override
  String get navCreate => 'Create';

  @override
  String get navParents => 'Parents';

  @override
  String ageYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years old',
      one: '1 year old',
    );
    return '$_temp0';
  }

  @override
  String profileIntro(String name) {
    return 'Hi, I’m $name';
  }

  @override
  String profileLikes1(String a) {
    return 'I like $a!';
  }

  @override
  String profileLikes2(String a, String b) {
    return 'I like $a and $b!';
  }

  @override
  String profileLikesMany(String rest, String last) {
    return 'I like $rest, and $last!';
  }

  @override
  String statsTitle(String name) {
    return '$name’s listening week overview';
  }

  @override
  String statsMood(int count) {
    return '$count Mood';
  }

  @override
  String statsStories(int count) {
    return '$count Stories';
  }

  @override
  String statsMinutes(int count) {
    return '$count Minutes';
  }

  @override
  String get bedtimeTitle => 'Auto Bedtime Story';

  @override
  String get bedtimeSubtitle =>
      'automatically play last stories at certain times';

  @override
  String get enterTime => 'Enter time';

  @override
  String get photoTitle => 'Profile Picture';

  @override
  String get photoCamera => 'Camera';

  @override
  String get photoLibrary => 'Choose from library';

  @override
  String get photoRemove => 'Remove Photo';

  @override
  String get photoCropTitle => 'Adjust Profile Photo';

  @override
  String get msgConnectionLost =>
      'We lost the connection to the server. Your story may still be finishing, so check the Story page in a moment.';

  @override
  String get msgNoticeNameReplaced =>
      'That character name can’t be used in stories, so we called them Pip instead.';

  @override
  String get msgNoticeBothReplaced =>
      'We couldn’t use that character name or part of your idea, so we wrote a gentle story about Pip instead.';

  @override
  String get msgNoticeIdeaDropped =>
      'We couldn’t use part of your idea, so we wrote a gentle story instead.';

  @override
  String get msgJobAiUnavailable =>
      'The story service isn’t running right now. Please try again in a moment.';

  @override
  String get msgJobAiFailed =>
      'We couldn’t write the story this time. Please try again.';

  @override
  String get msgJobVoiceFailed =>
      'Your story was saved, but we couldn’t create its voice.';

  @override
  String get msgJobSaveFailed =>
      'We couldn’t save the story. Please try again.';

  @override
  String get msgJobInterrupted =>
      'The story was interrupted. Please try again.';

  @override
  String get msgJobFailed =>
      'Something went wrong while creating the story. Please try again.';

  @override
  String get msgCharacterNameRequired => 'Please enter a character name.';

  @override
  String get msgChildProfileMissing =>
      'We couldn’t find the child profile. Please log out and log in again.';

  @override
  String msgChooseMissing(String items) {
    return 'Please choose $items.';
  }

  @override
  String get fieldCategory => 'a category';

  @override
  String get fieldLength => 'a story length';

  @override
  String get fieldVoice => 'a voice';

  @override
  String get createHeader => 'I want a story about...';

  @override
  String get createCharacterName => 'Character Name';

  @override
  String get createNicknameHint => 'Custom Your Nickname';

  @override
  String get createStoryLength => 'Story Length';

  @override
  String get createMood => 'Mood';

  @override
  String get createVoice => 'Voice';

  @override
  String get createDescribe => 'Describe Your Story';

  @override
  String get createDescribeHint =>
      'Optional, max 30 words. English or Indonesian is fine.';

  @override
  String get generateStory => 'Generate Story';

  @override
  String get regenerate => 'Re-Generate';

  @override
  String lengthMinutes(int count) {
    return '$count Minutes';
  }

  @override
  String get themeDaily => 'Daily';

  @override
  String get themeFriendship => 'Friendship';

  @override
  String get themeAdventure => 'Adventure';

  @override
  String get themeFeeling => 'Feeling';

  @override
  String get moodCalm => 'Calm';

  @override
  String get moodCurious => 'Curious';

  @override
  String get moodWarm => 'Warm';

  @override
  String get moodJoyful => 'Joyful';

  @override
  String get moodFantasy => 'Fantasy';

  @override
  String get moodCozy => 'Cozy';

  @override
  String get moodBrave => 'Brave';

  @override
  String get moodNature => 'Nature';

  @override
  String get voiceWarm => 'Warm';

  @override
  String get voiceBrave => 'Brave';

  @override
  String get voiceGentle => 'Gentle';

  @override
  String get voiceCharacter => 'Character';

  @override
  String get voiceFriendly => 'Friendly';

  @override
  String get voiceNeutral => 'Neutral';

  @override
  String get loadingStarting => 'Getting ready...';

  @override
  String get loadingWriting => 'Writing your story...';

  @override
  String get loadingVoice => 'Creating the voice...';

  @override
  String get loadingDone => 'Your story is ready';

  @override
  String get loadingFailed => 'Something went wrong';

  @override
  String get loadingStartingUp => 'Starting up';

  @override
  String loadingStep(int step) {
    return 'Step $step of 2';
  }

  @override
  String get loadingTakesMinute => 'This can take up to a minute';

  @override
  String get loadingKeepWorking =>
      'We’ll keep working on it. Your story will appear in Story when it’s ready.';

  @override
  String get openStory => 'Open story';

  @override
  String get back => 'Back';

  @override
  String get storyTabRecent => 'Recent';

  @override
  String get storyTabFavorites => 'Favorites';

  @override
  String get storyTabPopular => 'Popular';

  @override
  String storiesOf(String name) {
    return '$name’s stories';
  }

  @override
  String get searchStories => 'Search stories...';

  @override
  String get untitledStory => 'Untitled story';

  @override
  String minutesShort(int count) {
    return '$count min';
  }

  @override
  String storyCreated(String when) {
    return 'Created $when';
  }

  @override
  String get timeJustNow => 'Just now';

  @override
  String timeMinutesAgo(int count) {
    return '$count min ago';
  }

  @override
  String timeHoursAgo(int count) {
    return '$count h ago';
  }

  @override
  String timeDaysAgo(int count) {
    return '$count d ago';
  }

  @override
  String timeDate(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat('d MMM', localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String timeDateYear(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat(
      'd MMM y',
      localeName,
    );
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String get deleteStoryTitle => 'Delete this story?';

  @override
  String deleteStoryBody(String title) {
    return '\"$title\" and its voice will be removed. This can’t be undone.';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String noStoriesMatch(String query) {
    return 'No stories match \"$query\".';
  }

  @override
  String get noFavorites =>
      'No favorite stories yet.\nTap the heart on a story to keep it here.';

  @override
  String get noPopular => 'Stories you play the most will show up here.';

  @override
  String get noStories => 'No story has been created.';

  @override
  String get createFirstStory => 'Let’s create a story';

  @override
  String get storyLoadFailed => 'This story could not be loaded.';

  @override
  String get playOnTotem => 'Play on totem';

  @override
  String get playOnTotemSoon => 'Playing on the totem is coming soon!';

  @override
  String get msgTotemInvalidId =>
      'That doesn’t look like a totem ID. Use letters, numbers and dashes, like totem-001.';

  @override
  String get msgTotemNotVisible =>
      'We can’t see this totem. Make sure it is on and connected to Wi-Fi.';

  @override
  String get msgTotemTaken =>
      'This totem is already linked to another account.';

  @override
  String get msgTotemNotPaired => 'Link a totem first in Settings.';

  @override
  String get msgTotemOffline =>
      'Your totem is offline. Turn it on and try again.';

  @override
  String get msgTotemUnreachable =>
      'We can’t reach the totem right now. Please try again.';

  @override
  String get msgTotemUnavailable =>
      'The totem feature isn’t set up on the server yet.';

  @override
  String get msgStoryNoVoice =>
      'This story has no voice yet, so the totem can’t play it.';

  @override
  String get msgTotemLinked => 'Totem linked!';

  @override
  String get msgTotemUnlinked => 'Totem unlinked.';

  @override
  String get msgTotemSent => 'Sent to the totem.';

  @override
  String get totem => 'Totem';

  @override
  String get totemNotLinked => 'Not linked';

  @override
  String totemLinkedTo(String id) {
    return 'Linked to $id';
  }

  @override
  String get totemId => 'Totem ID';

  @override
  String get totemLinkIntro =>
      'Enter the ID printed on your totem. It must be turned on and connected to Wi-Fi.';

  @override
  String get totemLink => 'Link totem';

  @override
  String get totemUnlink => 'Unlink totem';

  @override
  String get totemOnline => 'Online';

  @override
  String get totemOffline => 'Offline';

  @override
  String get totemStateIdle => 'Idle';

  @override
  String get totemStateLoading => 'Loading';

  @override
  String get totemStatePlaying => 'Playing';

  @override
  String get totemStatePaused => 'Paused';

  @override
  String get totemStateError => 'Error';

  @override
  String get totemStateUnknown => 'Unknown';

  @override
  String get totemNowPlaying => 'Now playing on the totem';

  @override
  String get totemVolume => 'Volume';
}
