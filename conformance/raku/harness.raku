# Runs the LIVR test suite against the Raku "LIVR" distribution (zef).
# Comparison mirrors perl6-livr's own t/01-livr-test-suite.t (is-deeply, i.e. eqv
# on data decoded by JSON::Tiny): strict, value types matter, key order does not.
use JSON::Tiny;
use LIVR;

my $suite-dir = %*ENV<TEST_SUITE_DIR> // '../../test_suite';
my @suites = <positive negative aliases_positive aliases_negative>;
# LIVR 2.5: schemas that must not build
my $schema-errors = 'schema_errors';
@suites.push($schema-errors) if "$suite-dir/$schema-errors".IO.d;

sub read-json($dir, $name) {
    my $file = "$dir/$name.json".IO;
    $file.e ?? from-json($file.slurp) !! Any;
}

sub show($value) {
    my $s = try { to-json($value) } // $value.raku;
    $s.chars > 300 ?? $s.substr(0, 300) ~ '…' !! $s;
}

# LIVR 2.5: options.json {"now": "2026-10-18T12:00:00Z"} fixes the current time of a case, as
# perl6-livr's own t/01-livr-test-suite.t does: "time" is wrapped while the case runs. A version
# that reads the clock otherwise runs the case with the system clock
sub with-clock($options, &code) {
    return code() unless $options ~~ Associative && $options<now>.defined;
    return fixed-clock($options<now>, &code);
}

sub fixed-clock($now, &code) {
    my $posix = DateTime.new($now).posix;
    my $handle = &term:<time>.wrap({ $posix });
    LEAVE $handle.restore;

    return code();
}

# The case passes when building the validator dies: prepare(), or the first validation for a
# version without prepare()
sub run-schema-error-case($dir) {
    my $is-built = try {
        my $validator = LIVR::Validator.new(livr-rules => read-json($dir, 'rules'));
        $validator.register-aliased-rule($_) for @(read-json($dir, 'aliases') // []);
        $validator.can('prepare') ?? $validator.prepare !! $validator.validate({});
        True;
    };
    return $is-built ?? 'expected building the validator to fail' !! Nil;
}

sub run-case($suite, $dir) {
    my &run = $suite eq $schema-errors
        ?? { run-schema-error-case($dir) }
        !! { run-validation-case($suite, $dir) };
    return with-clock(read-json($dir, 'options'), &run);
}

sub run-validation-case($suite, $dir) {
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
    for dir("$suite-dir/$suite").grep(*.d).map(*.basename).grep(!*.starts-with('.')).sort -> $name {
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
