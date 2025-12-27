import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screen/login_screen.dart';
import '../screen/register_screen.dart';
import '../screen/story_list_screen.dart';
import '../screen/story_detail_screen.dart';
import '../screen/add_story_screen.dart';
import '../provider/add_story_controller.dart';
import '../l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';

class MyRouterDelegate extends RouterDelegate<String>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<String> {
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  String? _selectedStoryId;
  bool _isLoggedIn = false;
  bool _isRegister = false;
  bool _isAddStory = false;
  bool _showLogoutDialog = false;
  bool _showImageSourceDialog = false; // State for image source dialog

  MyRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  bool get isLoggedIn => _isLoggedIn;
  bool get isRegister => _isRegister;
  bool get isAddStory => _isAddStory;
  bool get showLogoutDialog => _showLogoutDialog;
  bool get showImageSourceDialog => _showImageSourceDialog;

  void setLoggedIn(bool value) {
    _isLoggedIn = value;
    notifyListeners();
  }

  void setRegister(bool value) {
    _isRegister = value;
    notifyListeners();
  }

  void setAddStory(bool value) {
    _isAddStory = value;
    notifyListeners();
  }

  void setShowLogoutDialog(bool value) {
    _showLogoutDialog = value;
    notifyListeners();
  }

  void setShowImageSourceDialog(bool value) {
    _showImageSourceDialog = value;
    notifyListeners();
  }

  void selectStory(String id) {
    _selectedStoryId = id;
    notifyListeners();
  }

  @override
  String? get currentConfiguration {
    if (!_isLoggedIn) {
      return _isRegister ? '/register' : '/login';
    }
    if (_isAddStory) {
      return '/add-story';
    }
    if (_selectedStoryId != null) {
      return '/story/$_selectedStoryId';
    }
    return '/';
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        if (!_isLoggedIn) ...[
          MaterialPage(
            key: const ValueKey('LoginScreen'),
            child: LoginScreen(
              onLogin: () {
                setLoggedIn(true);
              },
              onRegister: () {
                setRegister(true);
              },
            ),
          ),
          if (_isRegister)
            MaterialPage(
              key: const ValueKey('RegisterScreen'),
              child: RegisterScreen(
                onRegister: () {
                  setRegister(false);
                },
                onBack: () {
                  setRegister(false);
                },
              ),
            ),
        ] else ...[
          MaterialPage(
            key: const ValueKey('StoryListScreen'),
            child: StoryListScreen(
              onTapped: (String id) {
                selectStory(id);
              },
              onLogout: () {
                setLoggedIn(false);
              },
              onAddStory: () {
                setAddStory(true);
              },
              onShowLogoutDialog: () {
                setShowLogoutDialog(true);
              },
            ),
          ),
          if (_isAddStory)
            MaterialPage(
              key: const ValueKey('AddStoryScreen'),
              child: AddStoryScreen(
                onUpload: () {
                  setAddStory(false);
                },
                onBack: () {
                  setAddStory(false);
                },
                onShowImageSourceDialog: () {
                  setShowImageSourceDialog(true);
                },
              ),
            ),
          if (_selectedStoryId != null)
            MaterialPage(
              key: ValueKey('StoryDetail-$_selectedStoryId'),
              child: StoryDetailScreen(
                storyId: _selectedStoryId!,
                onBack: () {
                  _selectedStoryId = null;
                  notifyListeners();
                },
              ),
            ),
          // Image Source Dialog as a page (declarative approach)
          if (_showImageSourceDialog)
            MaterialPage(
              key: const ValueKey('ImageSourceDialog'),
              child: Builder(
                builder: (context) {
                  final controller = Provider.of<AddStoryController>(
                    context,
                    listen: false,
                  );
                  return ImageSourceDialogPage(
                    onCamera: () {
                      controller.requestImagePick(ImageSource.camera);
                      setShowImageSourceDialog(false);
                    },
                    onGallery: () {
                      controller.requestImagePick(ImageSource.gallery);
                      setShowImageSourceDialog(false);
                    },
                    onCancel: () {
                      setShowImageSourceDialog(false);
                    },
                  );
                },
              ),
            ),
          // Logout Dialog as a page (declarative approach)
          if (_showLogoutDialog)
            MaterialPage(
              key: const ValueKey('LogoutDialog'),
              child: LogoutDialogPage(
                onConfirm: () {
                  setShowLogoutDialog(false);
                  setLoggedIn(false);
                },
                onCancel: () {
                  setShowLogoutDialog(false);
                },
              ),
            ),
        ],
      ],
      onPopPage: (route, result) {
        final didPop = route.didPop(result);
        if (!didPop) {
          return false;
        }

        // Handle dialog pops
        if (_showImageSourceDialog) {
          _showImageSourceDialog = false;
        } else if (_showLogoutDialog) {
          _showLogoutDialog = false;
        } else if (_selectedStoryId != null) {
          _selectedStoryId = null;
        } else if (_isAddStory) {
          _isAddStory = false;
        } else if (_isRegister) {
          _isRegister = false;
        }

        notifyListeners();
        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(String configuration) async {}
}

// Declarative Image Source Dialog as a Page
class ImageSourceDialogPage extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onCancel;

  const ImageSourceDialogPage({
    Key? key,
    required this.onCamera,
    required this.onGallery,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: onCancel,
      behavior: HitTestBehavior.opaque,
      child: Material(
        color: Colors.black54,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {}, // Prevent closing when tapping on the dialog itself
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.camera_alt),
                      title: Text(localizations.camera),
                      onTap: onCamera,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: Text(localizations.gallery),
                      onTap: onGallery,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Declarative Logout Dialog as a Page
class LogoutDialogPage extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const LogoutDialogPage({
    Key? key,
    required this.onConfirm,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                localizations.logout,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                localizations.areYouSureLogout,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: onCancel,
                    child: Text(localizations.cancel),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: onConfirm,
                    child: Text(localizations.logout),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
