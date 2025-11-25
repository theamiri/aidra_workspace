import 'package:ampere/core/shared/use_case.dart';
import 'package:ampere/core/errors/exceptions.dart';
import 'package:ampere/core/errors/failures.dart';
import 'package:ampere/features/authentication/domain/entities/req_entites/signin_request.dart';
import 'package:ampere/features/authentication/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case for saving sign-in credentials locally
class SaveCredentialsUseCase implements UseCase<void, SignInRequest> {
  final AuthRepository _repository;

  SaveCredentialsUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(SignInRequest params) async {
    try {
      await _repository.storeSignInCredentials(params);
      return const Right(null);
    } on AppException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(UnexpectedFailure(
        message: 'Unexpected error during save credentials: $e',
      ));
    }
  }
}

