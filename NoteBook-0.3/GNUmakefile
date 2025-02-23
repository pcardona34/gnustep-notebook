#
# GNUmakefile - header gnerated by ProjectCenter
#
ifeq ($(GNUSTEP_MAKEFILES),)
 GNUSTEP_MAKEFILES := $(shell gnustep-config --variable=GNUSTEP_MAKEFILES 2>/dev/null)  
  ifeq ($(GNUSTEP_MAKEFILES),)
    $(warning )
    $(warning Unable to obtain GNUSTEP_MAKEFILES setting from gnustep-config!)
    $(warning Perhaps gnustep-make is not properly installed,)
    $(warning so gnustep-config is not in your PATH.)
    $(warning )
    $(warning Your PATH is currently $(PATH))
    $(warning )
  endif
endif
ifeq ($(GNUSTEP_MAKEFILES),)
 $(error You need to set GNUSTEP_MAKEFILES before compiling!)
endif

include $(GNUSTEP_MAKEFILES)/common.make

#
# Application
#

APP_NAME                  = NoteBook
PACKAGE_NAME              = NoteBook
NoteBook_PRINCIPAL_CLASS  = NSApplication
NoteBook_APPLICATION_ICON = NoteBook.png
NoteBook_VERSION          = 0.3

#
# Resource Files
#

NoteBook_MAIN_MODEL_FILE = NoteBookApp.gorm

NoteBook_RESOURCE_FILES = \
	NoteBook.png \
	NoteBookInfo.plist

NoteBook_LOCALIZED_RESOURCE_FILES = \
	NoteBookApp.gorm \
	Page.gorm \
	PageName.gorm

NoteBook_LANGUAGES = \
	English

#
# Source
#

NoteBook_HEADER_FILES = \
	BrowserDelegate.h \
	Controller.h \
	Page.h \
	PageNameController.h

NoteBook_OBJC_FILES = \
	BrowserDelegate.m \
	Controller.m \
	Page.m \
	PageNameController.m \
	main.m

#ADDITIONAL_CFLAGS = -Wall
#ADDITIONAL_OBJCFLAGS = -Wall

include $(GNUSTEP_MAKEFILES)/application.make
-include GNUmakefile.postamble
