<?php
// Runs the LIVR test suite against packagist validator/livr.
// Comparison mirrors php-validator-livr's own tests (PHPUnit assertEquals),
// using the same comparator library: loose scalar comparison ("1" == 1),
// key order does not matter.

require __DIR__ . '/vendor/autoload.php';

use Composer\InstalledVersions;
use SebastianBergmann\Comparator\ComparisonFailure;
use SebastianBergmann\Comparator\Factory;

$suiteDir = getenv('TEST_SUITE_DIR') ?: __DIR__ . '/../../test_suite';
$suites   = ['positive', 'negative', 'aliases_positive', 'aliases_negative'];

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

function runCase($suite, $dir)
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
    $cases = array_values(array_filter(scandir("$suiteDir/$suite"), function ($n) {
        return $n[0] !== '.';
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
