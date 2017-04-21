use strict;
use warnings;
use EAV::XS;
use Test::More;


my $testnum = 0;

my $eav = EAV::XS->new();
ok (defined $eav);

my @email_pass = (
    'test@localhost',
    'test@abc.invalid',
    'test@abc.test',
    'test@example.com',
    'abc+def@gmail.com',
    '"space in quote"@allowed.org',
    '"very.unusual.@.unusual.com"@ok.com',
    '"very.(),:;<>[]\".VERY.\"very@\\ \"very\".unusual"@strange.example.com',
    'example-indeed@strange-example.com',
    '" "@example.org',
    'example@s.solutions',
);

my @email_fail = (
    '',
    '@',
    '@@',
    'a@',
    '@b.com',
    'test.com',
    ' abc@space.before.com',
    'abc @space.after.com',
    '   tab@before.me',
    'tab    @after.me',
    'numeric@1234',
    'all-numeric@123.456',
    'admin@no-tld',
    # at the moment, by default libeav conforms to RFC20 & RFC6321:
    # characters like '#', '~', '{', '}', '|' should not be used
    # in international exchanges.
    # (may be it will be changed in future)
    '#!$%&\'*+-/=?^_`{}|~@example.org', 
    'no-fqdn@com',
);

for my $email (@email_pass) {
    ok ($eav->is_email($email), "pass: '" . $email . "'");
    $testnum++;
}

for my $email (@email_fail) {
    ok (! $eav->is_email($email), "fail: '" . $email . "'");
    $testnum++;
}

done_testing ($testnum + 1);
