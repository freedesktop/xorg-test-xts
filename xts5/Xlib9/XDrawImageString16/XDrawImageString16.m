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
>># File: xts5/Xlib9/XDrawImageString16/XDrawImageString16.m
>># 
>># Description:
>># 	Tests for XDrawImageString16()
>># 
>># Modifications:
>># $Log: drwimgst16.m,v $
>># Revision 1.2  2005-11-03 08:43:53  jmichael
>># clean up all vsw5 paths to use xts5 instead.
>>#
>># Revision 1.1.1.2  2005/04/15 14:05:34  anderson
>># Reimport of the base with the legal name in the copyright fixed.
>>#
>># Revision 8.0  1998/12/23 23:28:17  mar
>># Branch point for Release 5.0.2
>>#
>># Revision 7.0  1998/10/30 22:46:46  mar
>># Branch point for Release 5.0.2b1
>>#
>># Revision 6.0  1998/03/02 05:20:24  tbr
>># Branch point for Release 5.0.1
>>#
>># Revision 5.0  1998/01/26 03:16:54  tbr
>># Branch point for Release 5.0.1b1
>>#
>># Revision 4.0  1995/12/15 08:53:08  tbr
>># Branch point for Release 5.0.0
>>#
>># Revision 3.1  1995/12/15  00:53:00  andy
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
>>TITLE XDrawImageString16 Xlib9
void

Display *display = Dsp;
Drawable d;
GC		gc;
int 	x = 5;
int 	y = 20;
XChar2b	*string = defstr;
int 	length = NELEM(defstr);
>>EXTERN

/* Needed because function not used */
#define	A_DRAW	A_DRAWABLE

static	XChar2b defstr[] = {
	{1, 74},
	{1, 79},
	{48, 120},
	{36, 116},
	{36, 80},
	{48, 43},
	{33, 45},
};

static  Font    Xtfonts[XT_NFONTS];

>>SET startup localstartup
>>SET cleanup fontcleanup
static void
localstartup()
{
	fontstartup();
	if(Dsp) {
		openfonts(Xtfonts, XT_NFONTS);
		setgcfont(Xtfonts[2]);
	}
}

static void
rev(disp, gc)
Display *disp;
GC		gc;
{
	XSetForeground(disp, gc, W_BG);
	XSetBackground(disp, gc, W_FG);
}

>>ASSERTION Good A
A call to xname first fills the destination rectangle with the
.M background
pixel value and next draws a
.A string
of 2-byte or 16-bit characters, selected from the
.A gc 's
.M font ,
using the
.M foreground
pixel value.
>>STRATEGY
Reverse foreground and background.
Draw string
Pixmap verify
>>CODE
XVisualInfo	*vp;

	for (resetvinf(VI_WIN_PIX); nextvinf(&vp); ) {
		d = makewin(display, vp);
		gc = makegc(display, d);

		rev(display, gc);

		XSetFont(display, gc, Xtfonts[2]);
		x = 2;
		y = 30;
		XCALL;

		XSetFont(display, gc, Xtfonts[6]);
		x = 100;
		y = 60;
		XCALL;

		PIXCHECK(display, d);
	}

	CHECKPASS(nvinf());
>>ASSERTION def
>># NOTE is it always the Top-left corner, what if font is R-to-L ??? Ask Bob?
The upper-left corner of the filled rectangle is at
[
.A x ,
.A y
- max-ascent],
with width equal to the sum of the per-character
.M width s,
and with height
font-ascent + font-descent,
where font-ascent and font-descent
are the logical ascent and descent of the
.M font .
>>ASSERTION Good A
The origin of the string is at
[
.A x ,
.A y
].
>>STRATEGY
Vary x and y
Call XDrawImageString16 to draw string.
Pixmap verify.
>>CODE
XVisualInfo	*vp;
unsigned int 	width, height;

	/* Restrict length of string */
	length = 3;

	for (resetvinf(VI_WIN_PIX); nextvinf(&vp); ) {
		d = makewin(display, vp);
		gc = makegc(display, d);

		rev(display, gc);

		getsize(display, d, &width, &height);

		for (x = 0; x < width; x += 15) {
			for (y = 0; y < height; y += 16) {
				XCALL;
			}
		}

		PIXCHECK(display, d);
	}

	CHECKPASS(nvinf());

>>ASSERTION Good A
The effective
.M function
is 
.S GXcopy , 
and the effective
.M fill_style
is
.S FillSolid . 
>>STRATEGY
Set gc function to GXxor
Set fill-style to FillTiled
Set Tile.
Verify that these settings have no effect.
>>CODE
XVisualInfo	*vp;
XImage	*sav;
Pixmap	tile;

	for (resetvinf(VI_WIN_PIX); nextvinf(&vp); ) {
		d = makewin(display, vp);
		gc = makegc(display, d);

		rev(display, gc);

		XCALL;
		sav = savimage(display, d);
		dclear(display, d);

		tile = makepixm(display, vp);
		pattern(display, tile);

		XSetFunction(display, gc, GXxor);
		XSetFillStyle(display, gc, FillTiled);
		XSetTile(display, gc, tile);

		XCALL;
		XCALL;

		if (compsavimage(display, d, sav))
			CHECK;
		else {
			report("Effective function and fill style afected result");
			FAIL;
		}
	}

	CHECKPASS(nvinf());

>>ASSERTION Good B 3
When fonts are defined with linear indexing rather than 2-byte matrix indexing,
then each 
.S XChar2b 
structure is interpreted as a 16-bit number with byte1 as the 
most-significant byte.
>>ASSERTION gc
On a call to xname the GC components
.M plane-mask ,
.M font ,
.M subwindow-mode ,
.M clip-x-origin , 
.M clip-y-origin
and
.M clip-mask
are used.
>>ASSERTION gc
On a call to xname the GC mode-dependent components
.M foreground
and
.M background
are used.
>>ASSERTION Bad A
.ER BadDrawable
>>ASSERTION Bad A
.ER BadGC
>>ASSERTION Bad A
.ER BadMatch inputonly
>>ASSERTION Bad A
.ER BadMatch gc-drawable-depth
>>ASSERTION Bad A
.ER BadMatch gc-drawable-screen
>># HISTORY kieron Completed    Checked and passed ac
