import 'package:ampere/core/extensions/exception_failure_extension.dart';
import 'package:ampere/core/shared/use_case.dart';
import 'package:ampere/core/utils/jwt_utils.dart';
import 'package:ampere/core/errors/exceptions.dart';
import 'package:ampere/core/errors/failures.dart';
import 'package:ampere/features/authentication/domain/entities/res_entites/user_entity.dart';
import 'package:ampere/features/authentication/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case for checking if user is authenticated
/// Returns the authenticated user if found, otherwise returns a failure
class CheckAuthenticationUseCase implements UseCase<UserEntity, NoParams> {
  final AuthRepository _repository;

  CheckAuthenticationUseCase(this._repository);

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) async {
    try {
      // First check if we have a stored session
      final storedSession = await _repository.getStoredSession();

      if (storedSession == null ||
          storedSession.accessToken == null ||
          storedSession.accessToken!.isEmpty) {
        return Left(AuthenticationFailure(message: 'No active session found'));
      }

      // Check if the access token is expired
      if (JwtUtils.isTokenExpired(storedSession.accessToken!)) {
        // Also check if refresh token is expired
        if (storedSession.refreshToken != null &&
            JwtUtils.isTokenExpired(storedSession.refreshToken!)) {
          return Left(
            AuthenticationFailure(
              message: 'Your session has expired. Please sign in again.',
            ),
          );
        }
        // Access token expired but refresh token is still valid
        // The interceptor will handle refresh automatically
        return Left(
          AuthenticationFailure(
            message: 'Access token has expired. Please sign in again.',
          ),
        );
      }

      // Check if refresh token is expired (even if access token is valid)
      // This helps prevent using expired refresh tokens
      if (storedSession.refreshToken != null &&
          JwtUtils.isTokenExpired(storedSession.refreshToken!)) {
        return Left(
          AuthenticationFailure(
            message: 'Your session has expired. Please sign in again.',
          ),
        );
      }

      // Try to get stored user first
      final storedUser = await _repository.getUser();
      if (storedUser != null) {
        return Right(storedUser);
      }

      // If no stored user, try to fetch from API
      final currentUser = await _repository.getCurrentUser();

      if (currentUser == null) {
        return Left(
          AuthenticationFailure(message: 'User not found or not authenticated'),
        );
      }

      return Right(currentUser);
    } on AppException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'Unexpected error during authentication check: $e',
        ),
      );
    }
  }
}
