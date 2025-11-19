import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../subjects/providers/subject_selection_provider.dart';
import '../../options/providers/saved_schedules_provider.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../widgets/hero_section.dart';
import '../widgets/stats_cards.dart';
import '../widgets/quick_actions.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subjectSelection = ref.watch(subjectSelectionProvider);
    final savedSchedules = ref.watch(savedSchedulesProvider);

    return Scaffold(
      // backgroundColor: AppTheme.backgroundGrey,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
      
        slivers: [
          

          // Hero Section with VKU Branding
          SliverToBoxAdapter(
            child: HeroSection(
              animationController: _animationController,
              onGetStarted: () => context.push('/subjects'),
            ),
          ),

          // Stats Cards with Glassmorphism
          SliverToBoxAdapter(
            child: StatsCards(
              enrolledSubjectsCount: subjectSelection.enrolledSubjects.length,
              savedSchedulesCount: savedSchedules.length,
            ),
          ),

          // Quick Actions Section
          const SliverToBoxAdapter(
            child: QuickActionsSection(),
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentRoute: '/home'),
    );
  }
}
