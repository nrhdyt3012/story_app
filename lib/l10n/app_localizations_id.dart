// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Aplikasi Story';

  @override
  String get shareYourMoments => 'Bagikan momen Anda';

  @override
  String get email => 'Email';

  @override
  String get password => 'Kata Sandi';

  @override
  String get login => 'Masuk';

  @override
  String get register => 'Daftar';

  @override
  String get dontHaveAccount => 'Belum punya akun? ';

  @override
  String get pleaseEnterEmail => 'Silakan masukkan email Anda';

  @override
  String get pleaseEnterValidEmail => 'Silakan masukkan email yang valid';

  @override
  String get pleaseEnterPassword => 'Silakan masukkan kata sandi Anda';

  @override
  String get passwordMinLength => 'Kata sandi minimal 8 karakter';

  @override
  String get loginFailed => 'Login gagal';

  @override
  String get createAccount => 'Buat Akun';

  @override
  String get joinAndShareStories => 'Bergabung dan bagikan cerita Anda';

  @override
  String get name => 'Nama';

  @override
  String get pleaseEnterName => 'Silakan masukkan nama Anda';

  @override
  String get registrationSuccess => 'Registrasi berhasil! Silakan login.';

  @override
  String get registrationFailed => 'Registrasi gagal';

  @override
  String get addStory => 'Tambah Story';

  @override
  String get description => 'Deskripsi';

  @override
  String get descriptionHint => 'Ceritakan tentang momen ini...';

  @override
  String get pleaseEnterDescription => 'Silakan masukkan deskripsi';

  @override
  String get camera => 'Kamera';

  @override
  String get gallery => 'Galeri';

  @override
  String get tapToSelectImage => 'Ketuk untuk pilih gambar';

  @override
  String get imageAutoCompress =>
      'Gambar akan otomatis dikompres\njika lebih dari 1MB';

  @override
  String get removeImage => 'Hapus Gambar';

  @override
  String get uploadStory => 'Upload Story';

  @override
  String get compressingImage => 'Mengompres gambar...';

  @override
  String originalSize(String size) {
    return 'Ukuran asli: $size MB';
  }

  @override
  String imageCompressed(String size) {
    return 'Gambar dikompres menjadi $size MB';
  }

  @override
  String get errorProcessingImage => 'Error memproses gambar';

  @override
  String get storyUploadSuccess => 'Story berhasil diupload!';

  @override
  String get uploadFailed => 'Upload gagal';

  @override
  String get pleaseSelectImage => 'Silakan pilih gambar terlebih dahulu';

  @override
  String get logout => 'Keluar';

  @override
  String get areYouSureLogout => 'Apakah Anda yakin ingin keluar?';

  @override
  String get cancel => 'Batal';

  @override
  String get retry => 'Coba Lagi';

  @override
  String get noStoriesYet => 'Belum ada story';

  @override
  String get addYourFirstStory => 'Tambahkan Story Pertama Anda';

  @override
  String get storyNotFound => 'Story tidak ditemukan';

  @override
  String get location => 'Lokasi';
}
