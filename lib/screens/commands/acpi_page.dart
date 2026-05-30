import 'package:flutter/material.dart';
import '../../services/commands/acpi_service.dart';
import '../../widgets/data_screen_widgets.dart';

class AcpiPage extends StatelessWidget {
  const AcpiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'acpi',
      adbCommand: 'adb shell acpi -V',
      fetchData: (id) => AcpiService.fetch(id),
    );
  }
}
