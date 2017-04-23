use strict;
use warnings;
use Test::More tests => 9;


BEGIN { use_ok ('EAV::XS') };

my @methods = (
    'new',
    'is_email',
    'error',
);

can_ok ('EAV::XS', @methods);

my $eav = EAV::XS->new();
ok (defined $eav);
ok ($eav->is_email ('valid@gh0stwizard.tk'));
ok ($eav->error() eq 'no error');

ok (! $eav->is_email ('invalid'));
ok ($eav->error() eq 'domain is empty');

no warnings 'uninitialized';
ok (! $eav->is_email (undef));
ok ($eav->error() eq 'empty email address');
