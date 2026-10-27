import 'app_message.dart';

sealed class AccountResult {
  const AccountResult();
}

class AccountSuccess extends AccountResult {
  final AppMessage message;
  final String? value;
  const AccountSuccess(this.message, {this.value});
}

class AccountFailure extends AccountResult {
  final AppMessage message;
  const AccountFailure(this.message);
}
