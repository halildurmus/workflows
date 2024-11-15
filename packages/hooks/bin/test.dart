import 'dart:io';

import 'package:args/args.dart';

void main(List<String> args) {
  final argsParser = ArgParser()
    ..addFlag(
      'flutter',
      abbr: 'f',
      help: 'Use flutter instead of dart to run the analyze command.',
      negatable: false,
    );
  final argResults = argsParser.parse(args);
  final executable = argResults.flag('flutter') ? 'flutter' : 'dart';
  print('🧪 Running tests...');
  final result = Process.runSync(
    executable,
    ['test', ...argResults.rest],
    runInShell: true,
  );
  if (result.exitCode == 0) {
    print('✅ All tests passed successfully.');
  } else {
    print('🚨 Test failure(s) detected:');
    if (result.stdout case final String stdout when stdout.isNotEmpty) {
      print(stdout);
    }
    if (result.stderr case final String stderr when stderr.isNotEmpty) {
      print(stderr);
    }
    print('🛑 Please review the test failure(s) above.');
  }
  exit(result.exitCode);
}
