// Runs the LIVR test suite against the Dart "livr" package.
// Comparison mirrors the package's own test runner (package:test `equals`):
// deep equality, key order does not matter, value types matter ('1' is not 1),
// except that numbers compare by value, like in Dart (10 equals 10.0).
import 'dart:convert';
import 'dart:io';

import 'package:livr/livr.dart';

final String suiteDir =
    Platform.environment['TEST_SUITE_DIR'] ?? '../../test_suite';
const List<String> suites = [
  'positive',
  'negative',
  'aliases_positive',
  'aliases_negative',
];
// LIVR 2.5: schemas that must not build
const String schemaErrors = 'schema_errors';

Object? readJson(String dir, String name) {
  final file = File('$dir/$name.json');
  return file.existsSync() ? jsonDecode(file.readAsStringSync()) : null;
}

bool deepEqual(Object? a, Object? b) {
  if (a is Map && b is Map) {
    return a.length == b.length &&
        a.keys.every((key) => b.containsKey(key) && deepEqual(a[key], b[key]));
  }
  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!deepEqual(a[i], b[i])) return false;
    }
    return true;
  }
  if (a is Map || b is Map || a is List || b is List) return false;
  return a == b;
}

String show(Object? value) {
  final str = jsonEncode(value);
  return str.length > 300 ? '${str.substring(0, 300)}…' : str;
}

// LIVR 2.5: options.json {"now": "..."} is the current time of the bounds
// today, yesterday and tomorrow. livr 0.2.0+ takes a clock, `now:`; older
// versions have no such argument (checked by the type of the function), then
// the case runs with the system time
typedef _UntypedWithNow = Object? Function(
  Map<Object?, Object?> schema, {
  Iterable<LivrAlias>? aliases,
  DateTime Function()? now,
});

Validator<Map<String, Object?>> buildValidator(String dir) {
  final rules = readJson(dir, 'rules') as Map<String, Object?>;
  final aliases = [
    for (final alias
        in (readJson(dir, 'aliases') as List<Object?>?) ?? const [])
      LivrAlias.fromJson(alias as Map<String, Object?>),
  ];
  final now = (readJson(dir, 'options') as Map<String, Object?>?)?['now'];
  if (now == null) return Validator.untyped(rules, aliases: aliases);

  final fixedNow = DateTime.parse(now as String);
  const Object untyped = Validator.untyped;
  if (untyped is! _UntypedWithNow) {
    return Validator.untyped(rules, aliases: aliases);
  }
  return untyped(rules, aliases: aliases, now: () => fixedNow)
      as Validator<Map<String, Object?>>;
}

// The validator checks the schema when it is created
String? runSchemaErrorCase(String dir) {
  try {
    buildValidator(dir);
  } catch (e) {
    return null;
  }
  return 'expected building the validator to fail';
}

String? runCase(String suite, String dir) {
  if (suite == schemaErrors) return runSchemaErrorCase(dir);

  final validator = buildValidator(dir);
  final result = validator.validate(readJson(dir, 'input'));

  if (suite.endsWith('positive')) {
    final expected = readJson(dir, 'output');
    return switch (result) {
      ValidationFailure(:final errors) =>
        'expected no errors, got ${show(errors)}',
      ValidationSuccess(:final output) when !deepEqual(output, expected) =>
        'expected output ${show(expected)}, got ${show(output)}',
      _ => null,
    };
  }

  final expected = readJson(dir, 'errors');
  return switch (result) {
    ValidationSuccess(:final output) =>
      'expected validation to fail, got output ${show(output)}',
    ValidationFailure(:final errors) when !deepEqual(errors, expected) =>
      'expected errors ${show(expected)}, got ${show(errors)}',
    _ => null,
  };
}

// The version of livr from the package config that `dart run` uses
String? packageVersion() {
  final config = jsonDecode(
    File('.dart_tool/package_config.json').readAsStringSync(),
  ) as Map<String, Object?>;
  for (final package in config['packages'] as List<Object?>) {
    package as Map<String, Object?>;
    if (package['name'] != 'livr') continue;

    // rootUri is relative to .dart_tool/ and has no trailing slash
    final rootUri = package['rootUri'] as String;
    final root = Uri.parse('${Directory.current.uri}.dart_tool/')
        .resolve(rootUri.endsWith('/') ? rootUri : '$rootUri/');
    final pubspec = File.fromUri(root.resolve('pubspec.yaml'));
    final match = RegExp(
      r'^version:\s*(\S+)',
      multiLine: true,
    ).firstMatch(pubspec.readAsStringSync());
    return match?[1];
  }
  return null;
}

void main() {
  final failures = <Map<String, String>>[];
  var total = 0;

  final allSuites = [
    ...suites,
    if (Directory('$suiteDir/$schemaErrors').existsSync()) schemaErrors,
  ];
  for (final suite in allSuites) {
    final dirs =
        Directory('$suiteDir/$suite')
            .listSync()
            .whereType<Directory>()
            .map((dir) => dir.uri.pathSegments.lastWhere((s) => s.isNotEmpty))
            .where((name) => !name.startsWith('.'))
            .toList()
          ..sort();

    for (final name in dirs) {
      total++;
      String? message;
      try {
        message = runCase(suite, '$suiteDir/$suite/$name');
      } catch (e) {
        message = 'exception: $e';
      }
      if (message != null) {
        failures.add({'case': '$suite/$name', 'message': message});
      }
    }
  }

  // A version from a repository checkout also has the commit: 0.1.0@abc1234
  final rev = Platform.environment['LIVR_REV'] ?? '';
  final version = packageVersion();
  final result = {
    'id': 'dart',
    'package': 'livr',
    'version': version == null || rev.isEmpty ? version : '$version@$rev',
    'source': Platform.environment['SOURCE'] ?? 'pub',
    'total': total,
    'passed': total - failures.length,
    'failures': failures,
    'error': null,
  };
  final json = '${const JsonEncoder.withIndent('  ').convert(result)}\n';

  final outFile = Platform.environment['OUT_FILE'];
  if (outFile != null) {
    File(outFile).writeAsStringSync(json);
  } else {
    stdout.write(json);
  }
}
