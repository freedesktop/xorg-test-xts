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
>># File: xts5/Xlib17/XPolygonRegion.m
>># 
>># Description:
>># 	Tests for XPolygonRegion()
>># 
>># Modifications:
>># $Log: plygnrgn.m,v $
>># Revision 1.2  2005-11-03 08:43:09  jmichael
>># clean up all vsw5 paths to use xts5 instead.
>>#
>># Revision 1.1.1.2  2005/04/15 14:05:23  anderson
>># Reimport of the base with the legal name in the copyright fixed.
>>#
>># Revision 8.0  1998/12/23 23:34:47  mar
>># Branch point for Release 5.0.2
>>#
>># Revision 7.0  1998/10/30 22:57:10  mar
>># Branch point for Release 5.0.2b1
>>#
>># Revision 6.0  1998/03/02 05:26:05  tbr
>># Branch point for Release 5.0.1
>>#
>># Revision 5.0  1998/01/26 03:22:37  tbr
>># Branch point for Release 5.0.1b1
>>#
>># Revision 4.0  1995/12/15 09:11:29  tbr
>># Branch point for Release 5.0.0
>>#
>># Revision 3.1  1995/12/15  01:14:09  andy
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
>>TITLE XPolygonRegion Xlib17
Region
XPolygonRegion(points, n, fill_rule)
XPoint	*points;
int	n = 99;
int	fill_rule;
>>EXTERN
XPoint	poly1[] = { {20,20}, {35,10}, {55,10}, {80,20}, {90,35}, {85,50}, {75,65}, {50,70}, {30,65}, {20,60}, {15,40} };
XPoint	poly2[] = { {75,60}, {60,45}, {55,60}, {30,55}, {35,35}, {15,40}, {20,18}, {45,10}, {70,15}, {55,30}, {80,45} };
XPoint	poly3[] = { {85,40}, {30,20}, {20,55}, {30,69}, {55,35}, {85,44}, {10,43}, {14,66} };
/*
 * The same polygon used in XFillPolygon tests.
 */
XPoint   compshape[] = { {10, 10},  {80, 10},  {100, 30},  {65, 60},  {65, 30}, {85, 60},
                         {30, 50},  {30, 80},  {60, 80},   {60, 5},   {70, 5},  {70, 100}, {10, 100},
};

struct prec {
	XPoint	*points;
	int	size;
} poly[] = { 	{poly1, NELEM(poly1)},
		{poly2, NELEM(poly2)},
		{compshape, NELEM(compshape)}	};

>>ASSERTION Good A
A call to xname returns a region 
comprising the interior of the
filled polygon as described by the 
.A n
points
specified by the
.A points
argument, filled with the
.A fill_rule
argument.
>>STRATEGY
For a convex, concave and complex polygon :
   For fill_rule = EvenOddRule, WindingRule :
      Create a polygon region using xname.
      Create a gc using XCreateGC.
      Set the foreground of the GC to W_FG ^ W_BG.
      Create a drawable with background W_BG using XCreateWindow.
      Fill the polygon on the drawable using XFillPolygon.
      Set the GC clipmask to the region using XSetRegion.
      Set the graphics function of the GC to GXxor using XSetFunction.
      Fill the drawable using XFillRectangle.
      Verify that the entire drawable is W_BG.
>>CODE
int     loop;
XVisualInfo	*vi;
Region	reg;
Window	win;
GC	gc;
unsigned int    width;
unsigned int    height;

	resetvinf(VI_WIN);
	nextvinf(&vi);

	for(loop=0; loop < NELEM(poly); loop++) {
	
		win = makewin(Dsp, vi);
		gc = makegc(Dsp, win);
		fill_rule = EvenOddRule;
		XSetFillRule(Dsp, gc, fill_rule);
		XSetFillStyle(Dsp, gc, FillSolid);
		XSetFunction(Dsp, gc, GXxor);
		XSetForeground(Dsp, gc, W_BG^W_FG);
		points = poly[loop].points;
		n = poly[loop].size;
		reg = XCALL;

		getsize(Dsp, win, &width, &height);
		XFillPolygon(Dsp, win, gc, points, n, Complex, CoordModeOrigin);
		if( checkarea(Dsp, win, (struct area *) NULL, W_BG, W_BG, CHECK_ALL|CHECK_DIFFER)){
			delete("XFillPolygon() did set any pixels to non-background values.");
			return;
		} else
			CHECK;
		XSetRegion(Dsp, gc, reg);
		XFillRectangle(Dsp, win, gc, 0,0, width, height);	

		if( checkarea(Dsp, win, (struct area *) NULL, W_BG, W_BG, CHECK_ALL) == 0){
			report("When used as a clip-mask in a GC,");
			report("the polygon region did not produce the expected clipping.");
			report("Results depend on the correctness of XFillPolygon().");
			FAIL;
		} else
			CHECK;
		XDestroyRegion(reg);

		win = makewin(Dsp, vi);
		gc = makegc(Dsp, win);
		fill_rule = WindingRule;
		XSetFillRule(Dsp, gc, fill_rule);
		XSetFillStyle(Dsp, gc, FillSolid);
		XSetFunction(Dsp, gc, GXxor);
		XSetForeground(Dsp, gc, W_BG^W_FG);
		reg = XCALL;

		getsize(Dsp, win, &width, &height);
		XFillPolygon(Dsp, win, gc, points, n, Complex, CoordModeOrigin);
		if( checkarea(Dsp, win, (struct area *) NULL, W_BG, W_BG, CHECK_ALL|CHECK_DIFFER)){
			delete("XFillPolygon() did set any pixels to non-background values.");
			return;
		} else
			CHECK;
		XSetRegion(Dsp, gc, reg);
		XFillRectangle(Dsp, win, gc, 0,0, width, height);	

		if( checkarea(Dsp, win, (struct area *) NULL, W_BG, W_BG, CHECK_ALL) == 0){
			report("When used as a clip-mask in a GC,");
			report("the polygon region did not produce the expected clipping.");
			report("Results depend on the correctness of XFillPolygon().");
			FAIL;
		} else
			CHECK;
		XDestroyRegion(reg);
	}

	CHECKPASS(NELEM(poly) * 4);
