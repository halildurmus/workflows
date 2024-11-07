import 'dart:convert';
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
///
/// This function stops reading once it encounters the start of the next release
/// section.
String extractLatestChangelog([String changelogPath = 'CHANGELOG.md']) {
  final changelogContent = File(changelogPath).readAsStringSync();

  final latestRelease = StringBuffer();
  var isWithinLatestReleaseSection = false;

  for (final line in LineSplitter.split(changelogContent)) {
    if (line.startsWith('## ')) {
      // Stop after capturing the latest release section.
      if (isWithinLatestReleaseSection) break;
      isWithinLatestReleaseSection = true;
    }

    if (isWithinLatestReleaseSection) latestRelease.writeln(line);
  }

  return latestRelease.toString().trimRight();
}

void main() => print(extractLatestChangelog());
