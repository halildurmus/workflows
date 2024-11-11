import 'dart:io';

void main(List<String> args) {
  // Use 'dart' as the default executable if none is provided.
  final executable = args.isNotEmpty ? args.first : 'dart';

  // Define format options.
  const formatArgs = ['format', '--set-exit-if-changed', '.'];

  print('🧹 Checking code style...');

  // Run the format command.
  final result = Process.runSync(executable, formatArgs);

  // Output format results.
  if (result.exitCode == 0) {
    print('✅ Code is properly formatted. No changes needed.');
  } else {
    print('🚨 Code formatting issue(s) detected:\n\n${result.stdout}');
    print('🛑 Please commit the formatted files by running: "git add ."');
  }

  // Exit with the same exit code as the format process.
  exit(result.exitCode);
}
