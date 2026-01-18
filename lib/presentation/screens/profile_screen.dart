import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movieverse/presentation/providers/auth_provider.dart';
import 'package:movieverse/presentation/providers/core_providers.dart';
import 'package:movieverse/presentation/screens/edit_profile_screen.dart';
import 'package:movieverse/presentation/screens/static_info_screen.dart';
import 'package:movieverse/presentation/screens/subscription_screen.dart';
import 'package:movieverse/presentation/screens/watch_history_screen.dart';
import 'package:movieverse/presentation/screens/watchlist_screen.dart';
import 'package:movieverse/presentation/widgets/primary_button.dart';
import 'package:movieverse/presentation/widgets/settings_tile.dart';
import 'package:movieverse/presentation/providers/user_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final historyAsync = ref.watch(watchHistoryProvider);
    final reviewsAsync = ref.watch(userReviewsCountProvider);

    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
            child:
                Text('Not Logged In', style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Profile',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {
              // Navigate to general settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Avatar & Name Section
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.red, width: 2),
                        ),
                        child: const CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey,
                          child:
                              Icon(Icons.person, size: 60, color: Colors.white),
                          // TODO: Load image from URL if available
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit,
                              size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 140,
                    height: 36,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const EditProfileScreen()));
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('Edit Profile',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Stats Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Watchlist', '${user.watchlist.length}'),
                  _buildStatItem(
                      'Reviews', reviewsAsync.asData?.value.toString() ?? '0'),
                  _buildStatItem('Watched',
                      historyAsync.asData?.value.length.toString() ?? '0'),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Premium Banner
            if (user.subscriptionType != 'premium')
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade900, Colors.blue.shade900],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 30),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Go Premium',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          Text('Unlock 4K quality & no ads.',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SubscriptionScreen()));
                      },
                      child: const Text('Upgrade'),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Settings Sections
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Start Here'), // Content Section
                  SettingsTile(
                    icon: Icons.bookmark_border,
                    title: 'My Watchlist',
                    iconColor: Colors.blueAccent,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const WatchlistScreen()));
                    },
                  ),
                  const SizedBox(height: 8),
                  SettingsTile(
                    icon: Icons.history,
                    title: 'Watch History',
                    iconColor: Colors.purpleAccent,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const WatchHistoryScreen()));
                    },
                  ),

                  const SizedBox(height: 24),
                  _buildSectionHeader('Account'),
                  SettingsTile(
                    icon: Icons.person_outline,
                    title:
                        'Subscription Plan: ${user.subscriptionType.toUpperCase()}',
                    iconColor: Colors.orangeAccent,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SubscriptionScreen()));
                    },
                  ),
                  const SizedBox(height: 8),
                  SettingsTile(
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    iconColor: Colors.redAccent,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const EditProfileScreen()));
                    },
                  ),

                  const SizedBox(height: 24),
                  _buildSectionHeader('Support'),
                  SettingsTile(
                    icon: Icons.help_outline,
                    title: 'Help Center',
                    iconColor: Colors.greenAccent,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const StaticInfoScreen(
                                  title: 'Help Center',
                                  content: 'Contact support@example.com')));
                    },
                  ),
                  const SizedBox(height: 8),
                  SettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    iconColor: Colors.tealAccent,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const StaticInfoScreen(
                                  title: 'Privacy Policy',
                                  content: 'Your privacy is important...')));
                    },
                  ),

                  const SizedBox(height: 40),

                  PrimaryButton(
                    text: 'Log Out',
                    backgroundColor: Colors.red.withValues(alpha: 0.2),
                    textColor: Colors.red,
                    onPressed: () {
                      ref.read(authRepositoryProvider).logout();
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
