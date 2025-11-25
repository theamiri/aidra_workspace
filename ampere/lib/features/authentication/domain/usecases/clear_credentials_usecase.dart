import 'package:ampere/core/shared/use_case.dart';
import 'package:ampere/core/errors/exceptions.dart';
import 'package:ampere/core/errors/failures.dart';
import 'package:ampere/features/authentication/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case for clearing saved sign-in credentials
class ClearCredentialsUseCase implements UseCase<void, NoParams> {
  final AuthRepository _repository;

  ClearCredentialsUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    try {
      await _repository.clearSignInCredentials();
      return const Right(null);
    } on AppException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(UnexpectedFailure(
        message: 'Unexpected error during clear credentials: $e',
      ));
    }
  }
}

