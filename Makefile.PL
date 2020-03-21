use strict;
use ExtUtils::MakeMaker;
use ExtUtils::PkgConfig;

# The libeav options:
# * RFC6531_FOLLOW_RFC20 = ON | OFF     - allow extra chars (RFC 20)
# * RFC6531_FOLLOW_RFC5322 = ON | OFF   - white-space chars depricated in quotes
# * FORCE_IDN = idn | idn2 | idnkit     - force build with specific idn library
# * DESTDIR = /path/to/install/libeav
# * INDKIT_DIR = /path/with/idnkit
my @OPTIONS = ();
my $MYLIBS;

# directory where idnkit was installed
my $idnkit_dir = $ENV{ 'IDNKIT_DIR' } ? $ENV{ 'IDNKIT_DIR' } : '/usr/local';


if (prompt ("Use default options (y/n)?", "y") =~ /^y/i) {
    &build_with_auto();
}
else {
    my $with_idn = prompt
        "Select IDN library to build with (auto/idn/idn2/idnkit):",
        "auto";

    &set_rfc_options();

    if ($with_idn =~ /^auto$/i) {
        &build_with_auto();
    }
    elsif ($with_idn =~ /^idn1?$/i) {
        &build_with_idnX('idn');
    }
    elsif ($with_idn =~ /^idn2$/i) {
        &build_with_idnX('idn2');
    }
    elsif ($with_idn =~ /^idnkit$/i) {
        &build_with_idnkit();
    }
    else {
    print <<'EOF';

 *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***

ERROR: Invalid IDN library.

EOF
    }
}


WriteMakefile(
    dist              => {
        'PREOP'    => 'pod2text lib/EAV/XS.pm'
                    . ' | tee README >$(DISTVNAME)/README;'
                    . ' chmod -R u=rwX,go=rX . ;',
        'COMPRESS' => 'gzip -9v',
        'SUFFIX'   => '.gz',
    },
    NAME              => 'EAV::XS',
    VERSION_FROM      => 'lib/EAV/XS.pm',
    PREREQ_PM         => {
        'XSLoader' => 0,
    },
    TEST_REQUIRES     => {
        'Test::More' => 0,
    },
    ABSTRACT          => 'Email Address Validation Library',
    AUTHOR            => 'Vitaliy V. Tokarev <vitaliy.tokarev@gmail.com>',
    LICENSE           => 'freebsd',
    LIBS              => [ $MYLIBS ],
    DEFINE            => "",
    INC               => '-Ilibeav/include',
    OBJECT            => '$(O_FILES)',
    MYEXTLIB          => 'libeav/libeav.a',
    macro             =>  {
        # workaround to the current build system
        'LIBEAV_OPTIONS' => join(" ", @OPTIONS),
    },
    depend => {
        # also clean libeav files
        'clean_subdirs'     => 'clean-libeav',
        # libeav internal checks
        'check'             => 'check-libeav',
    },
);


# We don't want the default subdir rule, as it creates 
# a race condition with the rule we add below.
sub MY::subdir_x {
    return '';
}


sub MY::postamble {
    return <<'EOL';
$(MYEXTLIB): libeav/Makefile
	$(MAKE) -C libeav static $(LIBEAV_OPTIONS)

clean-libeav:
	$(MAKE) -C libeav clean

check-libeav:
	$(MAKE) -C libeav check $(LIBEAV_OPTIONS)

EOL
}


sub set_rfc_options() {
    print <<'EOF';

 *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***

In RFC 20 has been said that the following characters SHOULD NOT
to be used in international interchange without determining that
there is agreement between sender and recipient, such as
#, ~, ^, |, {, } and `.

By default the module follow this rule.

EOF

    if (prompt ("Allow extra characters (y/n)?", "n") =~ /^[yY]/) {
        push @OPTIONS, "RFC6531_FOLLOW_RFC20=ON";
    }

    print <<'EOF';

 *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***

RFC 5322 does NOT permit white-space characters (shortly WSP) in double 
quotes. Thats includes SPACE and TAB characters. According to this
RFC they must be specified as quote pair, e.g. "SPACE | TAB".

Also RFC 5322 allows some control characters in double quotes and
quoted pairs, such as Form Feed (\f), Line Feed (\n) and others.

By default the module does not allow any control characters.

EOF

    if (prompt("Use RFC 5322 syntax (y/n)?", "n") =~ /^[yY]/) {
        push @OPTIONS, "RFC6531_FOLLOW_RFC5322=ON";
    }
}


# test if idnkit is installed properly; no critic
sub test_idnkit() {
    return (-e "${idnkit_dir}/include/idn/api.h");
}

# set idnkit installation directory and returns whether or not it is correct
sub set_idnkit_dir {
    $idnkit_dir = prompt    "Directory where idnkit installed:",
                            "$idnkit_dir";
    return &test_idnkit();
}

# define options when build with idnkit
sub build_with_idnkit() {
    if (! &test_idnkit()) {
        print <<'EOF';

 *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***

Could not find idnkit header files. Please, set proper directory,
for instance, /opt/local.

EOF

        while (! &set_idnkit_dir()) {
            print <<'EOF';

 *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***

ERROR: Invalid idnkit directory.

EOF

            if (prompt ("Try again (y/n)?", "n") =~ /^[nN]/) {
                print <<'EOF';

 *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***

Sorry, can not build this module when idnkit is not installed.

Bye!
EOF
                exit 1;
            }
        }
    }

    push @OPTIONS, "FORCE_IDN=idnkit";
    push @OPTIONS, "IDNKIT_DIR=${idnkit_dir}";
}


sub build_with_auto() {
    foreach my $idnname ('idn2', 'idn') {
        my $idnpkg = "lib" . $idnname;
        next if !ExtUtils::PkgConfig->exists ($idnpkg);
        my %pkg_info = ExtUtils::PkgConfig->find ($idnpkg);
        $MYLIBS = $pkg_info{'libs'};
        push @OPTIONS, "FORCE_IDN=${idnname}";
        last;
    }

    if (!$MYLIBS) {
        print <<'EOF';

 *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***

WARNING: Could not found libidn2 and libidn libraries on this system.
         Looking for idnkit...

EOF

        &build_with_idnkit();
    }
}


sub build_with_idnX($) {
    my ($idnname) = @_;
    my $idnpkg = "lib" . $idnname;

    if (not ExtUtils::PkgConfig->exists ($idnpkg)) {
        print <<"EOF";

 *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***

ERROR: Could not found ${idnpkg} on this system.

EOF

        exit 2;
    }

    my %pkg_info = ExtUtils::PkgConfig->find ($idnpkg);
    $MYLIBS = $pkg_info{'libs'};
    push @OPTIONS, "FORCE_IDN=${idnname}";
}
