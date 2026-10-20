sealed class AccountResult {
  const AccountResult();
}

class AccountSuccess extends AccountResult {
  final String message;
  final String? value;
  const AccountSuccess(this.message, {this.value});
}

class AccountFailure extends AccountResult {
  final String message;
  const AccountFailure(this.message);
}
