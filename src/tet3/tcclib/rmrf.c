/*
 *	SCCS: @(#)rmrf.c	1.4 (98/09/01)
 *
 *	UniSoft Ltd., London, England
 *
 * (C) Copyright 1996 X/Open Company Limited
 *
 * All rights reserved.  No part of this source code may be reproduced,
 * stored in a retrieval system, or transmitted, in any form or by any
 * means, electronic, mechanical, photocopying, recording or otherwise,
 * except as stated in the end-user licence agreement, without the prior
 * permission of the copyright owners.
 * A copy of the end-user licence agreement is contained in the file
 * Licence which accompanies this distribution.
 * 
 * X/Open and the 'X' symbol are trademarks of X/Open Company Limited in
 * the UK and other countries.
 */

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

/************************************************************************

SCCS:   	@(#)rmrf.c	1.4 98/09/01 TETware release 3.3
NAME:		rmrf.c
PRODUCT:	TETware
AUTHOR:		Andrew Dingwall, UniSoft Ltd.
DATE CREATED:	October 1996

DESCRIPTION:
	function to emulate an invocation of rm -rf

	this function moved from tccd/stcc.c to here

MODIFICATIONS:

	Andrew Dingwall, UniSoft Ltd., March 1998
	tcf_lsdir() no longer includes "." in the list of files returned.

	Andrew Dingwall, UniSoft Ltd., July 1998
	Added support for shared API libraries.

	Aaron Plattner, April 2010
	Fixed warnings when compiled with GCC's -Wall option.

************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#  include <unistd.h>
#include "dtmac.h"
#include "dtmsg.h"
#include "error.h"
#include "globals.h"
#include "dtetlib.h"
#include "tcclib.h"

#ifndef NOTRACE
#  include "ltoa.h"
#endif


/*
**	tcf_rmrf() - emulate an invocation of rm -rf
**
**	return 0 if successful or -1 on error
*/

int tcf_rmrf(path)
char *path;
{
	register char **files, **fip;
	char file[MAXPATH + 1];
	struct STAT_ST stbuf;
	register char *p;
	register int rc = 0;
	int errsave;

	TRACE2(Ttcclib, 8, "rmrf(): path = %s", path);

	/* see if this is a file or a direcory */
	if (STAT(path, &stbuf) < 0) {
		errsave = errno;
		error(errno, "can't stat", path);
		errno = errsave;
		return(-1);
	}

	/*
	** if this is a directory, get a listing and remove each entry in
	** turn, then remove the directory itself;
	** otherwise, this is a file so just unlink it
	*/
	if (S_ISDIR(stbuf.st_mode)) {
		sprintf(file, "%.*s/", (int) sizeof file - 2, path);
		p = file + strlen(file);
		if ((files = tcf_lsdir(path)) == (char **) 0)
			return(-1);
		for (fip = files; *fip; fip++) {
			sprintf(p, "%.*s",
				(int) sizeof file - (int) (p - file) - 1, *fip);
			if (tcf_rmrf(file) < 0)
				rc = -1;
			TRACE2(tet_Tbuf, 6, "free dir entry = %s",
				tet_i2x(*fip));
			free(*fip);
		}
		if (tet_rmdir(path) < 0) {
			errsave = errno;
			error(errno, "can't remove directory", path);
			errno = errsave;
			rc = -1;
		}
		TRACE2(tet_Tbuf, 6, "free dir list = %s", tet_i2x(files));
		free((char *) files);
	}
	else if (UNLINK(path) < 0) {
		errsave = errno;
		error(errno, "can't unlink", path);
		errno = errsave;
		rc = -1;
	}

	return(rc);
}

