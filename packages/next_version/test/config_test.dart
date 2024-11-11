import 'package:checks/checks.dart';
import 'package:next_version/next_version.dart';
import 'package:test/scaffolding.dart';

void main() {
  group('VersioningConfig', () {
    test('config with empty map throws ArgumentError', () {
      check(() => VersioningConfig(incrementByCommitType: const {}))
          .throws<ArgumentError>();
    });

    test('default config uses correct increments', () {
      const config = VersioningConfig.defaultConfig;
      check(config.incrementByCommitType).deepEquals({
        'feat': VersionIncrement.minor,
        'fix': VersionIncrement.patch,
        'perf': VersionIncrement.minor,
        'refactor': VersionIncrement.patch,
      });
    });
  });
}
