package EAV::XS;

use strict;
use warnings;

our $VERSION = eval '0.1.1';

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

=over 4

=item *

L<RFC 20|https://tools.ietf.org/html/rfc20>

=item *

L<RFC 822|https://tools.ietf.org/html/rfc822>

=item *

L<RFC 5321|https://tools.ietf.org/html/rfc5321>

=item *

L<RFC 5322|https://tools.ietf.org/html/rfc5322>

=item *

L<RFC 6530|https://tools.ietf.org/html/rfc6530>

=item *

L<RFC 6531|https://tools.ietf.org/html/rfc6531>

=back

Other implementations:

=over 4

=item *

L<Email::Valid>

=item *

L<String::Validator::Email>

=item *

L<Data::Validate::Email>

=item *

L<Email::Address>

=back

=head1 AUTHOR

Vitaliy V. Tokarev, E<lt>vitaliy.tokarev@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2017 Vitaliy V. Tokarev

All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut
