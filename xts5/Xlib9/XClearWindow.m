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
>># File: xts5/Xlib9/XClearWindow.m
>># 
>># Description:
>># 	Tests for XClearWindow()
>># 
>># Modifications:
>># $Log: clrwdw.m,v $
>># Revision 1.2  2005-11-03 08:43:52  jmichael
>># clean up all vsw5 paths to use xts5 instead.
>>#
>># Revision 1.1.1.2  2005/04/15 14:05:33  anderson
>># Reimport of the base with the legal name in the copyright fixed.
>>#
>># Revision 8.0  1998/12/23 23:27:39  mar
>># Branch point for Release 5.0.2
>>#
>># Revision 7.0  1998/10/30 22:46:05  mar
>># Branch point for Release 5.0.2b1
>>#
>># Revision 6.0  1998/03/02 05:19:49  tbr
>># Branch point for Release 5.0.1
>>#
>># Revision 5.0  1998/01/26 03:16:20  tbr
>># Branch point for Release 5.0.1b1
>>#
>># Revision 4.0  1995/12/15 08:51:29  tbr
>># Branch point for Release 5.0.0
>>#
>># Revision 3.1  1995/12/15  00:52:30  andy
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
>>TITLE XClearWindow Xlib9
>>#SYNOPSIS
void
XClearWindow(display, w)
Display	*display = Dsp;
Window	w;
>>ASSERTION Good A
A call to xname
paints 
the entire area 
in the window specified by the
.A w
argument
with the window's background pixel or pixmap.
>>STRATEGY
Create window.
Set window's background pixel to 0.
Call XClearWindow.
Verify window is set.

Set window's background pixel to 1.
Call XClearWindow.
Verify window is set.

Set window background pixmap.
Verify that window is set.
>>CODE
Pixmap  pm;
XVisualInfo	*vp;

	for (resetvinf(VI_WIN); nextvinf(&vp); ) {
		w = makewin(display, vp);

		XSetWindowBackground(display, w, W_FG);
		XCALL;

		if (checkarea(display, w, (struct area *)0, W_FG, W_BG, 0) == False) {
			report("Clearing to W_FG failed");
			tet_result(TET_FAIL);
		} else {
			CHECK;
		}

		XSetWindowBackground(display, w, W_BG);
		XCALL;
		if (checkarea(display, w, (struct area *)0, W_BG, W_BG, 0) == False) {
			report("Clearing to W_BG failed");
			tet_result(TET_FAIL);
		} else
			CHECK;

		pm = maketile(display, w);
		XSetWindowBackgroundPixmap(display, w, pm);
		XCALL;

		/*
		 * Check the tiled area first and then the outside.
		 */
		if (checktile(display, w, (struct area*)0, 0, 0, pm) == False) {
			report("Failed with background pixmap");
			FAIL;
		} else
			CHECK;
	}

	CHECKPASS(3*nvinf());

>>ASSERTION  Good A
On a call to xname the subwindow-mode is
.S ClipByChildren .
>>STRATEGY
Create window
Create overlapping child window.
Call XClearWindow.
Verify that the child has not been drawn upon.
>>CODE
struct  area    carea;
Pixmap  pm;
Window  child;
XVisualInfo	*vp;

	for (resetvinf(VI_WIN); nextvinf(&vp); ) {
		w = makewin(display, vp);
		carea.x = 10;
		carea.y = 0;
		carea.width = carea.height = 0;
		child = crechild(display, w, &carea);

		pm = maketile(display, w);
		XSetWindowBackgroundPixmap(display, w, pm);
		XCALL;

		carea.x = carea.y = carea.width = carea.height = 0;
		if (checkarea(display, child, &carea, W_BG, W_BG, CHECK_ALL) == False) {
			report("Child window was drawn upon by clear window");
			FAIL;
		} else {
			CHECK;
		}
	}

	CHECKPASS(nvinf());

>>ASSERTION def
>>#DEFINITION
When the window has a defined background tile, then the rectangle
is tiled with a plane-mask of all ones and the
.S GXCopy
function.
>>ASSERTION Good A
When the window has a
.M background_pixmap 
of
.S None ,
>># It is the last thing that was set that matters.
>>#and an undefined
>>#.M background_pixel ,
then the contents of the window are not changed.
>>STRATEGY
Create window.
Set background pixel to W_FG.
Set background pixmap to None.
Call XClearWindow.
Check that the whole window is left alone.
>>CODE
XVisualInfo	*vp;

	for (resetvinf(VI_WIN); nextvinf(&vp); ) {
		w = makewin(display, vp);
		pattern(display, w);
		XSetWindowBackground(display, w, W_FG);
		XSetWindowBackgroundPixmap(display, w, None);
		XCALL;
		if (checkpattern(display, w, (struct area *)0) == False) {
			report("Window was changed when background was None");
			FAIL;
		} else {
			CHECK;
		}
	}
	CHECKPASS(nvinf());

>>ASSERTION Good A
When the window has a
.M background_pixmap 
of
.S ParentRelative
and the parent has a 
.M background_pixmap
of
.S None ,
then the contents of the window are not changed.
>>STRATEGY
Create parent window.
Create a child window covering the parent.
Draw pattern on the child window.
Set parent window background to none.
Set child window background pixmap to ParentRelative.
Clear area of child
Verify that there was no change to the child window.
>>CODE
struct  area    area;
Window  child;
Window  win;
XVisualInfo	*vp;

	for (resetvinf(VI_WIN); nextvinf(&vp); ) {
		win = makewin(display, vp);
		area.x = area.y = area.width = area.height = 0;
		child = crechild(display, win, &area);
		pattern(display, child);

		/*
		 * Set parent to None, child to Parent Relative.
		 */
		XSetWindowBackgroundPixmap(display, win, None);
		XSetWindowBackgroundPixmap(display, child, ParentRelative);

		w = child;
		XCALL;
		if (checkpattern(display, child, (struct area *)0) == False) {
			report("Window was changed when background was ParentRelative");
			FAIL;
		} else {
			CHECK;
		}
	}
	CHECKPASS(nvinf());

>># Assertion removed because the situation is not possible.
>>#When the window does not have the same depth as its 
>>#parent and has a background-pixmap of
>>#ParentRelative, then a BadMath error occurs.
>>ASSERTION Bad A
.ER Match inputonly
>>ASSERTION Bad A
.ER BadWindow
>># HISTORY steve Completed	Written in new format and style
>># HISTORY kieron Completed	Global and pixel checking to do - 19/11/90
>># HISTORY dave Completed	Final checking to do - 21/11/90
