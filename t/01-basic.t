use strict;
use warnings;
use Test::More tests => 6;


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

ok (! $eav->is_email ('invalid'));
ok ($eav->error() =~ /no domain part/);
