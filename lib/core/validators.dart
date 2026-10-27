import '../data/models/app_message.dart';

class AuthValidators {
  AuthValidators._();

  static const int minPasswordLength = 8;

  static final RegExp _email = RegExp(r'^[\w.+-]+@([\w-]+\.)+[\w-]{2,}$');
  static final RegExp _letter = RegExp(r'[A-Za-z]');
  static final RegExp _digit = RegExp(r'\d');

  static const int maxChildNameLength = 30;
  static final RegExp _childName = RegExp(r"^[A-Za-z][A-Za-z' \-]*$");

  // ---------- Versi berkode: dipakai layar yang sudah dilokalkan ----------

  static AppMessage? emailIssue(String value) {
    final text = value.trim();
    if (text.isEmpty) return AppMessage.emailRequired;
    if (!_email.hasMatch(text)) return AppMessage.emailInvalid;
    return null;
  }

  static AppMessage? newPasswordIssue(String value) {
    final text = value.trim();
    if (text.isEmpty) return AppMessage.passwordRequired;
    if (text.length < minPasswordLength || !_letter.hasMatch(text) || !_digit.hasMatch(text)) {
      return AppMessage.passwordRules;
    }
    return null;
  }

  static AppMessage? childNameIssue(String value) {
    final text = value.trim();
    if (text.isEmpty) return AppMessage.childNameRequired;
    if (text.length > maxChildNameLength) return AppMessage.childNameTooLong;
    if (!_childName.hasMatch(text)) return AppMessage.childNameInvalid;
    return null;
  }

  static AppMessage? characterNameIssue(String value) {
    final text = value.trim();
    if (text.isEmpty) return AppMessage.characterNameRequired;
    if (text.length > maxChildNameLength) return AppMessage.childNameTooLong;
    if (!_childName.hasMatch(text)) return AppMessage.childNameInvalid;
    return null;
  }
}

class FeedbackValidators {
  FeedbackValidators._();

  static const int minLength = 5;
  static const int maxLength = 1000;

  static AppMessage? issue(String value) {
    final text = value.trim();
    if (text.isEmpty) return AppMessage.feedbackEmpty;
    if (text.runes.length < minLength) return AppMessage.feedbackTooShort;
    if (text.runes.length > maxLength) return AppMessage.feedbackTooLong;
    return null;
  }
}
