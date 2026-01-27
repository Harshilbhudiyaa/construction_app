import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:construction_app/shared/theme/professional_theme.dart';

/// Keyboard shortcut handler for power users
class KeyboardShortcutHandler extends StatelessWidget {
  final Widget child;
  final Map<String, VoidCallback> shortcuts;

  const KeyboardShortcutHandler({
    super.key,
    required this.child,
    required this.shortcuts,
  });

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: _buildShortcuts(),
      child: Actions(
        actions: _buildActions(),
        child: Focus(
          autofocus: true,
          child: child,
        ),
      ),
    );
  }

  Map<ShortcutActivator, Intent> _buildShortcuts() {
    final map = <ShortcutActivator, Intent>{};
    
    if (shortcuts.containsKey('save')) {
      map[LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS)] =
          const SaveIntent();
    }
    if (shortcuts.containsKey('search')) {
      map[LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyF)] =
          const SearchIntent();
    }
    if (shortcuts.containsKey('new')) {
      map[LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyN)] =
          const NewIntent();
    }
    if (shortcuts.containsKey('refresh')) {
      map[LogicalKeySet(LogicalKeyboardKey.f5)] = const RefreshIntent();
    }
    if (shortcuts.containsKey('help')) {
      map[LogicalKeySet(LogicalKeyboardKey.f1)] = const HelpIntent();
    }
    
    return map;
  }

  Map<Type, Action<Intent>> _buildActions() {
    return {
      if (shortcuts.containsKey('save'))
        SaveIntent: CallbackAction<SaveIntent>(
          onInvoke: (_) => shortcuts['save']!(),
        ),
      if (shortcuts.containsKey('search'))
        SearchIntent: CallbackAction<SearchIntent>(
          onInvoke: (_) => shortcuts['search']!(),
        ),
      if (shortcuts.containsKey('new'))
        NewIntent: CallbackAction<NewIntent>(
          onInvoke: (_) => shortcuts['new']!(),
        ),
      if (shortcuts.containsKey('refresh'))
        RefreshIntent: CallbackAction<RefreshIntent>(
          onInvoke: (_) => shortcuts['refresh']!(),
        ),
      if (shortcuts.containsKey('help'))
        HelpIntent: CallbackAction<HelpIntent>(
          onInvoke: (_) => shortcuts['help']!(),
        ),
    };
  }
}

// Intent classes
class SaveIntent extends Intent {
  const SaveIntent();
}

class SearchIntent extends Intent {
  const SearchIntent();
}

class NewIntent extends Intent {
  const NewIntent();
}

class RefreshIntent extends Intent {
  const RefreshIntent();
}

class HelpIntent extends Intent {
  const HelpIntent();
}

/// Keyboard shortcuts guide overlay
class KeyboardShortcutsGuide extends StatelessWidget {
  final List<ShortcutInfo> shortcuts;

  const KeyboardShortcutsGuide({
    super.key,
    required this.shortcuts,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.deepBlue1.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.keyboard_rounded,
                    color: AppColors.deepBlue1,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Keyboard Shortcuts',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.deepBlue1,
                        ),
                      ),
                      Text(
                        'Power user commands',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              constraints: const BoxConstraints(maxHeight: 400),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: shortcuts.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final shortcut = shortcuts[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                shortcut.description,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              if (shortcut.hint != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  shortcut.hint!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Text(
                            shortcut.keys,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void show(BuildContext context, List<ShortcutInfo> shortcuts) {
    showDialog(
      context: context,
      builder: (_) => KeyboardShortcutsGuide(shortcuts: shortcuts),
    );
  }
}

class ShortcutInfo {
  final String description;
  final String keys;
  final String? hint;

  const ShortcutInfo({
    required this.description,
    required this.keys,
    this.hint,
  });
}

/// Common keyboard shortcuts
class CommonShortcuts {
  static const List<ShortcutInfo> form = [
    ShortcutInfo(
      description: 'Save Form',
      keys: 'Ctrl+S',
      hint: 'Save current form data',
    ),
    ShortcutInfo(
      description: 'Cancel/Go Back',
      keys: 'Esc',
      hint: 'Return to previous screen',
    ),
  ];

  static const List<ShortcutInfo> list = [
    ShortcutInfo(
      description: 'Search',
      keys: 'Ctrl+F',
      hint: 'Focus on search field',
    ),
    ShortcutInfo(
      description: 'Add New Item',
      keys: 'Ctrl+N',
      hint: 'Create new entry',
    ),
    ShortcutInfo(
      description: 'Refresh List',
      keys: 'F5',
      hint: 'Reload data from server',
    ),
  ];

  static const List<ShortcutInfo> general = [
    ShortcutInfo(
      description: 'Show Shortcuts',
      keys: 'F1',
      hint: 'Display this help guide',
    ),
    ShortcutInfo(
      description: 'Dashboard',
      keys: 'Alt+Home',
      hint: 'Navigate to dashboard',
    ),
  ];
}
