use strict;
use ExtUtils::MakeMaker;


# TODO: libeav/tests/* must accept new options.
#
# Current possible options:
# * RFC6531_PERMIT_EXTRA_CHARS - allow extra chars (RFC 20)
# * RFC6531_FOLLOW_RFC5322 - white-space chars depricated in quotes
my $DEFINE;

# directory where idnkit was installed
my $idnkit_dir = $ENV{ 'IDNKIT_DIR' } ? $ENV{ 'IDNKIT_DIR' } : '/usr/local';


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

        if (prompt ("Try again (y/n)?", "n") =~ /[nN]/) {
            print <<'EOF';

 *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***

Sorry, can't build this module when idnkit is not installed.

Bye!
EOF
            exit 1;
        }
    }
}


WriteMakefile(
    dist              => {
        'PREOP'     => 'pod2text lib/EAV/XS.pm'
                        . ' | tee README >$(DISTVNAME)/README;'
                        . ' chmod -R u=rwX,go=rX . ;',
        'COMPRESS'  => 'gzip -9v',
        'SUFFIX'    => '.gz',
    },
    NAME              => 'EAV::XS',
    VERSION_FROM      => 'lib/EAV/XS.pm',
    PREREQ_PM         => {
        'XSLoader'      => 0,
    },
    TEST_REQUIRES     => {
        'Test::More'    => 0,
    },
    ABSTRACT          => 'The Email Address Validator',
    AUTHOR            => 'Vitaliy V. Tokarev <vitaliy.tokarev@gmail>',
    LICENSE           => 'freebsd',
    LIBS              => [ "-L${idnkit_dir}/lib -lidnkit" ],
    DEFINE            => "$DEFINE",
    INC               => '-Ilibeav/include ' . "-I${idnkit_dir}/include",
    OBJECT            => '$(O_FILES)',
    MYEXTLIB          => 'libeav/libeav.a',
    macro             =>  {
        # workaround to the current build system
        'PERL_IDNKIT_DIR'   => "$idnkit_dir",
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
	cd libeav || exit 1; \
	$(MAKE) libeav.a CFLAGS=$(DEFINE) IDNKIT_DIR=$(PERL_IDNKIT_DIR)

clean-libeav:
	cd libeav || exit 1; \
	$(MAKE) clean

check-libeav:
	cd libeav || exit 1; \
	$(MAKE) check CFLAGS=$(DEFINE) IDNKIT_DIR=$(PERL_IDNKIT_DIR)

EOL
}


# does not working at the moment (libeav test fails)
sub set_define() {
    print <<'EOF';

 *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***

In RFC 20 has been said that the following characters SHOULD NOT
to be used in international interchange without determining that
there is agreement between sender and recipient, such as
"#", "~", "^", "|", "{", "}" and "`".

By default the module follow this rule.

EOF

    if (prompt ("Allow extra characters (y/n)?", "n") =~ /[yY]/) {
        $DEFINE .= " -DRFC6531_PERMIT_EXTRA_CHARS";
    }

    print <<'EOF';

 *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***

RFC 5322 does NOT permit white-space characters (shortly WSP) in double 
quotes. Thats includes SPACE and TAB characters. According to this
RFC they must be specified as quote pair, e.g. "\" SPACE / TAB.

Also RFC 5322 allows some control characters in double quotes and
quoted pairs, such as Form Feed (\f), Line Feed (\n) and others.

By default the module does not allow any control characters.

EOF

    if (prompt("Use RFC 5322 syntax (y/n)?", "n") =~ /[yY]/) {
        $DEFINE .= " -DRFC6531_FOLLOW_RFC5322";
    }
}
