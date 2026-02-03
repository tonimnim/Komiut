/// AppTextField widget tests.
///
/// Tests for the AppTextField widget component including:
/// - Rendering with label and hint
/// - Text input
/// - Password visibility toggle
/// - Validation
/// - Callbacks
library;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komiut/core/widgets/inputs/app_text_field.dart';

void main() {
  group('AppTextField', () {
    testWidgets('renders with label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(
              label: 'Test Label',
            ),
          ),
        ),
      );

      expect(find.text('Test Label'), findsOneWidget);
    });

    testWidgets('renders with hint text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(
              hint: 'Enter text here',
            ),
          ),
        ),
      );

      expect(find.text('Enter text here'), findsOneWidget);
    });

    testWidgets('accepts text input', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTextField(
              controller: controller,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Hello World');
      expect(controller.text, 'Hello World');
    });

    testWidgets('calls onChanged when text changes', (tester) async {
      String? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTextField(
              onChanged: (value) {
                changedValue = value;
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Test Input');
      expect(changedValue, 'Test Input');
    });

    testWidgets('calls onSubmitted when submitted', (tester) async {
      String? submittedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTextField(
              onSubmitted: (value) {
                submittedValue = value;
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Submit Me');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(submittedValue, 'Submit Me');
    });

    testWidgets('shows error text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(
              errorText: 'This field is required',
            ),
          ),
        ),
      );

      expect(find.text('This field is required'), findsOneWidget);
    });

    testWidgets('shows helper text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(
              helperText: 'Enter your email address',
            ),
          ),
        ),
      );

      expect(find.text('Enter your email address'), findsOneWidget);
    });

    testWidgets('is disabled when enabled is false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(
              enabled: false,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.enabled, isFalse);
    });

    testWidgets('shows prefix icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(
              prefixIcon: Icons.person,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('shows suffix icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(
              suffixIcon: Icons.clear,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    group('Password field', () {
      testWidgets('shows visibility toggle icon', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AppTextField.password(
                label: 'Password',
              ),
            ),
          ),
        );

        // Password field should show visibility off icon initially
        expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      });

      testWidgets('shows visibility toggle button', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AppTextField.password(
                label: 'Password',
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      });

      testWidgets('toggles visibility when button is pressed', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AppTextField.password(
                label: 'Password',
              ),
            ),
          ),
        );

        // Initially obscured
        expect(find.byIcon(Icons.visibility_off), findsOneWidget);

        // Tap to show password
        await tester.tap(find.byType(IconButton));
        await tester.pump();

        // Now visible
        expect(find.byIcon(Icons.visibility), findsOneWidget);

        // Tap to hide password again
        await tester.tap(find.byType(IconButton));
        await tester.pump();

        // Obscured again
        expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      });
    });

    group('Email field', () {
      testWidgets('shows email icon', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AppTextField.email(
                label: 'Email',
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.email_outlined), findsOneWidget);
      });

      testWidgets('renders email field correctly', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AppTextField.email(
                label: 'Email',
                hint: 'Enter email',
              ),
            ),
          ),
        );

        expect(find.text('Email'), findsOneWidget);
        expect(find.text('Enter email'), findsOneWidget);
      });
    });

    group('Phone field', () {
      testWidgets('shows phone icon', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AppTextField.phone(
                label: 'Phone',
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.phone_outlined), findsOneWidget);
      });

      testWidgets('renders phone field correctly', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AppTextField.phone(
                label: 'Phone',
                hint: 'Enter phone',
              ),
            ),
          ),
        );

        expect(find.text('Phone'), findsOneWidget);
        expect(find.text('Enter phone'), findsOneWidget);
      });
    });

    testWidgets('runs validator', (tester) async {
      final formKey = GlobalKey<FormState>();
      String? validatorResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: AppTextField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      // Validate empty form
      final isValid = formKey.currentState!.validate();
      await tester.pump();

      expect(isValid, isFalse);
      expect(find.text('Required'), findsOneWidget);
    });
  });
}
