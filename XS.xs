#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"


#include <eav.h>

typedef eav_t *EAV__XS;

/* ------------------------------------------------------------------ */

MODULE = EAV::XS		PACKAGE = EAV::XS		

PROTOTYPES: ENABLE


EAV::XS
new(package)
        const char  *package
    PREINIT:
        eav_t *eav = NULL;
        int r = EEAV_NO_ERROR;
    CODE:
        eav = (eav_t *) safemalloc(sizeof(eav_t));

        if (eav == NULL)
            croak ("safemalloc(): out of memory");

        eav_init (eav);
        r = eav_setup (eav);

        if (r == EEAV_NO_ERROR)
            RETVAL = eav;
        else
            croak ("eav_setup(): %s", eav_errstr (eav));
    OUTPUT:
        RETVAL


void
DESTROY(self)
        EAV::XS     self
    CODE:
        eav_free (self);
        safefree (self);


int
is_email(self, email)
        EAV::XS     self
        SV          *email
    PREINIT:
        const char *cp;
        STRLEN len;
        int r = EEAV_NO_ERROR;
    CODE:
        cp = SvPV(email, len);
        RETVAL = eav_is_email(self, cp, len);
    OUTPUT:
        RETVAL


SV *
error(self)
        EAV::XS     self
    PREINIT:
        const char *msg;
    CODE:
        msg = eav_errstr(self);

        if (msg != NULL)
            RETVAL = newSVpv(msg, 0);
        else
            RETVAL = newSVpv("", 0);
    OUTPUT:
        RETVAL
