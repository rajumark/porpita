import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'v2/base_screen.dart';
import 'screens/adb_setup_screen.dart';
import 'services/adb_manager.dart';
import 'services/device_manager.dart';
import 'services/emulator_manager.dart';
import 'services/screen_capture_service.dart';
import 'services/theme_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeManager = ThemeManager();
  await themeManager.init();

  final adb = AdbManager.instance;
  adb.initialize();

  final deviceManager = DeviceManager();
  final emulatorManager = EmulatorManager();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: adb),
        ChangeNotifierProvider.value(value: themeManager),
        ChangeNotifierProvider.value(value: deviceManager),
        ChangeNotifierProvider.value(value: emulatorManager),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = context.watch<ThemeManager>();

    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        SingleActivator(
          LogicalKeyboardKey.keyH,
          control: true,
          shift: true,
        ): const CaptureWindowIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          CaptureWindowIntent: CallbackAction<CaptureWindowIntent>(
            onInvoke: (_) => ScreenCaptureService.captureAndSave(context),
          ),
        },
        child: MaterialApp(
          title: 'Porpita',
          themeMode: themeManager.themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          home: const _AppGate(),
        ),
      ),
    );
  }
}

class _AppGate extends StatefulWidget {
  const _AppGate();

  @override
  State<_AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<_AppGate> {
  bool _deviceManagerStarted = false;

  @override
  Widget build(BuildContext context) {
    final adb = context.watch<AdbManager>();

    if (adb.isReady && !_deviceManagerStarted) {
      _deviceManagerStarted = true;
      context.read<DeviceManager>().start();
    }

    if (!adb.isReady) {
      return const AdbSetupScreen();
    }

    return const BaseScreen();
  }
}
