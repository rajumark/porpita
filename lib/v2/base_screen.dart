import 'package:flutter/material.dart';

class BaseScreen extends StatelessWidget {
  const BaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 36,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.menu),
                  iconSize: 24,
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tight(const Size(36, 36)),
                ),
                const Text('Porpita'),
              ],
            ),
          ),
          const Expanded(
            child: Center(
              child: Text('Comming SOon'),
            ),
          ),
        ],
      ),
    );
  }
}
