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
>># File: xts5/XI/chngpntrdv/chngpntrdv.m
>># 
>># Description:
>># 	Tests for XChangePointerDevice()
>># 
>># Modifications:
>># $Log: chgptr.m,v $
>># Revision 1.2  2005-11-03 08:42:04  jmichael
>># clean up all vsw5 paths to use xts5 instead.
>>#
>># Revision 1.1.1.2  2005/04/15 14:05:13  anderson
>># Reimport of the base with the legal name in the copyright fixed.
>>#
>># Revision 8.0  1998/12/23 23:31:54  mar
>># Branch point for Release 5.0.2
>>#
>># Revision 7.0  1998/10/30 22:52:00  mar
>># Branch point for Release 5.0.2b1
>>#
>># Revision 6.0  1998/03/02 05:23:29  tbr
>># Branch point for Release 5.0.1
>>#
>># Revision 5.0  1998/01/26 03:20:01  tbr
>># Branch point for Release 5.0.1b1
>>#
>># Revision 4.0  1995/12/15 09:03:27  tbr
>># Branch point for Release 5.0.0
>>#
>># Revision 3.3  1995/12/15  01:01:18  andy
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
>>TITLE XChangePointerDevice XI
void

Display	*display = Dsp;
XDevice *device;
int 	xaxis = 1;
int 	yaxis = 0;
>>EXTERN
extern ExtDeviceInfo Devs;
extern int NumValuators, MinKeyCode;

>>ASSERTION Good B 3
A call to xname changes the X pointer.
>>STRATEGY
Touch test.
>>EXTERN
verify_ptr(dpy, id)
	Display *dpy;
	int id;
	{
	XDeviceInfo *list;
	int i, ndevices;

	list = XListInputDevices (display, &ndevices);
	for (i=0; i<ndevices; i++,list++)
	    if (list->use==IsXPointer)
		if (list->id == id)
		    return(True);
		else
		    return(False);
	if (i==ndevices)
	    return(False);
	}
>>CODE
XDeviceInfo *list;
int i, ndevices, savid;
	int motiontype;
	XEventClass motionclass;
	Display *client2;		/* Second connection */

	if ((client2 = opendisplay()) == NULL)
		return;

	if (!Setup_Extension_DeviceInfo(ValMask) || NumValuators < 2)
	    {
	    untested("%s: Required input extension device not present.\n", TestName);
	    return;
	    }
	list = XListInputDevices (display, &ndevices);
	for (i=0; i<ndevices; i++,list++)
	    if (list->use==IsXPointer)
		savid = list->id;

	device = Devs.Valuator;
	DeviceMotionNotify(device, motiontype, motionclass);
	XSelectExtensionEvent (client2, defwin(client2), &motionclass, 1);
	XSync(client2,0);

	XCALL;

	if (verify_ptr(display, Devs.Valuator->device_id))
	    CHECK;
	else
	    {
	    report("%s: Couldn't change X pointer\n",TestName);
	    FAIL;
	    }
	device = XOpenDevice(display, savid);
	if (!device) {
		tet_infoline("ERROR: XOpenDevice failed");
		tet_result(TET_UNRESOLVED);
		return;
	}
	XCALL;
	if (verify_ptr(display, savid))
	    CHECK;
	else
	    {
	    report("%s: Couldn't restore X pointer\n",TestName);
	    FAIL;
	    }
	CHECKPASS(2);

>>ASSERTION Good B 3
If a button is pressed on the pointer device, then the pointer device is
changed to a new device, then the button is released, the state of the
old pointer device will show all buttons up.
>>STRATEGY
Press a button on the pointer device.
Change the pointer to a new device.
Release the button on the old pointer device.
Verify that the old X pointer device shows all buttons up.
>>CODE
#define BUTTONMAPLEN 32
XDevice *dev;
XDeviceInfo *list;
XDeviceState *state;
XButtonState *bs;
XEventClass dmnc;
XEvent ev;
int n, dmn, i, j, ndevices, savid, ax=0;
char *buttons;

	if (!Setup_Extension_DeviceInfo(ValMask) || NumValuators < 2)
	    {
	    untested("%s: Required input extension device not present.\n", TestName);
	    return;
	    }

	if (noext(1))
	    return;

	list = XListInputDevices (display, &ndevices);
	for (i=0; i<ndevices; i++,list++)
	    if (list->use==IsXPointer)
		savid = list->id;

	device = Devs.Valuator;
	buttonpress (display, Button1);
	XSync(display, 0);
	XCALL;
	XSync(display, 0);
	dev = XOpenDevice (display, savid);
	if (!dev) {
		tet_infoline("ERROR: XOpenDevice failed");
		tet_result(TET_UNRESOLVED);
		return;
	}
	DeviceMotionNotify(dev, dmn, dmnc);
	XSelectExtensionEvent (display, DRW(display), &dmnc, 1);
	XSync(display, 0);
	devicebuttonrel(display, dev, Button1);
	SimulateDeviceMotionEvent(display, dev, 0, 1, &ax, 0);
	XSync(display, 0);

	state = XQueryDeviceState (display, dev);
	bs = (XButtonState *) state->data;
	for (i=0; i<state->num_classes; i++)
	    {
	    if (bs->class == ButtonClass)
		{
		for (j=0,buttons=bs->buttons; j<BUTTONMAPLEN; j++,buttons++)
		    if (j != Button1 >> 3 && *buttons != 0)
			{
			report("%s: byte %d of buttons was %x, should be 0\n",
			    TestName,j,*buttons);
			FAIL;
			}
		    else
			CHECK;
		}
	    bs = (XButtonState *) ((char *) bs + bs->length);
	    }
	if (((n = getevent(display, &ev)) != 2) || ev.type != MappingNotify) {
		report("Expected one MappingNotify event");
		report("Got %d events, first was type %d",n,ev.type);
		FAIL;
		return;
	} else
		CHECK;
	if (((n = getevent(display, &ev)) != 1) || ev.type != dmn) {
		report("Expected one DeviceMotion event");
		report("Got %d events, first was type %d",n,ev.type);
		FAIL;
		return;
	} else
		CHECK;

	if (((XDeviceMotionEvent *) &ev)->device_state != 0) {
	    report ("Device motion state was %x, not 0 after press/release\n",
		((XDeviceMotionEvent *) &ev)->device_state);
	    FAIL;
	    }
	else
		CHECK;
	CHECKPASS(BUTTONMAPLEN + 3);


>>ASSERTION Good B 3
Termination of the client that changed the pointer does not affect
which input device is the X pointer.
>>STRATEGY
Change the pointer to a new device.
Terminate the client that made the change.
Verify that the X pointer remains the same.
>>CODE
Display	*client2, *client1;
XDeviceInfo *list;
int i, ndevices, savid;

	if (!Setup_Extension_DeviceInfo(ValMask) || NumValuators < 2)
	    {
	    untested("%s: Required input extension device not present.\n", TestName);
	    return;
	    }
	list = XListInputDevices (display, &ndevices);
	for (i=0; i<ndevices; i++,list++)
	    if (list->use==IsXPointer)
		savid = list->id;

	device = Devs.Valuator;
/* Create client1, without causing resource registration. */
	if (config.display == (char *) NULL) {
		delete("config.display not set");
		return;
	}
	else
		CHECK;
	client1 = XOpenDisplay(config.display);
	if (client1 == (Display *) NULL) {
		delete("Couldn't create client1.");
		return;
	}
	else
		CHECK;
		
	display = client1;
	XCALL;
	XCloseDisplay(display);

	if ((client2 = opendisplay()) == NULL)
		return;

	display = client2;
	if (verify_ptr(display, Devs.Valuator->device_id))
	    CHECK;
	else
	    {
	    report("%s: Couldn't change X pointer\n",TestName);
	    FAIL;
	    }
	device = XOpenDevice(display, savid);
	if (!device) {
		tet_infoline("ERROR: XOpenDevice failed");
		tet_result(TET_UNRESOLVED);
		return;
	}
	XCALL;
	if (verify_ptr(display, savid))
	    CHECK;
	else
	    {
	    report("%s: Couldn't restore X pointer\n",TestName);
	    FAIL;
	    }
	CHECKPASS(4);

>>ASSERTION Bad B 3
If the specified device has no valuators, a call to 
XChangePointerDevice will result in a BadMatch error.
>>STRATEGY
Call xname with a device that has no valuators.
Verify that a BadMatch error occurs.
>>CODE BadMatch

	if (!Setup_Extension_DeviceInfo(NValsMask))
	    {
	    untested("%s: No input extension device without valuators.\n", TestName);
	    return;
	    }
	device = Devs.NoValuators;

	XCALL;

	if (geterr() == BadMatch)
		PASS;
	else
		FAIL;
>>ASSERTION Bad B 1
If the implementation does not support use of the specified device
as the X pointer, a BadDevice error  will result.

>>ASSERTION Bad B 3
After a successful call to ChangePointerDevice, a call to any
other input device extension request that requires a Device,
specifying the new X pointer, will result in a BadDevice error.
>>STRATEGY
Change the pointer to a new device.
Verify that all input device extension requests that require a Device pointer
fail with a BadDevice error, when the new pointer is specified.
>>CODE
int baddevice;
int devicemotionnotify;
XDeviceInfo *list;
int i, ndevices, revert, nfeed, mask, ksyms_per, savid;
int nevents, mode, evcount, valuators, count=0;
Window focus, w;
Time time;
XKbdFeedbackControl feedctl;
KeySym ksyms;
XModifierKeymap *modmap;
unsigned char bmap[8];
XDeviceResolutionControl dctl;
XEventClass devicemotionnotifyclass;
XEvent ev;
XDevice bogus;


	if (!Setup_Extension_DeviceInfo(ValMask) || NumValuators < 2)
	    {
	    untested("%s: Required input extension device not present.\n", TestName);
	    return;
	    }
	list = XListInputDevices (display, &ndevices);
	for (i=0; i<ndevices; i++,list++)
	    if (list->use==IsXPointer)
		savid = list->id;

	w = defwin(display);
	device = Devs.Valuator;
	bogus.device_id = Devs.Valuator->device_id;
	DeviceMotionNotify(device, devicemotionnotify, devicemotionnotifyclass);
	modmap = XGetModifierMapping(display);
	XCALL;

	if (verify_ptr(display, Devs.Valuator->device_id))
	    {
	    CHECK;
	    count++;
	    }
	else
	    {
	    report("%s: Couldn't change X pointer\n",TestName);
	    FAIL;
	    }

	XSetErrorHandler(error_status);
	XOpenDevice(display, device->device_id);
	XSync(display,0);
	BadDevice (display, baddevice);
	if (geterr() == baddevice)
		{
		CHECK;
		count++;
		}
	else
		FAIL;

	/*
	 * Since xts5/XI does not clean up the devices created by
	 * Setup_Extension_DeviceInfo, it is safe to XCloseDevice "device".
	 */
	XCloseDevice(display, device);
	XSync(display,0);
	if (geterr() == baddevice)
		{
		CHECK;
		count++;
		}
	else
		FAIL;

	XSetDeviceMode(display, &bogus, Absolute);
	XSync(display,0);
	if (geterr() == baddevice)
		{
		CHECK;
		count++;
		}
	else
		FAIL;

	XGetDeviceMotionEvents(display, &bogus, CurrentTime, CurrentTime,
	    &nevents, &mode, &evcount);
	if (geterr() == baddevice)
		{
		CHECK;
		count++;
		}
	else
		FAIL;

	XChangeKeyboardDevice(display, &bogus);
	XSync(display,0);
	if (geterr() == baddevice)
		{
		CHECK;
		count++;
		}
	else
		FAIL;

	XChangePointerDevice(display, &bogus, 0, 1);
	XSync(display,0);
	if (geterr() == baddevice)
		{
		CHECK;
		count++;
		}
	else
		FAIL;

	XGrabDevice(display, &bogus, w, True, 1, &devicemotionnotifyclass,
	   GrabModeAsync, GrabModeAsync, CurrentTime);
	if (geterr() == baddevice)
		{
		CHECK;
		count++;
		}
	else
		FAIL;

	XUngrabDevice(display, &bogus, CurrentTime);
	XSync(display,0);
	if (geterr() == baddevice)
		{
		CHECK;
		count++;
		}
	else
		FAIL;

	XGrabDeviceKey(display, &bogus, AnyKey, AnyModifier, NULL,
	   w, True, 0, NULL, GrabModeAsync, GrabModeAsync);
	if (geterr() == baddevice)
		{
		CHECK;
		count++;
		}
	else
		FAIL;

	XUngrabDeviceKey(display, &bogus, AnyKey, AnyModifier, NULL, w);
	XSync(display,0);

	if (geterr() == baddevice)
		{
		CHECK;
		count++;
		}
	else
		FAIL;

	XGrabDeviceButton(display, &bogus, AnyButton, AnyModifier, NULL,
	   w, True, 0, NULL, GrabModeAsync, GrabModeAsync);
	if (geterr() == baddevice)
		{
		CHECK;
		count++;
		}
	else
		FAIL;

	XUngrabDeviceButton(display, &bogus, AnyButton, AnyModifier, NULL, w);
	XSync(display,0);
	if (geterr() == baddevice)
		{
		CHECK;
		count++;
		}
	else
		FAIL;

	XAllowDeviceEvents(display, &bogus, AsyncAll, CurrentTime);
	XSync(display,0);
	if (geterr() == baddevice)
		{
		CHECK;
		count++;
		}
	else
		FAIL;

	XGetDeviceFocus(display, &bogus, &focus, &revert, &time);
	if (geterr() == baddevice)
		{
		CHECK;
		count++;
		}
	else
		FAIL;

	XSetDeviceFocus(display, &bogus, None, RevertToNone, CurrentTime);
	XSync(display,0);
	if (geterr() == baddevice)
		{
		CHECK;
		count++;
		}
	else
		FAIL;

	XGetFeedbackControl(display, &bogus, &nfeed);
	if (geterr() == baddevice)
		{
		CHECK;
		count++;
		}
	else
		FAIL;

	feedctl.class = KbdFeedbackClass;
	feedctl.percent = 0;
	mask = DvPercent;
	XChangeFeedbackControl(display, &bogus, mask, (XFeedbackControl*) &feedctl);
	XSync(display,0);
	if (geterr() == baddevice)
		{
		CHECK;
		count++;
		}
	else
		FAIL;

	XGetDeviceKeyMapping(display, &bogus, MinKeyCode, 1, &ksyms_per);
	if (geterr() == baddevice)
		{
		CHECK;
		count++;
		}
	else
		FAIL;

	XChangeDeviceKeyMapping(display, &bogus, MinKeyCode, 1, &ksyms, 1);
	XSync(display,0);
	if (geterr() == baddevice)
		{
		CHECK;
		count++;
		}
	else
		FAIL;

	XGetDeviceModifierMapping(display, &bogus);
	if (geterr() == baddevice)
		{
		CHECK;
		count++;
		}
	else
		FAIL;

	XSetDeviceModifierMapping(display, &bogus, modmap);
	XSync(display,0);
	if (geterr() == baddevice)
		{
		CHECK;
		count++;
		}
	else
		FAIL;

	XGetDeviceButtonMapping(display, &bogus, bmap, 8);
	if (geterr() == baddevice)
		{
		CHECK;
		count++;
		}
	else
		FAIL;

	XSetDeviceButtonMapping(display, &bogus, bmap, 8);
	XSync(display,0);
	if (geterr() == baddevice)
		{
		CHECK;
		count++;
		}
	else
		FAIL;

	XQueryDeviceState(display, &bogus);
	if (geterr() == baddevice)
		{
		CHECK;
		count++;
		}
	else
		FAIL;

	XSetDeviceValuators(display, &bogus, &valuators, 0, 1);
	XSync(display,0);
	if (geterr() == baddevice)
		{
		CHECK;
		count++;
		}
	else
		FAIL;

	XDeviceBell(display, &bogus, 0, 0, 100);
	XSync(display,0);
	if (geterr() == baddevice)
		{
		CHECK;
		count++;
		}
	else
		FAIL;

	XGetDeviceControl(display, &bogus, DEVICE_RESOLUTION);
	if (geterr() == baddevice)
		{
		CHECK;
		count++;
		}
	else
		FAIL;

	dctl.length = sizeof(XDeviceResolutionControl);
	dctl.control = DEVICE_RESOLUTION;
	dctl.num_valuators=1;
	dctl.first_valuator=0;
	dctl.resolutions = &valuators;
	XChangeDeviceControl(display, &bogus, DEVICE_RESOLUTION, (XDeviceControl*) &dctl);
	XSync(display,0);
	if (geterr() == baddevice)
		{
		CHECK;
		count++;
		}
	else
		FAIL;

	ev.type = devicemotionnotify;
	XSendExtensionEvent(display, &bogus, PointerWindow, True, 0, NULL,
	    &ev);
	XSync(display,0);
	if (geterr() == baddevice)
		{
		CHECK;
		count++;
		}
	else
		FAIL;

	device = XOpenDevice(display, savid);
	if (!device) {
		tet_infoline("ERROR: XOpenDevice failed");
		tet_result(TET_UNRESOLVED);
		return;
	}
	XCALL;
	XSync(display,0);
	if (verify_ptr(display, savid))
	    {
	    CHECK;
	    count++;
	    }
	else
	    {
	    report("%s: Couldn't restore X pointer\n",TestName);
	    FAIL;
	    }
	XSetErrorHandler(unexp_err);
	CHECKPASS(count);

>>ASSERTION Bad B 3
When an invalid device is specified, a BadDevice error will result.
>>STRATEGY
Make the call with an invalid device.
>>CODE baddevice
XDevice nodevice;
int baddevice;
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

>>ASSERTION Bad B 3
When the specified axes are not in the range of axes supported by the device,
then a
.S BadMatch
error occurs.
>>STRATEGY
Call xname with xaxis less than 0.
Verify that a BadMatch error occurs.
Call xname with yaxis greater than the number of axes supported.
Verify that a BadMatch error occurs.
>>CODE BadMatch

	if (!Setup_Extension_DeviceInfo(ValMask))
	    {
	    untested("%s: No input extension valuator device.\n", TestName);
	    return;
	    }
	device = Devs.Valuator;

	xaxis = -1;
	XCALL;

	if (geterr() == BadMatch)
		CHECK;

	/*
	 * Since the protocol only has one byte for the key then this
	 * assertion cannot be tested when max_button is 255.
	 */
	if (yaxis < 255) {

		yaxis = 255;

		XCALL;

		if (geterr() == BadMatch)
			CHECK;
	} else
		CHECK;

	CHECKPASS(2);

>>ASSERTION Bad B 3
A call to xname will fail with a status of 
.S AlreadyGrabbed 
if some other client has grabbed the new device.
>>STRATEGY
Grab the new device.
Create client2.
Attempt to change the pointer to the new device.
>>CODE
int ret;
Display	*client2;
Window grab_window;

        grab_window = defwin (display);
	if (!Setup_Extension_DeviceInfo(ValMask))
	    {
	    untested("%s: No input extension valuator device.\n", TestName);
	    return;
	    }
	device = Devs.Valuator;

	XGrabDevice(Dsp, device, grab_window, True, 0, 
		NULL, GrabModeAsync, GrabModeAsync, CurrentTime);
	if (isdeleted()) {
		delete("Could not set up initial grab");
		return;
	}

	if ((client2 = opendisplay()) == NULL)
		return;

	display = client2;
	ret = XCALL;

	if (ret == AlreadyGrabbed)
		CHECK;
	else
		FAIL;

	CHECKPASS(1);
        XUngrabDevice(Dsp, device, CurrentTime);
	XSync(display,0);

>>ASSERTION Bad B 3
A call to xname will fail with a status of 
.S GrabFrozen
if the device is frozen by the grab of some other client.
>>STRATEGY
Grab the new device when it is frozen by a grab of another device.
Create client2.
Attempt to change the pointer to the new device.
>>CODE
int ret;
Display	*client2;
Window grab_window;

	if (!Setup_Extension_DeviceInfo(ValMask))
	    {
	    untested("%s: No input extension valuator device.\n", TestName);
	    return;
	    }
	device = Devs.Valuator;
        grab_window = defwin (display);

	XGrabKeyboard (Dsp, grab_window, True,
		GrabModeSync, GrabModeSync, CurrentTime);
	XSync(Dsp,0);
	if (isdeleted()) {
		delete("Could not set up initial grab");
		return;
	}

	if ((client2 = opendisplay()) == NULL)
		return;

	display = client2;
	ret = XCALL;

	if (ret == GrabFrozen)
		CHECK;
	else
		{
		FAIL;
		report("Wanted GrabFrozen, got %d", ret);
		}

	CHECKPASS(1);
