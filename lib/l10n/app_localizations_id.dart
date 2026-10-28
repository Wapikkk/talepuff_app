// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get language => 'Bahasa';

  @override
  String get languageFollowDevice => 'Ikuti perangkat';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageIndonesian => 'Bahasa Indonesia';

  @override
  String get languageStoriesNote =>
      'Cerita selalu ditulis dalam bahasa Inggris sederhana.';

  @override
  String get landingTitle => 'Buat ceritamu sendiri';

  @override
  String get landingSubtitle =>
      'Bantu anak Anda belajar bahasa Inggris lewat cerita yang mereka sukai';

  @override
  String get landingGetStarted => 'Ayo mulai';

  @override
  String get alreadyHaveAccount => 'Sudah punya akun? ';

  @override
  String get login => 'Masuk';

  @override
  String get signUp => 'Daftar';

  @override
  String get signUpWithGoogle => 'Daftar dengan Google';

  @override
  String get continueWithGoogle => 'Lanjutkan dengan Google';

  @override
  String get email => 'Email';

  @override
  String get password => 'Kata sandi';

  @override
  String get enterEmail => 'Masukkan email Anda';

  @override
  String get enterPassword => 'Masukkan kata sandi Anda';

  @override
  String get rememberMe => 'Ingat saya';

  @override
  String get forgotPassword => 'Lupa kata sandi?';

  @override
  String get newUser => 'Pengguna baru? ';

  @override
  String get acceptTermsPrefix => 'Saya menyetujui ';

  @override
  String get termsOfService => 'ketentuan layanan';

  @override
  String get acceptTermsAnd => ' & ';

  @override
  String get privacyPolicyLink => 'kebijakan privasi';

  @override
  String get childInfoTitle => 'Informasi Anak';

  @override
  String get basicInfo => 'Info Dasar';

  @override
  String get childName => 'Nama Anak';

  @override
  String get enterChildName => 'Masukkan nama anak Anda';

  @override
  String get age => 'Usia';

  @override
  String get enterAgeOptional => 'Masukkan usia (opsional)';

  @override
  String get gender => 'Jenis kelamin';

  @override
  String get genderMale => 'Laki-laki';

  @override
  String get genderFemale => 'Perempuan';

  @override
  String get genderNotSpecified => 'Tidak disebutkan';

  @override
  String get interest => 'Minat';

  @override
  String interestSlotsRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sisa $count pilihan',
      zero: 'Tidak ada sisa pilihan',
    );
    return '$_temp0';
  }

  @override
  String get interestSports => 'Olahraga';

  @override
  String get interestMusic => 'Musik';

  @override
  String get interestArt => 'Seni';

  @override
  String get interestScience => 'Sains';

  @override
  String get interestNature => 'Alam';

  @override
  String get interestSpace => 'Luar angkasa';

  @override
  String get interestMagic => 'Sihir';

  @override
  String get interestReading => 'Membaca';

  @override
  String get interestDancing => 'Menari';

  @override
  String get interestGames => 'Permainan';

  @override
  String get save => 'Simpan';

  @override
  String get saveAndContinue => 'Simpan & Lanjutkan';

  @override
  String get useDifferentAccount => 'Gunakan akun lain';

  @override
  String get tryAgain => 'Coba lagi';

  @override
  String get changeServerAddress => 'Ubah alamat server';

  @override
  String get settings => 'Pengaturan';

  @override
  String get accountSettings => 'Pengaturan Akun';

  @override
  String get mascot => 'Maskot';

  @override
  String get updatePassword => 'Ubah Kata Sandi';

  @override
  String get volumeLimit => 'Batas Volume';

  @override
  String get about => 'Tentang';

  @override
  String get version => 'Versi';

  @override
  String get serverAddress => 'Alamat Server';

  @override
  String get sendFeedback => 'Kirim Masukan';

  @override
  String get termsAndConditions => 'Syarat dan Ketentuan';

  @override
  String get privacyPolicy => 'Kebijakan Privasi';

  @override
  String get logout => 'Keluar';

  @override
  String get msgCredentialsRequired => 'Email dan kata sandi wajib diisi!';

  @override
  String get msgEmailRequired => 'Email wajib diisi!';

  @override
  String get msgEmailInvalid =>
      'Format email tidak valid, silakan periksa kembali!';

  @override
  String get msgPasswordRequired => 'Kata sandi wajib diisi!';

  @override
  String msgPasswordRules(int minLength) {
    return 'Kata sandi minimal $minLength karakter dengan huruf dan angka!';
  }

  @override
  String get msgTermsNotAccepted =>
      'Silakan setujui Syarat dan Ketentuan kami untuk melanjutkan.';

  @override
  String get msgChildInfoMissing =>
      'Silakan isi informasi anak terlebih dahulu';

  @override
  String get msgFillMandatory => 'Silakan isi semua kolom yang wajib!';

  @override
  String get msgAgeInvalid => 'Masukkan usia yang valid.';

  @override
  String get msgChildNameRequired => 'Nama anak wajib diisi!';

  @override
  String msgChildNameTooLong(int maxLength) {
    return 'Nama maksimal $maxLength karakter.';
  }

  @override
  String get msgChildNameInvalid =>
      'Gunakan huruf saja (spasi, \' dan - diperbolehkan), diawali huruf.';

  @override
  String get msgSessionRejected =>
      'Server menolak sesi Anda. Silakan masuk kembali.';

  @override
  String get msgServerUnreachable =>
      'Tidak dapat menjangkau server. Pastikan backend berjalan dan Anda berada di jaringan yang sama.';

  @override
  String get msgProfileSyncFailed =>
      'Akun Anda sudah dibuat, tetapi profil belum tersimpan. Periksa koneksi Anda lalu coba lagi.';

  @override
  String get msgGoogleAlreadyRegistered =>
      'Akun Google ini sudah terdaftar. Silakan masuk.';

  @override
  String get msgEmailInUse => 'Email ini sudah terdaftar. Silakan masuk.';

  @override
  String get msgInvalidCredentials =>
      'Email atau kata sandi salah. Silakan coba lagi.';

  @override
  String get msgUserNotFound =>
      'Akun dengan email ini tidak ditemukan. Silakan daftar terlebih dahulu.';

  @override
  String get msgWeakPassword =>
      'Kata sandi ini terlalu lemah. Silakan pilih yang lebih kuat.';

  @override
  String get msgTooManyRequests =>
      'Terlalu banyak percobaan. Silakan coba lagi nanti.';

  @override
  String get msgNoConnection =>
      'Tidak ada koneksi. Periksa internet Anda lalu coba lagi.';

  @override
  String get msgSessionExpired =>
      'Sesi Anda telah berakhir. Silakan masuk kembali.';

  @override
  String get msgGoogleSignInFailed =>
      'Masuk dengan Google gagal. Bila ini build baru, pastikan SHA-1 nya sudah terdaftar di Firebase.';

  @override
  String get msgGenericError => 'Terjadi kesalahan. Silakan coba lagi.';

  @override
  String get msgReloginRequired =>
      'Demi keamanan, silakan keluar lalu masuk kembali, kemudian coba lagi.';

  @override
  String get msgBackendOutdated =>
      'Server belum mendukung tindakan ini. Mulai ulang backend agar menjalankan versi terbaru.';

  @override
  String get msgRequestRejected => 'Server tidak menerima permintaan ini.';

  @override
  String get msgRequestNotUnderstood =>
      'Server tidak memahami permintaan ini. Silakan coba lagi.';

  @override
  String get msgUnreadableResponse =>
      'Server mengirim balasan yang tidak dapat dibaca. Silakan coba lagi.';

  @override
  String get msgManagedByGoogle =>
      'Akun ini masuk dengan Google, sehingga email dan kata sandinya dikelola oleh Google.';

  @override
  String get msgChildDataNotLoaded =>
      'Data anak belum dimuat. Silakan coba lagi sebentar lagi.';

  @override
  String get msgChildProfileNotFound =>
      'Profil anak ini tidak ditemukan. Silakan keluar lalu masuk kembali.';

  @override
  String msgChildNameRejected(int maxLength) {
    return 'Server tidak menerima nama ini. Gunakan huruf saja, maksimal $maxLength karakter.';
  }

  @override
  String get msgNameUpdated => 'Nama berhasil diperbarui!';

  @override
  String get msgMascotInvalid => 'Silakan pilih salah satu maskot.';

  @override
  String get msgMascotRejected =>
      'Server tidak menerima maskot ini. Silakan pilih yang lain.';

  @override
  String get msgMascotUpdated => 'Maskot diperbarui!';

  @override
  String get msgCurrentPasswordRequired => 'Kata sandi saat ini wajib diisi!';

  @override
  String get msgCurrentPasswordIncorrect => 'Kata sandi saat ini salah.';

  @override
  String get msgPasswordsMismatch => 'Kata sandi tidak cocok!';

  @override
  String get msgPasswordSameAsCurrent =>
      'Kata sandi baru harus berbeda dari yang sekarang.';

  @override
  String get msgPasswordUpdated => 'Kata sandi berhasil diperbarui!';

  @override
  String get msgSameEmail => 'Ini sudah menjadi alamat email Anda.';

  @override
  String msgVerificationSent(String email) {
    return 'Kami mengirim tautan verifikasi ke $email. Email Anda berubah setelah Anda membuka tautan tersebut.';
  }

  @override
  String get msgFeedbackCategoryRequired => 'Silakan pilih kategori.';

  @override
  String get msgFeedbackEmpty => 'Silakan tulis masukan Anda terlebih dahulu.';

  @override
  String get msgFeedbackTooShort =>
      'Pesan Anda terlalu singkat. Tambahkan sedikit detail.';

  @override
  String msgFeedbackTooLong(int maxLength) {
    return 'Pesan Anda terlalu panjang. Mohon singkat hingga di bawah $maxLength karakter.';
  }

  @override
  String get msgFeedbackRejected =>
      'Server tidak menerima pesan ini. Periksa kembali lalu coba lagi.';

  @override
  String get msgAccountNotFound =>
      'Akun Anda tidak ditemukan. Silakan keluar lalu masuk kembali.';

  @override
  String get msgFeedbackRateLimited =>
      'Anda sudah banyak mengirim masukan akhir-akhir ini. Silakan coba lagi nanti.';

  @override
  String get msgFeedbackSent => 'Terima kasih atas masukan Anda!';

  @override
  String get msgPhotoUpdated => 'Foto profil diperbarui!';

  @override
  String get msgPhotoRemoved => 'Foto profil dihapus.';

  @override
  String get msgPhotoUnsupported =>
      'Berkas itu bukan foto yang didukung. Gunakan gambar JPG, PNG, atau WebP.';

  @override
  String get msgPhotoTooLarge =>
      'Foto itu terlalu besar. Pilih foto di bawah 5 MB.';

  @override
  String get msgPhotoUnreadable =>
      'Foto itu tidak dapat dibaca. Silakan pilih foto lain.';

  @override
  String get msgPhotoPickerFailed =>
      'Pemilih foto tidak dapat dibuka. Silakan coba lagi.';

  @override
  String get msgFavoriteAdded => 'Ditambahkan ke favorit.';

  @override
  String get msgFavoriteRemoved => 'Dihapus dari favorit.';

  @override
  String get msgStoryDeleted => 'Cerita dihapus.';

  @override
  String get msgStoryNotFound =>
      'Cerita itu tidak ditemukan. Mungkin sudah dihapus.';

  @override
  String get msgAddressRequired =>
      'Masukkan alamat komputer Anda, misalnya 192.168.1.5:8080.';

  @override
  String get msgAddressInvalid =>
      'Itu tidak terlihat seperti alamat. Coba seperti 192.168.1.5:8080.';

  @override
  String get msgAddressBadScheme =>
      'Alamat harus diawali dengan http:// atau https://.';

  @override
  String get msgAddressExtraParts =>
      'Masukkan hanya alamat dan port, misalnya 192.168.1.5:8080.';

  @override
  String get msgAddressNotLocal =>
      'Gunakan alamat komputer Anda di Wi-Fi yang sama (misalnya 192.168.1.5), bukan alamat internet.';

  @override
  String get msgAddressNotTalepuff =>
      'Kami menemukan server di sana, tetapi itu bukan backend TalePuff, atau perlu dimulai ulang.';

  @override
  String get msgAddressUnreachable =>
      'Alamat itu tidak dapat dijangkau. Pastikan backend berjalan dan ponsel Anda di Wi-Fi yang sama.';

  @override
  String get updateName => 'Ubah Nama';

  @override
  String get newEmail => 'Email baru';

  @override
  String get currentPassword => 'Kata sandi saat ini';

  @override
  String get enterCurrentPassword => 'Masukkan kata sandi Anda saat ini';

  @override
  String get updateEmail => 'Ubah Email';

  @override
  String get newPassword => 'Kata sandi baru';

  @override
  String newPasswordHint(int minLength) {
    return 'Minimal $minLength karakter, huruf dan angka';
  }

  @override
  String get confirmPassword => 'Konfirmasi kata sandi';

  @override
  String get confirmNewPassword => 'Konfirmasi kata sandi baru Anda';

  @override
  String get mascotIntro =>
      'Pilih teman yang menyapa anak Anda di layar beranda.';

  @override
  String get updateMascot => 'Ubah Maskot';

  @override
  String get mascotHarimau => 'Harimau Sumatra';

  @override
  String get mascotOrangUtan => 'Orangutan';

  @override
  String get mascotBadak => 'Badak Jawa';

  @override
  String get mascotBurung => 'Burung Cenderawasih';

  @override
  String get feedbackIntro =>
      'Beri tahu kami apa yang tidak berfungsi atau apa yang ingin Anda lihat.';

  @override
  String get feedbackBug => 'Masalah';

  @override
  String get feedbackIdea => 'Ide';

  @override
  String get feedbackOther => 'Lainnya';

  @override
  String get feedbackHint => 'Tulis pesan Anda di sini...';

  @override
  String get send => 'Kirim';

  @override
  String get serverConnected => 'Terhubung ke server';

  @override
  String get serverSaved => 'Alamat server disimpan';

  @override
  String get serverBackToDefault => 'Kembali ke alamat bawaan';

  @override
  String get serverAddressLabel => 'Alamat server';

  @override
  String get serverAddressHelp =>
      'Gunakan alamat komputer Anda di Wi-Fi yang sama. Di komputer, jalankan ipconfig lalu cari alamat IPv4.';

  @override
  String get testConnection => 'Uji koneksi';

  @override
  String get useBuiltInAddress => 'Gunakan alamat bawaan';

  @override
  String get legalLoadFailed => 'Dokumen ini tidak dapat dimuat.';

  @override
  String get greetingMorning => 'Selamat Pagi';

  @override
  String get greetingAfternoon => 'Selamat Siang';

  @override
  String get greetingEvening => 'Selamat Malam';

  @override
  String get homePrompt => 'Cerita apa yang ingin kamu dengar hari ini?';

  @override
  String get searchStory => 'Cari ceritamu';

  @override
  String get createNewStory => 'Buat Cerita Baru';

  @override
  String get playLastStory => 'Putar Cerita Terakhir';

  @override
  String get playLastStoryComingSoon => 'Putar Cerita Terakhir segera hadir!';

  @override
  String get navHome => 'Beranda';

  @override
  String get navStory => 'Cerita';

  @override
  String get navCreate => 'Buat';

  @override
  String get navParents => 'Orang Tua';

  @override
  String ageYears(int count) {
    return '$count tahun';
  }

  @override
  String profileIntro(String name) {
    return 'Hai, aku $name';
  }

  @override
  String profileLikes1(String a) {
    return 'aku suka $a!';
  }

  @override
  String profileLikes2(String a, String b) {
    return 'aku suka $a dan $b!';
  }

  @override
  String profileLikesMany(String rest, String last) {
    return 'aku suka $rest dan $last!';
  }

  @override
  String statsTitle(String name) {
    return 'Ringkasan mendengarkan $name minggu ini';
  }

  @override
  String statsMood(int count) {
    return '$count Suasana';
  }

  @override
  String statsStories(int count) {
    return '$count Cerita';
  }

  @override
  String statsMinutes(int count) {
    return '$count Menit';
  }

  @override
  String get bedtimeTitle => 'Cerita Pengantar Tidur Otomatis';

  @override
  String get bedtimeSubtitle =>
      'putar cerita terakhir secara otomatis pada waktu tertentu';

  @override
  String get enterTime => 'Masukkan waktu';

  @override
  String get photoTitle => 'Foto Profil';

  @override
  String get photoCamera => 'Kamera';

  @override
  String get photoLibrary => 'Pilih dari galeri';

  @override
  String get photoRemove => 'Hapus Foto';

  @override
  String get photoCropTitle => 'Atur Foto Profil';

  @override
  String get msgConnectionLost =>
      'Koneksi ke server terputus. Ceritamu mungkin masih diproses, jadi cek halaman Cerita sebentar lagi.';

  @override
  String get msgNoticeNameReplaced =>
      'Nama karakter itu tidak dapat dipakai dalam cerita, jadi kami menamainya Pip.';

  @override
  String get msgNoticeBothReplaced =>
      'Kami tidak dapat memakai nama karakter itu atau sebagian idemu, jadi kami menulis cerita lembut tentang Pip.';

  @override
  String get msgNoticeIdeaDropped =>
      'Kami tidak dapat memakai sebagian idemu, jadi kami menulis cerita yang lembut.';

  @override
  String get msgJobAiUnavailable =>
      'Layanan cerita sedang tidak berjalan. Silakan coba lagi sebentar lagi.';

  @override
  String get msgJobAiFailed =>
      'Kali ini kami tidak berhasil menulis ceritanya. Silakan coba lagi.';

  @override
  String get msgJobVoiceFailed =>
      'Ceritamu sudah disimpan, tetapi kami tidak berhasil membuat suaranya.';

  @override
  String get msgJobSaveFailed =>
      'Kami tidak berhasil menyimpan ceritanya. Silakan coba lagi.';

  @override
  String get msgJobInterrupted =>
      'Pembuatan cerita terhenti. Silakan coba lagi.';

  @override
  String get msgJobFailed =>
      'Terjadi kesalahan saat membuat cerita. Silakan coba lagi.';

  @override
  String get msgCharacterNameRequired => 'Silakan isi nama karakter.';

  @override
  String get msgChildProfileMissing =>
      'Profil anak tidak ditemukan. Silakan keluar lalu masuk kembali.';

  @override
  String msgChooseMissing(String items) {
    return 'Silakan pilih $items.';
  }

  @override
  String get fieldCategory => 'kategori';

  @override
  String get fieldLength => 'panjang cerita';

  @override
  String get fieldVoice => 'suara';

  @override
  String get createHeader => 'Aku ingin cerita tentang...';

  @override
  String get createCharacterName => 'Nama Karakter';

  @override
  String get createNicknameHint => 'Tulis nama panggilan karakter';

  @override
  String get createStoryLength => 'Panjang Cerita';

  @override
  String get createMood => 'Suasana';

  @override
  String get createVoice => 'Suara';

  @override
  String get createDescribe => 'Jelaskan Ceritamu';

  @override
  String get createDescribeHint =>
      'Opsional, maksimal 30 kata. Bahasa Inggris atau Indonesia boleh.';

  @override
  String get generateStory => 'Buat Cerita';

  @override
  String get regenerate => 'Buat Ulang';

  @override
  String lengthMinutes(int count) {
    return '$count Menit';
  }

  @override
  String get themeDaily => 'Harian';

  @override
  String get themeFriendship => 'Persahabatan';

  @override
  String get themeAdventure => 'Petualangan';

  @override
  String get themeFeeling => 'Perasaan';

  @override
  String get moodCalm => 'Tenang';

  @override
  String get moodCurious => 'Penasaran';

  @override
  String get moodWarm => 'Hangat';

  @override
  String get moodJoyful => 'Ceria';

  @override
  String get moodFantasy => 'Fantasi';

  @override
  String get moodCozy => 'Nyaman';

  @override
  String get moodBrave => 'Berani';

  @override
  String get moodNature => 'Alam';

  @override
  String get voiceWarm => 'Hangat';

  @override
  String get voiceBrave => 'Berani';

  @override
  String get voiceGentle => 'Lembut';

  @override
  String get voiceCharacter => 'Karakter';

  @override
  String get voiceFriendly => 'Ramah';

  @override
  String get voiceNeutral => 'Netral';

  @override
  String get loadingStarting => 'Bersiap-siap...';

  @override
  String get loadingWriting => 'Menulis ceritamu...';

  @override
  String get loadingVoice => 'Membuat suaranya...';

  @override
  String get loadingDone => 'Ceritamu sudah siap';

  @override
  String get loadingFailed => 'Terjadi kesalahan';

  @override
  String get loadingStartingUp => 'Memulai';

  @override
  String loadingStep(int step) {
    return 'Langkah $step dari 2';
  }

  @override
  String get loadingTakesMinute => 'Ini bisa memakan waktu hingga satu menit';

  @override
  String get loadingKeepWorking =>
      'Kami akan terus mengerjakannya. Ceritamu akan muncul di Cerita saat sudah siap.';

  @override
  String get openStory => 'Buka cerita';

  @override
  String get back => 'Kembali';

  @override
  String get storyTabRecent => 'Terbaru';

  @override
  String get storyTabFavorites => 'Favorit';

  @override
  String get storyTabPopular => 'Terpopuler';

  @override
  String storiesOf(String name) {
    return 'Cerita $name';
  }

  @override
  String get searchStories => 'Cari cerita...';

  @override
  String get untitledStory => 'Cerita tanpa judul';

  @override
  String minutesShort(int count) {
    return '$count mnt';
  }

  @override
  String storyCreated(String when) {
    return 'Dibuat $when';
  }

  @override
  String get timeJustNow => 'Baru saja';

  @override
  String timeMinutesAgo(int count) {
    return '$count menit lalu';
  }

  @override
  String timeHoursAgo(int count) {
    return '$count jam lalu';
  }

  @override
  String timeDaysAgo(int count) {
    return '$count hari lalu';
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
  String get deleteStoryTitle => 'Hapus cerita ini?';

  @override
  String deleteStoryBody(String title) {
    return '\"$title\" beserta suaranya akan dihapus. Tindakan ini tidak dapat dibatalkan.';
  }

  @override
  String get cancel => 'Batal';

  @override
  String get delete => 'Hapus';

  @override
  String noStoriesMatch(String query) {
    return 'Tidak ada cerita yang cocok dengan \"$query\".';
  }

  @override
  String get noFavorites =>
      'Belum ada cerita favorit.\nKetuk hati pada cerita untuk menyimpannya di sini.';

  @override
  String get noPopular =>
      'Cerita yang paling sering diputar akan muncul di sini.';

  @override
  String get noStories => 'Belum ada cerita yang dibuat.';

  @override
  String get createFirstStory => 'Yuk, buat cerita';

  @override
  String get storyLoadFailed => 'Cerita ini tidak dapat dimuat.';

  @override
  String get playOnTotem => 'Putar di totem';

  @override
  String get playOnTotemSoon => 'Memutar di totem segera hadir!';

  @override
  String get msgTotemInvalidId =>
      'Itu bukan ID totem yang valid. Gunakan huruf, angka, dan tanda hubung, misalnya totem-001.';

  @override
  String get msgTotemNotVisible =>
      'Totem ini tidak terlihat. Pastikan totem menyala dan terhubung ke Wi-Fi.';

  @override
  String get msgTotemTaken => 'Totem ini sudah terhubung ke akun lain.';

  @override
  String get msgTotemNotPaired =>
      'Hubungkan totem terlebih dahulu di Pengaturan.';

  @override
  String get msgTotemOffline =>
      'Totem Anda sedang offline. Nyalakan totem lalu coba lagi.';

  @override
  String get msgTotemUnreachable =>
      'Totem tidak dapat dijangkau saat ini. Silakan coba lagi.';

  @override
  String get msgTotemUnavailable => 'Fitur totem belum disiapkan di server.';

  @override
  String get msgStoryNoVoice =>
      'Cerita ini belum punya suara, sehingga totem tidak dapat memutarnya.';

  @override
  String get msgTotemLinked => 'Totem terhubung!';

  @override
  String get msgTotemUnlinked => 'Totem diputuskan.';

  @override
  String get msgTotemSent => 'Dikirim ke totem.';

  @override
  String get totem => 'Totem';

  @override
  String get totemNotLinked => 'Belum terhubung';

  @override
  String totemLinkedTo(String id) {
    return 'Terhubung ke $id';
  }

  @override
  String get totemId => 'ID Totem';

  @override
  String get totemLinkIntro =>
      'Masukkan ID yang tertera pada totem. Totem harus menyala dan terhubung ke Wi-Fi.';

  @override
  String get totemLink => 'Hubungkan totem';

  @override
  String get totemUnlink => 'Putuskan totem';

  @override
  String get totemOnline => 'Online';

  @override
  String get totemOffline => 'Offline';

  @override
  String get totemStateIdle => 'Siaga';

  @override
  String get totemStateLoading => 'Memuat';

  @override
  String get totemStatePlaying => 'Memutar';

  @override
  String get totemStatePaused => 'Dijeda';

  @override
  String get totemStateError => 'Galat';

  @override
  String get totemStateUnknown => 'Tidak diketahui';

  @override
  String get totemNowPlaying => 'Sedang diputar di totem';

  @override
  String get totemVolume => 'Volume';
}
