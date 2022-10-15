use strict;
use warnings;
use open qw(:std :utf8);
use EAV::XS;
use Test::More;
# This is a workaround in case if the locale is not utf-8 compatable.
use POSIX qw(locale_h);
use locale;
# FIXME: see t/06-utf8.t for details, please.
setlocale(LC_ALL, "en_US.UTF-8") or do {
    if ($^O eq 'MSWin32') {
        diag("MSWin32: setlocale failed, as expected, continue ...");
    } else {
        die "failed to set locale";
    }
};

my $testnum = 0;

my $eav = EAV::XS->new();
ok (defined $eav, "new EAV::XS");


# This is a workaround for libidn. It depends on CHARSET environment
# variable ... no comments!!!
if (!$eav->is_email('иван@иванов.рф') &&
    $eav->get_error() eq 'Character encoding conversion error' &&
    !(exists($ENV{'CHARSET'}) && $ENV{'CHARSET'})) {
    diag('probably I have found libidn/CHARSET issue, trying to fix...');
    $ENV{'CHARSET'} = 'utf-8';
    $ENV{'CHARSET'} = 'UTF-8' if !$eav->is_email('иван@иванов.рф');
    delete $ENV{'CHARSET'} if !$eav->is_email('иван@иванов.рф');
}


# valid emails
{
    ok (open(my $fh, "<", 't/check-pass.txt'), "open t/check-pass.txt");

    while (<$fh>) {
        chomp();
        s/\r$//; # pff, cygwin...
        ok ($eav->is_email($_), "pass: " . $_);
        $testnum++;
    }

    ok (close ($fh));
}

# invalid emails
{
    ok (open(my $fh, "<", 't/check-fail.txt'), "open t/check-fail.txt");

    while (<$fh>) {
        chomp();
        s/\r$//;
#        diag("must fail: " . $_);
        my $test = $eav->is_email($_);

        if (/^idn2003/) {
            my $test = $eav->is_email($_);
            # This is a workaround for libidn (based on IDN2003).
            # The IDN2003 is allowing some unicode characters, while
            # IDN2008 and TR46 are not.
            if ($test) {
                diag("libidn workaround: $_\n");
                ok($test, "pass: " . $_);
            }
            else {
                ok (!$test, "fail: " . $_);
            }
        }
        else {
            ok (! $eav->is_email($_), "fail: " . $_);
        }
        $testnum++;
    }

    ok (close ($fh));
}

done_testing ($testnum + 5);
