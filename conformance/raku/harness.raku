# Runs the LIVR test suite against the Raku "LIVR" distribution (zef).
# Comparison mirrors perl6-livr's own t/01-livr-test-suite.t (is-deeply, i.e. eqv
# on data decoded by JSON::Tiny): strict, value types matter, key order does not.
use JSON::Tiny;
use LIVR;

my $suite-dir = %*ENV<TEST_SUITE_DIR> // '../../test_suite';
my @suites = <positive negative aliases_positive aliases_negative>;

sub read-json($dir, $name) {
    my $file = "$dir/$name.json".IO;
    $file.e ?? from-json($file.slurp) !! Any;
}

sub show($value) {
    my $s = try { to-json($value) } // $value.raku;
    $s.chars > 300 ?? $s.substr(0, 300) ~ '…' !! $s;
}

sub run-case($suite, $dir) {
    my $rules   = read-json($dir, 'rules');
    my $input   = read-json($dir, 'input');
    my $aliases = read-json($dir, 'aliases') // [];

    my $validator = LIVR::Validator.new(livr-rules => $rules);
    $validator.register-aliased-rule($_) for @$aliases;

    my $output = $validator.validate($input);
    my $errors = $validator.errors;

    if $suite.ends-with('positive') {
        my $expected = read-json($dir, 'output');
        return "expected no errors, got {show($errors)}" if $errors;
        return "expected output {show($expected)}, got {show($output)}" unless $output eqv $expected;
    }
    else {
        my $expected = read-json($dir, 'errors');
        return "expected validation to fail, got output {show($output)}" if $output;
        return "expected errors {show($expected)}, got {show($errors)}" unless $errors eqv $expected;
    }
    return Nil;
}

my $dist = $*REPO.resolve(CompUnit::DependencySpecification.new(:short-name<LIVR>)).distribution;

my %result =
    id       => 'raku',
    package  => 'LIVR',
    version  => ~($dist.meta<ver> // $dist.meta<version>),
    source   => 'zef',
    total    => 0,
    passed   => 0,
    failures => [],
    error    => Nil;

for @suites -> $suite {
    for dir("$suite-dir/$suite").map(*.basename).grep(!*.starts-with('.')).sort -> $name {
        %result<total>++;
        my $message = try run-case($suite, "$suite-dir/$suite/$name");
        $message = "exception: {$!.^name}: {$!.message.lines.head}" if $!;
        if $message.defined {
            %result<failures>.push: { case => "$suite/$name", message => $message };
        }
        else {
            %result<passed>++;
        }
    }
}

my $out = to-json(%result) ~ "\n";
with %*ENV<OUT_FILE> { .IO.spurt($out) } else { print $out }
