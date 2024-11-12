import 'dart:convert';
import 'dart:io';

import 'package:next_version/next_version.dart';
import 'package:yaml_edit/yaml_edit.dart';

void main(List<String> args) {
  final pubspecFile = File('pubspec.yaml');
  final pubspecContent = pubspecFile.readAsStringSync();
  final yamlEditor = YamlEditor(pubspecContent);

  // Retrieve the current version from pubspec.yaml.
  final versionNode =
      yamlEditor.parseAt(['version'], orElse: () => wrapAsYamlNode(null));
  if (versionNode.value == null) {
    print('❌ "version" field not found in "pubspec.yaml".');
    exit(1);
  }

  final currentVersion = versionNode.value;
  print('📦 Current version: $currentVersion');

  // Get the latest Git tag.
  final lastTag = _getLastGitTag();
  if (lastTag == null) {
    print('❌ Failed to retrieve the latest Git tag.');
    exit(1);
  }
  print('🔖 Last tag: $lastTag');

  // Get the commit messages since the last tag.
  final commitMessages = _getCommitMessagesSince(lastTag);
  if (commitMessages == null) {
    print('❌ Error retrieving commit messages.');
    exit(1);
  }

  if (commitMessages.isEmpty) {
    // If no new commits, exit with success.
    print('✅ No new commits since the last tag.');
    exit(0);
  } else {
    // Display commit messages.
    print('📜 Commit messages since the last tag:');
    commitMessages.forEach(print);
  }

  // Calculate the next version based on the last tag and commit messages since.
  final nextVersion =
      '${Version.parse(lastTag.substring(1)).calculateNext(commitMessages)}-wip';
  print('🚀 Next version: $nextVersion');

  // If no changes in the version, exit with success.
  if (nextVersion == currentVersion) {
    print('✅ No version bump required.');
    exit(0);
  }

  // Update the version in pubspec.yaml with the next version.
  _updatePubspecVersion(pubspecFile, yamlEditor, nextVersion);
}

String? _getLastGitTag() {
  final result =
      Process.runSync('git', const ['describe', '--tags', '--abbrev=0']);
  if (result.exitCode != 0) return null;
  return result.stdout.toString().trim();
}

List<String>? _getCommitMessagesSince(String latestTag) {
  final result = Process.runSync(
    'git',
    ['log', '$latestTag..HEAD', '--pretty=format:%s'],
  );
  if (result.exitCode != 0) return null;
  return LineSplitter.split(result.stdout.toString().trim()).toList();
}

void _updatePubspecVersion(
  File pubspecFile,
  YamlEditor yamlEditor,
  String nextVersion,
) {
  try {
    yamlEditor.update(['version'], nextVersion);
    pubspecFile.writeAsStringSync(yamlEditor.toString());
    print('📦 Updated version in pubspec.yaml to: $nextVersion');
    print('💡 To apply the update, stage and amend the commit:');
    print('   git add pubspec.yaml');
    print('   git commit --amend -C HEAD --no-verify');
    exit(1);
  } catch (e) {
    print('❌ Error updating pubspec.yaml: $e');
    exit(1);
  }
}
