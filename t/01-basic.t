use strict;
use warnings;
use Test::More tests => 9;


BEGIN { use_ok ('EAV::XS') };

my @methods = (
    'new',
    'is_email',
    'get_error',
);

can_ok ('EAV::XS', @methods);

my $eav = EAV::XS->new();
ok (defined $eav);
ok ($eav->is_email ('valid@gh0stwizard.tk'));
ok ($eav->get_error() eq 'no error');

ok (! $eav->is_email ('invalid'));
ok ($eav->get_error() eq 'domain is empty');

no warnings 'uninitialized';
ok (! $eav->is_email (undef));
ok ($eav->get_error() eq 'empty email address');
