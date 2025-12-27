import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';
import '../provider/story_provider.dart';
import '../widgets/story_card.dart';
import '../l10n/app_localizations.dart';

class StoryListScreen extends StatefulWidget {
  final Function(String) onTapped;
  final VoidCallback onLogout;
  final VoidCallback onAddStory;
  final VoidCallback onShowLogoutDialog;

  const StoryListScreen({
    Key? key,
    required this.onTapped,
    required this.onLogout,
    required this.onAddStory,
    required this.onShowLogoutDialog,
  }) : super(key: key);

  @override
  State<StoryListScreen> createState() => _StoryListScreenState();
}

class _StoryListScreenState extends State<StoryListScreen> {
  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  Future<void> _loadStories() async {
    final authProvider = context.read<AuthProvider>();
    final storyProvider = context.read<StoryProvider>();
    final token = await authProvider.getToken();

    if (token != null) {
      storyProvider.fetchStories(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.appTitle),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadStories),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: widget.onShowLogoutDialog, // FIXED: Use declarative callback
          ),
        ],
      ),
      body: Consumer<StoryProvider>(
        builder: (context, storyProvider, child) {
          if (storyProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (storyProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(storyProvider.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadStories,
                    child: Text(localizations.retry),
                  ),
                ],
              ),
            );
          }

          if (storyProvider.stories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inbox, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(localizations.noStoriesYet),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: widget.onAddStory,
                    child: Text(localizations.addYourFirstStory),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadStories,
            child: ListView.builder(
              itemCount: storyProvider.stories.length,
              itemBuilder: (context, index) {
                final story = storyProvider.stories[index];
                return StoryCard(
                  story: story,
                  onTap: () => widget.onTapped(story.id),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: widget.onAddStory,
        child: const Icon(Icons.add),
      ),
    );
  }
}