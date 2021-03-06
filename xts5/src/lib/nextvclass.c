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
* File:	xts5/src/lib/nextvclass.c
*
* Description:
*	Visual Class support routines
*
* Modifications:
* $Log: nextvclass.c,v $
* Revision 1.2  2005-11-03 08:42:01  jmichael
* clean up all vsw5 paths to use xts5 instead.
*
* Revision 1.1.1.2  2005/04/15 14:05:10  anderson
* Reimport of the base with the legal name in the copyright fixed.
*
* Revision 8.0  1998/12/23 23:24:44  mar
* Branch point for Release 5.0.2
*
* Revision 7.0  1998/10/30 22:42:56  mar
* Branch point for Release 5.0.2b1
*
* Revision 6.0  1998/03/02 05:17:08  tbr
* Branch point for Release 5.0.1
*
* Revision 5.0  1998/01/26 03:13:41  tbr
* Branch point for Release 5.0.1b1
*
* Revision 4.1  1996/01/25 01:57:14  andy
* Portability improvements from DEPLOY tools
*
* Revision 4.0  1995/12/15  08:42:42  tbr
* Branch point for Release 5.0.0
*
* Revision 3.1  1995/12/15  00:40:03  andy
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

/*
 * Functions to cycle through all the visual classes that are supposed to
 * supported by the display/screen that is being tested.
 * Note that these functions are only used in the tests for 
 * XMatchVisualInfo and XGetVisualInfo.
 * Other tests call functions in nextvinf.c, which use XGetVisualInfo, and 
 * rely on XGetVisualInfo to work properly.
 */

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include "xtest.h"
#include "stdlib.h"
#include "string.h"
#include "tet_api.h"
#include "X11/Xlib.h"
#include "X11/Xutil.h"
#include "xtestlib.h"
#include "pixval.h"

/*
 * Table and index into it.
 */
static	int 	*Vclass;
static	int 	*Vdepth;
static	int 	VCindex;
static	int 	Nclass;

/*
 * Items are separated by spaces.
 */
#define SEPS		" "
#define LEFT_BRACKET	'('
#define RIGHT_BRACKET	')'
#define COMMA		','

#define	CLASSBUFLEN	40

static char classbuf[CLASSBUFLEN+1];

static struct valname S_displayclass[] = {
	{ StaticGray, "StaticGray" },
	{ GrayScale, "GrayScale" },
	{ StaticColor, "StaticColor" },
	{ PseudoColor, "PseudoColor" },
	{ TrueColor, "TrueColor" },
	{ DirectColor, "DirectColor" },
	{ 0, (char*)0 },
};

/*
 * Initialise the visual class table.  The visual classes that are
 * supported are supplied by the test suite user in the
 * variable XT_VISUAL_CLASSES, together with the depths at which 
 * they are supported.
 * Returns -1 on failure, 0 on success.
 */
int
initvclass()
{
struct	valname *vp;
char	*dp;
char	*tok, *s, *left_bracket, *right_bracket, *comma;
int	Lclass;

	dp = config.visual_classes;
	if (dp == (char*)0) {
		report("XT_VISUAL_CLASSES not set");
		return(-1);
	}

	/*
	 * The number of visual classes in the string is less than the
	 * length of the string.
	 */
	Vclass = (int*)malloc(strlen(dp) * sizeof(int));
	if (Vclass == (int*)0) {
		report("Could not allocate memory for visual class table");
		return(-1);
	}
	Vdepth = (int*)malloc(strlen(dp) * sizeof(int));
	if (Vdepth == (int*)0) {
		report("Could not allocate memory for visual class table");
		return(-1);
	}

	Nclass = 0;
	for (tok = strtok(dp, SEPS); tok; tok = strtok((char*)0, SEPS)) {

		strncpy(classbuf, tok, CLASSBUFLEN);
		classbuf[CLASSBUFLEN] = '\0';
		if (!(left_bracket = strchr(classbuf, LEFT_BRACKET))) {
			report("Display class %s does not contain a '('", tok);
			return(-1);
		} else
			*left_bracket = '\0';
		if (!(right_bracket = strchr(left_bracket+1, RIGHT_BRACKET))) {
			report("Display class %s does not contain a ')'", tok);
			return(-1);
		} else
			*right_bracket = '\0';
		for (vp = S_displayclass; vp->name; vp++) {
			if (strcmp(vp->name, classbuf) == 0)
				break;
		}
		if (vp->name == 0) {
			report("Bad display class %s in config file", tok);
			return(-1);
		}
		Lclass = Nclass;
		for (s = left_bracket; s; s = comma) {
			comma = strchr(++s, COMMA);
			if (comma)
				*comma = '\0';
			if (*s == '\0')
				break;
			Vclass[Nclass] = vp->val;
			Vdepth[Nclass++]   = atov(s);
		}
		if (Nclass <= Lclass) {
			report("Display class %s specifies no depths", tok);
			return(-1);
		}
	}

	return(0);

}

/*
 * Start again at the beginning of the list of visual classes.
 */
void
resetvclass()
{
	VCindex = 0;
}

/*
 * Get the next visual class and depth.  
 * Function returns False if there are no more in the list, 
 * otherwise True.
 */
int
nextvclass(vp, dp)
int 	*vp;
int 	*dp;
{
	if (Vclass == 0) {
		report("initvclass has not been called");
		tet_result(TET_UNRESOLVED);
		return(False);
	}

	if (VCindex >= Nclass)
		return(False);

	*vp = Vclass[VCindex];
	*dp = Vdepth[VCindex++];

	return(True);
}

int
nvclass()
{
	return(Nclass);
}
