import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final gitCliffArgs = ['changelog', '--unreleased', ...args];
  final result =
      Process.runSync('git-cliff', gitCliffArgs, stdoutEncoding: utf8);
  if (result.exitCode != 0) {
    print('🚨 Error generating changelog:');
    if (result.stdout case final String stdout when stdout.isNotEmpty) {
      print(stdout);
    }
    if (result.stderr case final String stderr when stderr.isNotEmpty) {
      print(stderr);
    }
    exit(result.exitCode);
  }

  final newChangelog = result.stdout.toString().toUnixLineEndings().trim();
  if (!newChangelog.contains('## [')) {
    print('✅ No new changes to update in CHANGELOG.md.');
    exit(0);
  }

  _updateChangelog(newChangelog);
}

void _updateChangelog(String newChangelog) {
  try {
    final changelogFile = File('CHANGELOG.md');
    var changelogContent = changelogFile.readAsStringSync().toUnixLineEndings();
    if (changelogContent.startsWith(newChangelog)) {
      print('✅ No new changes to update in CHANGELOG.md.');
      exit(0);
    }

    changelogContent =
        changelogContent.stripChangelogHeader().stripUnreleasedSection();
    changelogContent =
        '$newChangelog\n\n$changelogContent'.toPlatformLineEndings();

    changelogFile.writeAsStringSync(changelogContent);
    print('📝 Changelog updated successfully.');
  } catch (e) {
    print('🚨 Error updating changelog: $e');
    exit(1);
  }
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
