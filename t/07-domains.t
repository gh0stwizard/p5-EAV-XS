use strict;
use warnings;
use EAV::XS;
use Test::More;


my $testnum = 0;

my $eav = EAV::XS->new();
ok (defined $eav);

my @email_pass = (
    'ok@test.aaa',
    'ok@дети.дети',
    'ok@ею.ею',
    'ok@қаз.қаз',
    'ok@קום.קום',
);

my @email_fail = (
    # test
    'test@测试.测试',
    'test@परीक्षा.परीक्षा',
    'test@испытание.испытание',
    'test@테스트.테스트',
    'test@טעסט.טעסט',
    'test@測試.測試',
    'test@آزمایشی.آزمایشی',
    'test@பரிட்சை.பரிட்சை',
    'test@δοκιμή.δοκιμή',
    'test@إختبار.إختبار',
    'test@テスト.テスト',
    # not assigned
    'na@test.bl',
    'na@test.bq',
    'na@test.eh',
    'na@test.mf',
    'na@test.ss',
    'na@test.um',
    'na@ಭಾರತ.ಭಾರತ',
    'na@ଭାରତ.ଭାରତ',
    'na@ভাৰত.ভাৰত',
    'na@भारतम्.भारतम्',
    'na@भारोत.भारोत',
    'na@بارت.بارت',
    'na@ڀارت.ڀارت',
    'na@ഭാരതം.ഭാരതം',
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
