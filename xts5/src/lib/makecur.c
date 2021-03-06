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
* File:	xts5/src/lib/makecur.c
*
* Description:
*	Cursor support routines
*
* Modifications:
* $Log: makecur.c,v $
* Revision 1.2  2005-11-03 08:42:01  jmichael
* clean up all vsw5 paths to use xts5 instead.
*
* Revision 1.1.1.2  2005/04/15 14:05:10  anderson
* Reimport of the base with the legal name in the copyright fixed.
*
* Revision 8.0  1998/12/23 23:24:41  mar
* Branch point for Release 5.0.2
*
* Revision 7.0  1998/10/30 22:42:53  mar
* Branch point for Release 5.0.2b1
*
* Revision 6.0  1998/03/02 05:17:05  tbr
* Branch point for Release 5.0.1
*
* Revision 5.0  1998/01/26 03:13:38  tbr
* Branch point for Release 5.0.1b1
*
* Revision 4.1  1996/01/25 01:57:14  andy
* Portability improvements from DEPLOY tools
*
* Revision 4.0  1995/12/15  08:42:32  tbr
* Branch point for Release 5.0.0
*
* Revision 3.1  1995/12/15  00:39:50  andy
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

#include	<stdlib.h>
#include	"xtest.h"
#include	"X11/Xlib.h"
#include	"X11/Xutil.h"
#include	"xtestlib.h"
#include	"tet_api.h"

/*
 * Create a cursor that can be used within the test suite.
 * The cursor is created using XCreateFontCursor.  The shape
 * chosen can be controlled through the configuration variable
 * XT_FONTCURSOR_GOOD and arg. "inc".  If the config. variable is not set or is
 * undefined, the shape defaults to inc.
 */
Cursor
makecurnum(disp, inc)
Display	*disp;
int inc;
{
Cursor cursor;
char *varptr;
unsigned int shape;

	varptr = tet_getvar("XT_FONTCURSOR_GOOD");
	if (varptr == NULL || *varptr == 'U')
		shape = 0;
	else
		shape = atov(varptr);

	shape += (inc >= 0) ? (unsigned int) inc : (unsigned int) 0;

	cursor = XCreateFontCursor(disp, shape);

	/* register cursor */
	regid(disp, (union regtypes *)&cursor, REG_CURSOR);

	return(cursor);
}

/*
 * Create a cursor that can be used within the test suite.
 * The cursor is created using XCreateFontCursor.  The shape
 * chosen can be controlled through the configuration variable
 * XT_FONTCURSOR_GOOD.  If this variable is not set or is
 * undefined, the shape defaults to 0.
 */
Cursor
makecur(disp)
Display *disp;
{
	return makecurnum(disp, 0);
}

/*
 * Create a cursor that can be used within the test suite.
 * The cursor is created using XCreateFontCursor.  The shape
 * chosen can be controlled through the configuration variable
 * XT_FONTCURSOR_GOOD; it's XT_FONTCURSOR_GOOD+2.  If this
 * variable is not set or is undefined, the shape defaults to 2.
 */
Cursor
makecur2(disp)
Display *disp;
{
	return makecurnum(disp, 2);
}
