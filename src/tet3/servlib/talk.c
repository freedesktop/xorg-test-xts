/*
 *      SCCS:  @(#)talk.c	1.6 (96/11/04) 
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

SCCS:   	@(#)talk.c	1.6 96/11/04 TETware release 3.3
NAME:		talk.c
PRODUCT:	TETware
AUTHOR:		Andrew Dingwall, UniSoft Ltd.
DATE CREATED:	April 1992

DESCRIPTION:
	function to talk to a server

MODIFICATIONS:

	Aaron Plattner, April 2010
	Fixed warnings when compiled with GCC's -Wall option.

************************************************************************/

#include <stdio.h>
#include <sys/types.h>
#include "dtmac.h"
#include "dtmsg.h"
#include "ptab.h"
#include "error.h"
#include "servlib.h"
#include "dtetlib.h"

/*
**	tet_ti_talk() - talk to a server and receive a reply
**
**	return 0 if successful or -1 on error
*/

int tet_ti_talk(pp, delay)
struct ptab *pp;
int delay;
{
	register int rc;

	tet_si_clientloop(pp, delay);

	if (pp->pt_state == PS_DEAD || (pp->pt_flags & PF_IOERR))
		rc = -1;
	else if (pp->pt_flags & PF_TIMEDOUT) {
		pp->pt_flags &= ~PF_TIMEDOUT;
		error(0, "server timed out", tet_r2a(&pp->pt_rid));
		rc = -1;
	}
	else
		rc = 0;

	return(rc);
}

