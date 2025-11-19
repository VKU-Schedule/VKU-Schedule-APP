import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vku_schedule/core/theme/app_theme.dart';

/// Standardized AppBar component for VKU Schedule app
/// 
/// Features:
/// - Gradient background (Navy → Red)
/// - Automatic back button based on navigation context
/// - Centered title with proper styling
/// - Support for custom actions and leading widgets
/// - Subtle shadow effect
class VKUAppBar extends StatelessWidget implements PreferredSizeWidget {
  const VKUAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.centerTitle = true,
    this.elevation = 0,
  });

  /// Title text to display in the AppBar
  final String title;

  /// Action buttons to display on the right side
  final List<Widget>? actions;

  /// Custom leading widget (overrides automatic back button)
  final Widget? leading;

  /// Whether to automatically show back button when navigation stack allows
  final bool automaticallyImplyLeading;

  /// Whether to center the title
  final bool centerTitle;

  /// Elevation of the AppBar (default 0 for flat design)
  final double elevation;

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  Widget? _buildLeading(BuildContext context) {
    // If custom leading widget is provided, use it
    if (leading != null) return leading;

    // If automatic back button is disabled, return null
    if (!automaticallyImplyLeading) return null;

    // Try to get GoRouter, return null if not available (e.g., in tests)
    try {
      final router = GoRouter.of(context);
      final canPop = router.canPop();
      if (!canPop) return null;

      // Show back button
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
        tooltip: 'Quay lại',
        color: Colors.white,
      );
    } catch (e) {
      // GoRouter not available (e.g., in tests), check if we can use Navigator
      final navigator = Navigator.maybeOf(context);
      if (navigator == null || !navigator.canPop()) return null;

      return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
        tooltip: 'Quay lại',
        color: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.gradientNavyToRed,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.15,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: centerTitle,
        leading: _buildLeading(context),
        actions: actions,
        backgroundColor: Colors.transparent,
        elevation: elevation,
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 24,
        ),
        actionsIconTheme: const IconThemeData(
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}


/// Standardized SliverAppBar component for VKU Schedule app with hero sections
/// 
/// Features:
/// - Expandable/collapsible behavior
/// - Same gradient background as VKUAppBar
/// - FlexibleSpace support for hero content (avatar, stats)
/// - Smooth title fade-in animation when collapsed
/// - Collapsed state matches VKUAppBar appearance exactly
class VKUSliverAppBar extends StatelessWidget {
  const VKUSliverAppBar({
    super.key,
    required this.title,
    this.expandedHeight = 200.0,
    this.flexibleSpace,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.pinned = true,
    this.floating = false,
  });

  /// Title text to display in the AppBar
  final String title;

  /// Height when expanded
  final double expandedHeight;

  /// Custom content to display in the flexible space (hero section)
  final Widget? flexibleSpace;

  /// Action buttons to display on the right side
  final List<Widget>? actions;

  /// Custom leading widget (overrides automatic back button)
  final Widget? leading;

  /// Whether to automatically show back button when navigation stack allows
  final bool automaticallyImplyLeading;

  /// Whether the app bar should remain visible at the top when scrolling
  final bool pinned;

  /// Whether the app bar should become visible as soon as the user scrolls towards it
  final bool floating;

  Widget? _buildLeading(BuildContext context) {
    // If custom leading widget is provided, use it
    if (leading != null) return leading;

    // If automatic back button is disabled, return null
    if (!automaticallyImplyLeading) return null;

    // Try to get GoRouter, return null if not available (e.g., in tests)
    try {
      final router = GoRouter.of(context);
      final canPop = router.canPop();
      if (!canPop) return null;

      // Show back button
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
        tooltip: 'Quay lại',
        color: Colors.white,
      );
    } catch (e) {
      // GoRouter not available (e.g., in tests), check if we can use Navigator
      final navigator = Navigator.maybeOf(context);
      if (navigator == null || !navigator.canPop()) return null;

      return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
        tooltip: 'Quay lại',
        color: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: pinned,
      floating: floating,
      leading: _buildLeading(context),
      actions: actions,
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(
        color: Colors.white,
        size: 24,
      ),
      actionsIconTheme: const IconThemeData(
        color: Colors.white,
        size: 24,
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.15,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        titlePadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        background: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.gradientNavyToRed,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: flexibleSpace,
        ),
      ),
    );
  }
}
