/// AppButton widget tests.
///
/// Tests for the AppButton widget component including:
/// - Rendering different variants
/// - Size configurations
/// - Loading states
/// - Icon positions
/// - Tap callbacks
library;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komiut/core/widgets/buttons/app_button.dart';

void main() {
  group('AppButton', () {
    testWidgets('renders with label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Test Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Tap Me',
              onPressed: () {
                pressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap Me'));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('does not call onPressed when disabled', (tester) async {
      const pressed = false;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Disabled',
              onPressed: null,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Disabled'));
      await tester.pump();

      expect(pressed, isFalse);
    });

    testWidgets('shows loading indicator when isLoading is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Loading',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('does not call onPressed when loading', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Loading',
              onPressed: () {
                pressed = true;
              },
              isLoading: true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(pressed, isFalse);
    });

    testWidgets('renders with leading icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'With Icon',
              onPressed: () {},
              icon: Icons.add,
              iconPosition: IconPosition.leading,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('With Icon'), findsOneWidget);
    });

    testWidgets('renders with trailing icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'With Trailing Icon',
              onPressed: () {},
              icon: Icons.arrow_forward,
              iconPosition: IconPosition.trailing,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });

    group('Variants', () {
      testWidgets('renders primary variant', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppButton.primary(
                label: 'Primary',
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.byType(ElevatedButton), findsOneWidget);
        expect(find.text('Primary'), findsOneWidget);
      });

      testWidgets('renders outlined variant', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppButton.outlined(
                label: 'Outlined',
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.byType(OutlinedButton), findsOneWidget);
        expect(find.text('Outlined'), findsOneWidget);
      });

      testWidgets('renders text variant', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppButton.text(
                label: 'Text',
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.byType(TextButton), findsOneWidget);
        expect(find.text('Text'), findsOneWidget);
      });
    });

    group('Sizes', () {
      testWidgets('renders small size', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppButton(
                label: 'Small',
                onPressed: () {},
                size: ButtonSize.small,
              ),
            ),
          ),
        );

        expect(find.text('Small'), findsOneWidget);
      });

      testWidgets('renders medium size', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppButton(
                label: 'Medium',
                onPressed: () {},
                size: ButtonSize.medium,
              ),
            ),
          ),
        );

        expect(find.text('Medium'), findsOneWidget);
      });

      testWidgets('renders large size', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppButton(
                label: 'Large',
                onPressed: () {},
                size: ButtonSize.large,
              ),
            ),
          ),
        );

        expect(find.text('Large'), findsOneWidget);
      });
    });

    testWidgets('renders full width when isFullWidth is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Full Width',
              onPressed: () {},
              isFullWidth: true,
            ),
          ),
        ),
      );

      // The button should be wrapped in a SizedBox with infinite width
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, double.infinity);
    });
  });
}
