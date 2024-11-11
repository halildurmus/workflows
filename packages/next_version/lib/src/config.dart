import 'increment.dart';

final class VersioningConfig {
  /// Creates a [VersioningConfig] instance with a map of commit types to
  /// version increments.
  ///
  /// The [incrementByCommitType] map should not be empty.
  VersioningConfig({required this.incrementByCommitType}) {
    if (incrementByCommitType.isEmpty) {
      throw ArgumentError.value(
        incrementByCommitType,
        'incrementByCommitType',
        'Map cannot be empty.',
      );
    }
  }

  const VersioningConfig._({required this.incrementByCommitType});

  /// Default configuration for versioning, using the following increments:
  /// - `feat`: [VersionIncrement.minor]
  /// - `fix`: [VersionIncrement.patch]
  /// - `perf`: [VersionIncrement.minor]
  /// - `refactor`: [VersionIncrement.patch]
  static const VersioningConfig defaultConfig = VersioningConfig._(
    incrementByCommitType: {
      'feat': VersionIncrement.minor,
      'fix': VersionIncrement.patch,
      'perf': VersionIncrement.minor,
      'refactor': VersionIncrement.patch,
    },
  );

  /// Maps commit types to version increments (e.g.,
  /// `feat` -> [VersionIncrement.minor]).
  final Map<String, VersionIncrement> incrementByCommitType;
}
