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
    'user@ارامكو.ارامكو',
    'r2l@عربي.de',
    '微博@微博.微博',
    # valid domain
    'الجزائر@الجزائر.الجزائر',
    'ok@hello.vermögensberater',
    'ok@クラウド.クラウド',
    'ok@日本｡co｡jp',
);

my @email_fail = (
    'иван@бездомена',
    'no-tld@xn--p1ai',
    '@ελ.ελ',
    '时尚@微博',
    # :) test domain
    'إختبار@إختبار.إختبار',
    'long-domain@ファッション.ファッション.ファッション.ファッション.ファッション.ファッション.ファッション.ファッション.ファッション.ファッション.ファッション.ファッション.ファッション.ファッション.ファッション.ファッション.ファッション',
    'test-tld@إختبار.إختبار',
    'test-tld@آزمایشی.آزمایشی',
    'not-assinged@भारतम्.भारतम्',
    '{rfc20}@test',
    '#rfc20#@test',
    '^rfc20^@test',
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
