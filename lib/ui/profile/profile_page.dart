import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../store/auth_store.dart';
import '../../shared/bottom_nav_bar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthStore _store = AuthStore.instance;

  @override
  void initState() {
    super.initState();
    _store.fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile", style: Theme.of(context).textTheme.headlineSmall),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Observer(
        builder: (_) {
          if (_store.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.black));
          }
          final p = _store.profileData;
          if (p == null) {
            return const Center(child: Text("No Profile Data Found"));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header Info
                CircleAvatar(
                  radius: 54,
                  backgroundImage: const NetworkImage('https://via.placeholder.com/150'),
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                ).animate().scale(delay: 100.ms, duration: 400.ms),
                const SizedBox(height: 16),
                Text(
                  p['name'] ?? 'Your Name',
                  style: Theme.of(context).textTheme.headlineMedium,
                ).animate().fadeIn(delay: 200.ms),
                Text(
                  "PREMIUM MEMBER",
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 2),
                ).animate().fadeIn(delay: 300.ms),
                
                const SizedBox(height: 32),
                
                // Stat circles
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCircle("HEIGHT", "${p['height'] ?? '--'}", "cm"),
                    _buildStatCircle("WEIGHT", "${p['weight'] ?? '--'}", "kg"),
                    _buildStatCircle("AGE", "${p['age'] ?? '--'}", "y"),
                  ],
                ).animate().slideY(begin: 0.1, delay: 400.ms).fadeIn(),

                const SizedBox(height: 48),

                // AI Insights Stub matching HTML
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "AI Insights",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInsightCard(Icons.restaurant, "Optimal Macros", "Based on your goals"),
                const SizedBox(height: 12),
                _buildInsightCard(Icons.fitness_center, "Next suggested workout", "Chest & Triceps"),
                
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const FloatingBottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildStatCircle(String label, String value, String unit) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
              Text(unit, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.white.withAlpha(150), fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
        ],
      ),
    );
  }
}
