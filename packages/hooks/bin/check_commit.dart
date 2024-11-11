import 'dart:io';

import 'package:conventional_commit/conventional_commit.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    print('❌ No commit message file provided.');
    exit(1);
  }

  final commitMessageFile = File(args[0]);
  final commitMessage = commitMessageFile.readAsStringSync().trim();
  print('📝 Commit message: "$commitMessage"');

  try {
    final commit = ConventionalCommit.tryParse(commitMessage);
    if (commit == null) {
      print('❌ Invalid commit message: "$commitMessage"');
      print('Please follow the conventional commit message format:');
      print('https://www.conventionalcommits.org/en/v1.0.0/');
      exit(1);
    }

    print('✅ Commit message is valid.');
  } catch (e) {
    print('❌ Error while validating commit message: "$commitMessage"');
    print('Please follow the conventional commit message format:');
    print('https://www.conventionalcommits.org/en/v1.0.0/');
    exit(1);
  }
}
