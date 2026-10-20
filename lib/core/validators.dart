/// Validasi input autentikasi. Fungsi murni: mengembalikan pesan error, atau null bila valid.
class AuthValidators {
  AuthValidators._();

  static const int minPasswordLength = 8;

  // Local-part boleh berisi huruf, angka, titik, plus, dan tanda hubung; domain minimal 2 huruf
  // (batas lama 4 huruf menolak domain sah seperti ".technology").
  static final RegExp _email = RegExp(r'^[\w.+-]+@([\w-]+\.)+[\w-]{2,}$');
  static final RegExp _letter = RegExp(r'[A-Za-z]');
  static final RegExp _digit = RegExp(r'\d');

  static String? email(String value) {
    final text = value.trim();
    if (text.isEmpty) return 'Email is required!';
    if (!_email.hasMatch(text)) return 'Invalid email format, please check again!';
    return null;
  }

  /// Aturan untuk kata sandi BARU: minimal 8 karakter, memuat huruf dan angka.
  /// Simbol diperbolehkan (aturan lama hanya menerima huruf dan angka).
  static String? newPassword(String value) {
    final text = value.trim();
    if (text.isEmpty) return 'Password is required!';
    if (text.length < minPasswordLength || !_letter.hasMatch(text) || !_digit.hasMatch(text)) {
      return 'Password must be at least $minPasswordLength characters with letters and numbers!';
    }
    return null;
  }
}
