import 'package:flutter/material.dart';

class SearchView extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const SearchView({
    super.key,
    required this.controller,
    this.hintText = 'Search...',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: TextField(
        controller: controller,
        style: Theme.of(context).textTheme.bodySmall,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search, size: 20),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ),
    );
  }
}
