import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  // Define the git cliff arguments.
  const gitCliffArgs = ['cliff', 'changelog', '--unreleased'];

  // Run the git cliff changelog command.
  final result = Process.runSync('git', gitCliffArgs, stdoutEncoding: utf8);

  // Output changelog results.
  if (result.exitCode == 0) {
    final newChangelog = result.stdout.toString().trim();
    if (!newChangelog.contains('## [unreleased]')) {
      print('✅ No new changes to update in CHANGELOG.md.');
      exit(0);
    }

    try {
      final changelogFile = File('CHANGELOG.md');
      var changelogContent =
          changelogFile.readAsStringSync().toUnixLineEndings();
      if (changelogContent.startsWith(newChangelog.toUnixLineEndings())) {
        print('✅ No new changes to update in CHANGELOG.md.');
        exit(0);
      }
      changelogContent =
          changelogContent.stripChangelogHeader().stripUnreleasedSection();
      changelogContent =
          '$newChangelog\n\n$changelogContent'.toWindowsLineEndings();
      changelogFile.writeAsStringSync(changelogContent);
      print('📝 Changelog updated successfully.');
      print('💡 To apply the update, stage and amend the commit:');
      print('   git add CHANGELOG.md');
      print('   git commit --amend -C HEAD --no-verify');
      exit(1);
    } catch (e) {
      print('🚨 Error updating changelog: $e');
      exit(1);
    }
  } else {
    print('🚨 Error updating changelog:\n\n${result.stdout}');
    exit(1);
  }
}

extension on String {
  String stripChangelogHeader() => replaceFirst(
        '''
# Changelog\n
All notable changes to this project will be documented in this file.\n
''',
        '',
      );

  String stripUnreleasedSection() {
    final start = indexOf('## [unreleased]');
    if (start == -1) return this;
    final end = indexOf('## [', start + 1);
    if (end == -1) return '';
    return substring(end);
  }

  String toUnixLineEndings() => replaceAll('\r\n', '\n');

  String toWindowsLineEndings() => replaceAll('\n', '\r\n');
}
