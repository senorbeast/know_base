part of 'vault_bloc.dart';

@freezed
class VaultEvent with _$VaultEvent {
  const factory VaultEvent.loadRequested() = _LoadRequested;
}
