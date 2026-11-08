# Runs the LIVR test suite against CPAN Validator::LIVR.
# Comparison mirrors Validator-LIVR's own t/01-livr_test_suite.t (is_deeply):
# scalars are compared as strings, so 1 and "1" are equal.
use strict;
use warnings;

use JSON::PP;
use Scalar::Util qw/blessed/;

# LIVR 2.5: options.json {"now": "..."} fixes the current time of a case, as Validator-LIVR's own
# t/01-livr_test_suite.t does with Test::MockTime. It replaces "time" of the modules compiled after
# it, so it is loaded before Validator::LIVR. Without it the cases run with the system clock
my $has_mock_time;
BEGIN {
    $has_mock_time = eval {
        require Test::MockTime;
        Test::MockTime->import(qw/set_fixed_time restore_time/);
        1;
    };
}
use Validator::LIVR;

my $suite_dir = $ENV{TEST_SUITE_DIR} || '../../test_suite';
my @suites    = qw/positive negative aliases_positive aliases_negative/;
# LIVR 2.5: schemas that must not build
my $schema_errors = 'schema_errors';
push @suites, $schema_errors if -d "$suite_dir/$schema_errors";
my $json      = JSON::PP->new->utf8->canonical;

sub read_json {
    my ( $dir, $name ) = @_;
    my $file = "$dir/$name.json";
    return undef unless -e $file;
    open( my $fh, '<:raw', $file ) or die "Cannot open $file: $!";
    local $/;
    return $json->decode(<$fh>);
}

sub is_equal {
    my ( $x, $y ) = @_;
    return !defined $y if !defined $x;
    return 0 if !defined $y;

    $x = $$x + 0 if blessed($x) && $x->isa('JSON::PP::Boolean');
    $y = $$y + 0 if blessed($y) && $y->isa('JSON::PP::Boolean');

    my ( $rx, $ry ) = ( ref $x, ref $y );
    return 0 if $rx ne $ry;

    if ( $rx eq 'HASH' ) {
        return 0 if keys %$x != keys %$y;
        for my $k ( keys %$x ) {
            return 0 unless exists $y->{$k} && is_equal( $x->{$k}, $y->{$k} );
        }
        return 1;
    }
    if ( $rx eq 'ARRAY' ) {
        return 0 if @$x != @$y;
        for my $i ( 0 .. $#$x ) {
            return 0 unless is_equal( $x->[$i], $y->[$i] );
        }
        return 1;
    }
    return 0 if $rx;
    return "$x" eq "$y";
}

sub show {
    my $value = shift;
    my $s = defined $value ? eval { JSON::PP->new->canonical->allow_nonref->allow_blessed->convert_blessed->encode($value) } // "$value" : 'null';
    return length($s) > 300 ? substr( $s, 0, 300 ) . '...' : $s;
}

sub with_clock {
    my ( $options, $code ) = @_;
    return $code->() unless $has_mock_time && $options && defined $options->{now};

    # A datetime in UTC, as the cases have it: "2026-10-18T12:00:00Z"
    die qq{options.json: a wrong "now": $options->{now}\n}
        unless $options->{now} =~ /^\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d(?:\.\d+)?Z$/;
    ( my $now = $options->{now} ) =~ s/\.\d+Z$/Z/;

    Test::MockTime::set_fixed_time( $now, '%Y-%m-%dT%H:%M:%SZ' );
    my @result = eval { $code->() };
    my $error = $@;
    Test::MockTime::restore_time();
    die $error if $error;
    return $result[0];
}

# The case passes when building the validator dies: prepare(), or the first validation for a
# version without prepare()
sub run_schema_error_case {
    my $dir = shift;
    my $is_built = eval {
        my $validator = Validator::LIVR->new( read_json( $dir, 'rules' ) );
        $validator->register_aliased_rule($_) for @{ read_json( $dir, 'aliases' ) || [] };
        if   ( $validator->can('prepare') ) { $validator->prepare() }
        else                                { $validator->validate( {} ) }
        1;
    };
    return $is_built ? 'expected building the validator to fail' : undef;
}

sub run_case {
    my ( $suite, $dir ) = @_;
    my $run = $suite eq $schema_errors
        ? sub { run_schema_error_case($dir) }
        : sub { run_validation_case( $suite, $dir ) };
    return with_clock( read_json( $dir, 'options' ), $run );
}

sub run_validation_case {
    my ( $suite, $dir ) = @_;
    my $rules   = read_json( $dir, 'rules' );
    my $input   = read_json( $dir, 'input' );
    my $aliases = read_json( $dir, 'aliases' ) || [];

    my $validator = Validator::LIVR->new($rules);
    $validator->register_aliased_rule($_) for @$aliases;

    my $output = $validator->validate($input);
    my $errors = $validator->get_errors();

    if ( $suite =~ /positive$/ ) {
        my $expected = read_json( $dir, 'output' );
        return 'expected no errors, got ' . show($errors) if $errors;
        return 'expected output ' . show($expected) . ', got ' . show($output)
            unless is_equal( $output, $expected );
    }
    else {
        my $expected = read_json( $dir, 'errors' );
        return 'expected validation to fail, got output ' . show($output) if $output;
        return 'expected errors ' . show($expected) . ', got ' . show($errors)
            unless is_equal( $errors, $expected );
    }
    return undef;
}

my %result = (
    id       => 'perl',
    package  => 'Validator::LIVR',
    version  => "$Validator::LIVR::VERSION",
    source   => 'cpan',
    total    => 0,
    passed   => 0,
    failures => [],
    error    => undef,
);

for my $suite (@suites) {
    opendir( my $dh, "$suite_dir/$suite" ) or die "Cannot open $suite_dir/$suite: $!";
    my @cases = sort grep { !/^\./ && -d "$suite_dir/$suite/$_" } readdir $dh;
    closedir $dh;

    for my $name (@cases) {
        $result{total}++;
        my $message = eval { run_case( $suite, "$suite_dir/$suite/$name" ) };
        if ($@) {
            ( $message = "exception: $@" ) =~ s/\s+$//;
        }
        if ( defined $message ) {
            push @{ $result{failures} }, { case => "$suite/$name", message => $message };
        }
        else {
            $result{passed}++;
        }
    }
}

my $out = JSON::PP->new->utf8->canonical->pretty->encode( \%result );
if ( $ENV{OUT_FILE} ) {
    open( my $fh, '>:raw', $ENV{OUT_FILE} ) or die "Cannot write $ENV{OUT_FILE}: $!";
    print $fh $out;
    close $fh;
}
else {
    print $out;
}
