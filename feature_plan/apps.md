# Apps Screen — Feature Plan

## ADB Commands

| List Type | Command |
|---|---|
| All packages | `adb shell pm list packages` |
| User apps | `adb shell pm list packages -3` |
| System apps | `adb shell pm list packages -s` |
| Enabled apps | `adb shell pm list packages -e` |
| Disabled apps | `adb shell pm list packages -d` |

## UI Layout

### Split-pane design

- **Left panel** — Package list
  - Search bar (filter by package name)
  - Filter icon button to toggle list type (all / user / system / enabled / disabled)
  - Default: user apps (`-3`)
  - Scrollable list of package names
- **Right panel** — Detail view (when an item is selected)

### Context menu (right-click on list item)

| Action | ADB command |
|---|---|
| Start | `adb shell monkey -p <pkg> 1` |
| Stop | `adb shell am force-stop <pkg>` |
| Restart | `adb shell am restart <pkg>` |
| Clear data | `adb shell pm clear <pkg>` |
| Uninstall | `adb uninstall <pkg>` |
| Enable | `adb shell pm enable <pkg>` |
| Disable | `adb shell pm disable-user <pkg>` |
| Copy | Copy package name to clipboard |
| View in Play Store | Open `https://play.google.com/store/apps/details?id=<pkg>` |
| View on website | Open developer-provided URL from dump |
| Find online | Search the package name on the web |
| Grant all permissions | `adb shell pm grant <pkg> <perm>` (iterate) |
| Revoke all permissions | `adb shell pm revoke <pkg> <perm>` (iterate) |
| Manage permissions | Open system permission settings intent |

## Detail View (right panel)

When a package is clicked, run `adb shell pm dump <pkg>` and parse the output.

### Structure

- **Back button** (top-left) — returns to empty/null selection state
- **Package name** — displayed as heading
- **Tabs** below the heading:

  | Tab | Content |
  |---|---|
  | **Overview** | Summary: app label, version, installer, flags, SDK versions, first install time, last update time |
  | **Components** | Split left-right layout: left sidebar lists component categories, right shows selected category details |
  | **Data** | Data directories, cache sizes, permissions granted/denied, shared users |

### Components sub-navigation (sidebar)

Categories parsed from the dump:

- Activities
- Services
- Broadcast Receivers
- Content Providers
- Permissions (requested + granted/denied)
- Flags
- Intents
- Instrumentation
- Processes
- Configuration
- Features
- Signatures
