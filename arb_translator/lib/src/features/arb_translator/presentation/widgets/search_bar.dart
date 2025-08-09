import 'package:arb_translator/src/features/arb_translator/presentation/providers/project_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Search bar widget for filtering translations by key, description, or base locale value
class TranslationSearchBar extends ConsumerStatefulWidget {
  const TranslationSearchBar({super.key});

  @override
  ConsumerState<TranslationSearchBar> createState() => _TranslationSearchBarState();
}

class _TranslationSearchBarState extends ConsumerState<TranslationSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(projectControllerProvider);

    // Update controller text if state changed externally
    if (_controller.text != state.searchQuery) {
      _controller.text = state.searchQuery;
    }

    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: TextField(
        controller: _controller,
        onChanged: (value) => ref.read(projectControllerProvider.notifier).updateSearchQuery(value),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search keys, descriptions, or English text...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
          suffixIcon: state.searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
                  onPressed: () {
                    _controller.clear();
                    ref.read(projectControllerProvider.notifier).updateSearchQuery('');
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFF2A2A2A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xFF404040)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xFF404040)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xFF0078D4), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          isDense: true,
        ),
      ),
    );
  }
}
