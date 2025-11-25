import 'package:ampere/core/shared/use_case.dart';
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
      final storedSession = await _repository.getStoredSessionResponse();
      
      if (storedSession == null || 
          storedSession.accessToken == null || 
          storedSession.accessToken!.isEmpty) {
        return Left(AuthenticationFailure(
          message: 'No active session found',
        ));
      }

      // Try to get stored user first
      final storedUser = await _repository.getStoredUser();
      if (storedUser != null) {
        return Right(storedUser);
      }

      // If no stored user, try to fetch from API
      final currentUser = await _repository.getCurrentUser();
      
      if (currentUser == null) {
        return Left(AuthenticationFailure(
          message: 'User not found or not authenticated',
        ));
      }

      return Right(currentUser);
    } on AppException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(UnexpectedFailure(
        message: 'Unexpected error during authentication check: $e',
      ));
    }
  }
}

