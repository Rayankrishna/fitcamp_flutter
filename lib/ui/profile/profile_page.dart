import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../store/auth_store.dart';
import '../../shared/bottom_nav_bar.dart';
import '../auth/onboarding_page.dart';
import '../../theme/app_colors.dart';

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Profile",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Observer(
        builder: (_) {
          if (_store.profileData == null && _store.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          }
          final p = _store.profileData;
          if (p == null) {
            return const Center(child: Text("No Profile Data Found"));
          }

          final rawHeight = p['height'];
          final rawWeight = p['weight'];
          final rawAge = p['age'];
          final rawEmail = p['email'] as String?;

          String heightStr = '--';
          if (rawHeight != null) {
            final double hVal = (rawHeight is num)
                ? rawHeight.toDouble()
                : (double.tryParse(rawHeight.toString()) ?? 0.0);
            heightStr = hVal.round().toString(); // Height is always a whole number
          }

          String weightStr = '--';
          if (rawWeight != null) {
            final double wVal = (rawWeight is num)
                ? rawWeight.toDouble()
                : (double.tryParse(rawWeight.toString()) ?? 0.0);
            weightStr = wVal % 1 == 0 ? wVal.toInt().toString() : wVal.toStringAsFixed(1);
          }

          final String ageStr = rawAge?.toString() ?? '--';
          
          // Generate a display name from the email prefix
          final String displayName = rawEmail != null 
              ? rawEmail.split('@')[0].replaceAll(RegExp(r'[._-]'), ' ').split(' ').map((s) => s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : '').join(' ')
              : 'User';
          final String initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Premium Header Card (Row Layout for space-efficiency)
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 16.r,
                        offset: Offset(0, 4.h),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Gradient initial-avatar
                      Container(
                        width: 72.r,
                        height: 72.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2E2E3A), Color(0xFF0F0F12)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: Colors.black.withOpacity(0.08),
                            width: 2.w,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8.r,
                              offset: Offset(0, 2.h),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initial,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                      SizedBox(width: 16.w),
                      // Info column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.sp,
                                    color: AppColors.primary,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              rawEmail ?? 'user@fitcamp.com',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 12.sp,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8.h),
                            // Gold Premium badge
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF9E6),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: const Color(0xFFFFD580).withOpacity(0.8),
                                  width: 1.w,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.workspace_premium,
                                    color: const Color(0xFFD4AF37),
                                    size: 14.r,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    "PREMIUM MEMBER",
                                    style: TextStyle(
                                      color: const Color(0xFFB8860B),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 9.sp,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, duration: 300.ms),

                SizedBox(height: 16.h),

                // 2. Stat Cards Row
                Row(
                  children: [
                    _buildStatCard("HEIGHT", heightStr, "cm", Icons.height),
                    SizedBox(width: 10.w),
                    _buildStatCard("WEIGHT", weightStr, "kg", Icons.scale_outlined),
                    SizedBox(width: 10.w),
                    _buildStatCard("AGE", ageStr, "years", Icons.cake_outlined),
                  ],
                ).animate().fadeIn(delay: 150.ms, duration: 300.ms).slideY(begin: 0.05, duration: 300.ms),

                SizedBox(height: 20.h),

                // 3. Settings Actions Group Card
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 12.r,
                        offset: Offset(0, 3.h),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildSettingsTile(
                        icon: Icons.edit_note_outlined,
                        title: "Edit Physical Profile",
                        subtitle: "Update weight, height, age or goals",
                        color: Colors.blueAccent,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const OnboardingPage(isEditing: true),
                            ),
                          ).then((_) {
                            _store.fetchProfile();
                            _store.fetchHomeData();
                          });
                        },
                      ),
                      Divider(height: 1.h, thickness: 1.h, color: AppColors.surfaceContainerLow),
                      _buildSettingsTile(
                        icon: Icons.logout_rounded,
                        title: "Log Out",
                        subtitle: "Sign out of your account",
                        color: AppColors.error,
                        isDestructive: true,
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Confirm Logout"),
                              content: const Text("Are you sure you want to log out of FitCamp?"),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: Text("Log Out", style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await _store.logout();
                          }
                        },
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 250.ms, duration: 300.ms),

                SizedBox(height: 24.h),

                // 4. AI Insights Section
                Text(
                  "AI Insights",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                      ),
                ).animate().fadeIn(delay: 300.ms),
                SizedBox(height: 12.h),
                _buildInsightCard(
                  Icons.restaurant_rounded,
                  "Optimal Macros",
                  "Based on your profile metrics, we've computed a custom protein target and caloric split.",
                  const Color(0xFF4CAF50),
                ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.05),
                SizedBox(height: 10.h),
                _buildInsightCard(
                  Icons.fitness_center_rounded,
                  "Suggested Routine",
                  "Try starting with your Chest & Triceps routine today to hit your muscle volume benchmarks.",
                  const Color(0xFFFF9800),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.05),
                
                SizedBox(height: 100.h), // Spacing for bottom navbar
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const FloatingBottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildStatCard(String label, String value, String unit, IconData icon) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: Colors.black.withOpacity(0.03),
            width: 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10.r,
              offset: Offset(0, 3.h),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18.r, color: AppColors.primaryFixed),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: AppColors.onSurfaceVariant.withOpacity(0.8),
                  ),
            ),
            SizedBox(height: 4.h),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                          color: AppColors.primary,
                        ),
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    unit,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: 9.sp,
                          color: AppColors.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 22.r,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: isDestructive ? AppColors.error : AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.outlineVariant,
              size: 14.r,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(IconData icon, String title, String subtitle, Color themeColor) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.black.withOpacity(0.03),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: themeColor, size: 20.r),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                        color: AppColors.primary,
                      ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 11.sp,
                        height: 1.3,
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
