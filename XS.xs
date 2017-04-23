#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

#include <eav.h>

typedef eav_t *EAV__XS;

typedef enum {
    EAV_PARAM_UNKNOWN,
    EAV_PARAM_TLD_CHECK,
    EAV_PARAM_RFC,
    EAV_PARAM_ALLOW_TLD
} eav_param_t;

#define sv_eav_param(sv)    THX_sv_eav_param(aTHX_ sv)


static eav_param_t
eav_param (const char *s, const STRLEN len)
{
    switch (len) {
    case 3:
        if (memEQ(s, "rfc", 3))
            return EAV_PARAM_RFC;
        break;
    case 9:
        if (memEQ(s, "tld_check", 9))
            return EAV_PARAM_TLD_CHECK;
        else if (memEQ(s, "allow_tld", 9))
            return EAV_PARAM_ALLOW_TLD;
        break;
    }

    return EAV_PARAM_UNKNOWN;
}


static eav_param_t
THX_sv_eav_param (pTHX_ SV *sv)
{
    const char *str;
    STRLEN len;

    str = SvPV_const(sv, len);
    return eav_param(str, len);
}


/* ------------------------------------------------------------------ */


MODULE = EAV::XS		PACKAGE = EAV::XS		

PROTOTYPES: ENABLE


EAV::XS
new(package, ...)
        const char  *package
    PREINIT:
        eav_t *eav = NULL;
        int r = EEAV_NO_ERROR;
        I32 i;
    CODE:
        if (((items - 1) % 2) != 0)
            croak ("options have the odd number of elements");

        eav = (eav_t *) safemalloc(sizeof(eav_t));

        if (eav == NULL)
            croak ("safemalloc(): out of memory");

        eav_init (eav);

        for (i = 1; i < items; i += 2) {
            switch (sv_eav_param(ST(i))) {
            case EAV_PARAM_ALLOW_TLD:
                eav->allow_tld = SvIV(ST(i+1));
                break;
            case EAV_PARAM_TLD_CHECK:
                eav->tld_check = (SvIV(ST(i+1))) ? true : false;
                break;
            case EAV_PARAM_RFC:
                eav->rfc = SvIV(ST(i+1));
                break;
            }
        }

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
        char *cp;
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
