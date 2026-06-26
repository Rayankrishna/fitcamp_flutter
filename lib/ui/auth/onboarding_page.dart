import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../store/auth_store.dart';
import '../../shared/enums.dart';
import '../../shared/app_snackbar.dart';
import '../home/home_page.dart';

class OnboardingPage extends StatefulWidget {
  final String? email;
  final String? password;
  final bool isEditing;

  const OnboardingPage({
    super.key,
    this.email,
    this.password,
    this.isEditing = false,
  });

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final AuthStore _authStore = AuthStore.instance;
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Form State
  double _height = 175.0; // cm
  double _weight = 70.0; // kg
  int _age = 25;
  String _activityLevel = 'moderately_active';
  String _dietGoal = 'maintain';

  final List<Map<String, String>> _activityLevels = [
    {
      'key': 'sedentary',
      'title': 'Sedentary',
      'desc': 'Little or no exercise. Desk job.'
    },
    {
      'key': 'lightly_active',
      'title': 'Lightly Active',
      'desc': 'Light exercise/sports 1-3 days/week.'
    },
    {
      'key': 'moderately_active',
      'title': 'Moderately Active',
      'desc': 'Moderate exercise/sports 3-5 days/week.'
    },
    {
      'key': 'active',
      'title': 'Active',
      'desc': 'Hard exercise/sports 6-7 days/week.'
    },
    {
      'key': 'very_active',
      'title': 'Very Active',
      'desc': 'Very hard exercise/sports, physical job or training 2x/day.'
    },
  ];

  final List<Map<String, String>> _dietGoals = [
    {
      'key': 'lose_weight',
      'title': 'Lose Weight',
      'desc': 'Clean calorie deficit to lose body fat.'
    },
    {
      'key': 'maintain',
      'title': 'Maintain',
      'desc': 'Balance calories to maintain current weight.'
    },
    {
      'key': 'gain_weight',
      'title': 'Gain Weight',
      'desc': 'Steady surplus to gain size and strength.'
    },
    {
      'key': 'clean_bulk',
      'title': 'Clean Bulk',
      'desc': 'Controlled surplus focusing on muscle gains.'
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && _authStore.profileData != null) {
      final p = _authStore.profileData!;
      _height = ((p['height'] as num?)?.toDouble() ?? 175.0).roundToDouble();
      _weight = (p['weight'] as num?)?.toDouble() ?? 70.0;
      _age = p['age'] as int? ?? 25;
      _activityLevel = p['activity_level'] as String? ?? 'moderately_active';
      _dietGoal = p['diet_goal'] as String? ?? 'maintain';
    }
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: 350.ms,
        curve: Curves.easeInOutCubic,
      );
    } else {
      _submit();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: 350.ms,
        curve: Curves.easeInOutCubic,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _submit() async {
    bool success = false;
    if (widget.isEditing) {
      success = await _authStore.updateProfile(
        height: _height,
        weight: _weight,
        age: _age,
        activityLevel: _activityLevel,
        dietGoal: _dietGoal,
      );
      if (success && mounted) {
        AppSnackbar.show('Profile updated successfully');
        Navigator.pop(context);
      }
    } else {
      if (widget.email == null || widget.password == null) {
        AppSnackbar.show('Missing credentials. Please restart registration.');
        return;
      }
      success = await _authStore.register(
        email: widget.email!,
        password: widget.password!,
        height: _height,
        weight: _weight,
        age: _age,
        activityLevel: _activityLevel,
        dietGoal: _dietGoal,
      );
      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: _prevStep,
        ),
        title: Text(
          widget.isEditing ? "Update Profile" : "Personalize Plan",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Row(
                children: List.generate(4, (index) {
                  final active = index <= _currentStep;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: active ? Colors.black : Colors.grey[200],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            
            // Steps PageView
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildHeightAndAgeStep(),
                  _buildWeightStep(),
                  _buildActivityStep(),
                  _buildGoalStep(),
                ],
              ),
            ),

            // Bottom Navigation Panel
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 56.h,
                        margin: const EdgeInsets.only(right: 12),
                        child: OutlinedButton(
                          onPressed: _prevStep,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.black, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28.r),
                            ),
                          ),
                          child: const Text(
                            "Back",
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    flex: 2,
                    child: Observer(
                      builder: (_) {
                        final loading = widget.isEditing
                            ? _authStore.profileUpdateState == LoadingStatusEnum.loading
                            : _authStore.registerState == LoadingStatusEnum.loading;

                        return SizedBox(
                          height: 56.h,
                          child: ElevatedButton(
                            onPressed: loading ? null : _nextStep,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28.r),
                              ),
                            ),
                            child: loading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    _currentStep == 3
                                        ? (widget.isEditing ? "Save & Close" : "Calculate Goals")
                                        : "Continue",
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                          ),
                        );
                      },
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

  Widget _buildHeightAndAgeStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What is your height & age?",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ).animate().fadeIn().slideY(begin: 0.1),
          const SizedBox(height: 8),
          Text(
            "We use these stats to accurately estimate your baseline metabolic rate.",
            style: TextStyle(color: Colors.grey[600]),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 48),

          // Height control
          Center(
            child: Column(
              children: [
                Text(
                  "HEIGHT",
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _height.toInt().toString(),
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 72,
                              color: Colors.black,
                            ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "cm",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
                Slider(
                  value: _height,
                  min: 100.0,
                  max: 250.0,
                  activeColor: Colors.black,
                  inactiveColor: Colors.grey[200],
                  onChanged: (val) {
                    setState(() {
                      _height = val.roundToDouble();
                    });
                  },
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 48),

          // Age control
          Center(
            child: Column(
              children: [
                Text(
                  "AGE",
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 36),
                      onPressed: () {
                        if (_age > 1) {
                          setState(() {
                            _age--;
                          });
                        }
                      },
                    ),
                    Container(
                      width: 100,
                      alignment: Alignment.center,
                      child: Text(
                        _age.toString(),
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 36),
                      onPressed: () {
                        if (_age < 120) {
                          setState(() {
                            _age++;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }

  Widget _buildWeightStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What is your current weight?",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ).animate().fadeIn().slideY(begin: 0.1),
          const SizedBox(height: 8),
          Text(
            "Your weight is key for daily macro target allocations.",
            style: TextStyle(color: Colors.grey[600]),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 60),

          Center(
            child: Column(
              children: [
                Text(
                  "WEIGHT",
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _weight.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 80,
                              color: Colors.black,
                            ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "kg",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Slider(
                  value: _weight,
                  min: 30.0,
                  max: 200.0,
                  divisions: 1700,
                  activeColor: Colors.black,
                  inactiveColor: Colors.grey[200],
                  onChanged: (val) {
                    setState(() {
                      _weight = val;
                    });
                  },
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }

  Widget _buildActivityStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "How active are you?",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ).animate().fadeIn().slideY(begin: 0.1),
          const SizedBox(height: 8),
          Text(
            "Select the description that matches your weekly physical activity.",
            style: TextStyle(color: Colors.grey[600]),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 24),

          ..._activityLevels.map((act) {
            final isSelected = _activityLevel == act['key'];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                title: Text(
                  act['title']!,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    act['desc']!,
                    style: TextStyle(
                      color: isSelected ? Colors.white70 : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: Colors.white)
                    : null,
                onTap: () {
                  setState(() {
                    _activityLevel = act['key']!;
                  });
                },
              ),
            ).animate().fadeIn(delay: 150.ms);
          }),
        ],
      ),
    );
  }

  Widget _buildGoalStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What is your goal?",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ).animate().fadeIn().slideY(begin: 0.1),
          const SizedBox(height: 8),
          Text(
            "We adjust calorie and protein allocations based on your direction.",
            style: TextStyle(color: Colors.grey[600]),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 24),

          ..._dietGoals.map((g) {
            final isSelected = _dietGoal == g['key'];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                title: Text(
                  g['title']!,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    g['desc']!,
                    style: TextStyle(
                      color: isSelected ? Colors.white70 : Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: Colors.white)
                    : null,
                onTap: () {
                  setState(() {
                    _dietGoal = g['key']!;
                  });
                },
              ),
            ).animate().fadeIn(delay: 150.ms);
          }),
        ],
      ),
    );
  }
}
