import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ampere/core/errors/failures.dart';
import 'package:ampere/core/shared/use_case.dart';
import 'package:ampere/features/authentication/domain/usecases/get_credentials_usecase.dart';
import 'package:ampere/features/authentication/presentation/logic/credentails_cubit/credentials_state.dart';

/// Cubit responsible for managing saved credentials (email and password)
class CredentialsCubit extends Cubit<CredentialsState> {
  final GetCredentialsUseCase _getCredentialsUseCase;

  CredentialsCubit({required GetCredentialsUseCase getCredentialsUseCase})
    : _getCredentialsUseCase = getCredentialsUseCase,

      super(const CredentialsInitial());

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

  /// Get error message from failure
  String _getErrorMessage(Failure failure) {
    return failure.message;
  }
}
