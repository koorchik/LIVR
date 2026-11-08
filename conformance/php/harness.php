<?php
// Runs the LIVR test suite against packagist validator/livr.
// Comparison mirrors php-validator-livr's own tests (PHPUnit assertEquals),
// using the same comparator library: loose scalar comparison ("1" == 1),
// key order does not matter.

require __DIR__ . '/vendor/autoload.php';
require __DIR__ . '/clock.php';

use Composer\InstalledVersions;
use SebastianBergmann\Comparator\ComparisonFailure;
use SebastianBergmann\Comparator\Factory;

$suiteDir = getenv('TEST_SUITE_DIR') ?: __DIR__ . '/../../test_suite';
$suites   = ['positive', 'negative', 'aliases_positive', 'aliases_negative'];
// LIVR 2.5: schemas that must not build
$schemaErrors = 'schema_errors';
if (is_dir("$suiteDir/$schemaErrors")) {
    $suites[] = $schemaErrors;
}

function readJson($dir, $name)
{
    $file = "$dir/$name.json";
    return file_exists($file) ? json_decode(file_get_contents($file), true) : null;
}

function isEqual($expected, $actual)
{
    try {
        Factory::getInstance()->getComparatorFor($expected, $actual)->assertEquals($expected, $actual);
        return true;
    } catch (ComparisonFailure $e) {
        return false;
    }
}

function show($value)
{
    $s = json_encode($value, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    if ($s === false) {
        $s = var_export($value, true);
    }
    return strlen($s) > 300 ? substr($s, 0, 300) . '...' : $s;
}

// LIVR 2.5: options.json {"now": "..."} is the current time for the bounds today, yesterday and
// tomorrow, set for the case (clock.php) and restored after it
function withClock($options, $fn)
{
    if (!is_array($options) || !array_key_exists('now', $options)) {
        return $fn();
    }
    LivrHarnessClock::$now = (new DateTimeImmutable($options['now']))->getTimestamp();
    try {
        return $fn();
    } finally {
        LivrHarnessClock::$now = null;
    }
}

function runSchemaErrorCase($dir)
{
    try {
        $validator = new Validator\LIVR(readJson($dir, 'rules'));
        foreach (readJson($dir, 'aliases') ?: [] as $alias) {
            $validator->registerAliasedRule($alias);
        }
        if (method_exists($validator, 'prepare')) {
            $validator->prepare();
        } else {
            $validator->validate([]);
        }
    } catch (Throwable $e) {
        return null;
    }
    return 'expected building the validator to fail';
}

function runCase($suite, $dir)
{
    return withClock(readJson($dir, 'options'), function () use ($suite, $dir) {
        return $suite === 'schema_errors' ? runSchemaErrorCase($dir) : runValidationCase($suite, $dir);
    });
}

function runValidationCase($suite, $dir)
{
    $rules   = readJson($dir, 'rules');
    $input   = readJson($dir, 'input');
    $aliases = readJson($dir, 'aliases') ?: [];

    $validator = new Validator\LIVR($rules);
    foreach ($aliases as $alias) {
        $validator->registerAliasedRule($alias);
    }

    $output = $validator->validate($input);
    $errors = $validator->getErrors();

    if (substr($suite, -8) === 'positive') {
        $expected = readJson($dir, 'output');
        if ($errors) {
            return 'expected no errors, got ' . show($errors);
        }
        if (!isEqual($expected, $output)) {
            return 'expected output ' . show($expected) . ', got ' . show($output);
        }
    } else {
        $expected = readJson($dir, 'errors');
        if ($output) {
            return 'expected validation to fail, got output ' . show($output);
        }
        if (!isEqual($expected, $errors)) {
            return 'expected errors ' . show($expected) . ', got ' . show($errors);
        }
    }
    return null;
}

$version   = InstalledVersions::getPrettyVersion('validator/livr');
$reference = InstalledVersions::getReference('validator/livr');
if ($reference && strpos($version, 'dev-') === 0) {
    $version .= '@' . substr($reference, 0, 7);
}

$result = [
    'id'       => 'php',
    'package'  => 'validator/livr',
    'version'  => $version,
    'source'   => 'packagist',
    'total'    => 0,
    'passed'   => 0,
    'failures' => [],
    'error'    => null,
];

foreach ($suites as $suite) {
    $cases = array_values(array_filter(scandir("$suiteDir/$suite"), function ($n) use ($suiteDir, $suite) {
        return $n[0] !== '.' && is_dir("$suiteDir/$suite/$n");
    }));
    sort($cases);

    foreach ($cases as $name) {
        $result['total']++;
        try {
            $message = runCase($suite, "$suiteDir/$suite/$name");
        } catch (Throwable $e) {
            $message = 'exception: ' . get_class($e) . ': ' . $e->getMessage();
        }
        if ($message !== null) {
            $result['failures'][] = ['case' => "$suite/$name", 'message' => $message];
        } else {
            $result['passed']++;
        }
    }
}

$out = json_encode($result, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES) . "\n";
if (getenv('OUT_FILE')) {
    file_put_contents(getenv('OUT_FILE'), $out);
} else {
    echo $out;
}
