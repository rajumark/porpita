# Porpita - Flutter Project Rules

## Project Goal
- **Desktop ADB GUI** — native-quality app on macOS, Windows, and Linux from a single Flutter codebase
- **Design-first for developers & QA** — intuitive, fast, keyboard-friendly interface that reduces friction for both engineers and non-engineers
- **Complete ADB coverage** — every `adb` and related command (shell, logcat, screencap, push/pull, install, forward, reverse, bugreport, dumpsys, pm, am, etc.) will be exposed through the UI. Goal: zero commands left behind. If it exists in ADB, it exists in Porpita.

## Material Design & UI
- Build on Material Design 3 defaults — `ColorScheme.fromSeed`, `useMaterial3: true`, standard `AppBar`, `Card`, `ListTile`, `NavigationBar`/`NavigationRail`, `MaterialPageRoute`, Material `Icons`
- Custom UI components must live in `core/design_system/` as reusable, tokenized widgets — no ad-hoc inline custom widgets
- Use `Theme.of(context)` everywhere — never hardcode colors, padding, or text styles
- Extend theme via `ThemeData.copyWith` — never override globally
- Responsive: `LayoutBuilder`, `MediaQuery`, `Flexible`/`Expanded` — no fixed sizes
- **Platform-aware UI:** Use Material for Windows/Linux; respect macOS HIG conventions (menu bar position, window controls). Use `defaultTargetPlatform` / `Platform` for conditional adaptations — never mix Material and Cupertino in the same screen.
- **Desktop window sizing:** Set minimum window size (800×600) via `window_manager`. Remember and restore previous window dimensions across launches.
- **Global keyboard shortcuts:** Bind app-wide shortcuts (e.g., `Cmd/Ctrl+F` for search, `Cmd/Ctrl+K` for clear console) using `Shortcuts`/`Actions`/`Intent`. Respect platform modifier key conventions.
- **Right-click context menus:** Every actionable item (device, log line, file) must support native right-click context menus.

## Desktop Experience (Critical)
- Use `window_manager` for window control: custom title bar, drag-to-move, double-click maximize, min/max/close buttons per platform convention
- Use `tray_manager` for system tray icon with reactive context menu
- Use `local_notifier` for native desktop OS notifications
- Wrap all desktop integrations in `core/services/desktop_service.dart` — single facade for `window_manager`, `tray_manager`, `local_notifier`. Never call these plugins directly from widgets.
- **Keyboard-first:** Use `Shortcuts`/`Actions`/`Intent` for all common operations. Bind `FocusNode` for logical tab order. Use `MouseRegion` for hover feedback.
- **Window persistence:** Save and restore window size/position between sessions via `SharedPreferences`
- **Close behavior:** Intercept `onWindowClose` — support both "exit" and "minimize to tray" based on user preference. Handle platform lifecycle differences (macOS close ≠ exit; Windows close = exit).
- **Multi-window:** Use `desktop_multi_window` for detachable panels (settings, logcat in separate window)

## Project Architecture (Desktop-Focused Feature Slicing)
```
lib/
├── core/                         # Cross-cutting infrastructure
│   ├── design_system/            # Reusable desktop components (terminal panels, split-view dividers)
│   ├── theme/                    # Tokenized theme, typography, color definitions
│   ├── environment/              # ADB binary path auto-detection, OS environment resolvers
│   ├── process/                  # System process executors, Isolate wrappers for ADB streams
│   ├── router/                   # Top-level go_router configuration
│   ├── constants/                # App-wide constants
│   └── utils/                    # Pure utility functions, extensions
└── features/
    └── logcat_viewer/            # Feature slice example (not a generic placeholder)
        ├── data/
        │   ├── datasources/      # Local process stream wrapper (subscribes to `adb logcat`)
        │   └── models/           # LogLine DTOs — parsing log levels, timestamps, tags
        ├── domain/
        │   ├── entities/         # Immutable clean log entries
        │   └── repositories/     # Interface contracts for log filtering/saving
        └── presentation/
            ├── controllers/      # Throttled state providers (regex search, filter, ring-buffer)
            ├── screens/          # Main viewport containing layout splits
            └── widgets/          # Performance-isolated log rows, auto-scroll anchors
```

Other possible features: `device_manager`, `file_explorer`, `package_inspector`, `screen_mirror`, `app_installer`

**Self-containment rule:** A feature folder must be deletable without breaking other features. Shared entities go in `core/`, never in a feature that other features import.

## Monorepo (Melos v7 + Pub Workspaces)
- Use **Melos v7+** with native pub workspaces (config in root `pubspec.yaml` under `melos:` key, no separate `melos.yaml`)
- Structure: `packages/core`, `packages/feature_logcat`, `packages/feature_file_explorer`, `packages/feature_device_manager`, `apps/porpita`
- Every workspace member must have `resolution: workspace` and `publish_to: none`
- Use `melos bootstrap` (never `flutter pub get` per package)
- Define scripts in root `pubspec.yaml` for `analyze`, `test`, `generate` across all packages
- Required Dart SDK ≥ 3.10, Flutter ≥ 3.38

## State Management
- **Must use Riverpod or Bloc** — Provider/ChangeNotifier is disallowed for 1000+ scale (widget-tree coupling, memory leaks, no isolate support)
- State is decoupled from `BuildContext` — predictable scoping and auto-disposal
- UI state controllers must be transient/auto-disposed when the screen pops
- Data sources and repositories must be registered as singletons
- **Three kinds of state:** ephemeral (local widget state), server (AsyncNotifier/FutureProvider), app-wide (NotifierProvider) — never mix them in one provider

## Dependency Injection
- Use Riverpod's built-in dependency tracking or `GetIt` for explicit lifecycle management
- Constructor injection everywhere — no global singletons except for truly stateless infrastructure
- Factory vs Singleton: data sources/repos = singleton; UI controllers = transient (auto-disposed)

## Navigation
- **Top-level routing only: use `go_router`** — manages primary view transitions (Device List → Device Dashboard → Settings). Not suited for managing concurrent tabbed panels or split panes.
- Use **`go_router_deferred`** for Dart `deferred` import code splitting
- **Concurrent workspace panels** (multi-device tabs, side-by-side terminal/logcat, split-pane file explorer) must be managed by dedicated presentation-layer tab-state controllers — not URL path state.
- All routes defined in `core/router/` — auto-registered, no manual route lists.

## ADB Integration
- Use **`adb_kit`** Dart package as the typed ADB wrapper — never shell out to raw `adb` process with string concatenation
- Wrap `adb_kit` in `core/services/adb_service.dart` as the single point of interaction
- All ADB commands go through the repository pattern: screen → provider → use case → repository → adb_kit service
- **Environment detection (`core/environment/`):** On first launch, auto-detect `adb` binary location from `ANDROID_HOME`, `PATH`, and common install paths per OS. Allow manual override in settings. Show clear error state if ADB is not found — never crash silently.

## Large-Scale Rules (Complex Multi-Panel Desktop App)
Desktop ADB utilities don't have 1000+ routing pages — they have **dense, multi-panel single screens** (like Android Studio / VS Code). Rules shift from page routing to widget modularity:
- **Widget Modularity & Sectional Rebuild Boundaries:** Isolate complex panels (device mirror feed, package inspector, logcat stream) with `RepaintBoundary` and tightly-scoped Riverpod providers — one panel's rebuild must never affect another
- **Multi-package monorepo via Melos** — break domains into `packages/core`, `packages/feature_*`, etc.
- Deferred/code-split feature packages loaded on demand via `go_router_deferred`
- Repository pattern: screens never call data sources directly
- Lazy lists with `ListView.builder` — never build full lists in memory
- Prefer `const` constructors everywhere — minimizes rebuilds
- Immutable models via `freezed` — no runtime type errors
- **Self-containment rule:** every feature folder must be independently removable

## Performance
- Use **Impeller rendering engine** (stable in Flutter 3.38, 40% CPU reduction over Skia)
- **ADB stream isolates:** Every persistent ADB stream (`adb logcat`, `adb shell top`, `adb shell dumpsys -t`) **must** run in a dedicated background `Isolate` / `Worker`. Presentation layer listens only to throttled/batched updates to prevent UI thread flooding
- **Ring-buffer for log/terminal views:** Implement strict maximum-line limits (e.g., cap at 5,000 lines in memory). Infinite log accumulation without truncation is prohibited — prevents OOM crashes
- Avoid `build()` with heavy computation — use `compute()` isolates
- Const widgets where possible; minimize rebuilds with `Selector` / `select()`
- Minimize overdraw — prefer `ColorFiltered` over `Opacity`
- Profile regularly with Flutter DevTools (rebuild counts, memory, GPU, isolate thread health)
- Defer non-essential work until after first frame — let shell appear, then hydrate secondary services

## Code Generation
- All generated files (`.g.dart`, `.freezed.dart`) must be in `.gitignore` — never committed
- CI/CD pipeline must run: `dart run build_runner build --delete-conflicting-outputs`
- Run code generation before every PR

## Code Quality & Conventions
- Follow [Effective Dart](https://dart.dev/effective-dart/style) — `camelCase`, `PascalCase`, `lowercase_with_underscores`
- One class per file (except small private helpers)
- `const` constructors always when possible
- No wildcard imports — explicit imports only
- `late final` for one-time init; avoid `late` unless guaranteed
- No `dynamic` — prefer explicit types or `Object?`
- All public APIs must have doc comments
- **Lint enforcement:** Use `flutter_lints` + `dart_code_metrics` in `analysis_options.yaml` with rules for max method length (15 lines), max file length (400 lines), cyclomatic complexity — automate, don't rely on manual review
- **Boring codebase philosophy:** avoid custom solutions — pick well-known packages and stick with them. Predictable code beats clever code.

## Testing
- Unit test all `usecases`, `repositories`, `providers`/`blocs`
- Widget test all screens
- Integration test critical user flows
- Use `mocktail` or `mockito` — never mock what you don't own
- Coverage target: >80%

## Package Management
- Pin major versions in `pubspec.yaml` — avoid `any` constraint
- Run `flutter pub outdated` regularly; upgrade minor/patch
- Audit dependencies for size and licensing before adding
- Prefer packages with active maintenance & Flutter team backing

## Git & Workflow
- Branch: `main` (stable) → `develop` → `feature/<name>` / `fix/<name>`
- Conventional commits: `feat:`, `fix:`, `refactor:`, `chore:`
- No commits to `main` without PR + review
- Run `flutter analyze` and tests before every PR
- CI/CD validates codegen output and lints
