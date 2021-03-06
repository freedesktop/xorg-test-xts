/*
 *	SCCS: @(#)lockfile.c	1.2 (97/07/21)
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

SCCS:   	@(#)lockfile.c	1.2 97/07/21 TETware release 3.3
NAME:		lockfile.c
PRODUCT:	TETware
AUTHOR:		Andrew Dingwall, UniSoft Ltd.
DATE CREATED:	October 1996

DESCRIPTION:
	tcc action function - create an exclusive lock

	this function moved from tccd/stcc.c to here

MODIFICATIONS:

	Aaron Plattner, April 2010
	Fixed warnings when compiled with GCC's -Wall option.

************************************************************************/

#include <stdio.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <time.h>
#include <errno.h>
#  include <unistd.h>
#include "dtmac.h"
#include "dtmsg.h"
#include "error.h"
#include "dtetlib.h"
#include "tcclib.h"


/* lock file mode */
#define MODEANY \
	((mode_t) (S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH | S_IWOTH))


/*
**	tcf_lockfile() - create a lock file (exclusive lock)
**
**	return ER_OK if successful or other ER_* code on error
**
**	a zero timeout means return immediately if the operation fails
**	a -ve timeout means try indefinately until a lock is obtained or an
**	error occurs
*/

int tcf_lockfile(fname, timeout)
char *fname;
int timeout;
{
	register int fd, errsave, rc;
	register time_t start;

	ASSERT(fname && *fname);

	/* create the lock file, sleeping a bit if it fails */
	start = time((time_t *) 0);
	while ((fd = OPEN(fname, O_RDONLY | O_CREAT | O_EXCL, MODEANY)) < 0) {
		if ((errsave = errno) != EEXIST || !timeout)
			break;
		if (timeout > 0 && time((time_t *) 0) > start + timeout) {
			errno = 0;
			return(ER_TIMEDOUT);
		}
		SLEEP(2);
	}

	/* handle unexpected errors */
	if (fd < 0) {
		if ((rc = tet_maperrno(errsave)) == ER_ERR)
			error(errsave, "can't create", fname);
		errno = errsave;
		return(rc);
	}

	/* all ok so close the file and return success */
	CLOSE(fd);
	return(ER_OK);
}

