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
>># File: xts5/Xlib11/LeaveNotify.m
>># 
>># Description:
>># 	Tests for LeaveNotify()
>># 
>># Modifications:
>># $Log: lvntfy.m,v $
>># Revision 1.2  2005-11-03 08:42:29  jmichael
>># clean up all vsw5 paths to use xts5 instead.
>>#
>># Revision 1.1.1.2  2005/04/15 14:05:17  anderson
>># Reimport of the base with the legal name in the copyright fixed.
>>#
>># Revision 8.0  1998/12/23 23:31:18  mar
>># Branch point for Release 5.0.2
>>#
>># Revision 7.0  1998/10/30 22:50:54  mar
>># Branch point for Release 5.0.2b1
>>#
>># Revision 6.0  1998/03/02 05:22:59  tbr
>># Branch point for Release 5.0.1
>>#
>># Revision 5.0  1998/01/26 03:19:31  tbr
>># Branch point for Release 5.0.1b1
>>#
>># Revision 4.0  1995/12/15 09:01:41  tbr
>># Branch point for Release 5.0.0
>>#
>># Revision 3.1  1995/12/15  00:58:39  andy
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
>>TITLE LeaveNotify Xlib11
>>EXTERN
#define	EVENT		LeaveNotify
#define	OTHEREVENT	EnterNotify
#define	MASK		LeaveWindowMask
#define	OTHERMASK	EnterWindowMask
#define	BOTHMASKS	(MASK|OTHERMASK)
#define EVENTMASK	MASK

static	Display	*_display_;
static	int	_detail_;
static	long	_event_mask_;
static	XEvent	good;

static	int
selectinput(start, stop, current, previous)
Winh	*start, *stop, *current, *previous;
{
#ifdef	lint
	winh_free(start);
	winh_free(stop);
	winh_free(previous);
#endif
	return(winh_selectinput(_display_, current, _event_mask_));
}

static	int
plant(start, stop, current, previous)
Winh	*start, *stop, *current, *previous;
{
#ifdef	lint
	winh_free(start);
	winh_free(stop);
	winh_free(previous);
#endif
	good.xany.window = current->window;
	return(winh_plant(current, &good, NoEventMask, WINH_NOMASK));
}

static	Bool	increasing;	/* event sequence increases as we climb */

static	int
checksequence(start, stop, current, previous)
Winh	*start, *stop, *current, *previous;
{
	Winhe	*d;
	int	current_sequence;
	int	status;
	static	int	last_sequence;

#ifdef	lint
	winh_free(start);
	winh_free(stop);
#endif
	/* look for desired event type */
	for (d = current->delivered; d != (Winhe *) NULL; d = d->next) {
		if (d->event->type == good.type) {
			current_sequence = d->sequence;
			break;
		}
	}
	if (d == (Winhe *) NULL) {
		report("%s event not delivered", eventname(good.type));
		delete("Missing event");
		return(-1);
	}
	if (previous == (Winh *) NULL)
		status = 0;	/* first call, no previous sequence value */
	else {
		/* assume sequence numbers are not the same */
		status = (current_sequence < last_sequence);
		if (increasing)
			status = (status ? 0 : 1);
		if (status)
			report("Ordering problem between 0x%x (%d) and 0x%x (%d)",
				current->window, current_sequence,
				previous->window, last_sequence);
	}
	last_sequence = current_sequence;
	return(status);
}

static	int
checkdetail(start, stop, current, previous)
Winh	*start, *stop, *current, *previous;
{
	Winhe	*d;

#ifdef	lint
	winh_free(start);
	winh_free(stop);
	winh_free(previous);
#endif
	/* look for desired event type */
	for (d = current->delivered; d != (Winhe *) NULL; d = d->next)
		if (d->event->type == good.type)
			break;
	if (d == (Winhe *) NULL) {
		report("%s event not delivered to window 0x%x",
			eventname(good.type), current->window);
		delete("Missing event");
		return(-1);
	}
	/* check detail */
	if (_detail_ != d->event->xcrossing.detail) {
		report("Expected detail of %d, got %d on window 0x%x",
			_detail_, d->event->xcrossing.detail, current->window);
		return(1);
	}
	return(0);
}
>>ASSERTION Good A
>>#NOTE
>>#NOTE Hierarchy events are:
>>#NOTE 	UnmapNotify,
>>#NOTE 	MapNotify,
>>#NOTE 	ConfigureNotify,
>>#NOTE 	GravityNotify, and
>>#NOTE 	CirculateNotify.
>>#NOTE
When a xname event is generated by a hierarchy change,
then the xname event is delivered after any hierarchy event.
>>STRATEGY
Create window1.
Create window2 on top of window1.
Select for xname and UnmapNotify events on window2.
Move pointer to window2.
Call XUnmapWindow on window2.
Verify that UnmapNotify event was received on window2.
Verify that xname event was received on window1.
Verify that pointer has remained where it was moved.
>>CODE
int	i;
Display	*display = Dsp;
Window	w2;
XEvent	event;
struct area	area;
PointerPlace	*warp;

/* Create window1. */
	area.x = 0;
	area.y = 0;
	area.width = W_STDWIDTH;
	area.height = W_STDHEIGHT;
	mkwin(display, (XVisualInfo *) NULL, &area, True);
/* Create window2 on top of window1. */
	w2 = mkwin(display, (XVisualInfo *) NULL, &area, True);
/* Select for xname and UnmapNotify events on window2. */
	XSelectInput(display, w2, MASK|StructureNotifyMask);
/* Move pointer to window2. */
	warp = warppointer(display, w2, 0, 0);
	if (warp == (PointerPlace *) NULL)
		return;
	else
		CHECK;
	XSync(display, True);
/* Call XUnmapWindow on window2. */
	XUnmapWindow(display, w2);
	XSync(display, False);
/* Verify that UnmapNotify event was received on window2. */
	if (XPending(display) < 1) {
		report("Expected UnmapNotify event not delivered.");
		FAIL;
		return;
	}
	else
		CHECK;
	XNextEvent(display, &event);
	if (event.type != UnmapNotify) {
		report("Expected %s, got %s", eventname(UnmapNotify), eventname(event.type));
		FAIL;
	}
	else
		CHECK;
/* Verify that xname event was received on window1. */
	if (XPending(display) < 1) {
		report("Expected %s event not delivered.", TestName);
		FAIL;
		return;
	}
	else
		CHECK;
	XNextEvent(display, &event);
	if (event.type != EVENT) {
		report("Expected %s, got %s", eventname(EVENT), eventname(event.type));
		FAIL;
	}
	else
		CHECK;
	if ((i = XPending(display)) > 0) {
		report("Expected 2 events, got %d", i+2);
		FAIL;
	}
	else
		CHECK;

	/* Additional possible testing: */
	/* Select for no events on window1. */
	/* Select for MapNotify events on window2. */
	/* Select for xname events on window2. */
	/* Select for xname events on window2 with client2. */
	/* Call XMapWindow on window2. */
	/* Verify that MapNotify event was received on window2. */
	/* Verify that xname event was received on window2. */
	/* Verify that xname event was received on window2 by client2. */
	/* Verify that pointer has remained where it was moved. */
	/* Select for xname events on window1. */
	/* Select for xname events on window1 with client2. */
	/* Select for ConfigureNotify events on window2. */
	/* Call XLowerWindow on window2. */
	/* Verify that ConfigureNotify event was received on window2. */
	/* Verify that xname event was received on window1. */
	/* Verify that xname event was received on window1 by client2. */
	/* Verify that pointer has remained where it was moved. */

	/* Others: GravityNotify, CirculateNotify. */

/* Verify that pointer has remained where it was moved. */
	if (pointermoved(display, warp)) {
		delete("Pointer moved unexpectedly");
		return;
	}
	else
		CHECK;
	CHECKPASS(7);
>>ASSERTION Good A
When a xname event is generated,
then
all clients having set
.S LeaveWindowMask
event mask bits on the event window are delivered
a xname event.
>>STRATEGY
Create clients client2 and client3.
Create window.
Move pointer inside of window.
Select for xname events on window.
Select for xname events on window with client2.
Select for no events on window with client3.
Warp pointer outside window.
Verify that a single xname event was received.
Verify that a single xname event was received by client2.
Verify that no events were received by client2.
>>CODE
int	i;
Display	*display = Dsp;
Display	*client2, *client3;
Window	w;
XEvent	event;
XLeaveWindowEvent	good;
struct	area	area;

/* Create clients client2 and client3. */
	if ((client2 = opendisplay()) == (Display *) NULL) {
		delete("Couldn't create client2.");
		return;
	}
	else
		CHECK;
	if ((client3 = opendisplay()) == (Display *) NULL) {
		delete("Couldn't create client3.");
		return;
	}
	else
		CHECK;
/* Create window. */
	area.x = 10;
	area.y = 10;
	area.width = W_STDWIDTH;
	area.height = W_STDHEIGHT;
	w = mkwin(display, (XVisualInfo *) NULL, &area, True);
/* Move pointer inside of window. */
	if (warppointer(display, w, 0, 0) == (PointerPlace *) NULL)
		return;
	else
		CHECK;
/* Select for xname events on window. */
	XSelectInput(display, w, MASK);
/* Select for xname events on window with client2. */
	XSelectInput(client2, w, MASK);
/* Select for no events on window with client3. */
	XSelectInput(client3, w, NoEventMask);
/* Warp pointer outside window. */
	XSync(display, True);
	XSync(client2, True);
	XSync(client3, True);
	XWarpPointer(display, None, DRW(display), 0, 0, 0, 0, 0, 0);
	XSync(display, False);
	XSync(client2, False);
	XSync(client3, False);
/* Verify that a single xname event was received. */
	if (XPending(display) < 1) {
		report("Expected %s event not delivered.", TestName);
		FAIL;
		return;
	}
	else
		CHECK;
	XNextEvent(display, &event);
	good = event.xcrossing;
	good.type = EVENT;
	good.send_event = False;
	good.display = display;
	good.window = w;
	good.root = DRW(display);
	good.subwindow = None;
	rootcoordset(display, DRW(display), w, 0, 0, &(good.x), &(good.y));
	good.x_root = 0;
	good.y_root = 0;
	good.mode = NotifyNormal;
	/* under virtual root windows detail gets set to NotifyNonlinear */
	good.detail = NotifyAncestor;
	good.same_screen = True;
	good.focus = True;	/* assumes focus follows pointer */
	good.state = 0;
	if (checkevent((XEvent*)&good, &event)) {
		FAIL;
	}
	else
		CHECK;
	if ((i = XPending(display)) > 0) {
		report("Expected 1 event, got %d", i+1);
		FAIL;
	}
	else
		CHECK;
/* Verify that a single xname event was received by client2. */
	if (XPending(client2) < 1) {
		report("Expected %s event not delivered to client2.", TestName);
		FAIL;
		return;
	}
	else
		CHECK;
	XNextEvent(client2, &event);
	good = event.xcrossing;
	good.type = EVENT;
	good.send_event = False;
	good.display = client2;
	good.window = w;
	good.root = DRW(client2);
	good.subwindow = None;
	rootcoordset(client2, DRW(client2), w, 0, 0, &(good.x), &(good.y));
	good.x_root = 0;
	good.y_root = 0;
	good.mode = NotifyNormal;
	/* under virtual root windows detail gets set to NotifyNonlinear */
	good.detail = NotifyAncestor;
	good.same_screen = True;
	good.focus = True;	/* assumes focus follows pointer */
	good.state = 0;
	if (checkevent((XEvent*)&good, &event)) {
		report("Unexpected structure member values for client2");
		FAIL;
	}
	else
		CHECK;
	if ((i = XPending(client2)) > 0) {
		report("Expected 1 event, got %d for client2", i+1);
		FAIL;
	}
	else
		CHECK;
/* Verify that no events were received by client2. */
	if ((i = XPending(client2)) > 0) {
		report("For client2: Expected 0 events, got %d", i);
		FAIL;
	}
	else
		CHECK;
	CHECKPASS(10);
>>ASSERTION def
>>#NOTE Tested for in previous assertion.
When a xname event is generated,
then
clients not having set
.S LeaveWindowMask
event mask bits on the event window are not delivered
a xname event.
>>#NOTEd >>ASSERTION
>>#NOTEd When the window which contains the pointer changes,
>>#NOTEd then ARTICLE xname event is generated.
>>#NOTEm >>ASSERTION
>>#NOTEm When a client calls
>>#NOTEm .F XGrabPointer
>>#NOTEm or
>>#NOTEm .F XUngrabPointer ,
>>#NOTEm then ARTICLE xname event is generated.
>>#NOTEs >>ASSERTION
>>#NOTEs When ARTICLE xname event is delivered,
>>#NOTEs then
>>#NOTEs .M type
>>#NOTEs is set to
>>#NOTEs xname.
>>#NOTEs >>ASSERTION
>>#NOTEs >>#NOTE The method of expansion is not clear.
>>#NOTEs When ARTICLE xname event is delivered,
>>#NOTEs then
>>#NOTEs .M serial
>>#NOTEs is set
>>#NOTEs from the serial number reported in the protocol
>>#NOTEs but expanded from the 16-bit least-significant bits
>>#NOTEs to a full 32-bit value.
>>#NOTEm >>ASSERTION
>>#NOTEm When ARTICLE xname event is delivered
>>#NOTEm and the event came from a
>>#NOTEm .S SendEvent
>>#NOTEm protocol request,
>>#NOTEm then
>>#NOTEm .M send_event
>>#NOTEm is set to
>>#NOTEm .S True .
>>#NOTEs >>ASSERTION
>>#NOTEs When ARTICLE xname event is delivered
>>#NOTEs and the event was not generated by a
>>#NOTEs .S SendEvent
>>#NOTEs protocol request,
>>#NOTEs then
>>#NOTEs .M send_event
>>#NOTEs is set to
>>#NOTEs .S False .
>>#NOTEs >>ASSERTION
>>#NOTEs When ARTICLE xname event is delivered,
>>#NOTEs then
>>#NOTEs .M display
>>#NOTEs is set to
>>#NOTEs a pointer to the display on which the event was read.
>>#NOTEs >>ASSERTION
>>#NOTEs >>#NOTE Global except for MappingNotify and KeymapNotify.
>>#NOTEs When ARTICLE xname event is delivered,
>>#NOTEs then
>>#NOTEs .M window
>>#NOTEs is set to
>>#NOTEs the
>>#NOTEs ifdef(`WINDOWTYPE', WINDOWTYPE, event)
>>#NOTEs window.
>>#NOTEs >>ASSERTION
>>#NOTEs When ARTICLE xname event is delivered,
>>#NOTEs then
>>#NOTEs .M root
>>#NOTEs is set to the source window's root window.
>>ASSERTION Good A
When a xname event is delivered
and the child of the event window contains the initial pointer position,
then
.M subwindow
is set to
that child.
>>STRATEGY
Build window hierarchy.
Create the hierarchy.
Move pointer to inside of child window.
Set LeaveWindowMask event mask bits on the eventw.
Move pointer to outside  of windows.
Verify that a xname event was received.
Verify that subwindow is set to the source window.
>>CODE
int	status;
Display	*display = Dsp;
Winh	*eventw;
Winh	*child;
XEvent	good;
Winhg	winhg;

/* Build window hierarchy. */
	winhg.area.x = 10;
	winhg.area.y = 10;
	winhg.area.width = W_STDWIDTH;
	winhg.area.height = W_STDHEIGHT;
	winhg.border_width = 1;
	eventw = winh_adopt(display, (Winh *) NULL, 0L, (XSetWindowAttributes *) NULL, &winhg, WINH_NOMASK);
	if (eventw == (Winh *) NULL) {
		report("Could not create eventw");
		return;
	}
	else
		CHECK;
	winhg.area.width /= 2;
	winhg.area.height /= 2;
	child = winh_adopt(display, eventw, 0L, (XSetWindowAttributes *) NULL, &winhg, WINH_NOMASK);
	if (child == (Winh *) NULL) {
		report("Could not create child");
		return;
	}
	else
		CHECK;
/* Create the hierarchy. */
	if (winh_create(display, (Winh *) NULL, WINH_MAP))
		return;
	else
		CHECK;
/* Move pointer to inside of child window. */
	if (warppointer(display, child->window, 0, 0) == (PointerPlace *) NULL)
		return;
	else
		CHECK;
/* Set LeaveWindowMask event mask bits on the eventw. */
	if (winh_selectinput(display, eventw, MASK))
		return;
	else
		CHECK;
/* Move pointer to outside  of windows. */
	XSync(display, True);
	XWarpPointer(display, None, DRW(display), 0, 0, 0, 0, 0, 0);
	XSync(display, False);
/* Verify that a xname event was received. */
	good.type = EVENT;
	good.xany.display = display;
	good.xany.window = eventw->window;
	if (winh_plant(eventw, &good, NoEventMask, WINH_NOMASK))
		return;
	else
		CHECK;
	if (winh_harvest(display, (Winh *) NULL))
		return;
	else
		CHECK;
	status = winh_weed((Winh *) NULL, -1, WINH_WEED_IDENTITY);
	if (status < 0)
		return;
	else if (status > 0) {
		report("Event delivery was not as expected");
		FAIL;
	}
	else {
/* Verify that subwindow is set to the source window. */
		/* since only one event was expected, it must be first in list */
		if (eventw->delivered->event->xcrossing.subwindow != child->window) {
			report("Subwindow set to 0x%x, expected 0x%x",
				eventw->delivered->event->xcrossing.subwindow, child->window);
			FAIL;
		}
		else
			CHECK;
	}

	CHECKPASS(8);
>>ASSERTION Good A
When a xname event is delivered
and the child of the event window does not contain the initial pointer position,
then
.M subwindow
is set to
.S None .
>>STRATEGY
Build window hierarchy.
Create the hierarchy.
Move pointer to inside of window.
Set LeaveWindowMask event mask bits on the eventw.
Move pointer to outside  of windows.
Verify that a xname event was received.
Verify that subwindow is set to None.
  since only one event was expected, it must be first in list
>>CODE
int	status;
Display	*display = Dsp;
Winh	*eventw;
XEvent	good;
Winhg	winhg;

/* Build window hierarchy. */
	winhg.area.x = 10;
	winhg.area.y = 10;
	winhg.area.width = W_STDWIDTH;
	winhg.area.height = W_STDHEIGHT;
	winhg.border_width = 1;
	eventw = winh_adopt(display, (Winh *) NULL, 0L, (XSetWindowAttributes *) NULL, &winhg, WINH_NOMASK);
	if (eventw == (Winh *) NULL) {
		report("Could not create eventw");
		return;
	}
	else
		CHECK;
/* Create the hierarchy. */
	if (winh_create(display, (Winh *) NULL, WINH_MAP))
		return;
	else
		CHECK;
/* Move pointer to inside of window. */
	if (warppointer(display, eventw->window, 0, 0) == (PointerPlace *) NULL)
		return;
	else
		CHECK;
/* Set LeaveWindowMask event mask bits on the eventw. */
	if (winh_selectinput(display, eventw, MASK))
		return;
	else
		CHECK;
/* Move pointer to outside  of windows. */
	XSync(display, True);
	XWarpPointer(display, None, DRW(display), 0, 0, 0, 0, 0, 0);
	XSync(display, False);
/* Verify that a xname event was received. */
	good.type = EVENT;
	good.xany.display = display;
	good.xany.window = eventw->window;
	if (winh_plant(eventw, &good, NoEventMask, WINH_NOMASK))
		return;
	else
		CHECK;
	if (winh_harvest(display, (Winh *) NULL))
		return;
	else
		CHECK;
	status = winh_weed((Winh *) NULL, -1, WINH_WEED_IDENTITY);
	if (status < 0)
		return;
	else if (status > 0) {
		report("Event delivery was not as expected");
		FAIL;
	}
	else {
/* Verify that subwindow is set to None. */
		/* since only one event was expected, it must be first in list */
		if (eventw->delivered->event->xcrossing.subwindow != None) {
			report("Subwindow set to 0x%x, expected 0x%x",
				eventw->delivered->event->xcrossing.subwindow, None);
			FAIL;
		}
		else
			CHECK;
	}

	CHECKPASS(7);
>>#NOTEs >>ASSERTION
>>#NOTEs When ARTICLE xname event is delivered,
>>#NOTEs then
>>#NOTEs .M time
>>#NOTEs is set to
>>#NOTEs the time in milliseconds at which the event was generated.
>>#NOTEs >>ASSERTION
>>#NOTEs When ARTICLE xname event is delivered
>>#NOTEs and the event window is on the same screen as the root window,
>>#NOTEs then
>>#NOTEs .M x
>>#NOTEs and
>>#NOTEs .M y
>>#NOTEs are set to
>>#NOTEs the coordinates of
>>#NOTEs the final pointer position relative to the event window's origin.
>>ASSERTION Good C
>>#COMMENT:
>># Assertion category changed March 1992 since it was found not to require
>># device events.
>># - Cal.
If multiple screens are supported:
When a xname event is delivered
and the event and root windows are not on the same screen,
then
.M x
and
.M y
are set to
zero.
>>STRATEGY
If multiple screens are supported:
  Create a window on the default screen.
  Create a window on the alternate screen.
  Warp the pointer into the first window.
  Grab the pointer for the first window.
  Warp the pointer to the alternate window.
  Verify that an xname event was generated relative to the grab window.
  Verify that the x and y components of the event were set to zero.
>>CODE
Window		w;
Window		w2;
XEvent		ev;
int		gr;


	/* If multiple screens are supported: */
	if (config.alt_screen == -1) {
		unsupported("Multiple screens not supported.");
		return;
	} else
		CHECK;

			/* Create a window on the default screen. */
        w = defwin(Dsp);
	
			/* Create a window on the alternate screen. */
	w2 = defdraw(Dsp, VI_ALT_WIN);

			/* Warp the pointer into the first window. */
	warppointer(Dsp, w, 2,3);

			/* Grab the pointer for the first window. */
	if((gr=XGrabPointer(Dsp, w, False, EVENTMASK, GrabModeAsync, GrabModeAsync, None, None, CurrentTime)) != GrabSuccess) {
		delete("XGrabPointer() returned %s instead of GrabSuccess.", grabreplyname(gr));
		return;
	} else
		CHECK;

			/* Warp the pointer to the alternate window. */
	XSync(Dsp, True);
	warppointer(Dsp, w2, 1,1);
	XSync(Dsp, False);

			/* Verify that an xname event was generated relative to the grab window. */
	if (XCheckWindowEvent(Dsp, w, EVENTMASK, &ev) == False) {
		report("Expected %s event was not received.", eventname(EVENT));
		FAIL;
	} else {
		CHECK;

			/* Verify that the x and y components of the event were set to zero. */
		if(ev.xcrossing.x != 0 || ev.xcrossing.y != 0) {
			report("The x (value %d) and y (value %d) components of the %s event were not set to zero.",
				 ev.xcrossing.x, ev.xcrossing.y, eventname(EVENT));
			FAIL;
		} else 
			CHECK;
	}
	
	XUngrabPointer(Dsp, CurrentTime);
	CHECKPASS(4);

>>#NOTEs >>ASSERTION
>>#NOTEs When ARTICLE xname event is delivered,
>>#NOTEs then
>>#NOTEs .M x_root
>>#NOTEs and
>>#NOTEs .M y_root
>>#NOTEs are set to coordinates of the pointer
>>#NOTEs when the event was generated
>>#NOTEs relative to the root window's origin.
>>#NOTEm >>ASSERTION
>>#NOTEm >>#NOTE
>>#NOTEm >>#NOTE The spec does not actually state this.  What the spec states is that
>>#NOTEm >>#NOTE things behave as if the pointer moved from the confine-to window to
>>#NOTEm >>#NOTE the grab window, the opposite of what one might expect.
>>#NOTEm >>#NOTE
>>#NOTEm When ARTICLE xname event is generated as the result of a grab activation,
>>#NOTEm then xname event generation occurs as if the pointer moved from
>>#NOTEm the grab window to the confine-to window with
>>#NOTEm .M mode
>>#NOTEm set to
>>#NOTEm .S NotifyGrab .
>>#NOTEm >>ASSERTION
>>#NOTEm >>#NOTE
>>#NOTEm >>#NOTE The spec does not actually state this.  What the spec states is that
>>#NOTEm >>#NOTE things behave as if the pointer moved from the grab window to
>>#NOTEm >>#NOTE the confine-to window, the opposite of what one might expect.
>>#NOTEm >>#NOTE
>>#NOTEm When ARTICLE xname event is generated as the result of a grab deactivation,
>>#NOTEm then xname event generation occurs as if the pointer moved from
>>#NOTEm the confine-to window to the grab window with
>>#NOTEm .M mode
>>#NOTEm set to
>>#NOTEm .S NotifyUngrab .
>>ASSERTION def
All xname events are delivered before
any related
.S EnterNotify
events are delivered.
>>#NOTE
>>#NOTE It would not surprise me in the least if these assertions could
>>#NOTE be simplified and/or reduced in number.
>>#NOTE
>>ASSERTION Good A
When the pointer moves from window A to window B
and A is an inferior of B,
then a xname event is generated on window A with
.M detail
set to
.S NotifyAncestor
and then on each window
between window A and window B, exclusive, with
.M detail
set to
.S NotifyVirtual .
>>STRATEGY
Build window hierarchy.
Move pointer to known location.
Set window B.
Set window A to child of window B.
Select for EnterNotify and xname events on windows A and B.
Move pointer from window A to window B.
Verify that the expected events were delivered.
Verify that event delivered to window A with detail set to NotifyAncestor.
Verify events delivered, between window A and window B, exclusive,
in proper order.
Verify that detail is set to NotifyVirtual.
Verify that all xname events are delivered before all
EnterNotify events.
>>CODE
Display	*display = Dsp;
int	depth = 4;
Winh	*A, *B;
int	status;

/* Build window hierarchy. */
	if (winh(display, depth, WINH_MAP)) {
		report("Could not build window hierarchy");
		return;
	}
	else
		CHECK;
/* Move pointer to known location. */
	if (warppointer(display, DRW(display), 0, 0) == (PointerPlace *) NULL)
		return;
	else
		CHECK;
/* Set window B. */
	B = guardian->firstchild;
/* Set window A to child of window B. */
	A = B->firstchild->firstchild->firstchild;
/* Select for EnterNotify and xname events on windows A and B. */
	_event_mask_ = BOTHMASKS;
	_display_ = display;
	if (winh_climb(A, B, selectinput)) {
		report("Could not select for events");
		return;
	}
	else
		CHECK;
	good.type = EVENT;
	good.xany.display = display;
	if (winh_climb(A, B->firstchild, plant)) {
		report("Could not plant events");
		return;
	}
	else
		CHECK;
/* Move pointer from window A to window B. */
	XWarpPointer(display, None, A->window, 0, 0, 0, 0, 0, 0);
	XSync(display, True);
	XWarpPointer(display, None, B->window, 0, 0, 0, 0, 0, 0);
	XSync(display, False);
	if (winh_harvest(display, (Winh *) NULL)) {
		report("Could not harvest events");
		return;
	}
	else
		CHECK;
/* Verify that the expected events were delivered. */
	if (winh_ignore_event(B, OTHEREVENT, WINH_NOMASK)) {
		delete("Could not ignore %s events", eventname(OTHEREVENT));
		return;
	}
	else
		CHECK;
	status = winh_weed((Winh *) NULL, -1, WINH_WEED_IDENTITY);
	if (status < 0)
		return;
	else if (status > 0) {
		report("Event delivery was not as expected");
		FAIL;
	}
	else {
/* Verify that event delivered to window A with detail set to NotifyAncestor. */
		_detail_ = NotifyAncestor;
		if (winh_climb(A, A, checkdetail))
			FAIL;
		else
			CHECK;
/* Verify events delivered, between window A and window B, exclusive, */
/* in proper order. */
		increasing = False;
		if (winh_climb(A, B->firstchild, checksequence))
			FAIL;
		else
			CHECK;
/* Verify that detail is set to NotifyVirtual. */
		_detail_ = NotifyVirtual;
		if (winh_climb(A->parent, B->firstchild, checkdetail))
			FAIL;
		else
			CHECK;
/* Verify that all xname events are delivered before all */
/* EnterNotify events. */
		status = winh_ordercheck(EVENT, OTHEREVENT);
		if (status == -1)
			return;
		else if (status)
			FAIL;
		else
			CHECK;
	}
	CHECKPASS(10);
>>ASSERTION Good A
When the pointer moves from window A to window B
and B is an inferior of A,
then a xname event is generated on window A with
.M detail
set to
.S NotifyInferior .
>>STRATEGY
Build window hierarchy.
Move pointer to known location.
Set window A.
Set window B to child of window A.
Select for xname and EnterNotify events on windows A and B.
Move pointer from window A to window B.
Verify xname event received on window A.
Verify that detail is set to NotifyInferior.
Verify that all xname events are delivered before all
EnterNotify events.
>>CODE
Display	*display = Dsp;
int	depth = 3;
Winh	*A, *B;
int	status;
XEvent	*event;

/* Build window hierarchy. */
	if (winh(display, depth, WINH_MAP)) {
		report("Could not build window hierarchy");
		return;
	}
	else
		CHECK;
/* Move pointer to known location. */
	if (warppointer(display, DRW(display), 0, 0) == (PointerPlace *) NULL)
		return;
	else
		CHECK;
/* Set window A. */
	A = guardian->firstchild;
/* Set window B to child of window A. */
	B = A->firstchild;
/* Select for xname and EnterNotify events on windows A and B. */
	if (winh_selectinput(display, A, BOTHMASKS)) {
		report("Error selecting for events.");
		return;
	}
	else
		CHECK;
	if (winh_selectinput(display, B, BOTHMASKS)) {
		report("Error selecting for events.");
		return;
	}
	else
		CHECK;

/* Move pointer from window A to window B. */
	XWarpPointer(display, None, A->window, 0, 0, 0, 0, 0, 0);
	XSync(display, True);
	XWarpPointer(display, None, B->window, 0, 0, 0, 0, 0, 0);
	XSync(display, False);
	if (winh_harvest(display, (Winh *) NULL)) {
		report("Could not harvest events");
		return;
	}
	else
		CHECK;
/* Verify xname event received on window A. */
	if (A->delivered == (Winhe *) NULL || (event = A->delivered->event)->type != EVENT) {
		report("Expected event not generated");
		FAIL;
	}
	else
	{
/* Verify that detail is set to NotifyInferior. */
		if (event->xcrossing.detail != NotifyInferior) {
			report("Got detail %d, expected %d", event->xcrossing.detail, NotifyInferior);
			FAIL;
		}
		else
			CHECK;
/* Verify that all xname events are delivered before all */
/* EnterNotify events. */
		status = winh_ordercheck(EVENT, OTHEREVENT);
		if (status == -1)
			return;
		else if (status)
			FAIL;
		else
			CHECK;
	}
	CHECKPASS(7);
>>ASSERTION Good A
>>#NOTE
>>#NOTE The approved form of this assertion was in error.  
>>#NOTE	The offending line is listed below:
>>#NOTE
>>#NOTE	between window B and window C, exclusive, with
>>#NOTE
When the pointer moves from window A to window B
and there exists a window C that is their least common ancestor,
then a xname event is generated on window A with
.M detail
set to
.S NotifyNonlinear
and then on each window
between window A and window C, exclusive, with
.M detail
set to
.S NotifyNonlinearVirtual .
>>STRATEGY
Build window hierarchy.
Move pointer to known location.
Set windows A, B, and C.
Select for xname and EnterNotify events on window A and
between windows A and C, exclusive.
Select for xname and EnterNotify events between windows B and C.
Move pointer from window A to window B.
Verify that event delivered to window A with detail set to NotifyNonlinear.
Verify events delivered in proper order.
Verify that detail is set to NotifyNonlinearVirtual on events delivered on
each window between window A and window C, exclusive.
Verify that all xname events are delivered before all
EnterNotify events.
>>CODE
Display	*display = Dsp;
int	depth = 5;
Winh	*A, *B, *C;
int	status;

/* Build window hierarchy. */
	if (winh(display, depth, WINH_MAP)) {
		report("Could not build window hierarchy");
		return;
	}
	else
		CHECK;
/* Move pointer to known location. */
	if (warppointer(display, DRW(display), 0, 0) == (PointerPlace *) NULL)
		return;
	else
		CHECK;
/* Set windows A, B, and C. */
	C = guardian->firstchild;
	A = C->firstchild->nextsibling->firstchild->firstchild;
	B = C->firstchild->             firstchild->firstchild;
/* Select for xname and EnterNotify events on window A and */
/* between windows A and C, exclusive. */
	_event_mask_ = BOTHMASKS;
	_display_ = display;
	if (winh_climb(A, C->firstchild->nextsibling, selectinput)) {
		report("Could not select for events");
		return;
	}
	else
		CHECK;
/* Select for xname and EnterNotify events between windows B and C. */
	_display_ = display;
	if (winh_climb(B, C, selectinput)) {
		report("Could not select for events between C and B");
		return;
	}
	else
		CHECK;
	good.type = EVENT;
	good.xany.display = display;
	if (winh_climb(A, C->firstchild->nextsibling, plant)) {
		report("Could not plant events");
		return;
	}
	else
		CHECK;
/* Move pointer from window A to window B. */
	XWarpPointer(display, None, A->window, 0, 0, 0, 0, 0, 0);
	XSync(display, True);
	XWarpPointer(display, None, B->window, 0, 0, 0, 0, 0, 0);
	XSync(display, False);
	if (winh_harvest(display, (Winh *) NULL)) {
		report("Could not harvest events");
		return;
	}
	else
		CHECK;
	if (winh_ignore_event((Winh *) NULL, OTHEREVENT, WINH_NOMASK)) {
		delete("Could not ignore %s events", eventname(OTHEREVENT));
		return;
	}
	else
		CHECK;
	status = winh_weed((Winh *) NULL, -1, WINH_WEED_IDENTITY);
	if (status < 0)
		return;
	else if (status > 0) {
		report("Event delivery was not as expected");
		FAIL;
	}
	else {
/* Verify that event delivered to window A with detail set to NotifyNonlinear. */
		_detail_ = NotifyNonlinear;
		if (winh_climb(A, A, checkdetail))
			FAIL;
		else
			CHECK;
/* Verify events delivered in proper order. */
		increasing = False;
		if (winh_climb(A, C->firstchild->nextsibling, checksequence))
			FAIL;
		else
			CHECK;
/* Verify that detail is set to NotifyNonlinearVirtual on events delivered on */
/* each window between window A and window C, exclusive. */
		_detail_ = NotifyNonlinearVirtual;
		if (winh_climb(A->parent, C->firstchild->nextsibling, checkdetail))
			FAIL;
		else
			CHECK;
/* Verify that all xname events are delivered before all */
/* EnterNotify events. */
		status = winh_ordercheck(EVENT, OTHEREVENT);
		if (status == -1)
			return;
		else if (status) {
			report("Incorrect event ordering.");
			FAIL;
		}
		else
			CHECK;
	}
	CHECKPASS(11);
>>ASSERTION Good C
If the implementation supports multiple screens:
When the pointer moves from window A to window B
and window A and window B are on different screens,
then a xname event is generated on window A with
.M detail
set to
.S NotifyNonlinear .
>>STRATEGY
Check to see if multiple screens are supported.
Build window hierarchy.
Move pointer to window A.
Select for xname and EnterNotify events on windows A and B.
Move pointer from window A to window B.
Verify that the expected events were received.
Verify that detail is set to NotifyNonlinear.
Verify that all xname events are delivered before all
EnterNotify events.
>>CODE
Display	*display = Dsp;
int	depth = 1;
Winh	*A, *B, *Broot;
int	status;

/* Check to see if multiple screens are supported. */
	if (config.alt_screen == -1) {
		unsupported("Multiple screens not supported.");
		return;
	}
	else
		CHECK;
/* Build window hierarchy. */
	if (winh(display, depth, WINH_MAP|WINH_BOTH_SCREENS)) {
		report("Could not build window hierarchy");
		return;
	}
	else
		CHECK;
/* Set windows A and B. */ 
	A = guardian->firstchild;
	Broot = guardian->nextsibling;
	B = Broot->firstchild;
/* Move pointer to window A. */
	if (warppointer(display, A->window, 0, 0) == (PointerPlace *) NULL)
		return;
	else
		CHECK;
/* Select for xname and EnterNotify events on windows A and B. */
	if (winh_selectinput(display, A, BOTHMASKS)) {
		report("Could not select for events on A");
		return;
	}
	else
		CHECK;
	if (winh_selectinput(display, B, BOTHMASKS)) {
		report("Could not select for events on B");
		return;
	}
	else
		CHECK;
/* Move pointer from window A to window B. */
	XSync(display, True);
	XWarpPointer(display, None, B->window, 0, 0, 0, 0, 0, 0);
	XSync(display, False);
/* Verify that the expected events were received. */
	good.type = EVENT;
	good.xany.display = display;
	good.xany.window = A->window;
	if (winh_plant(A, &good, NoEventMask, WINH_NOMASK)) {
		report("Could not plant events");
		return;
	}
	else
		CHECK;
	if (winh_harvest(display, (Winh *) NULL)) {
		report("Could not harvest events");
		return;
	}
	else
		CHECK;
	if (winh_ignore_event(B, OTHEREVENT, WINH_NOMASK)) {
		report("Could not ignore %s events on B",
			eventname(OTHEREVENT));
		return;
	}
	else
		CHECK;
	status = winh_weed((Winh *) NULL, -1, WINH_WEED_IDENTITY);
	if (status < 0)
		return;
	else if (status > 0) {
		report("Event delivery was not as expected");
		FAIL;
	}
	else {
/* Verify that detail is set to NotifyNonlinear. */
		if (A->delivered->event->xcrossing.detail != NotifyNonlinear) {
			report("Got detail %d, expected %d",
				A->delivered->event->xcrossing.detail,
				NotifyNonlinear);
			FAIL;
		}
		else
			CHECK;
/* Verify that all xname events are delivered before all */
/* EnterNotify events. */
		status = winh_ordercheck(EVENT, OTHEREVENT);
		if (status == -1)
			return;
		else if (status) {
			report("Incorrect event ordering.");
			FAIL;
		}
		else
			CHECK;
	}
	CHECKPASS(10);
>>ASSERTION Good C
If the implementation supports multiple screens:
When the pointer moves from window A to window B
and window A and window B are on different screens
and window A is not a root window,
then, after the related xname event is generated
with
.M detail
set to
.S NotifyNonlinear ,
a xname event is generated on
each window above A up to and including its root, with
.M detail
set to
.S NotifyNonlinearVirtual .
>>STRATEGY
Check to see if multiple screens are supported.
Create client.
Build window hierarchy.
Move pointer to window A.
Select for xname and EnterNotify events on windows A and B.
Move pointer from window A to window B.
Verify that the expected events were received.
Verify that detail is set to NotifyNonlinear for event delivered to A.
Verify events delivered on each window above A up to and
including its root, with detail set to NotifyNonlinearVirtual.
Verify that all xname events are delivered before all
EnterNotify events.
>>CODE
Display	*display;
int	depth = 4;
Winh	*A, *B, *Aroot;
int	status;

/* Check to see if multiple screens are supported. */
	if (config.alt_screen == -1) {
		unsupported("Multiple screens not supported.");
		return;
	}
	else
		CHECK;
/* Create client. */
	if ((display = opendisplay()) == (Display *) NULL) {
		delete("Couldn't create client.");
		return;
	}
	else
		CHECK;
/* Build window hierarchy. */
	if (winh(display, depth, WINH_MAP|WINH_BOTH_SCREENS)) {
		report("Could not build window hierarchy");
		return;
	}
	else
		CHECK;
/* Set windows A and B. */ 
	Aroot = guardian;
	A = guardian->firstchild->firstchild->firstchild;
	B = guardian->nextsibling->firstchild;
/* Move pointer to window A. */
	if (warppointer(display, A->window, 0, 0) == (PointerPlace *) NULL)
		return;
	else
		CHECK;
/* Select for xname and EnterNotify events on windows A and B. */
	_event_mask_ = BOTHMASKS;
	_display_ = display;
	if (winh_climb(A, Aroot, selectinput)) {
		report("Could not select for events");
		return;
	}
	else
		CHECK;
	if (winh_selectinput(display, B, BOTHMASKS)) {
		report("Could not select for events on B");
		return;
	}
	else
		CHECK;
/* Move pointer from window A to window B. */
	XSync(display, True);
	XWarpPointer(display, None, B->window, 0, 0, 0, 0, 0, 0);
	XSync(display, False);
/* Verify that the expected events were received. */
	good.type = EVENT;
	good.xany.display = display;
	if (winh_climb(A, Aroot, plant)) {
		report("Could not plant events");
		return;
	}
	else
		CHECK;
	if (winh_harvest(display, (Winh *) NULL)) {
		report("Could not harvest events");
		return;
	}
	else
		CHECK;
	if (winh_ignore_event(B, OTHEREVENT, WINH_NOMASK)) {
		report("Could not ignore %s events on B",
			eventname(OTHEREVENT));
		return;
	}
	else
		CHECK;
	status = winh_weed((Winh *) NULL, -1, WINH_WEED_IDENTITY);
	if (status < 0)
		return;
	else if (status > 0) {
		report("Event delivery was not as expected");
		FAIL;
	}
	else {
/* Verify that detail is set to NotifyNonlinear for event delivered to A. */
		if (A->delivered->event->xcrossing.detail != NotifyNonlinear) {
			report("Got detail %d, expected %d on A",
				A->delivered->event->xcrossing.detail,
				NotifyNonlinear);
			FAIL;
		}
		else
			CHECK;
/* Verify events delivered on each window above A up to and */
/* including its root, with detail set to NotifyNonlinearVirtual. */
		increasing = False;
		if (winh_climb(A, Aroot, checksequence))
			FAIL;
		else
			CHECK;
		_detail_ = NotifyNonlinearVirtual;
		if (winh_climb(A->parent, Aroot, checkdetail))
			FAIL;
		else
			CHECK;
/* Verify that all xname events are delivered before all */
/* EnterNotify events. */
		status = winh_ordercheck(EVENT, OTHEREVENT);
		if (status == -1)
			return;
		else if (status) {
			report("Incorrect event ordering.");
			FAIL;
		}
		else
			CHECK;
	}
	CHECKPASS(13);

>>#NOTEs >>ASSERTION
>>#NOTEs When ARTICLE xname event is delivered
>>#NOTEs and the event and root windows are on the same screen,
>>#NOTEs then
>>#NOTEs .M same_screen
>>#NOTEs is set to
>>#NOTEs .S True .
>>ASSERTION Good C
>>#COMMENT:
>># Assertion category changed March 1992 since it was found not to require
>># device events.
>># - Cal.
If multiple screens are supported:
When a xname event is delivered
and the event and root windows are not on the same screen,
then
.M same_screen
is set to
.S False .
>>STRATEGY
If multiple screens are supported:
  Create a window on the default screen.
  Create a window on the alternate screen.
  Warp the pointer into the first window.
  Grab the pointer for the first window.
  Warp the pointer to the alternate window.
  Verify that an xname event was generated relative to the grab window.
  Verify that the same_screen component of the event was False.
>>CODE
Window		w;
Window		w2;
XEvent		ev;
int		gr;

	/* If multiple screens are supported: */
	if(config.alt_screen == -1) {
		unsupported("Multiple screens not supported.");
		return;
	} else
		CHECK;

			/* Create a window on the default screen. */
        w = defwin(Dsp);
	
			/* Create a window on the alternate screen. */
	w2 = defdraw(Dsp, VI_ALT_WIN);

			/* Warp the pointer into the first window. */
	warppointer(Dsp, w, 2,3);

			/* Grab the pointer for the first window. */
	if((gr=XGrabPointer(Dsp, w, False, EVENTMASK, GrabModeAsync, GrabModeAsync, None, None, CurrentTime)) != GrabSuccess) {
		delete("XGrabPointer() returned %s instead of GrabSuccess.", grabreplyname(gr));
		return;
	} else
		CHECK;

			/* Warp the pointer to the alternate window. */
	XSync(Dsp, True);
	warppointer(Dsp, w2, 1,1);
	XSync(Dsp, False);

			/* Verify that an xname event was generated relative to the grab window. */
	if (XCheckWindowEvent(Dsp, w, EVENTMASK, &ev) == False) {
		report("Expected %s event was not received.", eventname(EVENT));
		FAIL;
	} else {
		CHECK;

			/* Verify that the same_screen component of the event was False. */
		if(ev.xcrossing.same_screen != False) {
			report("The same_screen component of the %s event was not set to False.", eventname(EVENT));
			FAIL;
		} else 
			CHECK;
	}
	
	XUngrabPointer(Dsp, CurrentTime);
	CHECKPASS(4);

>>ASSERTION Good A
When a xname event is delivered
and the event window is the focus window,
then
.M focus
is set to
.S True .
>>STRATEGY
Build window hierarchy.
Set input focus to eventw.
Move pointer to window.
Select xname events on the eventw.
Call XWarpPointer to move the pointer to outside of window.
Verify event was delivered with focus set to True.
Move pointer back to window.
Set input focus to known window.
Call XWarpPointer to move the pointer to eventw.
Verify event was delivered with focus set to False.
>>CODE
Display	*display = Dsp;
Winh	*eventw;
int	status;

/* Build window hierarchy. */
	if (winh(display, 1, WINH_MAP)) {
		report("Could not build window hierarchy");
		return;
	}
	else
		CHECK;
	eventw = guardian->firstchild;
/* Set input focus to eventw. */
	XSetInputFocus(display, eventw->window, RevertToPointerRoot, CurrentTime);
/* Move pointer to window. */
	if (warppointer(display, eventw->window, 0, 0) == (PointerPlace *) NULL)
		return;
	else
		CHECK;
/* Select xname events on the eventw. */
	if (winh_selectinput(display, eventw, MASK))
		return;
	else
		CHECK;
/* Call XWarpPointer to move the pointer to outside of window. */
	XSync(display, True);
	XWarpPointer(display, None, DRW(display), 0, 0, 0, 0, 0, 0);
	XSync(display, False);
/* Verify event was delivered with focus set to True. */
	good.type = EVENT;
	good.xany.display = display;
	good.xany.window = eventw->window;
	if (winh_plant(eventw, &good, NoEventMask, WINH_NOMASK)) {
		report("Could not initialize for event delivery");
		return;
	}
	else
		CHECK;
	if (winh_harvest(display, (Winh *) NULL)) {
		report("Could not harvest events");
		return;
	}
	else
		CHECK;
	status = winh_weed((Winh *) NULL, -1, WINH_WEED_IDENTITY);
	if (status < 0)
		return;
	else if (status > 0) {
		report("Event delivery was not as expected");
		FAIL;
	}
	else {
		if (eventw->delivered->event->xcrossing.focus != True) {
			report("Focus set to %d, expected %d",
				eventw->delivered->event->xcrossing.focus,True);
			FAIL;
		}
		else
			CHECK;
	}
/* Move pointer back to window. */
	XWarpPointer(display, None, eventw->window, 0, 0, 0, 0, 0, 0);
/* Set input focus to known window. */
	XSetInputFocus(display, eventw->nextsibling->window, RevertToPointerRoot, CurrentTime);
/* Call XWarpPointer to move the pointer to eventw. */
	XSync(display, True);
	XWarpPointer(display, None, DRW(display), 0, 0, 0, 0, 0, 0);
	XSync(display, False);
/* Verify event was delivered with focus set to False. */
	if (winh_plant(eventw, &good, NoEventMask, WINH_NOMASK)) {
		report("Could not initialize for event delivery");
		return;
	}
	else
		CHECK;
	if (winh_harvest(display, (Winh *) NULL)) {
		report("Could not harvest events");
		return;
	}
	else
		CHECK;
	status = winh_weed((Winh *) NULL, -1, WINH_WEED_IDENTITY);
	if (status < 0)
		return;
	else if (status > 0) {
		report("Event delivery was not as expected");
		FAIL;
	}
	else {
		if (eventw->delivered->event->xcrossing.focus != False) {
			report("Focus set to %d, expected %d",
				eventw->delivered->event->xcrossing.focus, False);
			FAIL;
		}
		else
			CHECK;
	}
	CHECKPASS(9);
>>ASSERTION Good A
When a xname event is delivered
and the event window is an inferior of the focus window,
then
.M focus
is set to
.S True .
>>STRATEGY
Build window hierarchy.
Set input focus to ancestor of window eventw.
Move pointer to event window.
Select xname events on the eventw.
Call XWarpPointer to move the pointer outside event window.
Verify event was delivered with focus set to True.
>>CODE
Display	*display = Dsp;
Winh	*eventw, *focusw;
int	status;

/* Build window hierarchy. */
	if (winh(display, 2, WINH_MAP)) {
		report("Could not build window hierarchy");
		return;
	}
	else
		CHECK;
	focusw = guardian->firstchild;
	eventw = guardian->firstchild->firstchild;
/* Set input focus to ancestor of window eventw. */
	XSetInputFocus(display, focusw->window, RevertToPointerRoot, CurrentTime);
/* Move pointer to event window. */
	if (warppointer(display, eventw->window, 0, 0) == (PointerPlace *) NULL)
		return;
	else
		CHECK;
/* Select xname events on the eventw. */
	if (winh_selectinput(display, eventw, MASK))
		return;
	else
		CHECK;
/* Call XWarpPointer to move the pointer outside event window. */
	XSync(display, True);
	XWarpPointer(display, None, DRW(display), 0, 0, 0, 0, 0, 0);
	XSync(display, False);
/* Verify event was delivered with focus set to True. */
	good.type = EVENT;
	good.xany.display = display;
	good.xany.window = eventw->window;
	if (winh_plant(eventw, &good, NoEventMask, WINH_NOMASK)) {
		report("Could not initialize for event delivery");
		return;
	}
	else
		CHECK;
	if (winh_harvest(display, (Winh *) NULL)) {
		report("Could not harvest events");
		return;
	}
	else
		CHECK;
	status = winh_weed((Winh *) NULL, -1, WINH_WEED_IDENTITY);
	if (status < 0)
		return;
	else if (status > 0) {
		report("Event delivery was not as expected");
		FAIL;
	}
	else {
		if (eventw->delivered->event->xcrossing.focus != True) {
			report("Focus set to %d, expected %d",
				eventw->delivered->event->xcrossing.focus, True);
			FAIL;
		}
		else
			CHECK;
	}
	CHECKPASS(6);
>>#NOTEs >>ASSERTION
>>#NOTEs When ARTICLE xname event is delivered
>>#NOTEs and the event window is not the focus window or
>>#NOTEs an inferior of the focus window,
>>#NOTEs then
>>#NOTEs .M focus
>>#NOTEs is set to
>>#NOTEs .S False .
>>#NOTEs >>ASSERTION
>>#NOTEs When ARTICLE xname event is delivered,
>>#NOTEs then
>>#NOTEs .M state
>>#NOTEs is set to
>>#NOTEs indicate the logical state
>>#NOTEs of the pointer buttons,
>>#NOTEs which is the bitwise OR of one or more of
>>#NOTEs the button or modifier key masks
>>#NOTEs .S Button1Mask ,
>>#NOTEs .S Button2Mask ,
>>#NOTEs .S Button3Mask ,
>>#NOTEs .S Button4Mask ,
>>#NOTEs .S Button5Mask ,
>>#NOTEs .S ShiftMask ,
>>#NOTEs .S LockMask ,
>>#NOTEs .S ControlMask ,
>>#NOTEs .S Mod1Mask ,
>>#NOTEs .S Mod2Mask ,
>>#NOTEs .S Mod3Mask ,
>>#NOTEs .S Mod4Mask ,
>>#NOTEs and
>>#NOTEs .S Mod5Mask .
