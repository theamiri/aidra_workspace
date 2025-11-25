import 'package:ampere/core/shared/use_case.dart';
import 'package:ampere/core/errors/exceptions.dart';
import 'package:ampere/core/errors/failures.dart';
import 'package:ampere/features/authentication/domain/entities/req_entites/signin_request.dart';
import 'package:ampere/features/authentication/domain/entities/res_entites/session_response.dart';
import 'package:ampere/features/authentication/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case for signing in a user
class SignInUseCase implements UseCase<SessionResponse, SignInRequest> {
  final AuthRepository _repository;

  SignInUseCase(this._repository);

  @override
  Future<Either<Failure, SessionResponse>> call(SignInRequest params) async {
    try {
      final sessionResponse = await _repository.signIn(params);
      
      if (sessionResponse == null) {
        return Left(ServerFailure(
          message: 'Sign in failed: Empty response from server',
        ));
      }

      return Right(sessionResponse);
    } on AppException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(UnexpectedFailure(
        message: 'Unexpected error during sign in: $e',
      ));
    }
  }
}

