part of 'vault_bloc.dart';

@freezed
class VaultState with _$VaultState {
  const factory VaultState.initial() = _Initial;
  const factory VaultState.loading() = _Loading;
  const factory VaultState.loaded(List<KnowledgeBit> bits) = _Loaded;
  const factory VaultState.failure(String message) = _Failure;
}
