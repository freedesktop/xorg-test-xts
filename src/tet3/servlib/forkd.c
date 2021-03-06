/*
 *      SCCS:  @(#)forkd.c	1.8 (98/09/01) 
 *
 *	UniSoft Ltd., London, England
 *
 * (C) Copyright 1992 X/Open Company Limited
 *
 * All rights reserved.  No part of this source code may be reproduced,
 * stored in a retrieval system, or transmitted, in any form or by any
 * means, electronic, mechanical, photocopying, recording or otherwise,
 * except as stated in the end-user licence agreement, without the prior
 * permission of the copyright owners.
 *
 * X/Open and the 'X' symbol are trademarks of X/Open Company Limited in
 * the UK and other countries.
 */

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

/************************************************************************

SCCS:   	@(#)forkd.c	1.8 98/09/01 TETware release 3.3
NAME:		fork.c
PRODUCT:	TETware
AUTHOR:		Andrew Dingwall, UniSoft Ltd.
DATE CREATED:	April 1992

DESCRIPTION:
	function to start a daemon process

	this function is not implemented on WIN32

MODIFICATIONS:

	Andrew Dingwall, UniSoft Ltd., July 1998
	Added support for shared API libraries.

	Aaron Plattner, April 2010
	Fixed warnings when compiled with GCC's -Wall option.

************************************************************************/


#include <stdio.h>
#include <unistd.h>
#include <errno.h>
#include "dtmac.h"
#include "globals.h"
#include "error.h"
#include "servlib.h"
#include "dtetlib.h"


/*
**	tet_si_forkdaemon() - fork off a daemon process
*/

void tet_si_forkdaemon()
{
	int rc;

	if ((rc = tet_dofork()) < 0)
		fatal(errno, "can't fork", (char *) 0);
	else if (rc > 0)
		_exit(0);

	tet_mypid = getpid();
}

