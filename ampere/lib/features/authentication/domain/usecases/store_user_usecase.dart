import 'package:ampere/core/shared/use_case.dart';
import 'package:ampere/core/errors/exceptions.dart';
import 'package:ampere/core/errors/failures.dart';
import 'package:ampere/features/authentication/domain/entities/res_entites/user_entity.dart';
import 'package:ampere/features/authentication/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case for storing user information locally
class StoreUserUseCase implements UseCase<void, UserEntity> {
  final AuthRepository _repository;

  StoreUserUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(UserEntity params) async {
    try {
      await _repository.storeUser(params);
      return const Right(null);
    } on AppException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(UnexpectedFailure(
        message: 'Unexpected error during store user: $e',
      ));
    }
  }
}

