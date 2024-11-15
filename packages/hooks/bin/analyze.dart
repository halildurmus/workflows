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
  final analyzeArgs = ['--fatal-infos', '--fatal-warnings', ...argResults.rest];
  print('🔍 Analyzing code...');
  final result = Process.runSync(
    executable,
    ['analyze', ...analyzeArgs],
    runInShell: true,
  );
  if (result.exitCode == 0) {
    print('✅ Analysis completed without issues.');
  } else {
    print('🚨 Analyzer issue(s) detected:');
    if (result.stdout case final String stdout when stdout.isNotEmpty) {
      print(stdout);
    }
    if (result.stderr case final String stderr when stderr.isNotEmpty) {
      print(stderr);
    }
    print('🛑 Please fix the issue(s) above.');
  }
  exit(result.exitCode);
}
