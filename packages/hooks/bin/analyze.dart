import 'dart:io';

void main(List<String> args) {
  // Use 'dart' as the default executable if none is provided.
  final executable = args.isNotEmpty ? args.first : 'dart';

  // Define analyze options.
  final analyzeArgs = [
    'analyze',
    '--fatal-infos',
    '--fatal-warnings',
    ...args.skip(1),
  ];

  print('🔍 Analyzing code...');

  // Run the analyze command.
  final result = Process.runSync(executable, analyzeArgs);

  // Output analyze results.
  if (result.exitCode == 0) {
    print('✅ Analysis completed without issues.');
  } else {
    print('🚨 Analyzer issue(s) detected:\n\n${result.stdout}');
    print('🛑 Please fix the issue(s) above.');
  }

  // Exit with the same exit code as the analyze process.
  exit(result.exitCode);
}
