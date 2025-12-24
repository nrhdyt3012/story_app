import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';
import '../provider/story_provider.dart';
import '../widgets/story_card.dart';

class StoryListScreen extends StatefulWidget {
  final Function(String) onTapped;
  final VoidCallback onLogout;
  final VoidCallback onAddStory;

  const StoryListScreen({
    Key? key,
    required this.onTapped,
    required this.onLogout,
    required this.onAddStory,
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

  Future<void> _handleLogout() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();
    widget.onLogout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Story App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStories,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _handleLogout();
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
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
                    child: const Text('Retry'),
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
                  const Text('No stories yet'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: widget.onAddStory,
                    child: const Text('Add Your First Story'),
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