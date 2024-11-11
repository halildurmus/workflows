import 'package:conventional_commit/conventional_commit.dart';
import 'package:version/version.dart';

import 'config.dart';

/// Specifies the type of version increment to be applied based on commit type
/// or other criteria.
enum VersionIncrement {
  /// A major increment, typically applied when there are breaking changes that
  /// are not backward-compatible.
  ///
  /// This resets the minor and patch numbers to zero (e.g.,
  /// `1.2.3` -> `2.0.0`).
  major,

  /// A minor increment, usually applied when adding new, backward-compatible
  /// features or significant improvements that don’t introduce breaking
  /// changes.
  ///
  /// This resets the patch number to zero (e.g., `1.2.3` -> `1.3.0`).
  minor,

  /// A patch increment, generally applied for backward-compatible bug fixes or
  /// minor improvements that do not affect the API or add new features
  /// (e.g., `1.2.3` -> `1.2.4`).
  patch,

  /// A pre-release increment, applied for creating a pre-release version.
  ///
  /// Often used to release versions that are not fully stable (e.g.,
  /// `1.2.3` -> `1.2.4-beta`).
  preRelease;

  /// Determines the appropriate version increment type based on the current
  /// version ([currentVersion]), a list of commits ([commits]), and the rules
  /// defined in the provided [config].
  ///
  /// Versioning Rules:
  ///
  /// - **Pre-1.0 Versions (0.x.x)**:
  ///   - If there are any breaking changes, treats them as a _minor_ increment
  ///     (e.g., `0.2.3` -> `0.3.0`).
  ///   - For non-breaking changes, increments the patch version only
  ///     (e.g., `0.2.3` -> `0.2.4`), regardless of commit type.
  ///
  /// - **Stable Versions (1.x.x and above)**:
  ///   - If a breaking change is detected, returns a _major_ increment.
  ///   - For non-breaking changes, the highest priority increment among the
  ///     commit types is chosen, where `major > minor > patch > preRelease`.
  ///
  /// Returns `null` if no increment is required.
  ///
  /// Throws an [ArgumentError] if [commits] is empty.
  static VersionIncrement? calculate(
    Version currentVersion,
    List<ConventionalCommit> commits,
    VersioningConfig config,
  ) {
    if (commits.isEmpty) {
      throw ArgumentError.value(commits, 'commits', 'Commits cannot be empty.');
    }

    // Check for any breaking changes and handle according to version rules.
    if (commits.any((commit) => commit.isBreakingChange)) {
      return _handleBreakingChange(currentVersion);
    }

    // Collect all increments based on commit types.
    final increments = commits
        .map((commit) => config.incrementByCommitType[commit.type])
        .whereType<VersionIncrement>()
        .toList();
    if (increments.isEmpty) return null;

    // In `0.x.x` versions, only increment the patch version regardless of
    // commit types.
    if (currentVersion.major == 0) return VersionIncrement.patch;

    // Return the highest priority increment.
    return increments.reduce(_higherPriorityIncrement);
  }

  /// Handles breaking changes based on the given [version].
  ///
  /// For `0.x.x` versions, returns [minor], otherwise returns [major].
  static VersionIncrement _handleBreakingChange(Version version) =>
      version.major == 0 ? VersionIncrement.minor : VersionIncrement.major;

  /// Determines which increment has higher priority, with [major] taking
  /// precedence, followed by [minor], then [patch], and finally [preRelease].
  static VersionIncrement _higherPriorityIncrement(
    VersionIncrement a,
    VersionIncrement b,
  ) =>
      a.index < b.index ? a : b;

  /// Applies the increment type to the given [version].
  Version applyTo(Version version) => switch (this) {
        VersionIncrement.major => version.incrementMajor(),
        VersionIncrement.minor => version.incrementMinor(),
        VersionIncrement.patch => version.incrementPatch(),
        VersionIncrement.preRelease => version.incrementPreRelease(),
      };
}
