import 'package:checks/checks.dart';
import 'package:next_version/next_version.dart';
import 'package:test/scaffolding.dart';

void main() {
  group('VersionCalculator', () {
    test('applies major increment for breaking change on 1.x.x versions', () {
      final version = Version.parse('1.2.3');
      const commits = [
        'feat: add new feature',
        'fix: bug fix',
        '''
feat: breaking API change

BREAKING CHANGE: This is a breaking change.
'''
      ];
      final nextVersion = version.calculateNext(commits);
      check(nextVersion).equals(Version.parse('2.0.0'));
    });

    test('applies minor increment for breaking change on 0.x.x versions', () {
      final version = Version.parse('0.2.3');
      const commits = [
        '''
feat: breaking API change

BREAKING CHANGE: This is a breaking change.
'''
      ];
      final nextVersion = version.calculateNext(commits);
      check(nextVersion).equals(Version.parse('0.3.0'));
    });

    test('applies patch increment for non-breaking change on 0.x.x versions',
        () {
      final version = Version.parse('0.2.3');
      const commits = ['feat: add new feature'];
      final nextVersion = version.calculateNext(commits);
      check(nextVersion).equals(Version.parse('0.2.4'));
    });

    test('applies minor increment for feature commit on 1.x.x versions', () {
      final version = Version.parse('1.2.3');
      const commits = ['feat: add new feature'];
      final nextVersion = version.calculateNext(commits);
      check(nextVersion).equals(Version.parse('1.3.0'));
    });

    test('applies patch increment for fix commit on 1.x.x versions', () {
      final version = Version.parse('1.2.3');
      const commits = ['fix: bug fix'];
      final nextVersion = version.calculateNext(commits);
      check(nextVersion).equals(Version.parse('1.2.4'));
    });

    test('applies patch increment for fix commit on 0.x.x versions', () {
      final version = Version.parse('0.2.3');
      const commits = ['fix: bug fix'];
      final nextVersion = version.calculateNext(commits);
      check(nextVersion).equals(Version.parse('0.2.4'));
    });

    test('no increment for unrelated commits', () {
      final version = Version.parse('1.2.3');
      const commits = ['chore: clean up'];
      final nextVersion = version.calculateNext(commits);
      check(nextVersion).equals(version);
    });

    test('supports custom config to map new types', () {
      final version = Version.parse('1.2.3');
      const commits = ['docs: update README'];
      final config = VersioningConfig(
        incrementByCommitType: {'docs': VersionIncrement.patch},
      );
      final nextVersion = version.calculateNext(commits, config: config);
      check(nextVersion).equals(Version.parse('1.2.4'));
    });

    test('ignores commits not matching the config', () {
      final version = Version.parse('1.2.3');
      const commits = ['build: update dependencies'];
      final nextVersion = version.calculateNext(commits);
      check(nextVersion).equals(version);
    });

    test('throws ArgumentError on empty commit list', () {
      final version = Version.parse('1.2.3');
      check(() => version.calculateNext([])).throws<ArgumentError>();
    });

    test('pre-release increment on pre-release version', () {
      final version = Version.parse('1.2.3-alpha.1');
      const commits = ['fix: minor fix'];
      final config = VersioningConfig(
        incrementByCommitType: {'fix': VersionIncrement.preRelease},
      );
      final nextVersion = version.calculateNext(commits, config: config);
      check(nextVersion).equals(Version.parse('1.2.3-alpha.2'));
    });

    test('defaults to patch when no other increment type is applicable', () {
      final version = Version.parse('0.2.3');
      const commits = ['fix: typo fix'];
      final nextVersion = version.calculateNext(commits);
      check(nextVersion).equals(Version.parse('0.2.4'));
    });

    test('applies highest applicable increment from multiple commits', () {
      final version = Version.parse('1.2.3');
      const commits = [
        'fix: minor bug fix',
        'perf: improve performance',
        'feat: add new feature'
      ];
      final nextVersion = version.calculateNext(commits);
      check(nextVersion).equals(Version.parse('1.3.0'));
    });

    test('does not increment the version if no significant commit types', () {
      final version = Version.parse('1.2.3');
      const commits = ['docs: tweak documentation'];
      final nextVersion = version.calculateNext(commits);
      check(nextVersion).equals(Version.parse('1.2.3'));
    });
  });

  group('VersionExtension', () {
    test('calculateNext method increments version correctly', () {
      final version = Version.parse('1.2.3');
      const commits = ['feat: add new feature'];
      final nextVersion = version.calculateNext(commits);
      check(nextVersion).equals(Version.parse('1.3.0'));
    });

    test('calculateNext method respects custom config', () {
      final version = Version.parse('1.2.3');
      const commits = ['docs: update documentation'];
      final config = VersioningConfig(
        incrementByCommitType: {'docs': VersionIncrement.patch},
      );
      final nextVersion = version.calculateNext(commits, config: config);
      check(nextVersion).equals(Version.parse('1.2.4'));
    });
  });
}
