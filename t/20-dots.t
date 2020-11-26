use strict;
use warnings;
use EAV::XS;
use Test::More;


my $testnum = 0;
my $eav = EAV::XS->new();

my @email_pass = (
    'abc.xyz@pass.com',
    '"abc."@pass.com',
    '"abc.".xyz@pass.com',
    '".xyz"@pass.com',
);

my @email_fail = (
    '.@fail.com',
    '..@fail.com',
    'abc.@fail.com',
    'abc..xyz@fail.com',
    'abc...xyz@fail.com',
    '.".xyz"@fail.com',
    'abc".xyz"@fail.com',
    'abc.."xyz"@fail.com',
);

for my $email (@email_pass) {
    ok ($eav->is_email($email), "pass: '" . $email . "'");
    $testnum++;
}

for my $email (@email_fail) {
    ok (! $eav->is_email($email), "fail: '" . $email . "'");
    $testnum++;
}

done_testing ($testnum);
