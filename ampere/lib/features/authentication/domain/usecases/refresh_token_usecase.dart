import 'package:ampere/core/shared/use_case.dart';
import 'package:ampere/core/errors/exceptions.dart';
import 'package:ampere/core/errors/failures.dart';
import 'package:ampere/features/authentication/domain/entities/res_entites/session_entity.dart';
import 'package:ampere/features/authentication/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:ampere/core/extensions/exception_failure_extension.dart';

/// Use case for refreshing access token
class RefreshTokenUseCase
    implements UseCase<SessionEntity, RefreshTokenParams> {
  final AuthRepository _repository;

  RefreshTokenUseCase(this._repository);

  @override
  Future<Either<Failure, SessionEntity>> call(RefreshTokenParams params) async {
    try {
      final sessionResponse = await _repository.refreshToken(
        params.refreshToken,
      );

      if (sessionResponse == null) {
        return Left(
          ServerFailure(
            message: 'Refresh token failed: Empty response from server',
          ),
        );
      }

      return Right(sessionResponse);
    } on AppException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(
        UnexpectedFailure(message: 'Unexpected error during refresh token: $e'),
      );
    }
  }
}

class RefreshTokenParams extends Equatable {
  final String refreshToken;

  const RefreshTokenParams({required this.refreshToken});

  @override
  List<Object?> get props => [refreshToken];
}
