// screens/home_screen.dart
// Thyme App Home Page - Cute Style Version
// Using shared widget library

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';
import '../controllers/habit_controller.dart';
import '../controllers/mood_controller.dart';
import '../controllers/garden_controller.dart';
import '../controllers/kindness_controller.dart';
import 'habit_tracker_screen.dart';
import 'mood_journal_screen.dart';
import 'ai_coach_screen.dart';
import 'garden_screen.dart';
import 'kindness_chain_screen.dart';
import 'analytics_screen.dart';
import '../utils/theme.dart';
import '../widgets/cute_garden_icons.dart';
import '../widgets/cute_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;
  bool _isInitialized = false; // ✅ FIXED (v3): 防止 didChangeDependencies 重复初始化

  final List<Widget> _screens = [
    const HabitTrackerScreen(),
    const MoodJournalScreen(),
    const GardenScreen(),
    const KindnessChainScreen(),
    const AICoachScreen(),
    const AnalyticsScreen(),
  ];

  final List<_NavItem> _navItems = [
    _NavItem('Habits', 'habits', Icons.spa_outlined, Icons.spa),
    _NavItem('Mood', 'mood', Icons.edit_outlined, Icons.edit),
    _NavItem('Garden', 'garden', Icons.local_florist_outlined, Icons.local_florist),
    _NavItem('Kindness', 'kindness', Icons.favorite_outline, Icons.favorite),
    _NavItem('Fern', 'fern', Icons.chat_bubble_outline, Icons.chat_bubble),
    _NavItem('Journey', 'journey', Icons.auto_graph_outlined, Icons.auto_graph),
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  // ✅ FIXED (v3): 从 initState 移到 didChangeDependencies，安全使用 context
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      _loadUserData();
    }
  }

  void _initAnimations() {
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -3, end: 3).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final authController = Provider.of<AuthController>(context, listen: false);
    final userId = authController.currentUser?.uid;

    if (kDebugMode) {
      debugPrint('🏠 HomeScreen: Loading user data for $userId');
    }

    if (userId != null) {
      Provider.of<HabitController>(context, listen: false).loadHabits(userId);
      Provider.of<MoodController>(context, listen: false).loadMoodEntries(userId);
      Provider.of<GardenController>(context, listen: false).loadGardenState(userId);
      Provider.of<KindnessController>(context, listen: false).loadKindnessActs(userId);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CuteTheme.warmWhite,
      appBar: _buildCuteAppBar(),
      body: _screens[_selectedIndex],
      bottomNavigationBar: _buildCuteBottomNav(),
    );
  }

  PreferredSizeWidget _buildCuteAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 70,
      title: Row(
        children: [
          ListenableBuilder(
            listenable: _floatAnimation,
            builder: (context, _) {
              return Transform.translate(
                offset: Offset(0, _floatAnimation.value),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        CuteTheme.primaryGreen.withValues(alpha: 0.15),
                        CuteTheme.petalPink.withValues(alpha: 0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: CuteNavIcon(
                    type: _navItems[_selectedIndex].type,
                    size: 26,
                    isActive: true,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 14),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _navItems[_selectedIndex].label,
                  style: GoogleFonts.poppins(
                    color: CuteTheme.deepGreen,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _getSubtitle(_selectedIndex),
                  style: GoogleFonts.poppins(
                    color: CuteTheme.textMuted,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Consumer<GardenController>(
          builder: (context, gardenController, _) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CuteResourceDisplay(
                waterDrops: gardenController.gardenState.waterDrops,
                sunlightPoints: gardenController.gardenState.sunlightPoints,
              ),
            );
          },
        ),
        Container(
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: CuteTheme.petalPink.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.logout_rounded,
              color: CuteTheme.flowerCenter,
              size: 20,
            ),
            onPressed: () => _showLogoutDialog(),
            tooltip: 'Leave Garden',
          ),
        ),
      ],
    );
  }

  String _getSubtitle(int index) {
    switch (index) {
      case 0: return 'Small steps, big growth';
      case 1: return 'Express yourself freely';
      case 2: return 'Watch your garden bloom';
      case 3: return 'Spread joy to others';
      case 4: return 'Your forest spirit friend';
      case 5: return 'See how far you\'ve come';
      default: return '';
    }
  }

  Widget _buildCuteBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: CuteTheme.primaryGreen.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (index) {
              return _buildNavItem(index);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final isSelected = _selectedIndex == index;
    final item = _navItems[index];

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 14 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
            colors: [
              CuteTheme.primaryGreen.withValues(alpha: 0.15),
              CuteTheme.petalPink.withValues(alpha: 0.1),
            ],
          )
              : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CuteNavIcon(
              type: item.type,
              size: 24,
              isActive: isSelected,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? CuteTheme.primaryGreen : CuteTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    // ✅ FIXED (v3): 在 dialog builder 外捕获引用，防止 pop 后 context 失效
    final authController = Provider.of<AuthController>(context, listen: false);
    final navigator = Navigator.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CuteTheme.radiusXLarge),
        ),
        contentPadding: const EdgeInsets.all(28),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    CuteTheme.petalPink.withValues(alpha: 0.3),
                    CuteTheme.sunnyYellow.withValues(alpha: 0.2),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Text('👋', style: TextStyle(fontSize: 40)),
            ),
            const SizedBox(height: 20),
            Text(
              'Leaving so soon?',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: CuteTheme.deepGreen,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your garden will wait patiently for you.\nTake care out there! 🌸',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: CuteTheme.textMuted,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: const BorderSide(color: CuteTheme.borderLight),
                  ),
                  child: Text(
                    'Stay',
                    style: GoogleFonts.poppins(color: CuteTheme.textMuted),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(dialogContext);
                    await authController.signOut();
                    if (mounted) {
                      navigator.pushReplacementNamed('/auth');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CuteTheme.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Leave',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final String label;
  final String type;
  final IconData icon;
  final IconData activeIcon;

  _NavItem(this.label, this.type, this.icon, this.activeIcon);
}