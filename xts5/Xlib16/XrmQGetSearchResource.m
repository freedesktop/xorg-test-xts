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
>># File: xts5/Xlib16/XrmQGetSearchResource.m
>># 
>># Description:
>># 	Tests for XrmQGetSearchResource()
>># 
>># Modifications:
>># $Log: rmqgtsrchr.m,v $
>># Revision 1.2  2005-11-03 08:42:59  jmichael
>># clean up all vsw5 paths to use xts5 instead.
>>#
>># Revision 1.1.1.2  2005/04/15 14:05:22  anderson
>># Reimport of the base with the legal name in the copyright fixed.
>>#
>># Revision 8.0  1998/12/23 23:34:20  mar
>># Branch point for Release 5.0.2
>>#
>># Revision 7.0  1998/10/30 22:56:39  mar
>># Branch point for Release 5.0.2b1
>>#
>># Revision 6.0  1998/03/02 05:25:39  tbr
>># Branch point for Release 5.0.1
>>#
>># Revision 5.0  1998/01/26 03:22:12  tbr
>># Branch point for Release 5.0.1b1
>>#
>># Revision 4.2  1996/08/29 23:40:45  srini
>># Enhancements and clean-up
>>#
>># Revision 4.1  1996/05/09  20:51:21  andy
>># removed caddr_t
>>#
>># Revision 4.0  1995/12/15  09:10:16  tbr
>># Branch point for Release 5.0.0
>>#
>># Revision 3.1  1995/12/15  01:12:36  andy
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
>>TITLE XrmQGetSearchResource Xlib16
Bool

XrmHashTable *list = sl;
XrmName name;
XrmClass class;
XrmRepresentation *type_return = &type;
XrmValue *value=&val;
>>SET startup rmstartup
>>EXTERN
static	XrmRepresentation type;
static	XrmValue val;
static 	XrmDatabase	dbase;

#define XQGSR_ARRAY_SIZE 10
static	XrmHashTable	sl[XQGSR_ARRAY_SIZE];
static	XrmName	nl[XQGSR_ARRAY_SIZE];
static	XrmClass	cl[XQGSR_ARRAY_SIZE];

/* Database data */
#define XQGSR_T1_DATA	5
static	char	*t1_data[XQGSR_T1_DATA] = {
	"applic.window.background:blue",
	"Applic.window.BackGround:cyan",
	"applic.Window.background:magenta",
	"Applic.Window.BackGround:orange",
	"Applic.Window.Unimportant:pink" };

/* Searchlist data */
#define XQGSR_T1_SEARCH	2
static	char	*t1_search[XQGSR_T1_SEARCH][2] = {
	{ "applic", "Applic" },
	{ "window",	"Window" } };

/* SearchResource tests */
#define XQGSR_T1_TESTS	3
static char *t1_tests[XQGSR_T1_TESTS][3] = {
	{ "background",	"BackGround",	"blue"	},
	{ "border",	"BackGround",	"cyan"	},
	{ "misc",	"Unimportant",	"pink"	} };

#define XQGSR_T2_TESTS  1
static char *t2_tests[XQGSR_T2_TESTS][2] = {
	{ "nomatch", "Nomatch" } };

>>ASSERTION Good A
When
.A name
and
.A class
fully identify a resource which is contained in
the specified database levels
.A list ,
then a call to xname shall
return the type in
.A type_return 
and
the value in
.A value_return 
of the first match,
and return 
.S True.
>>STRATEGY
Create a database containing testable resource/value pairs.
Call XrmQGetSearchList to build up the search list.
Call xname to retrieve information.
Verify the retrieved information was correct.
>>CODE
int a;
XrmRepresentation exp_type;
Bool ret;

	/* Create a database containing testable resource/value pairs. */
	dbase=(XrmDatabase)NULL;
	for(a=0; a<XQGSR_T1_DATA; a++) {
		CHECK;
		XrmPutLineResource(&dbase, t1_data[a]);
	}

#ifdef TESTING
	XrmPutFileDatabase(dbase, "xqgsr_one");
#endif

	/* Call XrmQGetSearchList to build up the search list. */
	for(a=0; a<XQGSR_T1_SEARCH; a++) {
		CHECK;
		nl[a]=XrmStringToName(t1_search[a][0]);
		cl[a]=XrmStringToClass(t1_search[a][1]);
	}
	nl[XQGSR_T1_SEARCH]=(XrmName)0;
	cl[XQGSR_T1_SEARCH]=(XrmClass)0;

	if(!XrmQGetSearchList(dbase, nl, cl, sl, XQGSR_ARRAY_SIZE)) {
		delete("XrmQGetSearchList unexpectedly exhausted the allocated space for table.");
		return;
	}
	else
		CHECK;

	exp_type = XrmStringToRepresentation("String");
	for (a=0; a<XQGSR_T1_TESTS; a++)
	{

	/* Call xname to retrieve information. */
		name = XrmStringToName(t1_tests[a][0]);
		class= XrmStringToClass(t1_tests[a][1]);
		type = (XrmRepresentation)0;
		val.addr = NULL;
		val.size = 0;
		ret = XCALL;

/* Verify the retrieved information was correct. */
		if(ret != True) {
			FAIL;
			report("%s returned False when expecting a database match.",
				TestName);
		} else {
			if (type != exp_type) {
				char *rt;

				FAIL;
				report("%s returned unexpected type.", TestName);
				report("Name (class): %s (%s)", t1_tests[a][0], t1_tests[a][1]);
				report("Expected type: String");
				rt=XrmRepresentationToString(type);
				report("Returned type: %s", (rt==NULL?"<NULL STRING":rt));
			} else
				CHECK;

			if (val.addr==NULL ||
				strncmp((char*)val.addr, t1_tests[a][2],
					strlen(t1_tests[a][2]))) {
				FAIL;
				report("%s returned unexpected value", TestName);
				report("Name (class): %s (%s)", t1_tests[a][0], t1_tests[a][1]);
				report("Expected value: %s", t1_tests[a][2]);
				if (val.addr==NULL) {
					report("Returned value: <NULL POINTER>");
				} else {
					report("Returned value: %.*s",
						val.size,
						(char *)val.addr);
				}
			}
			else
				CHECK;
		}
	}

	CHECKPASS(1+XQGSR_T1_DATA+XQGSR_T1_SEARCH+XQGSR_T1_TESTS*2);

	XrmDestroyDatabase(dbase);

>>ASSERTION Good A
When
.A name
and
.A class
fully identify a resource which is not contained in
the specified database levels
.A list ,
then a call to xname shall return
.S False.
>>STRATEGY
Create a database containing testable resource/value pairs.
Call XrmQGetSearchList to build up the search list.
Call xname to retrieve information.
Verify there was no match.
>>CODE
int a;
Bool ret;

/* Create a database containing testable resource/value pairs. */
	dbase=(XrmDatabase)NULL;
	for(a=0; a<XQGSR_T1_DATA; a++) {
		CHECK;
		XrmPutLineResource(&dbase, t1_data[a]);
	}

#ifdef TESTING
	XrmPutFileDatabase(dbase, "xqgsr_two");
#endif

/* Call XrmQGetSearchList to build up the search list. */
	for(a=0; a<XQGSR_T1_SEARCH; a++) {
		CHECK;
		nl[a]=XrmStringToName(t1_search[a][0]);
		cl[a]=XrmStringToClass(t1_search[a][1]);
	}
	nl[XQGSR_T1_SEARCH]=(XrmName)0;
	cl[XQGSR_T1_SEARCH]=(XrmClass)0;

	if (!XrmQGetSearchList(dbase, nl, cl, sl, XQGSR_ARRAY_SIZE))
	{
		delete("XrmQGetSearchList unexpectedly exhausted the allocated space for table.");
		return;
	}
	else
		CHECK;

	for (a=0; a < XQGSR_T2_TESTS; a++)
	{

		/* Call xname to retrieve information. */
		name = XrmStringToName(t2_tests[a][0]);
		class= XrmStringToClass(t2_tests[a][1]);
		type = (XrmRepresentation)0;
		val.addr = NULL;
		val.size = 0;
		ret = XCALL;

		/* Verify there was no match. */
		if (ret != False)
		{
			char *rt;

			FAIL;
			report("%s returned True when expecting no match.",
				TestName);
			report("Name (class): %s (%s)", t2_tests[a][0], t2_tests[a][1]);
			rt=XrmRepresentationToString(type);
			report("Returned type: %s", (rt==NULL?"<NULL STRING":rt));
			if (val.addr==NULL) {
				report("Returned value: <NULL POINTER>");
			} else {
				report("Returned value: %.*s",
					val.size,
					(char *)val.addr);
			}
		}
		else
			CHECK;
	}

	CHECKPASS(1+XQGSR_T1_DATA+XQGSR_T1_SEARCH+XQGSR_T2_TESTS);

	XrmDestroyDatabase(dbase);
