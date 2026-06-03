import 'dart:io';

/// Cross-platform launcher stub for native platforms.
void launchUrlString(String url) {
  if (Platform.isWindows) {
    Process.run('cmd', ['/c', 'start', '', url]);
  }
}
