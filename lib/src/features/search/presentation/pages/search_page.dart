import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/search_bloc.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search bits...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: (query) {
            context.read<SearchBloc>().add(SearchEvent.queryChanged(query));
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: Text('Enter a query to search')),
            loading: () => const Center(child: CircularProgressIndicator()),
            failure: (message) => Center(child: Text('Error: $message')),
            success: (results) {
              if (results.isEmpty) {
                return const Center(child: Text('No results found.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final bit = results[index];
                  return Card(
                    child: ListTile(
                      title: Text(bit.title),
                      subtitle: Text(bit.tags.join(', ')),
                      onTap: () {
                        // Implement navigation to detail/edit
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
