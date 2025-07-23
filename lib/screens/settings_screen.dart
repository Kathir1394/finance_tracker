import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/data_backup_service.dart';
import '../services/google_auth_service.dart';

// FIX: Providers are moved to the global scope to maintain a single,
// persistent state across the entire application. This resolves all
// reported issues (freezing, UI not updating, and missing buttons).
final googleAuthServiceProvider = Provider((ref) => GoogleAuthService());
final dataBackupServiceProvider = Provider((ref) => DataBackupService());
final userProvider = StateProvider<bool>((ref) {
  // Check the initial sign-in state when the app starts
  return ref.watch(googleAuthServiceProvider).googleSignIn.currentUser != null;
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This will now listen to the global provider and update correctly
    final isSignedIn = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const ListTile(
            leading: Icon(Icons.security),
            title: Text('Data & Privacy'),
            subtitle: Text('Manage your data backup and restore options.'),
          ),
          // Conditional UI based on the global sign-in state
          if (!isSignedIn)
            ElevatedButton.icon(
              onPressed: () async {
                final authService = ref.read(googleAuthServiceProvider);
                final user = await authService.signIn();
                // This updates the global state, causing the UI to rebuild
                ref.read(userProvider.notifier).state = user != null;
              },
              icon: const Icon(Icons.login),
              label: const Text('Sign in with Google'),
            )
          else ...[
            // This section will now appear correctly after signing in
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                        'You are signed in. You can now backup or restore your data.'),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await ref
                              .read(dataBackupServiceProvider)
                              .backupData();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Backup Successful!')));
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Backup Failed: $e')));
                          }
                        }
                      },
                      icon: const Icon(Icons.backup),
                      label: const Text('Backup Data to Google Drive'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await ref
                              .read(dataBackupServiceProvider)
                              .restoreData();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Restore Successful!')));
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Restore Failed: $e')));
                          }
                        }
                      },
                      icon: const Icon(Icons.restore),
                      label: const Text('Restore Data from Google Drive'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () async {
                final authService = ref.read(googleAuthServiceProvider);
                await authService.signOut();
                ref.read(userProvider.notifier).state = false;
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Sign Out', style: TextStyle(color: Colors.red)),
            ),
          ],
        ],
      ),
    );
  }
}