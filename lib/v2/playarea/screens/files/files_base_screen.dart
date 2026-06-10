import 'package:flutter/material.dart';
import 'package:porpita/v2/widgets/rounded_container.dart';
import 'file_explorer_screen.dart';

class FilesBaseScreen extends StatefulWidget {
  const FilesBaseScreen({super.key});

  @override
  State<FilesBaseScreen> createState() => _FilesBaseScreenState();
}

class _FilesBaseScreenState extends State<FilesBaseScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 8, top: 0, bottom: 8),
      child: RoundedContainer(
        child: FileExplorerScreen(),
      ),
    );
  }
}
