package EAV::XS;

use strict;
use warnings;

our $VERSION = eval '0.1.0';

require XSLoader;
XSLoader::load('EAV::XS', $VERSION);

1;
__END__

=pod

=encoding utf-8

=head1 NAME

EAV::XS - Email Address Validator

=head1 SYNOPSIS

    use EAV::XS;

    my $eav = EAV::XS->new();

    if ($eav->is_email ('valid@example.com')) {
        print "This is a valid email address.\n";
    } else {
        printf "The email address is not valid: %s\n",
                $eav->error();
    }

=head1 DESCRIPTION

The purpose of this module is a validation of the specified
L<Email Address|https://en.wikipedia.org/wiki/Email_address>.

The core part of the module is written in C and can be
found L<here|https://github.com/gh0stwizard/libeav>.

At the moment this module conforms to
L<RFC 6531|https://tools.ietf.org/html/rfc6531> and
L<RFC 20|https://tools.ietf.org/html/rfc20>.
This means that the module supports Internationalized Email Addresses
encoded in UTF-8, L<RFC 3629|https://tools.ietf.org/html/rfc3629>.

The default behavior of the module also includes
the check of:

=over 4

=item *

Special and Reserved domains as mentioned
in L<RFC 6761|https://tools.ietf.org/html/rfc6761>

=item *

FQDN - if the domain contains only alias and it is not
a special or reserved domain, then the result is negative,
that is, such an email address is considered as invalid.

=back

=head1 DEPENDENCIES

This module depends on L<libidnkit|https://jprs.co.jp/idn/index-e.html>.
You have to install it before using this module.

=head1 METHODS

=over 4

=item *

$eav = B<new ()>

Creates a new EAV::XS object, if something goes wrong a message will
be thrown via croak().

=item *

$yes_no = B<is_email ($email)>

Validates the specified email. Returns true if the email
is valid, otherwise returns false.

=item *

$error_message = B<error ()>

Returns an error message for the last email address tested
by B<is_email()> method.

=back


=head1 SEE ALSO

References:

=over

=item L<RFC 20|https://tools.ietf.org/html/rfc20>

=item L<RFC 822|https://tools.ietf.org/html/rfc822>

=item L<RFC 5321|https://tools.ietf.org/html/rfc5321>

=item L<RFC 5322|https://tools.ietf.org/html/rfc5322>

=item L<RFC 6530|https://tools.ietf.org/html/rfc6530>

=item L<RFC 6531|https://tools.ietf.org/html/rfc6531>

=back

Other implementations:

=over

=item L<Email::Valid>

=item L<String::Validator::Email>

=item L<Data::Validate::Email>

=item L<Email::Address>

=back

=head1 AUTHOR

Vitaliy V. Tokarev, E<lt>vitaliy.tokarev@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2017 by Vitaliy V. Tokarev

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
