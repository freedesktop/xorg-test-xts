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
>># File: xts5/Xlib12/XSync.m
>># 
>># Description:
>># 	Tests for XSync()
>># 
>># Modifications:
>># $Log: sync.m,v $
>># Revision 1.2  2005-11-03 08:42:37  jmichael
>># clean up all vsw5 paths to use xts5 instead.
>>#
>># Revision 1.1.1.2  2005/04/15 14:05:18  anderson
>># Reimport of the base with the legal name in the copyright fixed.
>>#
>># Revision 8.0  1998/12/23 23:33:29  mar
>># Branch point for Release 5.0.2
>>#
>># Revision 7.0  1998/10/30 22:55:00  mar
>># Branch point for Release 5.0.2b1
>>#
>># Revision 6.0  1998/03/02 05:24:53  tbr
>># Branch point for Release 5.0.1
>>#
>># Revision 5.0  1998/01/26 03:21:25  tbr
>># Branch point for Release 5.0.1b1
>>#
>># Revision 4.0  1995/12/15 09:07:54  tbr
>># Branch point for Release 5.0.0
>>#
>># Revision 3.1  1995/12/15  01:08:38  andy
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
>>TITLE XSync Xlib12
void
XSync(display, discard)
Display *display = Dsp;
Bool discard;
>>ASSERTION Good B 3
A call to xname flushes
the output buffer and waits until all requests have been received
and processed by the X server.
>>ASSERTION Good A
A call to xname
calls the client's error handling routine
for each error event received.
>>STRATEGY
Create client1.
Create pixmap with client1.
Create client2.
Call XFreePixmap from client2.
Call XSync from client2 to insure all potential errors arrive.
Verify that an error was received.
>>CODE
Pixmap	pm;
Display *client1;
Display *client2;
XVisualInfo	*vp;

	resetvinf(VI_PIX);
	nextvinf(&vp);
/* Create client1. */
	client1 = opendisplay();
	if (client1 == (Display *) NULL) {
		delete("Can not open display");
		return;
	}
	else
		CHECK;
/* Create pixmap with client1. */
	/* avoid using makepixm() */
	pm = XCreatePixmap(client1, DRW(client1), 10, 10, 1);
/* Create client2. */
	client2 = opendisplay();
	if (client2 == (Display *) NULL) {
		delete("Can not open display");
		return;
	}
	else
		CHECK;
/* Call XFreePixmap from client2. */
	_startcall(client2);
	XFreePixmap(client2, pm);
/* Call XSync from client2 to insure all potential errors arrive. */
	XSync(client2, True);
	_endcall(client2);
/* Verify that an error was received. */
	if (geterr() != BadPixmap || getbadvalue() != pm) {
		report("Missing error event");
		FAIL;
	}
	else
		CHECK;
	XFreePixmap(client1, pm);

	CHECKPASS(3);
>>ASSERTION Good A
During a call to xname,
any events generated by the X server are enqueued
into the client's event queue.
>>STRATEGY
Create client1.
Create window with client1.
Select MapNotify events with client1 on this window.
Create client2.
Select MapNotify events with client2 on this window.
Call XFlush with client1 to insure server has received create
window request before client2 requests which reference the window.
Call XFlush with client2 to insure server has received select
request before the event is generated.
Map window.
Call XSync for client1.
Verify that there are no errors.
Verify that client1 was delivered expected event.
Call XSync for client2.
Verify that there are no errors.
Verify that client2 was delivered expected event.
>>CODE
Display *client1;
Display *client2;
Window	w;
XEvent	event;
XWindowAttributes attrs;

/* Create client1. */
	client1 = opendisplay();
	if (client1 == (Display *) NULL) {
		delete("Can not open display");
		return;
	}
	else
		CHECK;
/* Create window with client1. */
	w = mkwin(client1, (XVisualInfo *) NULL, (struct area *) NULL, False);
/* Select MapNotify events with client1 on this window. */
	XSelectInput(client1, w, StructureNotifyMask);
/* Create client2. */
	client2 = opendisplay();
	if (client2 == (Display *) NULL) {
		delete("Can not open display");
		return;
	}
	else
		CHECK;
/* Call XGetWindowAttributes with client1 to insure server has received create */
/* window request before client2 requests which reference the window. */
	XFlush(client1);
	XGetWindowAttributes(client1, w, &attrs);
/* Select MapNotify events events with client2 on this window. */
	XSelectInput(client2, w, StructureNotifyMask);
/* Call XFlush & do req. with client2 to insure server has received select */
/* request before the event is generated. */
	XFlush(client2);
	XGetWindowAttributes(client2, w, &attrs);
/* Map window. */
	XMapWindow(client1, w);
/* Call XSync for client1. */
	_startcall(client1);
	XSync(client1, False);
	_endcall(client1);
/* Verify that there are no errors. */
	if (geterr() != Success) {
		delete("Got %s, Expecting Success", errorname(geterr()));
		return;
	}
	else
		CHECK;
/* Verify that client1 was delivered expected event. */
	if (!XCheckTypedWindowEvent(client1, w, MapNotify, &event)) {
		report("Selected event was not delivered to client1.");
		FAIL;
	}
	else
		CHECK;
/* Call XSync for client2. */
	_startcall(client2);
	XSync(client2, False);
	_endcall(client2);
/* Verify that there are no errors. */
	if (geterr() != Success) {
		delete("Got %s, Expecting Success", errorname(geterr()));
		return;
	}
	else
		CHECK;
/* Verify that client2 was delivered expected event. */
	if (!XCheckTypedWindowEvent(client2, w, MapNotify, &event)) {
		report("Selected event was not delivered to client2.");
		FAIL;
	}
	else
		CHECK;

	CHECKPASS(6);
>>ASSERTION def
>>#NOTE This test is included in in the previous test.
A call to xname with
.A discard
set to
.S False
does not discard the events in the queue.
>>ASSERTION Good A
>>#NOTE Since one can depend upon an error handler being called on pending
>>#NOTE error events, one can verify that the handler is called and that
>>#NOTE the event is not in the queue after XSync returns.
A call to xname with
.A discard
set to
.S True
discards all events in the queue.
>>STRATEGY
Create client1.
Create window with client1.
Select MapNotify events with client1 on this window.
Create client2.
Select MapNotify events with client2 on this window.
Map window.
Call XSync for client1.
Verify that client1 was not delivered MapNotify event.
Call XSync for client2.
Verify that client2 was not delivered MapNotify event.
>>CODE
Display *client1;
Display *client2;
Window	w;
XEvent	event;

/* Create client1. */
	client1 = opendisplay();
	if (client1 == (Display *) NULL) {
		delete("Can not open display");
		return;
	}
	else
		CHECK;
/* Create window with client1. */
	w = mkwin(client1, (XVisualInfo *) NULL, (struct area *) NULL, False);
/* Select MapNotify events with client1 on this window. */
	XSelectInput(client1, w, StructureNotifyMask);
/* Create client2. */
	client2 = opendisplay();
	if (client2 == (Display *) NULL) {
		delete("Can not open display");
		return;
	}
	else
		CHECK;
/* Select MapNotify events with client2 on this window. */
	XSelectInput(client2, w, StructureNotifyMask);
/* Map window. */
	XMapWindow(client1, w);
/* Call XSync for client1. */
	_startcall(client1);
	XSync(client1, True);
	_endcall(client1);
/* Verify that client1 was not delivered MapNotify event. */
	if (XCheckTypedWindowEvent(client1, w, MapNotify, &event)) {
		report("Selected event was delivered.");
		FAIL;
	}
	else
		CHECK;
/* Call XSync for client2. */
	_startcall(client2);
	XSync(client2, True);
	_endcall(client2);
/* Verify that client2 was not delivered MapNotify event. */
	if (XCheckTypedWindowEvent(client2, w, MapNotify, &event)) {
		report("Selected event was delivered.");
		FAIL;
	}
	else
		CHECK;

	CHECKPASS(4);
