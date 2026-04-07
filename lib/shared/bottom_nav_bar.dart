import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FloatingBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const FloatingBottomNavBar({
    super.key,
    this.currentIndex = 0,
    this.onTap,
  });

  @override
  State<FloatingBottomNavBar> createState() => _FloatingBottomNavBarState();
}

class _FloatingBottomNavBarState extends State<FloatingBottomNavBar>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;

  static int _lastSelectedIndex = 0;
  static const int _itemCount = 4;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    final fromIndex = _lastSelectedIndex;
    _animation = Tween<double>(
      begin: fromIndex.toDouble(),
      end: _selectedIndex.toDouble(),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    if (fromIndex != _selectedIndex) {
      _animationController.forward(from: 0);
    }

    _lastSelectedIndex = _selectedIndex;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant FloatingBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _animateTo(widget.currentIndex);
    }
  }

  void _animateTo(int index) {
    _animation = Tween<double>(
      begin: _selectedIndex.toDouble(),
      end: index.toDouble(),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    setState(() {
      _selectedIndex = index;
    });
    _animationController.forward(from: 0);
    _lastSelectedIndex = index;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24.h,
      left: 24.w,
      right: 24.w,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(50.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(50),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SizedBox(
          height: 54.h,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth / _itemCount;
              return Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Positioned(
                        left: _animation.value * itemWidth,
                        child: Container(
                          width: itemWidth,
                          height: 42.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22.r),
                          ),
                        ),
                      );
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(
                        onTap: () => widget.onTap?.call(0),
                        index: 0,
                        icon: Icons.home_rounded,
                        label: 'Home',
                      ),
                      _buildNavItem(
                        onTap: () => widget.onTap?.call(1),
                        index: 1,
                        icon: Icons.restaurant_rounded,
                        label: 'Food',
                      ),
                      _buildNavItem(
                        onTap: () => widget.onTap?.call(2),
                        index: 2,
                        icon: Icons.fitness_center_rounded,
                        label: 'Workout',
                      ),
                      _buildNavItem(
                        onTap: () => widget.onTap?.call(3),
                        index: 3,
                        icon: Icons.person_rounded,
                        label: 'Profile',
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required VoidCallback onTap,
    required int index,
    required IconData icon,
    String? label,
  }) {
    final isActive = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 4.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  icon,
                  key: ValueKey<bool>(isActive),
                  color: isActive ? Colors.black : Colors.grey[500],
                  size: isActive ? 22.sp : 26.sp,
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                child:
                    isActive && label != null
                        ? Padding(
                          padding: EdgeInsets.only(left: 6.w),
                          child: Text(
                            label,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                        : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
