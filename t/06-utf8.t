use strict;
use warnings;
use EAV::XS;
use Test::More;
use open qw(:std :utf8);

my $testnum = 0;

my $eav = EAV::XS->new();
ok (defined $eav);

my @email_pass = (
    'иван@иванов.рф',
    'иван@localhost',
    'борис.борисович+tag@test.com',
    'user@نامهای.نامهای',
    'r2l@عربي.de',
    '微博@微博.微博',
    # valid domain
    'الجزائر@الجزائر.الجزائر',
    'test@hello.vermögensberater',
);

my @email_fail = (
    'иван@бездомена',
    'без-tld@xn--p1ai',
    '@ελ.ελ',
    '时尚@微博',
    # :) test domain
    'إختبار@إختبار.إختبار',
    'long-domain@ファッション.ファッション.ファッション.ファッション.ファッション.ファッション.ファッション.ファッション.ファッション.ファッション.ファッション.ファッション.ファッション.ファッション.ファッション.ファッション.ファッション',
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
