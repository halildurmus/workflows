import 'dart:io';

/// Extracts the latest release section from a Markdown-formatted CHANGELOG
/// file.
///
/// This function reads the CHANGELOG file at the specified [changelogPath] and
/// captures the content of the latest release section (i.e., the first section
/// starting with `## `).
///
/// For example, given the following `CHANGELOG.md` content:
/// ```markdown
/// # Changelog
///
/// All notable changes to this project will be documented in this file.
///
/// ## 1.0.0
///
/// - Initial stable release with major features.
///
/// ## 0.1.3
///
/// - Minor improvements and bug fixes.
/// ```
///
/// The output will be:
/// ```markdown
/// ## 1.0.0
///
/// - Initial stable release with major features.
/// ```
String extractLatestChangelog([String changelogPath = 'CHANGELOG.md']) {
  final changelogFile = File(changelogPath);
  final changelogContent = changelogFile
      .readAsStringSync()
      .toUnixLineEndings()
      .stripChangelogHeader();
  final start = changelogContent.indexOf(versionSectionPattern);
  if (start == -1) {
    throw const FormatException('No version section found in CHANGELOG.md');
  }

  final end = changelogContent.indexOf(versionSectionPattern, start + 1);
  if (end == -1) return changelogContent.trim();
  return changelogContent.substring(0, end).trim();
}

/// Regular expression to match version sections like `## 1.0.0`, `## [1.0.0]`,
/// or `## [1.0.0] - 2024-10-01`.
final versionSectionPattern = RegExp(
  r'^## \[?(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)'
  r'(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?'
  r'(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?\]?'
  r'( - \d{4}-\d{2}-\d{2})?$',
  multiLine: true,
);

extension on String {
  String stripChangelogHeader() => replaceFirst(
        '''
# Changelog\n
All notable changes to this project will be documented in this file.\n
''',
        '',
      );

  String toUnixLineEndings() => replaceAll('\r\n', '\n');
}

void main() => print(extractLatestChangelog());
