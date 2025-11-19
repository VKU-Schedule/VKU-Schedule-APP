import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vku_schedule/core/widgets/app_bar.dart';
import 'package:vku_schedule/core/theme/app_theme.dart';

/// Comprehensive test to verify AppBar consistency across the application
/// 
/// This test verifies:
/// - Gradient rendering consistency
/// - Title styling and centering
/// - Back button behavior on root vs non-root pages
/// - Action buttons functionality
/// - Shadow effects
/// - Color scheme consistency
void main() {
  group('AppBar Consistency Verification', () {
    testWidgets('VKUAppBar gradient is consistent', (WidgetTester tester) async {
      // Test multiple instances to ensure consistency
      for (int i = 0; i < 3; i++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: VKUAppBar(title: 'Test $i'),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.ancestor(
            of: find.byType(AppBar),
            matching: find.byType(Container),
          ).first,
        );

        final decoration = container.decoration as BoxDecoration;
        final gradient = decoration.gradient as LinearGradient;
        
        // Verify gradient colors are consistent
        expect(gradient.colors[0], AppTheme.vkuNavy);
        expect(gradient.colors[1], AppTheme.vkuRed);
        expect(gradient.begin, Alignment.topLeft);
        expect(gradient.end, Alignment.bottomRight);
      }
    });

    testWidgets('VKUSliverAppBar gradient matches VKUAppBar',
        (WidgetTester tester) async {
      // First, get VKUAppBar gradient
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: VKUAppBar(title: 'Standard'),
          ),
        ),
      );

      final standardContainer = tester.widget<Container>(
        find.ancestor(
          of: find.byType(AppBar),
          matching: find.byType(Container),
        ).first,
      );
      final standardDecoration = standardContainer.decoration as BoxDecoration;
      final standardGradient = standardDecoration.gradient as LinearGradient;

      // Now test VKUSliverAppBar
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                const VKUSliverAppBar(title: 'Sliver'),
                SliverList(
                  delegate: SliverChildListDelegate([
                    Container(height: 1000),
                  ]),
                ),
              ],
            ),
          ),
        ),
      );

      final flexibleSpaceBar = tester.widget<FlexibleSpaceBar>(
        find.byType(FlexibleSpaceBar),
      );
      final sliverBackground = flexibleSpaceBar.background as Container;
      final sliverDecoration = sliverBackground.decoration as BoxDecoration;
      final sliverGradient = sliverDecoration.gradient as LinearGradient;

      // Verify gradients match
      expect(sliverGradient.colors, standardGradient.colors);
      expect(sliverGradient.begin, standardGradient.begin);
      expect(sliverGradient.end, standardGradient.end);
    });

    testWidgets('Title styling is consistent across instances',
        (WidgetTester tester) async {
      final titles = ['Home', 'Settings', 'Comparison', 'Options'];

      for (final title in titles) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: VKUAppBar(title: title),
            ),
          ),
        );

        final textWidget = tester.widget<Text>(find.text(title));
        
        // Verify consistent styling
        expect(textWidget.style?.color, Colors.white);
        expect(textWidget.style?.fontSize, 20);
        expect(textWidget.style?.fontWeight, FontWeight.w600);
        expect(textWidget.style?.letterSpacing, 0.15);
        expect(textWidget.maxLines, 1);
        expect(textWidget.overflow, TextOverflow.ellipsis);
      }
    });

    testWidgets('Shadow effect is consistent', (WidgetTester tester) async {
      for (int i = 0; i < 3; i++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: VKUAppBar(title: 'Test $i'),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.ancestor(
            of: find.byType(AppBar),
            matching: find.byType(Container),
          ).first,
        );

        final decoration = container.decoration as BoxDecoration;
        
        // Verify shadow consistency
        expect(decoration.boxShadow, isNotNull);
        expect(decoration.boxShadow!.length, 1);
        expect(decoration.boxShadow![0].blurRadius, 4);
        expect(decoration.boxShadow![0].offset, const Offset(0, 2));
        expect(decoration.boxShadow![0].color.alpha, greaterThan(0));
      }
    });

    testWidgets('Back button behavior is consistent on navigation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: const VKUAppBar(title: 'Root Page'),
            body: Builder(
              builder: (context) => Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Scaffold(
                            appBar: VKUAppBar(title: 'Page 1'),
                          ),
                        ),
                      );
                    },
                    child: const Text('To Page 1'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Root page should not have back button
      expect(find.byIcon(Icons.arrow_back), findsNothing);

      // Navigate to Page 1
      await tester.tap(find.text('To Page 1'));
      await tester.pumpAndSettle();
      
      // Page 1 should have back button
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.text('Page 1'), findsOneWidget);

      // Go back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Should be back on root page without back button
      expect(find.byIcon(Icons.arrow_back), findsNothing);
      expect(find.text('Root Page'), findsOneWidget);
    });

    testWidgets('Action buttons are displayed correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: VKUAppBar(
              title: 'Test',
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      // Verify all action buttons are present
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.filter_list), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);

      // Verify icons are white
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.actionsIconTheme?.color, Colors.white);
      expect(appBar.actionsIconTheme?.size, 24);
    });

    testWidgets('AppBar height is consistent', (WidgetTester tester) async {
      const expectedHeight = 56.0;

      for (int i = 0; i < 3; i++) {
        const appBar = VKUAppBar(title: 'Test');
        expect(appBar.preferredSize.height, expectedHeight);
      }
    });

    testWidgets('Icon theme is consistent', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: VKUAppBar(title: 'Test'),
          ),
        ),
      );

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      
      // Verify icon theme
      expect(appBar.iconTheme?.color, Colors.white);
      expect(appBar.iconTheme?.size, 24);
      expect(appBar.actionsIconTheme?.color, Colors.white);
      expect(appBar.actionsIconTheme?.size, 24);
    });

    testWidgets('Multiple navigation levels maintain consistency',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: const VKUAppBar(title: 'Level 0'),
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: const VKUAppBar(title: 'Level 1'),
                        body: Builder(
                          builder: (context) => ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Scaffold(
                                    appBar: VKUAppBar(title: 'Level 2'),
                                  ),
                                ),
                              );
                            },
                            child: const Text('To Level 2'),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: const Text('To Level 1'),
              ),
            ),
          ),
        ),
      );

      // Navigate through levels and verify consistency
      expect(find.byIcon(Icons.arrow_back), findsNothing);

      await tester.tap(find.text('To Level 1'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.text('Level 1'), findsOneWidget);

      await tester.tap(find.text('To Level 2'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.text('Level 2'), findsOneWidget);

      // Navigate back through levels
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.text('Level 1'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.text('Level 0'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });

    testWidgets('VKUSliverAppBar maintains consistency when scrolling',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                const VKUSliverAppBar(
                  title: 'Scrollable Page',
                  expandedHeight: 200.0,
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => ListTile(
                      title: Text('Item $index'),
                    ),
                    childCount: 50,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Verify title is visible when expanded
      expect(find.text('Scrollable Page'), findsOneWidget);

      // Scroll down
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Title should still be visible when collapsed
      expect(find.text('Scrollable Page'), findsOneWidget);

      // Verify the SliverAppBar is pinned
      final sliverAppBar = tester.widget<SliverAppBar>(
        find.byType(SliverAppBar),
      );
      expect(sliverAppBar.pinned, isTrue);
    });

    testWidgets('Custom leading widget overrides back button consistently',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Scaffold(
                        appBar: VKUAppBar(
                          title: 'Custom Leading',
                          leading: Icon(Icons.menu),
                        ),
                      ),
                    ),
                  );
                },
                child: const Text('Navigate'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      // Custom leading should be shown instead of back button
      expect(find.byIcon(Icons.menu), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });
  });
}
