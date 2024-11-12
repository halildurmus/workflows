import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  // Define the git cliff arguments.
  const gitCliffArgs = ['cliff', 'changelog', '--unreleased'];

  // Run the git cliff changelog command.
  final result = Process.runSync('git', gitCliffArgs, stdoutEncoding: utf8);
  // Handle changelog result.
  if (result.exitCode != 0) {
    _exitWithError('🚨 Error generating changelog:\n${result.stdout}');
  }

  final newChangelog = result.stdout.toString().toUnixLineEndings().trim();
  if (!newChangelog.contains('## [unreleased]')) {
    print('✅ No new changes to update in CHANGELOG.md.');
    exit(0);
  }

  _updateChangelog(newChangelog);
}

void _updateChangelog(String newChangelog) {
  try {
    final changelogFile = File('CHANGELOG.md');
    var changelogContent = changelogFile.readAsStringSync().toUnixLineEndings();
    // Check if new changelog is already present at the start of the file.
    if (changelogContent.startsWith(newChangelog)) {
      print('✅ No new changes to update in CHANGELOG.md.');
      exit(0);
    }

    // Clean up the changelog content and add the new changelog.
    changelogContent =
        changelogContent.stripChangelogHeader().stripUnreleasedSection();
    changelogContent =
        '$newChangelog\n\n$changelogContent'.toPlatformLineEndings();

    // Write the updated changelog to the file.
    changelogFile.writeAsStringSync(changelogContent);
    print('📝 Changelog updated successfully.');
    print('💡 To apply the update, stage and amend the commit:');
    print('   git add CHANGELOG.md');
    print('   git commit --amend -C HEAD --no-verify');
    exit(1);
  } catch (e) {
    _exitWithError('🚨 Error updating changelog: $e');
  }
}

void _exitWithError(String message) {
  print(message);
  exit(1);
}

extension on String {
  String stripChangelogHeader() => replaceFirst(
        '''
# Changelog

All notable changes to this project will be documented in this file.

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

  String toPlatformLineEndings() =>
      Platform.isWindows ? toWindowsLineEndings() : toUnixLineEndings();

  String toUnixLineEndings() => replaceAll('\r\n', '\n');

  String toWindowsLineEndings() => replaceAllMapped(
        '\n',
        (match) {
          final start = match.start;
          // Ensure we don't go out of bounds when checking for preceding '\r'.
          if (start > 0 && match.input[start - 1] == '\r') return '\n';
          return '\r\n';
        },
      );
}
