/*
 *	SCCS: @(#)remtime.c	1.11 (98/08/28)
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

SCCS:   	@(#)remtime.c	1.11 98/08/28 TETware release 3.3
NAME:		remtime.c
PRODUCT:	TETware
AUTHOR:		Geoff Clare, UniSoft Ltd.
DATE CREATED:	July 1996

SYNOPSIS:
	#include "tet_api.h"
	int tet_remtime(int sysid, time_t *tp);

DESCRIPTION:
	DTET API function

	Obtain current time on specified remote system.
	Return 0 if successful or -1 on error.

MODIFICATIONS:
	Geoff Clare, UniSoft Ltd., 27 Aug 1996
	Add sysid check.

	Geoff Clare, UniSoft Ltd., Sept 1996
	Changes for TETWare-Lite.

	Andrew Dingwall, UniSoft Ltd., July 1998
	Added support for shared API libraries.

	Aaron Plattner, April 2010
	Fixed warnings when compiled with GCC's -Wall option.

************************************************************************/

#ifndef TET_LITE /* -START-LITE-CUT- */

#include <time.h>
#include "dtmac.h"
#include "dtthr.h"
#include "globals.h"
#include "tet_api.h"
#include "dtmsg.h"
#include "ptab.h"
#include "sysent.h"
#include "servlib.h"

TET_IMPORT int tet_remtime(sysid, tp)
int sysid;
time_t *tp;
{
	long retval;

	if (!tp)
	{
		tet_errno = TET_ER_INVAL;
		return(-1);
	}

	API_LOCK;

	/* do something sensible if sysid is the local system */
	if (sysid == tet_mysysid)
	{
		time(tp);
		API_UNLOCK;
		return 0;
	}

	/* check sysid is valid */
	if (!tet_libgetsysbyid(sysid))
	{
		tet_errno = TET_ER_SYSID;
		API_UNLOCK;
		return(-1);
	}

	/* log on to the remote system if necessary */
	if (!tet_getptbysysptype(sysid, PT_STCC) && tet_tclogon(sysid) < 0)
	{
		tet_errno = TET_ER_LOGON;
		API_UNLOCK;
		return(-1);
	}

	/* do the remote time operation and handle the reply code */
	if (tet_tctime(sysid, &retval) < 0)
	{
		tet_errno = -tet_tcerrno;
		API_UNLOCK;
		return(-1);
	}

	API_UNLOCK;
	*tp = (time_t) retval;
	return(0);
}

#else /* -END-LITE-CUT- */

/* avoid "empty" file */
int tet_remtime_not_supported;

#endif /* -LITE-CUT-LINE- */

