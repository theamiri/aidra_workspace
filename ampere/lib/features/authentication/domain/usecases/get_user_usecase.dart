import 'package:ampere/core/shared/use_case.dart';
import 'package:ampere/core/errors/exceptions.dart';
import 'package:ampere/core/errors/failures.dart';
import 'package:ampere/features/authentication/domain/entities/res_entites/user_entity.dart';
import 'package:ampere/features/authentication/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case for retrieving stored user information
class GetUserUseCase implements UseCase<UserEntity?, NoParams> {
  final AuthRepository _repository;

  GetUserUseCase(this._repository);

  @override
  Future<Either<Failure, UserEntity?>> call(NoParams params) async {
    try {
      final user = await _repository.getUser();
      return Right(user);
    } on AppException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(UnexpectedFailure(
        message: 'Unexpected error during get user: $e',
      ));
    }
  }
}

