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
>># File: xts5/XI/gtdvcfcs/gtdvcfcs.m
>># 
>># Description:
>># 	Tests for XGetDeviceFocus()
>># 
>># Modifications:
>># $Log: getfocus.m,v $
>># Revision 1.2  2005-11-03 08:42:05  jmichael
>># clean up all vsw5 paths to use xts5 instead.
>>#
>># Revision 1.1.1.2  2005/04/15 14:05:14  anderson
>># Reimport of the base with the legal name in the copyright fixed.
>>#
>># Revision 8.0  1998/12/23 23:31:57  mar
>># Branch point for Release 5.0.2
>>#
>># Revision 7.0  1998/10/30 22:52:06  mar
>># Branch point for Release 5.0.2b1
>>#
>># Revision 6.1  1998/09/03 02:05:29  mar
>># vswsr212 - avoid conflict with sys/time.h definition of time
>>#
>># Revision 6.0  1998/03/02 05:23:32  tbr
>># Branch point for Release 5.0.1
>>#
>># Revision 5.0  1998/01/26 03:20:04  tbr
>># Branch point for Release 5.0.1b1
>>#
>># Revision 4.0  1995/12/15 09:03:36  tbr
>># Branch point for Release 5.0.0
>>#
>># Revision 3.2  1995/12/15  01:01:31  andy
>># Prepare for GA Release
>>#
/*
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

Copyright 1993 by the Hewlett-Packard Company.

Copyright 1990, 1991 UniSoft Group Limited.

Permission to use, copy, modify, distribute, and sell this software and
its documentation for any purpose is hereby granted without fee,
provided that the above copyright notice appear in all copies and that
both that copyright notice and this permission notice appear in
supporting documentation, and that the names of HP, and UniSoft not be
used in advertising or publicity pertaining to distribution of the
software without specific, written prior permission.  HP, and UniSoft
make no representations about the suitability of this software for any
purpose.  It is provided "as is" without express or implied warranty.
*/
>>TITLE XGetDeviceFocus XI
void

Display	*display = Dsp;
XDevice *device;
Window	*focus = &fwin;
int	*revert_to = &revert;
Time	*time1 = &focus_time;
>>EXTERN
Window fwin;
int revert;
Time focus_time;
int baddevice;
extern ExtDeviceInfo Devs;

>>ASSERTION Good B 3
A call to GetDeviceFocus returns the focus window, PointerRoot,
FollowKeyboard, or None to focus_return, the current focus
revert state to revert_to_return, and the last_focus_time to
time_return.
>>STRATEGY
Touch test.
>>CODE
Window w;
int devicestatenotify;
XEventClass devicestatenotifyclass;
XWindowAttributes attr;

	if (!Setup_Extension_DeviceInfo(FocusMask))
	    {
	    untested("%s: Required input extension devices not found.\n", TestName);
	    return;
	    }
	device = Devs.Focus;

	XCALL;
	if (fwin!=None && fwin!=PointerRoot && fwin!=FollowKeyboard)
	    if (XGetWindowAttributes(display, fwin, &attr) != Success)
		{
		report("Bad window returned by %s\n",TestName);
		FAIL;
		}
	    else
		CHECK;
	else
	    CHECK;
	if (revert!=RevertToNone && revert!=RevertToPointerRoot && 
	    revert!=RevertToFollowKeyboard && revert!=RevertToParent)
	    {
	    report("Bad revert_to returned by %s\n",TestName);
	    FAIL;
	    }
	else
	    CHECK;


	XSetDeviceFocus(display, device, PointerRoot, RevertToPointerRoot, CurrentTime);
	XCALL;
	if (fwin!=PointerRoot)
	    {
	    report("Bad window returned by %s\n",TestName);
	    FAIL;
	    }
	else
	    CHECK;
	if (revert!=RevertToPointerRoot)
	    {
	    report("Bad revert_to returned by %s\n",TestName);
	    FAIL;
	    }
	else
	    CHECK;


	XSetDeviceFocus(display, device, FollowKeyboard, RevertToFollowKeyboard, CurrentTime);
	XCALL;
	if (fwin!=FollowKeyboard)
	    {
	    report("Bad window returned by %s\n",TestName);
	    FAIL;
	    }
	else
	    CHECK;
	if (revert!=RevertToFollowKeyboard)
	    {
	    report("Bad revert_to returned by %s\n",TestName);
	    FAIL;
	    }
	else
	    CHECK;

	w = defwin(display);
	DeviceStateNotify(device, devicestatenotify, devicestatenotifyclass);
	XSelectExtensionEvent(display, w, &devicestatenotifyclass, 1);
	XSync(display,0);

	XSetDeviceFocus(display, device, None, RevertToNone, CurrentTime);
	XCALL;
	if (fwin!=None)
	    {
	    report("Bad window returned by %s\n",TestName);
	    FAIL;
	    }
	else
	    CHECK;
	if (revert!=RevertToNone)
	    {
	    report("Bad revert_to returned by %s\n",TestName);
	    FAIL;
	    }
	else
	    CHECK;
	
	XSetDeviceFocus(display, device, w, RevertToPointerRoot, CurrentTime);
	XCALL;
	if (fwin!=w)
	    {
	    report("Bad window returned by %s\n",TestName);
	    FAIL;
	    }
	else
	    CHECK;
	if (revert!=RevertToPointerRoot)
	    {
	    report("Bad revert_to returned by %s\n",TestName);
	    FAIL;
	    }
	else
	    CHECK;

	CHECKPASS(10);


>>ASSERTION Bad B 3
A call to xname specifying an invalid device results in a BadDevice error.
>>STRATEGY
Make the call with an invalid device.
>>CODE baddevice
XDevice nodevice;
int ximajor, first, err;

	if (!XQueryExtension (display, INAME, &ximajor, &first, &err))
	    {
	    untested("%s: Input extension not supported.\n", TestName);
	    return;
	    }

	BadDevice (display, baddevice);
	nodevice.device_id = -1;
	device = &nodevice;

	XCALL;

	if (geterr() == baddevice)
		CHECK;
	else
		FAIL;

	CHECKPASS(1);
