import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ampere/core/errors/failures.dart';
import 'package:ampere/core/shared/use_case.dart';
import 'package:ampere/features/authentication/domain/entities/req_entites/signin_request_entity.dart';
import 'package:ampere/features/authentication/domain/usecases/clear_credentials_usecase.dart';
import 'package:ampere/features/authentication/domain/usecases/get_credentials_usecase.dart';
import 'package:ampere/features/authentication/domain/usecases/save_credentials_usecase.dart';
import 'package:ampere/features/authentication/presentation/logic/credentials_state.dart';

/// Cubit responsible for managing saved credentials (email and password)
class CredentialsCubit extends Cubit<CredentialsState> {
  final SaveCredentialsUseCase _saveCredentialsUseCase;
  final GetCredentialsUseCase _getCredentialsUseCase;
  final ClearCredentialsUseCase _clearCredentialsUseCase;

  CredentialsCubit({
    required SaveCredentialsUseCase saveCredentialsUseCase,
    required GetCredentialsUseCase getCredentialsUseCase,
    required ClearCredentialsUseCase clearCredentialsUseCase,
  })  : _saveCredentialsUseCase = saveCredentialsUseCase,
        _getCredentialsUseCase = getCredentialsUseCase,
        _clearCredentialsUseCase = clearCredentialsUseCase,
        super(const CredentialsInitial());

  /// Save email and password credentials
  /// 
  /// [email] - User email to save
  /// [password] - User password to save
  Future<void> saveCredentials({
    required String email,
    required String password,
  }) async {
    emit(const CredentialsLoading());

    final credentials = SignInRequestEntity(
      email: email,
      password: password,
    );

    final result = await _saveCredentialsUseCase(credentials);

    result.fold(
      (failure) {
        emit(CredentialsError(_getErrorMessage(failure)));
      },
      (_) {
        emit(const CredentialsSaved());
      },
    );
  }

  /// Retrieve saved email and password credentials
  Future<void> getCredentials() async {
    emit(const CredentialsLoading());

    final result = await _getCredentialsUseCase(NoParams());

    result.fold(
      (failure) {
        emit(CredentialsError(_getErrorMessage(failure)));
      },
      (credentials) {
        emit(CredentialsLoaded(credentials));
      },
    );
  }

  /// Clear saved credentials
  Future<void> clearCredentials() async {
    emit(const CredentialsLoading());

    final result = await _clearCredentialsUseCase(NoParams());

    result.fold(
      (failure) {
        emit(CredentialsError(_getErrorMessage(failure)));
      },
      (_) {
        emit(const CredentialsCleared());
      },
    );
  }

  /// Get error message from failure
  String _getErrorMessage(Failure failure) {
    return failure.message;
  }
}

