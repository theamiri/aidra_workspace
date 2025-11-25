import 'package:ampere/core/shared/use_case.dart';
import 'package:ampere/core/errors/exceptions.dart';
import 'package:ampere/core/errors/failures.dart';
import 'package:ampere/features/authentication/domain/entities/req_entites/signin_request_entity.dart';
import 'package:ampere/features/authentication/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case for retrieving saved sign-in credentials
class GetCredentialsUseCase implements UseCase<SignInRequestEntity?, NoParams> {
  final AuthRepository _repository;

  GetCredentialsUseCase(this._repository);

  @override
  Future<Either<Failure, SignInRequestEntity?>> call(NoParams params) async {
    try {
      final credentials = await _repository.getStoredSignInCredentials();
      return Right(credentials);
    } on AppException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(UnexpectedFailure(
        message: 'Unexpected error during get credentials: $e',
      ));
    }
  }
}

