import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vku_schedule/core/widgets/app_bar.dart';
import 'package:vku_schedule/core/theme/app_theme.dart';

void main() {
  group('VKUAppBar', () {
    testWidgets('displays title correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: VKUAppBar(title: 'Test Title'),
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
    });

    testWidgets('title is centered by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: VKUAppBar(title: 'Test Title'),
          ),
        ),
      );

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.centerTitle, isTrue);
    });

    testWidgets('title has correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: VKUAppBar(title: 'Test Title'),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Test Title'));
      expect(textWidget.style?.color, Colors.white);
      expect(textWidget.style?.fontSize, 20);
      expect(textWidget.style?.fontWeight, FontWeight.w600);
      expect(textWidget.maxLines, 1);
      expect(textWidget.overflow, TextOverflow.ellipsis);
    });

    testWidgets('has correct preferred size', (WidgetTester tester) async {
      const appBar = VKUAppBar(title: 'Test Title');
      expect(appBar.preferredSize.height, 56.0);
    });

    testWidgets('shows back button when Navigator can pop',
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
                        appBar: VKUAppBar(title: 'Second Page'),
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

      // Navigate to second page
      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      // Back button should be visible
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('hides back button on root page',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: VKUAppBar(title: 'Root Page'),
          ),
        ),
      );

      // Back button should not be visible
      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });

    testWidgets('uses custom leading widget when provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: VKUAppBar(
              title: 'Test Title',
              leading: Icon(Icons.menu),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.menu), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });

    testWidgets('displays action buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: VKUAppBar(
              title: 'Test Title',
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
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

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('respects automaticallyImplyLeading parameter',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: VKUAppBar(
              title: 'Test Page',
              automaticallyImplyLeading: false,
            ),
          ),
        ),
      );

      // Back button should not be visible
      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });

    testWidgets('has gradient background', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: VKUAppBar(title: 'Test Title'),
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
      expect(decoration.gradient, isNotNull);
      expect(decoration.gradient, isA<LinearGradient>());
      
      final gradient = decoration.gradient as LinearGradient;
      expect(gradient.colors, [AppTheme.vkuNavy, AppTheme.vkuRed]);
    });

    testWidgets('has shadow effect', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: VKUAppBar(title: 'Test Title'),
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
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, 1);
      expect(decoration.boxShadow![0].blurRadius, 4);
      expect(decoration.boxShadow![0].offset, const Offset(0, 2));
    });

    testWidgets('back button has correct tooltip', (WidgetTester tester) async {
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
                        appBar: VKUAppBar(title: 'Second Page'),
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

      // Navigate to second page
      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      // Find the IconButton widget that contains the back arrow
      final backButton = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.arrow_back),
          matching: find.byType(IconButton),
        ),
      );
      expect(backButton.tooltip, 'Quay lại');
    });

    testWidgets('back button triggers navigation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: const VKUAppBar(title: 'First Page'),
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Scaffold(
                        appBar: VKUAppBar(title: 'Second Page'),
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

      // Navigate to second page
      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();
      expect(find.text('Second Page'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Should be back on first page
      expect(find.text('First Page'), findsOneWidget);
      expect(find.text('Second Page'), findsNothing);
    });
  });

  group('VKUSliverAppBar', () {
    testWidgets('displays title correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                const VKUSliverAppBar(title: 'Test Title'),
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

      expect(find.text('Test Title'), findsOneWidget);
    });

    testWidgets('has correct expanded height', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                const VKUSliverAppBar(
                  title: 'Test Title',
                  expandedHeight: 250.0,
                ),
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

      final sliverAppBar = tester.widget<SliverAppBar>(
        find.byType(SliverAppBar),
      );
      expect(sliverAppBar.expandedHeight, 250.0);
    });

    testWidgets('is pinned by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                const VKUSliverAppBar(title: 'Test Title'),
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

      final sliverAppBar = tester.widget<SliverAppBar>(
        find.byType(SliverAppBar),
      );
      expect(sliverAppBar.pinned, isTrue);
    });

    testWidgets('displays flexible space content', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                VKUSliverAppBar(
                  title: 'Test Title',
                  flexibleSpace: Container(
                    alignment: Alignment.center,
                    child: const Text('Hero Content'),
                  ),
                ),
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

      expect(find.text('Hero Content'), findsOneWidget);
    });

    testWidgets('has gradient background', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                const VKUSliverAppBar(title: 'Test Title'),
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
      
      final background = flexibleSpaceBar.background as Container;
      final decoration = background.decoration as BoxDecoration;
      
      expect(decoration.gradient, isNotNull);
      expect(decoration.gradient, isA<LinearGradient>());
      
      final gradient = decoration.gradient as LinearGradient;
      expect(gradient.colors, [AppTheme.vkuNavy, AppTheme.vkuRed]);
    });

    testWidgets('title is centered', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                const VKUSliverAppBar(title: 'Test Title'),
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
      expect(flexibleSpaceBar.centerTitle, isTrue);
    });

    testWidgets('shows back button when Navigator can pop',
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
                      builder: (context) => Scaffold(
                        body: CustomScrollView(
                          slivers: [
                            const VKUSliverAppBar(title: 'Second Page'),
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
                },
                child: const Text('Navigate'),
              ),
            ),
          ),
        ),
      );

      // Navigate to second page
      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      // Back button should be visible
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('displays action buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                VKUSliverAppBar(
                  title: 'Test Title',
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {},
                    ),
                  ],
                ),
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

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });
  });
}
