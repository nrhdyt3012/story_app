// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Story App';

  @override
  String get shareYourMoments => 'Share your moments';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get passwordMinLength => 'Password must be at least 8 characters';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get createAccount => 'Create Account';

  @override
  String get joinAndShareStories => 'Join and share your stories';

  @override
  String get name => 'Name';

  @override
  String get pleaseEnterName => 'Please enter your name';

  @override
  String get registrationSuccess => 'Registration successful! Please login.';

  @override
  String get registrationFailed => 'Registration failed';

  @override
  String get addStory => 'Add Story';

  @override
  String get description => 'Description';

  @override
  String get descriptionHint => 'Tell about this moment...';

  @override
  String get pleaseEnterDescription => 'Please enter description';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get tapToSelectImage => 'Tap to select image';

  @override
  String get imageAutoCompress =>
      'Image will be auto compressed\nif larger than 1MB';

  @override
  String get removeImage => 'Remove Image';

  @override
  String get uploadStory => 'Upload Story';

  @override
  String get compressingImage => 'Compressing image...';

  @override
  String originalSize(String size) {
    return 'Original size: $size MB';
  }

  @override
  String imageCompressed(String size) {
    return 'Image compressed to $size MB';
  }

  @override
  String get errorProcessingImage => 'Error processing image';

  @override
  String get storyUploadSuccess => 'Story uploaded successfully!';

  @override
  String get uploadFailed => 'Upload failed';

  @override
  String get pleaseSelectImage => 'Please select an image first';

  @override
  String get logout => 'Logout';

  @override
  String get areYouSureLogout => 'Are you sure you want to logout?';

  @override
  String get cancel => 'Cancel';

  @override
  String get retry => 'Retry';

  @override
  String get noStoriesYet => 'No stories yet';

  @override
  String get addYourFirstStory => 'Add Your First Story';

  @override
  String get storyNotFound => 'Story not found';

  @override
  String get location => 'Location';
}
