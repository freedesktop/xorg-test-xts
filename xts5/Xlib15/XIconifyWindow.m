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
>># File: xts5/Xlib15/XIconifyWindow.m
>># 
>># Description:
>># 	Tests for XIconifyWindow()
>># 
>># Modifications:
>># $Log: icnfywdw.m,v $
>># Revision 1.2  2005-11-03 08:42:50  jmichael
>># clean up all vsw5 paths to use xts5 instead.
>>#
>># Revision 1.1.1.2  2005/04/15 14:05:21  anderson
>># Reimport of the base with the legal name in the copyright fixed.
>>#
>># Revision 8.0  1998/12/23 23:33:58  mar
>># Branch point for Release 5.0.2
>>#
>># Revision 7.0  1998/10/30 22:55:57  mar
>># Branch point for Release 5.0.2b1
>>#
>># Revision 6.0  1998/03/02 05:25:20  tbr
>># Branch point for Release 5.0.1
>>#
>># Revision 5.0  1998/01/26 03:21:53  tbr
>># Branch point for Release 5.0.1b1
>>#
>># Revision 4.0  1995/12/15 09:09:20  tbr
>># Branch point for Release 5.0.0
>>#
>># Revision 3.1  1995/12/15  01:11:16  andy
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
>>TITLE XIconifyWindow Xlib15
Status
XIconifyWindow(display, w, screen_number)
Display	*display = Dsp;
Window	w = DRW(Dsp);
int	screen_number = DefaultScreen(Dsp);
>>ASSERTION Good A
A call to xname sends a WM_CHANGE_STATE 
.S ClientMessage 
event with a
.M window
of
.A w ,
a
.M format
of 32 and a first
.M data
element of 
.S IconicState 
to the root window of the screen specified by the
.A screen_number
argument using an event mask of
.S SubstructureRedirectMask |
.S SubstructureNotifyMask
and returns non-zero.
>>STRATEGY
Create a window using XCreateWindow.
Obtain the atom for the string \"WM_CHANGE_STATE\" using XInternAtom.
Select SubstructureNotify events on the root window with XSelectInput.
Generate an event on the root window using XIconifyWindow.
Verify that the call returned non-zero.
Verify that an event was generated with XNextEvent.
Verify that the event type was ClientMessage.
Verify that the event window was correct.
Verify that the event message_type was WM_CHANGE_STATE.
Verify that the event format was 32.
Verify that the first data element of the event structure was IconicState.

Select SubstructureRedirect events on the root window with XSelectInput.
Generate an event on the root window using XIconifyWindow.
Verify that the call returned non-zero.
Verify that an event was generated with XNextEvent.
Verify that the event type was ClientMessage.
Verify that the event window was correct.
Verify that the event message_type was WM_CHANGE_STATE.
Verify that the event format was 32.
Verify that the first data element of the event structure was IconicState.
>>CODE
Status			status;
Atom			wm_change_state;
XEvent			ev, rev;
int			i;
int			nevents = 0;
XVisualInfo		*vp;
unsigned long		event_mask[2];

	resetvinf(VI_WIN);
	nextvinf(&vp);
	w = makewin(display, vp);
	screen_number = DefaultScreen(display);

	event_mask[0] = SubstructureNotifyMask;
	event_mask[1] = SubstructureRedirectMask;

	if( (wm_change_state = XInternAtom(display, "WM_CHANGE_STATE", False)) == None) {
		delete("The string \"WM_CHANGE_STATE\" could not be interned.");
		return;
	} else
		CHECK;

	ev.type = ClientMessage;
	ev.xany.display = display;


	ev.xclient.window = w;
	ev.xclient.message_type = wm_change_state;
	ev.xclient.format = 32;
	ev.xclient.data.l[0] = IconicState;
	ev.xclient.data.l[1] = 0;
	ev.xclient.data.l[2] = 0;
	ev.xclient.data.l[3] = 0;
	ev.xclient.data.l[4] = 0;

	for(i=0; i < 2; i++) {

		startcall(display);
		XSelectInput(display, DRW(display), event_mask[i]);
		endcall(display);
	
		if(geterr() != Success) {
			delete("XSelectInput() failed with an event mask of 0x%lx.", event_mask[i]);
			return;
		} else
			CHECK;
	
		status = XCALL;
	
		if(status == 0) {
			delete("%s() returned zero.", TestName);
			return;
		} else
			CHECK;
	
		rev.type = -1;
		if( (nevents = getevent(display, &rev)) == 0 ) {
			report("No event was generated.");
			FAIL;
		} else {
			CHECK;
			if(nevents != 1) {
				delete("There were %d events generated instead of 1.", nevents);
				return;
			} else	{
				CHECK;
	
				rev.xclient.data.l[1] = 0;
				rev.xclient.data.l[2] = 0;
				rev.xclient.data.l[3] = 0;
				rev.xclient.data.l[4] = 0;
	
				if( checkevent(&ev, &rev) != 0 ) {
					FAIL;
				} else
					CHECK;
			}
		}
	}

	CHECKPASS(11);

>>ASSERTION Bad B 1
>># Untestable, and not worth the effort of adding XTest extension facilities
>># to provoke the error.
When the atom name \(lqWM_CHANGE_STATE\(rq cannot be interned, then
a call to xname
does not send a message and returns zero.
>>ASSERTION Bad B 1
>># Untestable, and not worth the effort of adding XTest extension facilities
>># to provoke the error.
When the
.S ClientMessage
event cannot be sent, then
a call to xname
returns zero.
>># Assertion removed at request of MIT (Bug Report 67) because
>># XIconifyWindow cannot generate this error (Spec bug)
>># >>ASSERTION Bad A
>># .ER Window
