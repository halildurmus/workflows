import 'package:next_version/next_version.dart';

void main(List<String> args) {
  final commits = args.isEmpty
      ? const ['feat: add a new feature', 'fix: resolve an issue']
      : args.join(' ').split(', ');
  print('Commits:');
  for (final c in commits) {
    print(' - $c');
  }
  final currentVersion = Version.parse('1.2.3');
  final nextVersion = currentVersion.calculateNext(commits);
  print('Next version: $nextVersion');
}
