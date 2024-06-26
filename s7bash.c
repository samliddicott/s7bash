/* bashs7 - bashs7 based on template example for loadable builtin */

/* See Makefile for compilation details. */

#include <config.h>

#if defined (HAVE_UNISTD_H)
#  include <unistd.h>
#endif
#include "bashansi.h"
#include <stdio.h>
#include <errno.h>

#include "loadables.h"
#include "s7/s7.h"
int s7main(int argc, char **argv);

#if !defined (errno)
extern int errno;
#endif

extern char *strerror ();

s7_scheme *sc = NULL;

int
bashs7_builtin (list)
     WORD_LIST *list;
{
  int opt, rval;

  rval = EXECUTION_SUCCESS;
  reset_internal_getopt ();
  while ((opt = internal_getopt (list, "")) != -1)
    {
      switch (opt)
	{
	CASE_HELPOPT;
	default:
	  builtin_usage ();
	  return (EX_USAGE);
	}
    }
  list = loptend;

//  char* n[]={ "./", NULL };
//  s7main(1, (char**)&n);

  s7_repl(sc);

  return (rval);
}

/* Called when `bashs7' is enabled and loaded from the shared object.  If this
   function returns 0, the load fails. */
int
bashs7_builtin_load (name)
     char *name;
{
  if (! (sc = s7_init())) return EX_MISCERROR;

  fprintf(stderr, "s7: %s\n", S7_DATE);

  return (1);
}

/* Called when `bashs7' is disabled. */
void
bashs7_builtin_unload (name)
     char *name;
{
}

char *bashs7_doc[] = {
	"Short description.",
	""
	"Longer description of builtin and usage.",
	(char *)NULL
};

struct builtin bashs7_struct = {
	"bashs7",			/* builtin name */
	bashs7_builtin,			/* function implementing the builtin */
	BUILTIN_ENABLED,		/* initial flags for builtin */
	bashs7_doc,			/* array of long documentation strings. */
	"bashs7",			/* usage synopsis; becomes short_doc */
	0				/* reserved for internal use */
};
