import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/vault_bloc.dart';

class VaultPage extends StatelessWidget {
  const VaultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Knowledge Vault'),
      ),
      body: BlocBuilder<VaultBloc, VaultState>(
        builder: (context, state) {
          return state.when(
            initial: () {
              context.read<VaultBloc>().add(const VaultEvent.loadRequested());
              return const Center(child: CircularProgressIndicator());
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            failure: (message) => Center(child: Text('Error: $message')),
            loaded: (bits) {
              if (bits.isEmpty) {
                return const Center(child: Text('No knowledge bits yet.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: bits.length,
                itemBuilder: (context, index) {
                  final bit = bits[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    child: ListTile(
                      title: Text(bit.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${bit.blocks.length} blocks • ${bit.tags.join(", ")}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Implement view/edit bit
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
