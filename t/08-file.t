use strict;
use warnings;
use open qw(:std :utf8);
use EAV::XS;
use Test::More;


my $testnum = 0;

my $eav = EAV::XS->new();
ok (defined $eav, "new EAV::XS");

# valid emails
{
    ok (open(my $fh, "<", 't/check-pass.txt'), "open t/check-pass.txt");

    while (<$fh>) {
        chomp();
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
#        diag("must fail: " . $_);
        ok (! $eav->is_email($_), "fail: " . $_);
        $testnum++;
    }

    ok (close ($fh));
}

done_testing ($testnum + 5);
