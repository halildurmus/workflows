import 'package:next_version/next_version.dart';

void main(List<String> args) {
  final currentVersion =
      args.isEmpty ? Version.parse('1.2.3') : Version.parse(args.first);
  final commits = args.isEmpty
      ? const ['feat: add a new feature', 'fix: resolve an issue']
      : args.skip(1).join(' ').split(', ');
  print('Commits:');
  for (final c in commits) {
    print(' - $c');
  }
  final nextVersion = currentVersion.calculateNext(commits);
  print('Next version: $nextVersion');
}
