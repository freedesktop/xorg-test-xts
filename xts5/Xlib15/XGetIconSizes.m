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

Copyright (c) Applied Testing and Technology, Inc. 1995
All Rights Reserved.

>># Project: VSW5
>># 
>># File: xts5/Xlib15/XGetIconSizes.m
>># 
>># Description:
>># 	Tests for XGetIconSizes()
>># 
>># Modifications:
>># $Log: gticnszs.m,v $
>># Revision 1.2  2005-11-03 08:42:48  jmichael
>># clean up all vsw5 paths to use xts5 instead.
>>#
>># Revision 1.1.1.2  2005/04/15 14:05:20  anderson
>># Reimport of the base with the legal name in the copyright fixed.
>>#
>># Revision 8.0  1998/12/23 23:33:52  mar
>># Branch point for Release 5.0.2
>>#
>># Revision 7.0  1998/10/30 22:55:45  mar
>># Branch point for Release 5.0.2b1
>>#
>># Revision 6.0  1998/03/02 05:25:14  tbr
>># Branch point for Release 5.0.1
>>#
>># Revision 5.0  1998/01/26 03:21:47  tbr
>># Branch point for Release 5.0.1b1
>>#
>># Revision 4.1  1996/05/09 00:28:47  andy
>># Corrected Xatom include
>>#
>># Revision 4.0  1995/12/15  09:09:02  tbr
>># Branch point for Release 5.0.0
>>#
>># Revision 3.1  1995/12/15  01:10:44  andy
>># Prepare for GA Release
>>#
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
>>TITLE XGetIconSizes Xlib15
Status
XGetIconSizes(display, w, size_list_return, count_return)
Display		*display = Dsp;
Window		w = DRW(Dsp);
XIconSize	**size_list_return = &icnszp;
int		*count_return = &countret;
>>EXTERN
#include	"X11/Xatom.h"
#define		NumPropIconSizeElements 6
XIconSize	*icnszp;
int		countret;
>>ASSERTION Good A
When the WM_ICON_SIZES property has been set for the window
.A w ,
and has format 32, a value which is a multiple of 6 elements and type
.S WM_ICON_SIZE ,
then a call to xname returns a list of
.S XIconSize
structures, which can be freed with XFree, in the
.A size_list_return
argument and the number of structures in the
.A count_return
argument and returns non-zero.
>>STRATEGY
Create a window using XCreateWindow.
Set the WM_ICON_SIZES property using XSetIconSizes.
Obtain the WM_ICON_SIZES property using XGetIconSizes.
Verify that the call did not return False.
Verify that the property value is correct.
Release the allocated memory using XFree.
>>CODE
Status		status;
XVisualInfo	*vp;
int		i;
int		v;
XIconSize	sizelist[5];
int		count = 5;
int		rcount;
XIconSize	*sp = NULL, *sref;


	resetvinf(VI_WIN);
	nextvinf(&vp);
	w = makewin(display, vp);

	for(i=0, sp=sizelist, v=0; i<count; i++, sp++) {
		sp->min_width = v++;
		sp->min_height = v++;
		sp->max_width = v++;
		sp->max_height = v++;
		sp->width_inc = v++;
		sp->height_inc = v++;
	}

	XSetIconSizes(display, w, sizelist, count);

	size_list_return = &sp;
	count_return = &rcount;

	status = XCALL;

	if(status == False) {
		report("%s() returned False.", TestName);
		FAIL;
	} else
		CHECK;

	if( sp == (XIconSize *) NULL) {
		report("No value was set for the WM_ICON_SIZES property.");
		FAIL;
	} else {
		
		CHECK;
		if( rcount != count ) {
			report("%s() returned %d elements instead of %d.", TestName, rcount, count);
			FAIL;
		} else {
			for(i=0, sref=sp, v=0; i<count; i++, sref++) {

				if( sref->min_width != v++ ) {
					report("The min_width component of XIconSize structure %d was %d instead of %d.", i, sref->min_width, v-1);
					FAIL;
				} else
					CHECK;

				if( sref->min_height != v++ ) {
					report("The min_height component of XIconSize structure %d was %d instead of %d.", i, sref->min_height, v-1);
					FAIL;
				} else
					CHECK;

				if( sref->max_width != v++ ) {
					report("The max_width component of XIconSize structure %d was %d instead of %d.", i, sref->max_width, v-1);
					FAIL;
				} else
					CHECK;

				if( sref->max_height != v++ ) {
					report("The max_height component of XIconSize structure %d was %d instead of %d.", i, sref->max_height, v-1);
					FAIL;
				} else
					CHECK;

				if( sref->width_inc != v++ ) {
					report("The width_inc component of XIconSize structure %d was %d instead of %d.", i, sref->width_inc, v-1);
					FAIL;
				} else
					CHECK;

				if( sref->height_inc != v++ ) {
					report("The height_inc component of XIconSize structure %d was %d instead of %d.", i, sref->height_inc, v-1);
					FAIL;
				} else
					CHECK;

			}
		}
		XFree((char *)sp);
	}

	CHECKPASS(6*count+2);

>>ASSERTION Good A
When the WM_ICON_SIZE property is not set for the window
.A w ,
or has format other than 32, a value which is not a multiple of 6 elements
or type other than WM_ICON_SIZE,
then a call
to xname returns zero.
>>STRATEGY
Create a window with XCreateWindow.
Obtain the value of the unset WM_ICON_SIZES property using XGetIconSizes.
Verify that the function returned zero.

Create a window with XCreateWindow.
Set the WM_ICON_SIZES property to have format 16 size 6 elements and type WM_ICON_SIZE using XChangeProperty.
Obtain the value of the WM_ICON_SIZES property using XGetIconSizes.
Verify that the call returned zero

Create a window with XCreateWindow.
Set the WM_ICON_SIZES property to have format 32 size 13 elements and type WM_ICON_SIZE using XChangeProperty.
Obtain the value of the WM_ICON_SIZES property using XGetIconSizes.
Verify that the call returned zero

Create a window with XCreateWindow.
Set the WM_ICON_SIZES property to have format 32 size 6 elements and type WM_SIZE_HINTS using XChangeProperty.
Obtain the value of the WM_ICON_SIZES property using XGetIconSizes.
Verify that the call returned zero

>>CODE
Status		status;
XVisualInfo	*vp;
XIconSize	*slp = (XIconSize *) NULL;
int		cret;
int		count = 3;
XIconSize	sl[3];

	resetvinf(VI_WIN);
	nextvinf(&vp);
	size_list_return = &slp;
	count_return = &cret;

	w = makewin(display, vp);
/* unset property */

	status = XCALL;

	if(status != False) {
		report("%s() did not return False when the property was unset.", TestName);
		FAIL;
	} else
		CHECK;

	w = makewin(display, vp);
/* format 16 */
	XChangeProperty(display, w, XA_WM_ICON_SIZE, XA_WM_ICON_SIZE, 16, PropModeReplace, (unsigned char *) sl, count*NumPropIconSizeElements);

	status = XCALL;

	if(status != False) {
		report("%s() did not return False when the property format was 16.", TestName);
		FAIL;
	} else
		CHECK;

	w = makewin(display, vp);
/* size 13 */
	XChangeProperty(display, w, XA_WM_ICON_SIZE, XA_WM_ICON_SIZE, 32, PropModeReplace, (unsigned char *) sl, NumPropIconSizeElements*2 + 1);

	status = XCALL;

	if(status != False) {
		report("%s() did not return False when the number of elements was 13.", TestName);
		FAIL;
	} else
		CHECK;

	w = makewin(display, vp);
/* type WM_SIZE_HINTS */
	XChangeProperty(display, w, XA_WM_ICON_SIZE, XA_WM_SIZE_HINTS, 32, PropModeReplace, (unsigned char *) sl, count*NumPropIconSizeElements);

	status = XCALL;

	if(status != False) {
		report("%s() did not return False when the property type was WM_SIZE_HINTS.", TestName);
		FAIL;
	} else
		CHECK;

	CHECKPASS(4);

>>ASSERTION Bad A
.ER BadWindow 
>># Kieron	Action	Review
