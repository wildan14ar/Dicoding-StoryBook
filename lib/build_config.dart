enum AppFlavor { free, paid }

class BuildConfig {
  // FLAVOR diset via --dart-define=FLAVOR=paid/free
  static const AppFlavor flavor =
      String.fromEnvironment('FLAVOR') == 'paid'
          ? AppFlavor.paid
          : AppFlavor.free;
}
