import 'dart:convert';
import 'package:ampere/core/utils/jwt_utils.dart';
import 'package:ampere/features/authentication/domain/enums/role_enum.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JwtUtils', () {
    // Helper function to create a valid JWT token for testing
    String createTestToken(Map<String, dynamic> payload) {
      final header = {'alg': 'HS256', 'typ': 'JWT'};
      final encodedHeader = base64Url.encode(utf8.encode(jsonEncode(header)));
      final encodedPayload = base64Url.encode(utf8.encode(jsonEncode(payload)));
      return '$encodedHeader.$encodedPayload.dummysignature';
    }

    group('extractRole', () {
      test('should extract role from valid JWT token with role as string', () {
        // Create token with payload: {"role": "ROLE_ADMIN", "sub": "test"}
        final token = createTestToken({'role': 'ROLE_ADMIN', 'sub': 'test'});

        final result = JwtUtils.extractRole(token);

        expect(result, Role.admin);
      });

      test('should extract role from valid JWT token with role as array', () {
        // Create token with payload: {"role": ["ROLE_ADMIN"], "sub": "test"}
        final token = createTestToken({
          'role': ['ROLE_ADMIN'],
          'sub': 'test'
        });

        final result = JwtUtils.extractRole(token);

        expect(result, Role.admin);
      });

      test('should extract role from roles claim', () {
        // Create token with payload: {"roles": "ROLE_MANAGER", "sub": "test"}
        final token = createTestToken({'roles': 'ROLE_MANAGER', 'sub': 'test'});

        final result = JwtUtils.extractRole(token);

        expect(result, Role.manager);
      });

      test('should extract role from authorities claim', () {
        // Create token with payload: {"authorities": "ROLE_USER", "sub": "test"}
        final token = createTestToken({'authorities': 'ROLE_USER', 'sub': 'test'});

        final result = JwtUtils.extractRole(token);

        expect(result, Role.user);
      });

      test('should return null for invalid JWT token format', () {
        const token = 'invalid.token';

        final result = JwtUtils.extractRole(token);

        expect(result, null);
      });

      test('should return null for token without role claim', () {
        // Create token with payload: {"sub": "test"}
        final token = createTestToken({'sub': 'test'});

        final result = JwtUtils.extractRole(token);

        expect(result, null);
      });

      test('should return null for empty role array', () {
        // Create token with payload: {"role": [], "sub": "test"}
        final token = createTestToken({
          'role': [],
          'sub': 'test'
        });

        final result = JwtUtils.extractRole(token);

        expect(result, null);
      });

      test('should return null for malformed token', () {
        const token = 'not.a.valid.jwt.token';

        final result = JwtUtils.extractRole(token);

        expect(result, null);
      });
    });
  });
}
