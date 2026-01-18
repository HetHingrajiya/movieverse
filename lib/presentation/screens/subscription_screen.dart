import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movieverse/presentation/widgets/primary_button.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Choose Your Plan',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Unlock the full experience',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Cancel anytime. No hidden fees.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 32),
            _buildPlanCard(
              context,
              title: 'Basic',
              price: 'Free',
              features: ['Ad-supported', 'HD Quality', 'Mobile & Web'],
              color: Colors.blueGrey,
              isCurrent: false, // In real app check user.subscriptionType
              onTap: () {
                _selectPlan(context, "basic");
              },
            ),
            const SizedBox(height: 16),
            _buildPlanCard(
              context,
              title: 'Premium',
              price: '\$9.99/mo',
              features: [
                'No Ads',
                '4K Ultra HD',
                'Download & Watch Offline',
                'All Devices'
              ],
              color: Colors.purple.shade700,
              isPopular: true,
              onTap: () {
                _selectPlan(context, "premium");
              },
            ),
            const SizedBox(height: 16),
            _buildPlanCard(
              context,
              title: 'Family',
              price: '\$19.99/mo',
              features: [
                '4 Screens at once',
                'No Ads',
                '4K Ultra HD',
                'Parental Controls'
              ],
              color: Colors.orange.shade800,
              onTap: () {
                _selectPlan(context, "family");
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'By verifying your subscription, you agree to our Terms of Service and Privacy Policy.',
              style: TextStyle(color: Colors.white24, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String price,
    required List<String> features,
    required Color color,
    required VoidCallback onTap,
    bool isPopular = false,
    bool isCurrent = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: isPopular ? Border.all(color: color, width: 2) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isPopular)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: const Text(
                'MOST POPULAR',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    if (isCurrent)
                      const Chip(
                          label:
                              Text('Current', style: TextStyle(fontSize: 10)),
                          backgroundColor: Colors.white24),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  price,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ...features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: color, size: 20),
                          const SizedBox(width: 12),
                          Text(feature,
                              style: const TextStyle(color: Colors.white70)),
                        ],
                      ),
                    )),
                const SizedBox(height: 20),
                PrimaryButton(
                  text: isCurrent ? 'Current Plan' : 'Select Plan',
                  backgroundColor: isCurrent ? Colors.white10 : color,
                  onPressed: isCurrent ? () {} : onTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _selectPlan(BuildContext context, String planId) {
    // Mock Payment Process
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!context.mounted) return;
      Navigator.pop(context); // Close loader

      // Show Success Dialog
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Access Granted',
              style: TextStyle(color: Colors.white)),
          content: Text('You have successfully subscribed to the $planId plan!',
              style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(ctx); // Close dialog
                  if (context.mounted) {
                    Navigator.pop(context); // Close Subscription Screen
                  }
                },
                child: const Text('Awesome'))
          ],
        ),
      );
    });
  }
}
