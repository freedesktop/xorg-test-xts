/*
Copyright (c) 2005 X.Org Foundation L.L.C.

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
/*
*
* Copyright Applied Testing and Technology Inc. 1995
* All rights reserved
*
* Project: VSW5
*
* File:	xts5/src/lib/startcall.c
*
* Description:
*	Startup routine
*
* Modifications:
* $Log: startcall.c,v $
* Revision 1.2  2005-11-03 08:42:01  jmichael
* clean up all vsw5 paths to use xts5 instead.
*
* Revision 1.1.1.2  2005/04/15 14:05:10  anderson
* Reimport of the base with the legal name in the copyright fixed.
*
* Revision 8.0  1998/12/23 23:24:52  mar
* Branch point for Release 5.0.2
*
* Revision 7.0  1998/10/30 22:43:04  mar
* Branch point for Release 5.0.2b1
*
* Revision 6.0  1998/03/02 05:17:15  tbr
* Branch point for Release 5.0.1
*
* Revision 5.0  1998/01/26 03:13:48  tbr
* Branch point for Release 5.0.1b1
*
* Revision 4.1  1996/01/25 01:57:14  andy
* Portability improvements from DEPLOY tools
*
* Revision 4.0  1995/12/15  08:43:03  tbr
* Branch point for Release 5.0.0
*
* Revision 3.1  1995/12/15  00:40:28  andy
* Prepare for GA Release
*
*/

/*
Portions of this software are based on Xlib and X Protocol Test Suite.
We have used this material under the terms of its copyright, which grants
free use, subject to the conditions below.  Note however that those
portions of this software that are based on the original Test Suite have
been significantly revised and that all such revisions are copyright (c)
1995 Applied Testing and Technology, Inc.  Insomuch as the proprietary
revisions cannot be separated from the freely copyable material, the net
result is that use of this software is governed by the ApTest copyright.

Copyright (c) 1990, 1991  X Consortium

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
X CONSORTIUM BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Except as contained in this notice, the name of the X Consortium shall not be
used in advertising or otherwise to promote the sale, use or other dealings
in this Software without prior written authorization from the X Consortium.

Copyright 1990, 1991 by UniSoft Group Limited.

Permission to use, copy, modify, distribute, and sell this software and
its documentation for any purpose is hereby granted without fee,
provided that the above copyright notice appear in all copies and that
both that copyright notice and this permission notice appear in
supporting documentation, and that the name of UniSoft not be
used in advertising or publicity pertaining to distribution of the
software without specific, written prior permission.  UniSoft
makes no representations about the suitability of this software for any
purpose.  It is provided "as is" without express or implied warranty.
*/

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include	"xtest.h"
#include	"stdio.h"
#include	"X11/Xlib.h"
#include	"X11/Xutil.h"
#include	"tet_api.h"
#include	"xtestlib.h"
#include	"pixval.h"

/*
 * This routine is similar to startcall except that no XSync() occurs.
 * Various tests assume that this routine merely sets up the error
 * handler stuff.  This routine should not generate protocol requests.
 */
void
_startcall(disp)
Display	*disp;
{
extern	int	error_status();
	/* Reset the error status */
	reseterr();

	/*
	 * Set error handler to trap errors that occur on this call
	 * Should be LAST.
	 */
	XSetErrorHandler(error_status);
}

/*
 * This routine contains setup procedures that should be called
 * before each time that the routine under test is called.
 */
void
startcall(disp)
Display	*disp;
{
	XSync(disp, True);

	_startcall(disp);
}

/*
 * This routine is similar to endcall() except that XSync() is
 * not called.
 * Various tests assume that this routine merely un-sets up the error
 * handler stuff.  This routine should not generate protocol requests.
 */
void
_endcall(disp)
Display	*disp;
{
extern	int 	unexp_err();

	/*
	 * Go back to the unexpected error handler.
	 */
	XSetErrorHandler(unexp_err);

	/* A debuging aid - pause for CR after displaying window */
	if (config.debug_pause_after) {
	int 	c;
	extern	int 	tet_thistest;

		printf("Test %d: Hit return to continue...", tet_thistest);
		fflush(stdout);
		while ((c = getchar()) != '\n' && c != EOF)
			;
	}
}

/*
 * The endcall() routine does all common cleanup code that
 * should be called after the routine under test has been
 * called.  XSync() needs to be called before this.
 */
void
endcall(disp)
Display	*disp;
{

	XSync(disp, False);

	_endcall(disp);
}
