import 'package:flutter_test/flutter_test.dart';
import '../mocks/fake_auth_service.dart';

void main() {
  group('FakeAuthService unit tests', () {
    late FakeAuthService authService;

    setUp(() {
      authService = FakeAuthService();
    });

    test('sign in with valid credentials', () async {
      final user = await authService.signIn('test@example.com', 'password');
      expect(user, isNotNull);
      expect(authService.isSignedIn, isTrue);
      expect(user?.email, 'test@example.com');
    });

    test('sign in with empty credentials returns null', () async {
      final user = await authService.signIn('', '');
      expect(user, isNull);
      expect(authService.isSignedIn, isFalse);
    });

    test('sign out resets isSignedIn', () async {
      await authService.signIn('test@example.com', 'password');
      expect(authService.isSignedIn, isTrue);

      await authService.signOut();
      expect(authService.isSignedIn, isFalse);
    });
  });
}
