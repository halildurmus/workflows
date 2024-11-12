import 'dart:io';

void main(List<String> args) {
  // Use 'dart' as the default executable if none is provided
  final executable = args.isNotEmpty ? args.first : 'dart';

  print('🧪 Running tests...');

  // Run the test command.
  final result = Process.runSync(executable, ['test', ...args]);

  // Output test results.
  if (result.exitCode == 0) {
    print('✅ All tests passed successfully.');
  } else {
    print('🚨 Test failure(s) detected:\n\n${result.stdout}');
    print('🛑 Please review the test failure(s) above.');
  }

  // Exit with the same exit code as the test process.
  exit(result.exitCode);
}
