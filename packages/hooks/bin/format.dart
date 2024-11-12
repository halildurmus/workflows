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
    print('🚨 Code formatting issue(s) detected:\n\n${result.stdout}');
    print('🛑 Please commit the formatted files by running: "git add ."');
  }
  exit(result.exitCode);
}
