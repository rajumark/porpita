import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../services/device_manager.dart';
import '../services/commands/adb_exec_service.dart';
import '../widgets/data_screen_widgets.dart';

class CmdEntry {
  final String category;
  final String name;
  final String description;
  final List<String> getArgs;
  final List<String> setArgs;
  final String inputLabel;
  final String inputHint;
  final List<String>? enumValues;
  final TextInputType inputType;

  const CmdEntry({
    required this.category,
    required this.name,
    this.description = '',
    this.getArgs = const [],
    required this.setArgs,
    this.inputLabel = '',
    this.inputHint = '',
    this.enumValues,
    this.inputType = TextInputType.text,
  });
}

final List<CmdEntry> commandEntries = [
  // ── Display ──
  CmdEntry(
    category: 'Display',
    name: 'Screen Density',
    description: 'Get/set display pixel density (DPI)',
    getArgs: ['wm', 'density'],
    setArgs: ['wm', 'density', '{value}'],
    inputLabel: 'DPI',
    inputHint: '320–640 (e.g. 400)',
    inputType: TextInputType.number,
  ),
  CmdEntry(
    category: 'Display',
    name: 'Screen Size',
    description: 'Get/set display resolution',
    getArgs: ['wm', 'size'],
    setArgs: ['wm', 'size', '{value}'],
    inputLabel: 'WxH',
    inputHint: 'e.g. 1080x1920, 720x1280',
  ),
  CmdEntry(
    category: 'Display',
    name: 'Screen Rotation',
    description: 'Get/set rotation lock',
    getArgs: ['wm', 'rotation'],
    setArgs: ['wm', 'rotation', 'lock', '{value}'],
    inputLabel: 'Rotation',
    inputHint: '0=portrait, 1=landscape, 2=rev portrait, 3=rev landscape',
    enumValues: ['0', '1', '2', '3'],
    inputType: TextInputType.number,
  ),
  CmdEntry(
    category: 'Display',
    name: 'Display Overscan',
    description: 'Set overscan margins',
    setArgs: ['wm', 'overscan', '{value}'],
    inputLabel: 'L,T,R,B',
    inputHint: 'e.g. 0,10,0,10',
  ),

  // ── System Settings ──
  CmdEntry(
    category: 'System',
    name: 'Airplane Mode',
    description: 'Get/set airplane mode',
    getArgs: ['settings', 'get', 'global', 'airplane_mode_on'],
    setArgs: ['settings', 'put', 'global', 'airplane_mode_on', '{value}'],
    inputLabel: '0|1',
    inputHint: '0=off, 1=on',
    enumValues: ['0', '1'],
    inputType: TextInputType.number,
  ),
  CmdEntry(
    category: 'System',
    name: 'Auto Rotate',
    description: 'Get/set auto-rotate screen',
    getArgs: ['settings', 'get', 'system', 'accelerometer_rotation'],
    setArgs: ['settings', 'put', 'system', 'accelerometer_rotation', '{value}'],
    inputLabel: '0|1',
    inputHint: '0=locked, 1=auto-rotate',
    enumValues: ['0', '1'],
    inputType: TextInputType.number,
  ),
  CmdEntry(
    category: 'System',
    name: 'Screen Brightness',
    description: 'Get/set screen brightness level',
    getArgs: ['settings', 'get', 'system', 'screen_brightness'],
    setArgs: ['settings', 'put', 'system', 'screen_brightness', '{value}'],
    inputLabel: '0–255',
    inputHint: '0=darkest, 255=brightest',
    inputType: TextInputType.number,
  ),
  CmdEntry(
    category: 'System',
    name: 'Screen Timeout',
    description: 'Get/set screen off timeout',
    getArgs: ['settings', 'get', 'system', 'screen_off_timeout'],
    setArgs: ['settings', 'put', 'system', 'screen_off_timeout', '{value}'],
    inputLabel: 'ms',
    inputHint: '15000=15s, 60000=1min, 300000=5min',
    inputType: TextInputType.number,
  ),
  CmdEntry(
    category: 'System',
    name: 'Font Scale',
    description: 'Get/set system font scale',
    getArgs: ['settings', 'get', 'system', 'font_scale'],
    setArgs: ['settings', 'put', 'system', 'font_scale', '{value}'],
    inputLabel: 'Scale',
    inputHint: '0.5–2.0 (1.0=default)',
    inputType: TextInputType.numberWithOptions(decimal: true),
  ),
  CmdEntry(
    category: 'System',
    name: 'Animation Duration',
    description: 'Get/set animator duration scale',
    getArgs: ['settings', 'get', 'global', 'animator_duration_scale'],
    setArgs: ['settings', 'put', 'global', 'animator_duration_scale', '{value}'],
    inputLabel: 'Scale',
    inputHint: '0=off, 0.5=half, 1=normal, 10=max',
    inputType: TextInputType.numberWithOptions(decimal: true),
  ),
  CmdEntry(
    category: 'System',
    name: 'Window Animation',
    description: 'Get/set window animation scale',
    getArgs: ['settings', 'get', 'global', 'window_animation_scale'],
    setArgs: ['settings', 'put', 'global', 'window_animation_scale', '{value}'],
    inputLabel: 'Scale',
    inputHint: '0=off, 0.5=half, 1=normal',
    inputType: TextInputType.numberWithOptions(decimal: true),
  ),
  CmdEntry(
    category: 'System',
    name: 'Transition Animation',
    description: 'Get/set transition animation scale',
    getArgs: ['settings', 'get', 'global', 'transition_animation_scale'],
    setArgs: ['settings', 'put', 'global', 'transition_animation_scale', '{value}'],
    inputLabel: 'Scale',
    inputHint: '0=off, 0.5=half, 1=normal',
    inputType: TextInputType.numberWithOptions(decimal: true),
  ),
  CmdEntry(
    category: 'System',
    name: 'Stay Awake',
    description: 'Get/set stay awake while charging',
    getArgs: ['settings', 'get', 'global', 'stay_on_while_plugged_in'],
    setArgs: ['settings', 'put', 'global', 'stay_on_while_plugged_in', '{value}'],
    inputLabel: '0–3',
    inputHint: '0=off, 1=USB, 2=AC, 3=USB+AC',
    enumValues: ['0', '1', '2', '3'],
    inputType: TextInputType.number,
  ),

  // ── Location ──
  CmdEntry(
    category: 'Location',
    name: 'Location Mode',
    description: 'Get/set location mode',
    getArgs: ['settings', 'get', 'secure', 'location_mode'],
    setArgs: ['settings', 'put', 'secure', 'location_mode', '{value}'],
    inputLabel: '0–3',
    inputHint: '0=off, 1=sensors, 2=battery saving, 3=high accuracy',
    enumValues: ['0', '1', '2', '3'],
    inputType: TextInputType.number,
  ),

  // ── Haptics & Touches ──
  CmdEntry(
    category: 'Interaction',
    name: 'Haptic Feedback',
    description: 'Get/set haptic feedback on taps',
    getArgs: ['settings', 'get', 'system', 'haptic_feedback_enabled'],
    setArgs: ['settings', 'put', 'system', 'haptic_feedback_enabled', '{value}'],
    inputLabel: '0|1',
    inputHint: '0=off, 1=on',
    enumValues: ['0', '1'],
    inputType: TextInputType.number,
  ),
  CmdEntry(
    category: 'Interaction',
    name: 'Show Touches',
    description: 'Get/set visual touch feedback',
    getArgs: ['settings', 'get', 'system', 'show_touches'],
    setArgs: ['settings', 'put', 'system', 'show_touches', '{value}'],
    inputLabel: '0|1',
    inputHint: '0=off, 1=show touches',
    enumValues: ['0', '1'],
    inputType: TextInputType.number,
  ),
  CmdEntry(
    category: 'Interaction',
    name: 'Pointer Location',
    description: 'Get/set pointer location overlay',
    getArgs: ['settings', 'get', 'system', 'pointer_location'],
    setArgs: ['settings', 'put', 'system', 'pointer_location', '{value}'],
    inputLabel: '0|1',
    inputHint: '0=off, 1=show pointer',
    enumValues: ['0', '1'],
    inputType: TextInputType.number,
  ),
  CmdEntry(
    category: 'Interaction',
    name: 'Key Event',
    description: 'Send a key event to device',
    setArgs: ['input', 'keyevent', '{value}'],
    inputLabel: 'Keycode',
    inputHint: '3=Home, 4=Back, 24=Vol+, 25=Vol-, 26=Power, 27=Camera, 82=Menu',
    inputType: TextInputType.number,
  ),
  CmdEntry(
    category: 'Interaction',
    name: 'Input Tap',
    description: 'Simulate tap at coordinates',
    setArgs: ['input', 'tap', '{value}'],
    inputLabel: 'X Y',
    inputHint: 'e.g. 500 1200 (use Pointer Location to find coords)',
  ),
  CmdEntry(
    category: 'Interaction',
    name: 'Input Text',
    description: 'Type text on screen',
    setArgs: ['input', 'text', '{value}'],
    inputLabel: 'Text',
    inputHint: 'Use %s for spaces, avoid special chars',
  ),

  // ── Battery ──
  CmdEntry(
    category: 'Battery',
    name: 'Battery Level',
    description: 'Get/simulate battery level',
    getArgs: ['dumpsys', 'battery'],
    setArgs: ['dumpsys', 'battery', 'set', 'level', '{value}'],
    inputLabel: '0–100',
    inputHint: 'Simulated battery percentage',
    inputType: TextInputType.number,
  ),
  CmdEntry(
    category: 'Battery',
    name: 'Battery Status',
    description: 'Get/simulate battery charging status',
    getArgs: ['dumpsys', 'battery'],
    setArgs: ['dumpsys', 'battery', 'set', 'status', '{value}'],
    inputLabel: '1–5',
    inputHint: '1=unknown, 2=charging, 3=discharging, 4=not charging, 5=full',
    enumValues: ['1', '2', '3', '4', '5'],
    inputType: TextInputType.number,
  ),
  CmdEntry(
    category: 'Battery',
    name: 'Reset Battery',
    description: 'Reset battery simulation to real values',
    setArgs: ['dumpsys', 'battery', 'reset'],
    inputLabel: '',
    inputHint: 'Resets all battery simulation',
  ),

  // ── Connectivity ──
  CmdEntry(
    category: 'Connectivity',
    name: 'WiFi Enable/Disable',
    description: 'Enable or disable WiFi',
    setArgs: ['svc', 'wifi', '{value}'],
    inputLabel: 'enable|disable',
    inputHint: 'Turn WiFi on or off',
    enumValues: ['enable', 'disable'],
  ),
  CmdEntry(
    category: 'Connectivity',
    name: 'Mobile Data',
    description: 'Enable or disable mobile data',
    setArgs: ['svc', 'data', '{value}'],
    inputLabel: 'enable|disable',
    inputHint: 'Turn mobile data on or off',
    enumValues: ['enable', 'disable'],
  ),
  CmdEntry(
    category: 'Connectivity',
    name: 'WiFi Country Code',
    description: 'Get/set WiFi country code',
    getArgs: ['cmd', 'wifi', 'get-country-code'],
    setArgs: ['cmd', 'wifi', 'set-country-code', '{value}'],
    inputLabel: 'Code',
    inputHint: 'e.g. US, JP, DE, IN',
  ),

  // ── App Management ──
  CmdEntry(
    category: 'Apps',
    name: 'Force Stop App',
    description: 'Force stop an app by package name',
    setArgs: ['am', 'force-stop', '{value}'],
    inputLabel: 'Package',
    inputHint: 'e.g. com.android.chrome',
  ),
  CmdEntry(
    category: 'Apps',
    name: 'Clear App Data',
    description: 'Clear app data and cache',
    setArgs: ['pm', 'clear', '{value}'],
    inputLabel: 'Package',
    inputHint: 'e.g. com.whatsapp',
  ),
  CmdEntry(
    category: 'Apps',
    name: 'Disable App',
    description: 'Disable a package',
    setArgs: ['pm', 'disable-user', '--user', '0', '{value}'],
    inputLabel: 'Package',
    inputHint: 'e.g. com.android.browser',
  ),
  CmdEntry(
    category: 'Apps',
    name: 'Enable App',
    description: 'Re-enable a disabled package',
    setArgs: ['pm', 'enable', '{value}'],
    inputLabel: 'Package',
    inputHint: 'e.g. com.android.browser',
  ),
  CmdEntry(
    category: 'Apps',
    name: 'List Packages',
    description: 'List installed packages matching text',
    setArgs: ['pm', 'list', 'packages', '{value}'],
    inputLabel: 'Filter',
    inputHint: 'e.g. google (or leave empty)',
  ),

  // ── Input / Simulation ──
  CmdEntry(
    category: 'Simulation',
    name: 'Open URL',
    description: 'Open a URL in browser',
    setArgs: ['am', 'start', '-a', 'android.intent.action.VIEW', '-d', '{value}'],
    inputLabel: 'URL',
    inputHint: 'e.g. https://www.google.com',
  ),
  CmdEntry(
    category: 'Simulation',
    name: 'Dial Number',
    description: 'Open dialer with number',
    setArgs: ['am', 'start', '-a', 'android.intent.action.DIAL', '-d', 'tel:{value}'],
    inputLabel: 'Phone #',
    inputHint: 'e.g. 1234567890',
    inputType: TextInputType.phone,
  ),

  // ── Performance ──
  CmdEntry(
    category: 'Performance',
    name: 'Show CPU Info',
    description: 'Display top CPU consuming processes',
    setArgs: ['top', '-m', '{value}'],
    inputLabel: 'Max processes',
    inputHint: 'e.g. 10 (leave empty for default)',
    inputType: TextInputType.number,
  ),
  CmdEntry(
    category: 'Performance',
    name: 'Kill Process',
    description: 'Kill a process by PID',
    setArgs: ['kill', '{value}'],
    inputLabel: 'PID',
    inputHint: 'Use Show CPU Info to find PID',
    inputType: TextInputType.number,
  ),

  // ── Media ──
  CmdEntry(
    category: 'Media',
    name: 'Take Screenshot',
    description: 'Capture screen to file',
    setArgs: ['screencap', '-p', '{value}'],
    inputLabel: 'Path',
    inputHint: '/sdcard/screenshot.png',
  ),
  CmdEntry(
    category: 'Media',
    name: 'Record Screen',
    description: 'Record screen for N seconds',
    setArgs: ['screenrecord', '--time-limit', '{value}', '/sdcard/record.mp4'],
    inputLabel: 'Seconds',
    inputHint: 'e.g. 30 (max 180)',
    inputType: TextInputType.number,
  ),

  // ── File Operations ──
  CmdEntry(
    category: 'Files',
    name: 'List Directory',
    description: 'List contents of a directory',
    setArgs: ['ls', '-la', '{value}'],
    inputLabel: 'Path',
    inputHint: 'e.g. /sdcard/Download',
  ),
  CmdEntry(
    category: 'Files',
    name: 'Read File',
    description: 'Print file contents',
    setArgs: ['cat', '{value}'],
    inputLabel: 'Path',
    inputHint: 'e.g. /proc/version',
  ),
  CmdEntry(
    category: 'Files',
    name: 'Delete File',
    description: 'Remove a file',
    setArgs: ['rm', '{value}'],
    inputLabel: 'Path',
    inputHint: 'e.g. /sdcard/temp.txt',
  ),
  CmdEntry(
    category: 'Files',
    name: 'Create Directory',
    description: 'Make a new directory',
    setArgs: ['mkdir', '-p', '{value}'],
    inputLabel: 'Path',
    inputHint: 'e.g. /sdcard/NewFolder',
  ),

  // ── Sound ──
  CmdEntry(
    category: 'Sound',
    name: 'Media Volume',
    description: 'Get/set media/music volume',
    getArgs: ['settings', 'get', 'system', 'volume_music'],
    setArgs: ['settings', 'put', 'system', 'volume_music', '{value}'],
    inputLabel: '0–15',
    inputHint: 'Volume level',
    inputType: TextInputType.number,
  ),
  CmdEntry(
    category: 'Sound',
    name: 'Ringer Volume',
    description: 'Get/set ringer volume',
    getArgs: ['settings', 'get', 'system', 'volume_ring'],
    setArgs: ['settings', 'put', 'system', 'volume_ring', '{value}'],
    inputLabel: '0–7',
    inputHint: 'Volume level',
    inputType: TextInputType.number,
  ),
  CmdEntry(
    category: 'Sound',
    name: 'Notification Volume',
    description: 'Get/set notification volume',
    getArgs: ['settings', 'get', 'system', 'volume_notification'],
    setArgs: ['settings', 'put', 'system', 'volume_notification', '{value}'],
    inputLabel: '0–7',
    inputHint: 'Volume level',
    inputType: TextInputType.number,
  ),
  CmdEntry(
    category: 'Sound',
    name: 'Alarm Volume',
    description: 'Get/set alarm volume',
    getArgs: ['settings', 'get', 'system', 'volume_alarm'],
    setArgs: ['settings', 'put', 'system', 'volume_alarm', '{value}'],
    inputLabel: '0–7',
    inputHint: 'Volume level',
    inputType: TextInputType.number,
  ),
  CmdEntry(
    category: 'Sound',
    name: 'Do Not Disturb',
    description: 'Get/set zen mode (Do Not Disturb)',
    getArgs: ['settings', 'get', 'global', 'zen_mode'],
    setArgs: ['settings', 'put', 'global', 'zen_mode', '{value}'],
    inputLabel: '0–3',
    inputHint: '0=off, 1=alarms, 2=priority, 3=silent',
    enumValues: ['0', '1', '2', '3'],
    inputType: TextInputType.number,
  ),

  // ── Connectivity ──
  CmdEntry(
    category: 'Connectivity',
    name: 'Bluetooth',
    description: 'Enable or disable Bluetooth',
    setArgs: ['svc', 'bluetooth', '{value}'],
    inputLabel: 'enable|disable',
    inputHint: 'Turn Bluetooth on or off',
    enumValues: ['enable', 'disable'],
  ),
  CmdEntry(
    category: 'Connectivity',
    name: 'NFC',
    description: 'Enable or disable NFC',
    setArgs: ['svc', 'nfc', '{value}'],
    inputLabel: 'enable|disable',
    inputHint: 'Turn NFC on or off',
    enumValues: ['enable', 'disable'],
  ),
  CmdEntry(
    category: 'Connectivity',
    name: 'HTTP Proxy',
    description: 'Get/set HTTP proxy for WiFi',
    getArgs: ['settings', 'get', 'global', 'http_proxy'],
    setArgs: ['settings', 'put', 'global', 'http_proxy', '{value}'],
    inputLabel: 'host:port',
    inputHint: 'e.g. 192.168.1.1:8080 (clear: :0)',
  ),

  // ── System ──
  CmdEntry(
    category: 'System',
    name: 'Install Unknown Apps',
    description: 'Get/set allow installs from unknown sources',
    getArgs: ['settings', 'get', 'global', 'install_non_market_apps'],
    setArgs: ['settings', 'put', 'global', 'install_non_market_apps', '{value}'],
    inputLabel: '0|1',
    inputHint: '0=block, 1=allow',
    enumValues: ['0', '1'],
    inputType: TextInputType.number,
  ),
  CmdEntry(
    category: 'System',
    name: 'Auto Date/Time',
    description: 'Get/set automatic date & time',
    getArgs: ['settings', 'get', 'global', 'auto_time'],
    setArgs: ['settings', 'put', 'global', 'auto_time', '{value}'],
    inputLabel: '0|1',
    inputHint: '0=manual, 1=auto network',
    enumValues: ['0', '1'],
    inputType: TextInputType.number,
  ),
  CmdEntry(
    category: 'System',
    name: 'USB Configuration',
    description: 'Get/set default USB function',
    getArgs: ['settings', 'get', 'global', 'usb_function'],
    setArgs: ['settings', 'put', 'global', 'usb_function', '{value}'],
    inputLabel: 'Mode',
    inputHint: 'mtp, ptp, midi, none',
    enumValues: ['mtp', 'ptp', 'midi'],
  ),

  // ── Display ──
  CmdEntry(
    category: 'Display',
    name: 'Night Mode',
    description: 'Get/set dark theme mode',
    getArgs: ['settings', 'get', 'secure', 'ui_night_mode'],
    setArgs: ['settings', 'put', 'secure', 'ui_night_mode', '{value}'],
    inputLabel: '0–2',
    inputHint: '0=off, 1=auto, 2=always on',
    enumValues: ['0', '1', '2'],
    inputType: TextInputType.number,
  ),
  CmdEntry(
    category: 'Display',
    name: 'Force RTL Layout',
    description: 'Get/set force right-to-left layout',
    getArgs: ['settings', 'get', 'global', 'force_rtl_layout'],
    setArgs: ['settings', 'put', 'global', 'force_rtl_layout', '{value}'],
    inputLabel: '0|1',
    inputHint: '0=off, 1=force RTL',
    enumValues: ['0', '1'],
    inputType: TextInputType.number,
  ),

  // ── Interaction ──
  CmdEntry(
    category: 'Interaction',
    name: 'Input Swipe',
    description: 'Simulate a swipe gesture',
    setArgs: ['input', 'swipe', '{value}'],
    inputLabel: 'X1 Y1 X2 Y2',
    inputHint: 'e.g. 300 400 800 400',
  ),
  CmdEntry(
    category: 'Interaction',
    name: 'Input Long Press',
    description: 'Simulate a long press (tap & hold)',
    setArgs: ['input', 'swipe', '{value}'],
    inputLabel: 'X Y X Y ms',
    inputHint: 'e.g. 500 800 500 800 2000',
  ),
  CmdEntry(
    category: 'Interaction',
    name: 'Show Layout Bounds',
    description: 'Get/set show clip bounds and margins',
    getArgs: ['settings', 'get', 'global', 'show_layout_bounds'],
    setArgs: ['settings', 'put', 'global', 'show_layout_bounds', '{value}'],
    inputLabel: '0|1',
    inputHint: '0=off, 1=show bounds',
    enumValues: ['0', '1'],
    inputType: TextInputType.number,
  ),
  CmdEntry(
    category: 'Interaction',
    name: 'Window Blur',
    description: 'Get/set window blur (Android 12+)',
    getArgs: ['settings', 'get', 'system', 'window_blur_enabled'],
    setArgs: ['settings', 'put', 'system', 'window_blur_enabled', '{value}'],
    inputLabel: '0|1',
    inputHint: '0=off, 1=enable blur',
    enumValues: ['0', '1'],
    inputType: TextInputType.number,
  ),

  // ── Battery ──
  CmdEntry(
    category: 'Battery',
    name: 'Battery Saver',
    description: 'Get/set battery saver (low power) mode',
    getArgs: ['settings', 'get', 'global', 'low_power_mode'],
    setArgs: ['settings', 'put', 'global', 'low_power_mode', '{value}'],
    inputLabel: '0|1',
    inputHint: '0=off, 1=on',
    enumValues: ['0', '1'],
    inputType: TextInputType.number,
  ),
  CmdEntry(
    category: 'Battery',
    name: 'Battery Temperature',
    description: 'Get/simulate battery temperature',
    getArgs: ['dumpsys', 'battery'],
    setArgs: ['dumpsys', 'battery', 'set', 'temp', '{value}'],
    inputLabel: '0.1°C',
    inputHint: 'e.g. 300 = 30.0°C',
    inputType: TextInputType.number,
  ),

  // ── Telephony ──
  CmdEntry(
    category: 'Telephony',
    name: 'Data Roaming',
    description: 'Get/set mobile data roaming',
    getArgs: ['settings', 'get', 'global', 'data_roaming'],
    setArgs: ['settings', 'put', 'global', 'data_roaming', '{value}'],
    inputLabel: '0|1',
    inputHint: '0=off, 1=on',
    enumValues: ['0', '1'],
    inputType: TextInputType.number,
  ),
  CmdEntry(
    category: 'Telephony',
    name: 'Preferred Network',
    description: 'Get/set preferred network type',
    getArgs: ['settings', 'get', 'global', 'preferred_network_mode'],
    setArgs: ['settings', 'put', 'global', 'preferred_network_mode', '{value}'],
    inputLabel: 'Mode code',
    inputHint: '0=WCDMA pref, 9=LTE/WCDMA, 20=NR/LTE/WCDMA/GSM, 22=NR/LTE',
    inputType: TextInputType.number,
  ),

  // ── Apps ──
  CmdEntry(
    category: 'Apps',
    name: 'Grant Permission',
    description: 'Grant a runtime permission to an app',
    setArgs: ['pm', 'grant', '{value}'],
    inputLabel: 'Package Permission',
    inputHint: 'e.g. com.app android.permission.CAMERA',
  ),
  CmdEntry(
    category: 'Apps',
    name: 'Revoke Permission',
    description: 'Revoke a runtime permission from an app',
    setArgs: ['pm', 'revoke', '{value}'],
    inputLabel: 'Package Permission',
    inputHint: 'e.g. com.app android.permission.CAMERA',
  ),
  CmdEntry(
    category: 'Apps',
    name: 'Check Feature',
    description: 'Check if a hardware feature is available',
    setArgs: ['pm', 'has-feature', '{value}'],
    getArgs: ['pm', 'has-feature', '{value}'],
    inputLabel: 'Feature name',
    inputHint: 'e.g. android.hardware.camera',
  ),
  CmdEntry(
    category: 'Apps',
    name: 'Switch User',
    description: 'Switch to a user profile by ID',
    setArgs: ['am', 'switch-user', '{value}'],
    inputLabel: 'User ID',
    inputHint: '0=primary, 10=work, 11=guest',
    inputType: TextInputType.number,
  ),
  CmdEntry(
    category: 'Apps',
    name: 'App Ops',
    description: 'Show app operation settings for a package',
    setArgs: ['appops', 'get', '{value}'],
    inputLabel: 'Package',
    inputHint: 'e.g. com.android.chrome',
  ),
  CmdEntry(
    category: 'Apps',
    name: 'APK Path',
    description: 'Show APK install path for a package',
    setArgs: ['pm', 'path', '{value}'],
    inputLabel: 'Package',
    inputHint: 'e.g. com.android.chrome',
  ),
  CmdEntry(
    category: 'Apps',
    name: 'App Info',
    description: 'Show detailed info for a package',
    setArgs: ['dumpsys', 'package', '{value}'],
    inputLabel: 'Package',
    inputHint: 'e.g. com.android.chrome',
  ),

  // ── Network ──
  CmdEntry(
    category: 'Network',
    name: 'Ping',
    description: 'Ping a host 4 times',
    setArgs: ['ping', '-c', '4', '{value}'],
    inputLabel: 'Host',
    inputHint: 'e.g. google.com',
  ),
  CmdEntry(
    category: 'Network',
    name: 'Interface Config',
    description: 'Show network interface details',
    setArgs: ['ifconfig', '{value}'],
    getArgs: ['ifconfig', '{value}'],
    inputLabel: 'Interface',
    inputHint: 'wlan0, lo, rmnet0',
  ),

  // ── System ──
  CmdEntry(
    category: 'System',
    name: 'Get Property',
    description: 'Read any system property',
    setArgs: ['getprop', '{value}'],
    getArgs: ['getprop', '{value}'],
    inputLabel: 'Property key',
    inputHint: 'e.g. ro.product.model, ro.build.version.release',
  ),
  CmdEntry(
    category: 'System',
    name: 'Set Date',
    description: 'Set system date and time',
    setArgs: ['date', '{value}'],
    inputLabel: 'MMDDhhmmYY.ss',
    inputHint: 'e.g. 0530120025.00 (May 30 12:00 2025)',
  ),
  CmdEntry(
    category: 'System',
    name: 'Logcat Tag',
    description: 'Show recent logcat entries for a tag',
    setArgs: ['logcat', '-d', '-s', '{value}'],
    inputLabel: 'Tag',
    inputHint: 'e.g. WiFi, ActivityManager, SystemUI',
  ),

  // ── Performance ──
  CmdEntry(
    category: 'Performance',
    name: 'Dir Size',
    description: 'Show disk usage of a file or directory',
    setArgs: ['du', '-sh', '{value}'],
    inputLabel: 'Path',
    inputHint: 'e.g. /sdcard/Download',
  ),
  CmdEntry(
    category: 'Performance',
    name: 'Find PID',
    description: 'Find process IDs by process name',
    setArgs: ['pidof', '{value}'],
    inputLabel: 'Process name',
    inputHint: 'e.g. mediaserver, surfaceflinger',
  ),
  CmdEntry(
    category: 'Performance',
    name: 'Proc Status',
    description: 'Show status of a process by PID',
    setArgs: ['cat', '/proc/{value}/status'],
    inputLabel: 'PID',
    inputHint: 'Use Find PID to get the number',
    inputType: TextInputType.number,
  ),
  CmdEntry(
    category: 'Performance',
    name: 'Disk Usage',
    description: 'Show disk usage for a path',
    setArgs: ['du', '-h', '{value}'],
    inputLabel: 'Path',
    inputHint: 'e.g. /sdcard (leave empty for current dir)',
  ),
  CmdEntry(
    category: 'Performance',
    name: 'Memory Usage',
    description: 'Show memory usage of a package',
    setArgs: ['dumpsys', 'meminfo', '{value}'],
    inputLabel: 'Package',
    inputHint: 'e.g. com.android.chrome',
  ),

  // ── Developer ──
  CmdEntry(
    category: 'Developer',
    name: 'Force GPU Rendering',
    description: 'Get/set force GPU rendering (2D HW accel)',
    getArgs: ['settings', 'get', 'global', 'force_gpu_rendering'],
    setArgs: ['settings', 'put', 'global', 'force_gpu_rendering', '{value}'],
    inputLabel: '0|1',
    inputHint: '0=off, 1=force GPU',
    enumValues: ['0', '1'],
    inputType: TextInputType.number,
  ),
  CmdEntry(
    category: 'Developer',
    name: 'Show HW Updates',
    description: 'Get/set flash hardware layer updates',
    getArgs: ['settings', 'get', 'global', 'show_hw_screen_updates'],
    setArgs: ['settings', 'put', 'global', 'show_hw_screen_updates', '{value}'],
    inputLabel: '0|1',
    inputHint: '0=off, 1=show GPU layers',
    enumValues: ['0', '1'],
    inputType: TextInputType.number,
  ),
  CmdEntry(
    category: 'Developer',
    name: 'Debug GPU Overdraw',
    description: 'Get/set GPU overdraw visualization',
    getArgs: ['settings', 'get', 'global', 'debug_gpu_overdraw'],
    setArgs: ['settings', 'put', 'global', 'debug_gpu_overdraw', '{value}'],
    inputLabel: '0–2',
    inputHint: '0=off, 1=blue, 2=green',
    enumValues: ['0', '1', '2'],
    inputType: TextInputType.number,
  ),
  CmdEntry(
    category: 'Developer',
    name: 'Overlay Display',
    description: 'Get/set simulated secondary display',
    getArgs: ['settings', 'get', 'global', 'overlay_display_devices'],
    setArgs: ['settings', 'put', 'global', 'overlay_display_devices', '{value}'],
    inputLabel: 'WxH/dpi',
    inputHint: 'e.g. 1920x1080/120 (empty=off)',
  ),
];

class CommandBrowserPage extends StatefulWidget {
  const CommandBrowserPage({super.key});

  @override
  State<CommandBrowserPage> createState() => _CommandBrowserPageState();
}

class _CommandBrowserPageState extends State<CommandBrowserPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _expandedId;
  final Map<String, TextEditingController> _inputControllers = {};
  final Map<String, String> _outputs = {};
  final Map<String, bool> _loading = {};

  List<CmdEntry> get _filteredEntries {
    if (_searchQuery.isEmpty) return commandEntries;
    final q = _searchQuery.toLowerCase();
    return commandEntries.where((e) =>
      e.name.toLowerCase().contains(q) ||
      e.category.toLowerCase().contains(q) ||
      e.description.toLowerCase().contains(q) ||
      _commandText(e).contains(q)
    ).toList();
  }

  String _commandText(CmdEntry cmd) {
    final args = cmd.setArgs.join(' ');
    return 'adb shell $args';
  }

  Future<void> _execute(CmdEntry cmd) async {
    final dm = context.read<DeviceManager>();
    final device = dm.selected;
    if (device == null || !device.isConnected) return;

    final id = cmd.name;
    setState(() {
      _loading[id] = true;
      _expandedId = id;
    });

    final controller = _inputControllers[id];
    final input = controller?.text.trim() ?? '';
    final resolved = cmd.setArgs.map((a) => a == '{value}' ? input : a).toList();
    final out = await AdbExecService.run(device.id, resolved);

    if (mounted) {
      setState(() {
        _outputs[id] = out.isEmpty ? '(empty)' : out;
        _loading[id] = false;
      });
    }
  }

  Future<void> _verify(CmdEntry cmd) async {
    if (cmd.getArgs.isEmpty) return;
    final dm = context.read<DeviceManager>();
    final device = dm.selected;
    if (device == null || !device.isConnected) return;

    setState(() {
      _loading[cmd.name] = true;
      _expandedId = cmd.name;
    });

    final out = await AdbExecService.run(device.id, cmd.getArgs);

    if (mounted) {
      setState(() {
        _outputs[cmd.name] = 'Current value:\n$out';
        _loading[cmd.name] = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    for (final c in _inputControllers.values) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dm = context.watch<DeviceManager>();
    final device = dm.selected;
    if (device == null || !device.isConnected) return const NoDevicePanel();

    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search commands…',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _filteredEntries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_off, size: 48, color: cs.outlineVariant),
                      const SizedBox(height: 8),
                      Text('No commands match "$_searchQuery"', style: TextStyle(color: cs.onSurfaceVariant)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: _filteredEntries.length,
                  itemBuilder: (ctx, i) => _CommandCard(
                    cmd: _filteredEntries[i],
                    isExpanded: _expandedId == _filteredEntries[i].name,
                    output: _outputs[_filteredEntries[i].name] ?? '',
                    isLoading: _loading[_filteredEntries[i].name] ?? false,
                    inputController: _inputControllers.putIfAbsent(
                      _filteredEntries[i].name,
                      () => TextEditingController(),
                    ),
                    onToggle: () => setState(() {
                      _expandedId = _expandedId == _filteredEntries[i].name ? null : _filteredEntries[i].name;
                    }),
                    onExecute: () => _execute(_filteredEntries[i]),
                    onVerify: _filteredEntries[i].getArgs.isEmpty ? null : () => _verify(_filteredEntries[i]),
                  ),
                ),
        ),
      ],
    );
  }
}

class _CommandCard extends StatelessWidget {
  final CmdEntry cmd;
  final bool isExpanded;
  final String output;
  final bool isLoading;
  final TextEditingController inputController;
  final VoidCallback onToggle;
  final VoidCallback onExecute;
  final VoidCallback? onVerify;

  const _CommandCard({
    required this.cmd,
    required this.isExpanded,
    required this.output,
    required this.isLoading,
    required this.inputController,
    required this.onToggle,
    required this.onExecute,
    this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      elevation: 0,
      color: isExpanded ? cs.surfaceContainerLow : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: isExpanded ? cs.primary.withValues(alpha: 0.3) : cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.terminal, size: 16, color: cs.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cmd.name, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                        if (cmd.description.isNotEmpty)
                          Text(cmd.description, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(cmd.category, style: tt.labelSmall?.copyWith(color: cs.primary, fontSize: 10)),
                  ),
                  const SizedBox(width: 4),
                  Icon(isExpanded ? Icons.expand_less : Icons.expand_more, size: 18),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ADB command display with copy
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF0F0F5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.code, size: 14, color: cs.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _commandDisplay(),
                            style: TextStyle(fontFamily: 'monospace', fontSize: 11.5, color: cs.onSurfaceVariant),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 16),
                          tooltip: 'Copy command',
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _commandDisplay()));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Command copied'), duration: Duration(seconds: 1)),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  if (cmd.getArgs.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF0F0F5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.visibility, size: 14, color: cs.secondary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _getCommandDisplay(),
                              style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: cs.onSurfaceVariant),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 14),
                            tooltip: 'Copy verify command',
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _getCommandDisplay()));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Command copied'), duration: Duration(seconds: 1)),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Input field
                  if (cmd.inputLabel.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: inputController,
                            decoration: InputDecoration(
                              labelText: cmd.inputLabel,
                              hintText: cmd.inputHint,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            keyboardType: cmd.inputType,
                            style: TextStyle(fontFamily: 'monospace', fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Enum chips
                  if (cmd.enumValues != null && cmd.enumValues!.length <= 6) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      children: cmd.enumValues!.map((v) => ActionChip(
                        label: Text(v, style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
                        onPressed: () {
                          inputController.text = v;
                        },
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      )).toList(),
                    ),
                  ],

                  // Action buttons
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: cmd.inputLabel.isEmpty || inputController.text.trim().isNotEmpty ? onExecute : null,
                        icon: isLoading
                            ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.play_arrow, size: 16),
                        label: Text(isLoading ? 'Running…' : 'Execute'),
                        style: FilledButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                      if (onVerify != null) ...[
                        const SizedBox(width: 6),
                        OutlinedButton.icon(
                          onPressed: onVerify,
                          icon: const Icon(Icons.visibility, size: 14),
                          label: const Text('Verify', style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
                        ),
                      ],
                      const Spacer(),
                      if (cmd.inputLabel.isNotEmpty && cmd.setArgs.any((a) => a == '{value}'))
                        TextButton(
                          onPressed: () => inputController.clear(),
                          child: const Text('Clear', style: TextStyle(fontSize: 11)),
                        ),
                    ],
                  ),

                  // Output
                  if (output.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: cs.outlineVariant),
                      ),
                      child: Stack(
                        children: [
                          SelectableText(
                            output,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11.5,
                              color: isDark ? const Color(0xFFCDD6F4) : Colors.black87,
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.copy, size: 14),
                              tooltip: 'Copy output',
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: output));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Output copied'), duration: Duration(seconds: 1)),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _commandDisplay() {
    final input = inputController.text.trim();
    final resolved = cmd.setArgs.map((a) => a == '{value}' ? (input.isEmpty ? '{value}' : input) : a).toList();
    return 'adb shell ${resolved.join(' ')}';
  }

  String _getCommandDisplay() {
    return 'adb shell ${cmd.getArgs.join(' ')}';
  }
}
