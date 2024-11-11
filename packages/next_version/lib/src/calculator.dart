import 'package:conventional_commit/conventional_commit.dart';
import 'package:version/version.dart';

import 'config.dart';
import 'increment.dart';

final class VersionCalculator {
  /// Calculates the next version based on the current version and a list of
  /// commit messages, applying the specified [config].
  ///
  /// If no conventional commits are found in the [commitMessages], the
  /// [currentVersion] is returned.
  static Version calculateNext(
    Version currentVersion,
    List<String> commitMessages,
    VersioningConfig config,
  ) {
    if (commitMessages.isEmpty) {
      throw ArgumentError.value(
        commitMessages,
        'commitMessages',
        'Commit messages cannot be empty.',
      );
    }

    final commits = commitMessages
        .map(ConventionalCommit.tryParse)
        .whereType<ConventionalCommit>()
        .toList();
    if (commits.isEmpty) return currentVersion;
    final versionIncrement = VersionIncrement.calculate(
      currentVersion,
      commits,
      config,
    );
    if (versionIncrement == null) return currentVersion;
    return versionIncrement.applyTo(currentVersion);
  }
}

extension VersionExtension on Version {
  /// Calculates the next version based on the current version and a list of
  /// commit messages, applying the specified [config].
  Version calculateNext(
    List<String> commitMessages, {
    VersioningConfig config = VersioningConfig.defaultConfig,
  }) =>
      VersionCalculator.calculateNext(this, commitMessages, config);
}
