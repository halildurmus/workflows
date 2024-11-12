import 'dart:convert';
import 'dart:io';

import 'package:next_version/next_version.dart';
import 'package:yaml_edit/yaml_edit.dart';

void main(List<String> args) {
  final pubspecFile = File('pubspec.yaml');
  final pubspecContent = pubspecFile.readAsStringSync();
  final yamlEditor = YamlEditor(pubspecContent);
  final currentVersion = _getCurrentVersion(yamlEditor);
  final lastTag = _getLastGitTag();

  final commitMessages = _getCommitMessagesSince(lastTag);
  if (commitMessages.isEmpty) {
    print('✅ No new commits since the last tag.');
    return;
  }

  print('📜 Commit messages since the last tag:');
  commitMessages.forEach(print);

  final nextVersion = _calculateNextVersion(lastTag, commitMessages);
  final nextWipVersion = '$nextVersion-wip';
  if (nextWipVersion == currentVersion) {
    print('✅ No version bump required.');
    return;
  }

  print('🚀 Next WIP version: $nextWipVersion');
  _updatePubspecVersion(pubspecFile, yamlEditor, nextWipVersion);
}

String _getCurrentVersion(YamlEditor yamlEditor) {
  final versionNode =
      yamlEditor.parseAt(['version'], orElse: () => wrapAsYamlNode(null));
  if (versionNode.value == null) {
    _exitWithError('❌ "version" field not found in "pubspec.yaml".');
  }

  final currentVersion = versionNode.value as String;
  print('📦 Current version: $currentVersion');
  return currentVersion;
}

String _getLastGitTag() {
  final result = Process.runSync(
    'git',
    const ['describe', '--tags', '--abbrev=0'],
  );
  if (result.exitCode != 0) {
    _exitWithError('❌ Failed to retrieve the latest Git tag.');
  }
  return result.stdout.toString().trim();
}

List<String> _getCommitMessagesSince(String latestTag) {
  final result = Process.runSync(
    'git',
    ['log', '$latestTag..HEAD', '--pretty=format:%s'],
  );
  if (result.exitCode != 0) {
    _exitWithError('❌ Error retrieving commit messages.');
  }
  return LineSplitter.split(result.stdout.toString().trim()).toList();
}

Version _calculateNextVersion(String lastTag, List<String> commitMessages) {
  final lastPublishedVersion = Version.parse(lastTag.substring(1));
  final nextVersion = lastPublishedVersion.calculateNext(commitMessages);
  if (nextVersion == lastPublishedVersion) {
    print('✅ No version bump required.');
    exit(0);
  }
  return nextVersion;
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
    _exitWithError('❌ Error updating pubspec.yaml: $e');
  }
}

void _exitWithError(String message) {
  print(message);
  exit(1);
}
