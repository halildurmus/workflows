import 'dart:io';

void main(List<String> args) {
  final formatArgs = [
    '--set-exit-if-changed',
    if (args.isEmpty) '.' else ...args
  ];
  print('🧹 Checking code style...');
  final result = Process.runSync('dart', ['format', ...formatArgs]);
  if (result.exitCode == 0) {
    print('✅ Code is properly formatted. No changes needed.');
  } else {
    print('🚨 Code formatting issue(s) detected:');
    if (result.stdout case final String stdout when stdout.isNotEmpty) {
      print(stdout);
    }
    if (result.stderr case final String stderr when stderr.isNotEmpty) {
      print(stderr);
    }
    print('🛑 Please commit the formatted files by running: "git add ."');
  }
  exit(result.exitCode);
}
