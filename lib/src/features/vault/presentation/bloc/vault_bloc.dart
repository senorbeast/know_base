import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import '../../../../domain/entities/knowledge_bit.dart';
import '../../../../domain/repositories/knowledge_repository.dart';

part 'vault_event.dart';
part 'vault_state.dart';
part 'vault_bloc.freezed.dart';

@injectable
class VaultBloc extends Bloc<VaultEvent, VaultState> {
  final IKnowledgeRepository _repository;

  VaultBloc(this._repository) : super(const VaultState.initial()) {
    on<_LoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(_LoadRequested event, Emitter<VaultState> emit) async {
    emit(const VaultState.loading());
    try {
      final bits = await _repository.getAllKnowledgeBits();
      emit(VaultState.loaded(bits));
    } catch (e) {
      emit(VaultState.failure(e.toString()));
    }
  }
}
