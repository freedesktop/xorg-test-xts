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
>># File: xts5/Xlib6/XCreateFontCursor.m
>># 
>># Description:
>># 	Tests for XCreateFontCursor()
>># 
>># Modifications:
>># $Log: crtfntcrsr.m,v $
>># Revision 1.2  2005-11-03 08:43:40  jmichael
>># clean up all vsw5 paths to use xts5 instead.
>>#
>># Revision 1.1.1.2  2005/04/15 14:05:29  anderson
>># Reimport of the base with the legal name in the copyright fixed.
>>#
>># Revision 8.0  1998/12/23 23:26:51  mar
>># Branch point for Release 5.0.2
>>#
>># Revision 7.0  1998/10/30 22:45:09  mar
>># Branch point for Release 5.0.2b1
>>#
>># Revision 6.0  1998/03/02 05:19:04  tbr
>># Branch point for Release 5.0.1
>>#
>># Revision 5.0  1998/01/26 03:15:35  tbr
>># Branch point for Release 5.0.1b1
>>#
>># Revision 4.0  1995/12/15 08:48:54  tbr
>># Branch point for Release 5.0.0
>>#
>># Revision 3.1  1995/12/15  00:47:51  andy
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
>>TITLE XCreateFontCursor Xlib6
Cursor
XCreateFontCursor(display, shape)
Display *display = Dsp;
unsigned int shape;
>>SET startup fontstartup
>>SET cleanup fontcleanup
>>ASSERTION Good B 1
When the
.A shape 
argument is
a defined glyph in the standard cursor font,
then a call to xname creates a
.S Cursor
with a black foreground and a white background
corresponding to the 
.A shape
argument
and returns the cursor ID.
>>STRATEGY
Get TET variable XT_FONTCURSOR_GOOD.
Call XCreateFontCursor with shape of this value.
Verify that XCreateFontCursor returns non-zero.
>>CODE
Cursor	qstat;

/* Get TET variable XT_FONTCURSOR_GOOD */
	/* UNSUPPORTED is not allowed */
	shape = config.fontcursor_good;
	if (shape == -1) {
		delete("A value of UNSUPPORTED is not allowed for XT_FONTCURSOR_GOOD");
		return;
	}

	trace("Shape used is %x", shape);
/* Call XCreateFontCursor with shape of this value, */
/* else call XCreateFontCursor with shape of zero. */
	
	qstat = XCALL;

/* Verify that XCreateFontCursor returns non-zero. */
	if (qstat == 0) {
		report("Returned wrong value %ld", (long) qstat);
		FAIL;
	} else
		CHECK;

	CHECKUNTESTED(1);
>>ASSERTION Bad A
When the
.A shape 
argument is not
a defined glyph in the standard cursor font,
then a
.S BadValue
error occurs.
>>STRATEGY
Get TET variable XT_FONTCURSOR_BAD.
Call XCreateFontCursor with shape of this value.
Verify that a BadValue error occurs.
>>CODE BadValue

/* Get TET variable XT_FONTCURSOR_BAD */
	shape = config.fontcursor_bad;
	if (shape == -1) {
		unsupported("There are no invalid cursor glyph values");
		return;
	}

	trace("Shape used is %x", shape);
/* Call XCreateFontCursor with shape of this value, */
/* else call XCreateFontCursor with shape of zero. */
	XCALL;

/* Verify that a BadValue error occurs. */
	if (geterr() == BadValue)
		PASS;
	else
		FAIL;
>>ASSERTION Bad B 1
.ER BadAlloc
>># HISTORY kieron Completed	Reformat to pass ca, plus correction
>># HISTORY peterc Completed	Wrote STRATEGY and CODE.
