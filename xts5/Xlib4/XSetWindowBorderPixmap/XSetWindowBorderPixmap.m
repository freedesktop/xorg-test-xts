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
>># File: xts5/Xlib4/XSetWindowBorderPixmap/XSetWindowBorderPixmap.m
>># 
>># Description:
>># 	Tests for XSetWindowBorderPixmap()
>># 
>># Modifications:
>># $Log: stwdwbrdrp.m,v $
>># Revision 1.2  2005-11-03 08:43:36  jmichael
>># clean up all vsw5 paths to use xts5 instead.
>>#
>># Revision 1.1.1.2  2005/04/15 14:05:26  anderson
>># Reimport of the base with the legal name in the copyright fixed.
>>#
>># Revision 8.0  1998/12/23 23:26:38  mar
>># Branch point for Release 5.0.2
>>#
>># Revision 7.0  1998/10/30 22:44:56  mar
>># Branch point for Release 5.0.2b1
>>#
>># Revision 6.0  1998/03/02 05:18:53  tbr
>># Branch point for Release 5.0.1
>>#
>># Revision 5.0  1998/01/26 03:15:24  tbr
>># Branch point for Release 5.0.1b1
>>#
>># Revision 4.0  1995/12/15 08:48:13  tbr
>># Branch point for Release 5.0.0
>>#
>># Revision 3.1  1995/12/15  00:46:49  andy
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
>>TITLE XSetWindowBorderPixmap Xlib4
void

Display	*display = Dsp;
Window	w;
Pixmap	border_pixmap;
>>EXTERN
static struct	area	ap;
static Window	parent;

static void
inittp()
{
	tpstartup();

	ap.x = 50;
	ap.y = 60;
	ap.width = 20;
	ap.height= 20;
}

static void
perform_map(display, w)
Display	*display;
Window	w;
{
	XEvent	event;
/* Await visibilty */
	XSelectInput(display, w , ExposureMask);
	XMapWindow(display, w);
	XWindowEvent(display, w, ExposureMask, &event);
}

>>SET	tpstartup inittp
>>ASSERTION Good A
A call to xname sets the border pixmap of the window to the pixmap
specified by
.A border_pixmap .
>>STRATEGY
Create a window, with a wide border.
Set the border-pixel by calling xname.
Unmap then remap the window, to ensure the border change occurs.
Get the border-pixel.
Verify the border pixel was set.
Reset the border-pixel by calling xname.
>># The unmap/remap is to allow this test to pass, even if the borders
>># are not being repainted as soon as the pixel is changed.		stu
Unmap then remap the window, to ensure the border change occurs.
Get the border-pixel.
Verify the border pixel was set.
>>CODE

	parent = defdraw(display, VI_WIN);

	w = creunmapchild(display, parent, &ap);

	XSetWindowBorderWidth(display, w, 5);
	XSetWindowBorder(display, w, W_FG);

	perform_map(display, w);

	border_pixmap = maketile(display, w);
	XCALL;

	XUnmapWindow(display, w);
	perform_map(display,w);

	PIXCHECK(display, parent);
	
	CHECKPASS(1);
>>ASSERTION Good A
When the border pixmap is changed, then the border is repainted.
>>STRATEGY
Create a mapped window with a wide border.
Set the border-pixmap by calling xname.
Verify the border pixmap was repainted.
>>CODE

/* Create windows */
	parent = defdraw(display, VI_WIN);
	w = creunmapchild(display, parent, &ap);
/* Set up child window border for test */
	XSetWindowBorderWidth(display, w, 5);
	XSetWindowBorder(display, w, W_FG);

	perform_map(display, w);

	border_pixmap = maketile(display,w);
	XCALL;
	
	PIXCHECK(display, parent);

	CHECKPASS(1);
>>ASSERTION Good A
When
.A border_pixmap
is
.S CopyFromParent ,
then the border-pixmap attribute is copied from the parent window.
>>STRATEGY
Create parent window.
Set parent border-pixmap attribute.
Set child window border-pixmap to CopyFromParent.
Ensure that window is mapped.
Pixmap verify to check that border is correct.
>>CODE
XVisualInfo	*vp;

	for (resetvinf(VI_WIN); nextvinf(&vp); ) {
		parent = makedrawable(display, vp);

		w = parent;
		border_pixmap = maketile(display, parent);
		XCALL;

		w = mkwinchild(display, vp, &ap, False, parent, 5);
		perform_map(display, w);

		border_pixmap = CopyFromParent;
		XCALL;

		PIXCHECK(display, parent);
	}

	CHECKPASS(nvinf());

>>ASSERTION Good B 1
When
.A border_pixmap
is
.S CopyFromParent
and the window is a root window, then the default border pixmap is restored.
>>ASSERTION Bad A
.ER BadPixmap CopyFromParent
>>ASSERTION Bad C
If windows with depth other than one are supported:
When
.A border_pixmap
and the window do not have the same depth, then a
.S BadMatch
error occurs.
>>STRATEGY
Use depth of 1 for the pixmap.
Find a visual not of depth 1.
If not such a visual
  UNSUPPORTED
else
  Attempt to set border_pixmap to the depth 1 pixmap.
  Verify that a BadMatch error occurs.
>>CODE BadMatch
Pixmap	pm;
XVisualInfo	*vp;
int 	found = 0;

	for (resetvinf(VI_WIN); nextvinf(&vp); ) {
		if (vp->depth != 1) {
			found = 1;
			break;
		}
	}

	if (!found) {
		unsupported("Only windows with depth one are supported");
		return;
	}

	pm = XCreatePixmap(display, DRW(display), 2, 2, 1);
	border_pixmap = pm;

	parent = defdraw(display, VI_WIN);
	w = mkwinchild(display, vp, &ap, False, parent, 2);

	XCALL;
	if (geterr() == BadMatch)
		PASS;
	else
		FAIL;
	XFreePixmap(display, pm);
>>ASSERTION Bad C
If multiple window depths are supported:
When
.A border_pixmap
is
.S CopyFromParent ,
and the window does not have the same depth as the parent window,
then a
.S BadMatch
error occurs.
>>STRATEGY
If two different depth windows are supported.
  Create window with different depth to parent.
  Attempt to set border_pixmap to ParentRelative.
  Verify that a BadMatch error occurs.
else
  UNSUPPORTED.
>>CODE BadMatch
XVisualInfo	*vp;
XVisualInfo	*vp2 = 0;
int 	found = 0;

	for (resetvinf(VI_WIN); nextvinf(&vp); ) {
		if (vp2 == 0) {
			vp2 = vp;
		} else if (vp->depth != vp2->depth) {
			found = 1;
			break;
		}
	}

	if (!found) {
		unsupported("Only one depth of window is supported");
		return;
	}

	parent = makedrawable(display, vp2);
	w      = mkwinchild(display, vp, &ap, False, parent, 1);

	border_pixmap = CopyFromParent;
	(void)XCALL;

	if (geterr() == BadMatch)
		PASS;
	else
		FAIL;
>>ASSERTION Bad A
.ER BadMatch wininputonly
>>ASSERTION Bad A
.ER BadWindow 
