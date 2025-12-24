import 'package:flutter/material.dart';
import '../screen/login_screen.dart';
import '../screen/register_screen.dart';
import '../screen/story_list_screen.dart';
import '../screen/story_detail_screen.dart';
import '../screen/add_story_screen.dart';

class MyRouterDelegate extends RouterDelegate<String>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<String> {
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  String? _selectedStoryId;
  bool _isLoggedIn = false;
  bool _isRegister = false;
  bool _isAddStory = false;

  MyRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  bool get isLoggedIn => _isLoggedIn;
  bool get isRegister => _isRegister;
  bool get isAddStory => _isAddStory;

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
        ],
      ],
      onPopPage: (route, result) {
        final didPop = route.didPop(result);
        if (!didPop) {
          return false;
        }

        if (_selectedStoryId != null) {
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
  Future<void> setNewRoutePath(String configuration) async {
    // Implementasi bisa kosong jika tidak menggunakan deep linking
  }
}