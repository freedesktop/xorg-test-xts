/*
 *      SCCS:  @(#)hexdump.c	1.5 (98/08/28) 
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

SCCS:   	@(#)hexdump.c	1.5 98/08/28 TETware release 3.3
NAME:		hexdump.c
PRODUCT:	TETware
AUTHOR:		Andrew Dingwall, UniSoft Ltd.
DATE CREATED:	April 1992

DESCRIPTION:
	hex dump function
	might be useful when debugging

MODIFICATIONS:

	Aaron Plattner, April 2010
	Fixed warnings when compiled with GCC's -Wall option.

************************************************************************/

#include <stdio.h>
#include "dtmac.h"
#include "dtetlib.h"

/*
**	tet_hexdump() - print a dump of n bytes starting at dp
*/

void tet_hexdump(dp, n, fp)
char *dp;
int n;
FILE *fp;
{
	register char *start, *end;
	register char *p1, *p2;

	end = dp + n;	/* end is first location not to dump */

	start = dp;
	do {
		fprintf(fp, "%#lx:", (long) start);
		if (start >= end)
			continue;
		p2 = TET_MIN(start + 16, end);
		for (p1 = start; p1 < p2; p1++)
			fprintf(fp, " %02x", (unsigned char) *p1);
		while (p1++ <= start + 16)
			fprintf(fp, "   ");
		for (p1 = start; p1 < p2; p1++)
			fprintf(fp, "%c",
				*p1 > '\040' && *p1 < '\177' ? *p1 : '.');
		fprintf(fp, "\n");
	} while ((start += 16) < end);

	fprintf(fp, "\n");
	fflush(fp);
}

