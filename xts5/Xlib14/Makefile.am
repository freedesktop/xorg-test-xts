include ../common.mk
AUTOMAKE_OPTIONS = subdir-objects

AM_CFLAGS = $(XTS_LCFLAGS) $(XTS_CFLAGS)
LDADD = $(TCM) $(XTS_LLIBS) $(XTS_LIBS) \
	$(top_builddir)/xts5/src/libXR5/libXR5.a

libexec_PROGRAMS = $(tprogs)
BUILT_SOURCES = $(tprogs:$(EXEEXT)=.c)
CLEANFILES = $(BUILT_SOURCES)

tprogs = \
	XBaseFontNameListOfFontSet/XBaseFontNameListOfFontSet \
	XCloseIM/XCloseIM \
	XContextDependentDrawing/XContextDependentDrawing \
	XCreateFontSet/XCreateFontSet \
	XCreateIC/XCreateIC \
	XDestroyIC/XDestroyIC \
	XDisplayOfIM/XDisplayOfIM \
	XExtentsOfFontSet/XExtentsOfFontSet \
	XFilterEvent/XFilterEvent \
	XFontsOfFontSet/XFontsOfFontSet \
	XFreeFontSet/XFreeFontSet \
	XGetICValues/XGetICValues \
	XGetIMValues/XGetIMValues \
	XIMOfIC/XIMOfIC \
	XLocaleOfFontSet/XLocaleOfFontSet \
	XLocaleOfIM/XLocaleOfIM \
	XmbDrawImageString/XmbDrawImageString \
	XmbDrawString/XmbDrawString \
	XmbDrawText/XmbDrawText \
	XmbLookupString/XmbLookupString \
	XmbResetIC/XmbResetIC \
	XmbSetWMProperties/XmbSetWMProperties \
	XmbTextEscapement/XmbTextEscapement \
	XmbTextExtents/XmbTextExtents \
	XmbTextListToTextProperty/XmbTextListToTextProperty \
	XmbTextPerCharExtents/XmbTextPerCharExtents \
	XmbTextPropertyToTextList/XmbTextPropertyToTextList \
	XOpenIM/XOpenIM \
	XSetICFocus/XSetICFocus \
	XSetICValues/XSetICValues \
	XSupportsLocale/XSupportsLocale \
	XSetLocaleModifiers/XSetLocaleModifiers \
	XUnsetICFocus/XUnsetICFocus \
	XVaCreateNestedList/XVaCreateNestedList \
	XwcDrawImageString/XwcDrawImageString \
	XwcDrawString/XwcDrawString \
	XwcDrawText/XwcDrawText \
	XwcFreeStringList/XwcFreeStringList \
	XwcLookupString/XwcLookupString \
	XwcResetIC/XwcResetIC \
	XwcTextEscapement/XwcTextEscapement \
	XwcTextListToTextProperty/XwcTextListToTextProperty \
	XwcTextPerCharExtents/XwcTextPerCharExtents \
	XwcTextPropertyToTextList/XwcTextPropertyToTextList \
	XwcTextExtents/XwcTextExtents